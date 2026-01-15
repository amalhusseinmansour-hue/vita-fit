const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { User, Subscription, SubscriptionPlan, Trainer } = require('../models');
const { sendNotificationToAdmins, NotificationTypes } = require('../utils/notificationHelper');
const {
  accountLockout,
  validatePasswordStrength,
  logSecurityEvent
} = require('../middleware/security');
const {
  createVerificationToken,
  verifyEmailCode,
  createPasswordResetToken,
  verifyPasswordResetCode,
  deletePasswordResetTokenByHash,
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendWelcomeEmail,
  sendLoginAlertEmail
} = require('../utils/emailService');

// Generate JWT Token
const generateToken = (id, expiresIn = process.env.JWT_EXPIRE || '30d') => {
  return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn });
};

// Generate Refresh Token
const generateRefreshToken = (id) => {
  return jwt.sign({ id, type: 'refresh' }, process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET, {
    expiresIn: '90d'
  });
};

// @desc    Register user
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res) => {
  try {
    const { name, email, password, phone, gender, birth_date, height, weight } = req.body;

    // Validate required fields
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide name, email and password'
      });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a valid email address'
      });
    }

    // Validate password strength
    const passwordValidation = validatePasswordStrength(password);
    if (!passwordValidation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Password does not meet security requirements',
        errors: passwordValidation.errors
      });
    }

    // Check if user already exists
    const userExists = await User.findOne({ where: { email: email.toLowerCase() } });

    if (userExists) {
      return res.status(400).json({
        success: false,
        message: 'User already exists with this email'
      });
    }

    // Hash password with higher cost factor
    const salt = await bcrypt.genSalt(12);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user (unverified)
    const user = await User.create({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password: hashedPassword,
      phone: phone?.trim(),
      gender,
      birth_date,
      height,
      weight,
      is_verified: false
    });

    // Create verification token
    const { token, code } = createVerificationToken(user.id, user.email);

    // Send verification email
    await sendVerificationEmail(user.email, user.name, code, token);

    // Log security event
    await logSecurityEvent('USER_REGISTERED', {
      userId: user.id,
      email: user.email
    }, req);

    // Send notification to admins about new registration
    await sendNotificationToAdmins({
      title: 'New User Registration',
      title_ar: 'تسجيل مستخدم جديد',
      body: `${name} has registered`,
      body_ar: `${name} قام بالتسجيل`,
      type: NotificationTypes.NEW_REGISTRATION,
      data: { userId: user.id.toString(), userName: name }
    });

    res.status(201).json({
      success: true,
      message: 'Registration successful. Please check your email to verify your account.',
      message_ar: 'تم التسجيل بنجاح. يرجى التحقق من بريدك الإلكتروني لتأكيد حسابك.',
      data: {
        user: {
          id: user.id,
          uuid: user.uuid,
          name: user.name,
          email: user.email,
          is_verified: false
        },
        requiresVerification: true
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Registration failed. Please try again.'
    });
  }
};

// @desc    Verify email with code
// @route   POST /api/auth/verify-email
// @access  Public
exports.verifyEmail = async (req, res) => {
  try {
    const { email, code } = req.body;

    if (!email || !code) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and verification code'
      });
    }

    // Verify the code
    const result = verifyEmailCode(email.toLowerCase(), code);

    if (!result.valid) {
      return res.status(400).json({
        success: false,
        message: result.error
      });
    }

    // Update user as verified
    const user = await User.findByPk(result.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    await user.update({ is_verified: true });

    // Send welcome email
    await sendWelcomeEmail(user.email, user.name);

    // Generate token for auto-login
    const token = generateToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // Log security event
    await logSecurityEvent('EMAIL_VERIFIED', {
      userId: user.id,
      email: user.email
    }, req);

    res.status(200).json({
      success: true,
      message: 'Email verified successfully',
      message_ar: 'تم التحقق من البريد الإلكتروني بنجاح',
      data: {
        user: {
          id: user.id,
          uuid: user.uuid,
          name: user.name,
          email: user.email,
          role: user.role,
          is_verified: true
        },
        token,
        refreshToken
      }
    });
  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).json({
      success: false,
      message: 'Verification failed. Please try again.'
    });
  }
};

// @desc    Resend verification code
// @route   POST /api/auth/resend-verification
// @access  Public
exports.resendVerification = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email address'
      });
    }

    const user = await User.findOne({ where: { email: email.toLowerCase() } });

    if (!user) {
      // Don't reveal if user exists
      return res.status(200).json({
        success: true,
        message: 'If your email is registered, you will receive a verification code.'
      });
    }

    if (user.is_verified) {
      return res.status(400).json({
        success: false,
        message: 'Email is already verified'
      });
    }

    // Create new verification token
    const { token, code } = createVerificationToken(user.id, user.email);

    // Send verification email
    await sendVerificationEmail(user.email, user.name, code, token);

    res.status(200).json({
      success: true,
      message: 'Verification code sent to your email',
      message_ar: 'تم إرسال رمز التحقق إلى بريدك الإلكتروني'
    });
  } catch (error) {
    console.error('Resend verification error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to resend verification code'
    });
  }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const clientIp = req.ip || req.connection.remoteAddress;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    // Check for account lockout
    const lockStatus = accountLockout.isLocked(email, clientIp);
    if (lockStatus && lockStatus.locked) {
      return res.status(429).json({
        success: false,
        message: `Account temporarily locked. Please try again in ${Math.ceil(lockStatus.remainingTime / 60)} minutes.`,
        message_ar: `الحساب مقفل مؤقتاً. يرجى المحاولة مرة أخرى بعد ${Math.ceil(lockStatus.remainingTime / 60)} دقيقة.`,
        retryAfter: lockStatus.remainingTime
      });
    }

    // Check for user
    const user = await User.findOne({ where: { email: email.toLowerCase() } });

    if (!user) {
      accountLockout.recordFailedAttempt(email, clientIp);
      const remaining = accountLockout.getRemainingAttempts(email, clientIp);

      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
        remainingAttempts: remaining
      });
    }

    // Check if password matches
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      accountLockout.recordFailedAttempt(email, clientIp);
      const remaining = accountLockout.getRemainingAttempts(email, clientIp);

      await logSecurityEvent('FAILED_LOGIN', {
        userId: user.id,
        email: user.email,
        reason: 'Invalid password'
      }, req);

      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
        remainingAttempts: remaining
      });
    }

    // Check if user is active
    if (!user.is_active) {
      return res.status(401).json({
        success: false,
        message: 'Account is inactive. Please contact support.',
        message_ar: 'الحساب غير نشط. يرجى التواصل مع الدعم.'
      });
    }

    // Check if email is verified (optional - can be enforced)
    if (!user.is_verified) {
      // Create new verification token
      const { token, code } = createVerificationToken(user.id, user.email);
      await sendVerificationEmail(user.email, user.name, code, token);

      return res.status(403).json({
        success: false,
        message: 'Please verify your email first. A new verification code has been sent.',
        message_ar: 'يرجى التحقق من بريدك الإلكتروني أولاً. تم إرسال رمز تحقق جديد.',
        requiresVerification: true
      });
    }

    // Reset login attempts on successful login
    accountLockout.resetAttempts(email, clientIp);

    // Update last login
    await user.update({ last_login: new Date() });

    // Generate tokens
    const token = generateToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // Log security event
    await logSecurityEvent('USER_LOGIN', {
      userId: user.id,
      email: user.email
    }, req);

    // Send login alert email for security (optional)
    if (process.env.SEND_LOGIN_ALERTS === 'true') {
      await sendLoginAlertEmail(user.email, user.name, {
        userAgent: req.headers['user-agent'],
        ip: clientIp,
        time: new Date().toISOString()
      });
    }

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user.id,
          uuid: user.uuid,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: user.role,
          avatar: user.avatar,
          gender: user.gender,
          goal: user.goal,
          is_verified: user.is_verified
        },
        token,
        refreshToken
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Login failed. Please try again.'
    });
  }
};

// @desc    Refresh access token
// @route   POST /api/auth/refresh-token
// @access  Public
exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token is required'
      });
    }

    // Verify refresh token
    const decoded = jwt.verify(
      refreshToken,
      process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET
    );

    if (decoded.type !== 'refresh') {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token'
      });
    }

    // Check if user exists and is active
    const user = await User.findByPk(decoded.id);
    if (!user || !user.is_active) {
      return res.status(401).json({
        success: false,
        message: 'User not found or inactive'
      });
    }

    // Generate new access token
    const newToken = generateToken(user.id);

    res.status(200).json({
      success: true,
      data: { token: newToken }
    });
  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(401).json({
      success: false,
      message: 'Invalid or expired refresh token'
    });
  }
};

// @desc    Forgot password - request reset
// @route   POST /api/auth/forgot-password
// @access  Public
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email address'
      });
    }

    const user = await User.findOne({ where: { email: email.toLowerCase() } });

    // Always return success to prevent email enumeration
    if (!user) {
      return res.status(200).json({
        success: true,
        message: 'If your email is registered, you will receive a password reset code.'
      });
    }

    // Create password reset token
    const { token, code } = createPasswordResetToken(user.id, user.email);

    // Send password reset email
    await sendPasswordResetEmail(user.email, user.name, code, token);

    // Log security event
    await logSecurityEvent('PASSWORD_RESET_REQUESTED', {
      userId: user.id,
      email: user.email
    }, req);

    res.status(200).json({
      success: true,
      message: 'Password reset code sent to your email',
      message_ar: 'تم إرسال رمز إعادة تعيين كلمة المرور إلى بريدك الإلكتروني'
    });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process request'
    });
  }
};

// @desc    Reset password with code
// @route   POST /api/auth/reset-password
// @access  Public
exports.resetPassword = async (req, res) => {
  try {
    const { email, code, newPassword } = req.body;

    if (!email || !code || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email, code, and new password'
      });
    }

    // Validate new password strength
    const passwordValidation = validatePasswordStrength(newPassword);
    if (!passwordValidation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Password does not meet security requirements',
        errors: passwordValidation.errors
      });
    }

    // Verify the reset code
    const result = verifyPasswordResetCode(email.toLowerCase(), code);

    if (!result.valid) {
      return res.status(400).json({
        success: false,
        message: result.error
      });
    }

    // Get user and update password
    const user = await User.findByPk(result.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Hash new password
    const salt = await bcrypt.genSalt(12);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await user.update({ password: hashedPassword });

    // Delete the reset token
    deletePasswordResetTokenByHash(result.hashedToken);

    // Log security event
    await logSecurityEvent('PASSWORD_RESET_COMPLETED', {
      userId: user.id,
      email: user.email
    }, req);

    res.status(200).json({
      success: true,
      message: 'Password reset successfully. You can now login with your new password.',
      message_ar: 'تم إعادة تعيين كلمة المرور بنجاح. يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.'
    });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to reset password'
    });
  }
};

// @desc    Get current logged in user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: { exclude: ['password'] },
      include: [
        {
          model: Subscription,
          include: [SubscriptionPlan],
          required: false
        }
      ]
    });

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Get me error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user data'
    });
  }
};

// @desc    Update user profile
// @route   PUT /api/auth/profile
// @access  Private
exports.updateProfile = async (req, res) => {
  try {
    const allowedFields = [
      'name', 'phone', 'gender', 'birth_date', 'height', 'weight',
      'goal', 'activity_level', 'avatar', 'address', 'city'
    ];

    const updates = {};
    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    await User.update(updates, { where: { id: req.user.id } });

    const user = await User.findByPk(req.user.id, {
      attributes: { exclude: ['password'] }
    });

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: user
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update profile'
    });
  }
};

// @desc    Update password
// @route   PUT /api/auth/updatepassword
// @access  Private
exports.updatePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Please provide current and new password'
      });
    }

    // Validate new password strength
    const passwordValidation = validatePasswordStrength(newPassword);
    if (!passwordValidation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'New password does not meet security requirements',
        errors: passwordValidation.errors
      });
    }

    const user = await User.findByPk(req.user.id);

    // Check current password
    const isMatch = await bcrypt.compare(currentPassword, user.password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    // Ensure new password is different from current
    const isSamePassword = await bcrypt.compare(newPassword, user.password);
    if (isSamePassword) {
      return res.status(400).json({
        success: false,
        message: 'New password must be different from current password'
      });
    }

    // Hash new password
    const salt = await bcrypt.genSalt(12);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await user.update({ password: hashedPassword });

    // Generate new token
    const token = generateToken(user.id);

    // Log security event
    await logSecurityEvent('PASSWORD_CHANGED', {
      userId: user.id,
      email: user.email
    }, req);

    res.status(200).json({
      success: true,
      message: 'Password updated successfully',
      data: { token }
    });
  } catch (error) {
    console.error('Update password error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update password'
    });
  }
};

// @desc    Update FCM token
// @route   PUT /api/auth/fcm-token
// @access  Private
exports.updateFcmToken = async (req, res) => {
  try {
    const { fcm_token } = req.body;

    await User.update({ fcm_token }, { where: { id: req.user.id } });

    res.status(200).json({
      success: true,
      message: 'FCM token updated'
    });
  } catch (error) {
    console.error('Update FCM token error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update FCM token'
    });
  }
};

// @desc    Logout user
// @route   POST /api/auth/logout
// @access  Private
exports.logout = async (req, res) => {
  try {
    // Clear FCM token on logout
    await User.update({ fcm_token: null }, { where: { id: req.user.id } });

    // Log security event
    await logSecurityEvent('USER_LOGOUT', {
      userId: req.user.id,
      email: req.user.email
    }, req);

    res.status(200).json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Logout failed'
    });
  }
};

// @desc    Change email (requires password confirmation)
// @route   PUT /api/auth/change-email
// @access  Private
exports.changeEmail = async (req, res) => {
  try {
    const { newEmail, password } = req.body;

    if (!newEmail || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide new email and password'
      });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(newEmail)) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a valid email address'
      });
    }

    const user = await User.findByPk(req.user.id);

    // Verify password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Incorrect password'
      });
    }

    // Check if new email is already in use
    const existingUser = await User.findOne({ where: { email: newEmail.toLowerCase() } });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email is already in use'
      });
    }

    // Update email and mark as unverified
    await user.update({
      email: newEmail.toLowerCase(),
      is_verified: false
    });

    // Send verification email to new address
    const { token, code } = createVerificationToken(user.id, newEmail.toLowerCase());
    await sendVerificationEmail(newEmail, user.name, code, token);

    // Log security event
    await logSecurityEvent('EMAIL_CHANGED', {
      userId: user.id,
      oldEmail: req.user.email,
      newEmail: newEmail.toLowerCase()
    }, req);

    res.status(200).json({
      success: true,
      message: 'Email updated. Please verify your new email address.',
      message_ar: 'تم تحديث البريد الإلكتروني. يرجى التحقق من بريدك الإلكتروني الجديد.'
    });
  } catch (error) {
    console.error('Change email error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to change email'
    });
  }
};

// @desc    Delete account
// @route   DELETE /api/auth/delete-account
// @access  Private
exports.deleteAccount = async (req, res) => {
  try {
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide your password to confirm'
      });
    }

    const user = await User.findByPk(req.user.id);

    // Verify password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Incorrect password'
      });
    }

    // Log before deletion
    await logSecurityEvent('ACCOUNT_DELETED', {
      userId: user.id,
      email: user.email
    }, req);

    // Soft delete - deactivate account instead of hard delete
    await user.update({
      is_active: false,
      email: `deleted_${user.id}_${user.email}`,
      fcm_token: null
    });

    res.status(200).json({
      success: true,
      message: 'Account deleted successfully'
    });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete account'
    });
  }
};

// @desc    Apple Sign In
// @route   POST /api/auth/apple
// @access  Public
exports.appleSignIn = async (req, res) => {
  try {
    const { identity_token, authorization_code, email, full_name, user_identifier } = req.body;

    if (!identity_token || !user_identifier) {
      return res.status(400).json({
        success: false,
        message: 'Missing required Apple authentication data'
      });
    }

    // Verify Apple identity token
    // In production, you should verify the token with Apple's servers
    // For now, we'll decode and use the data
    let decodedToken;
    try {
      // Decode JWT without verification (Apple tokens are already signed)
      const tokenParts = identity_token.split('.');
      if (tokenParts.length === 3) {
        decodedToken = JSON.parse(Buffer.from(tokenParts[1], 'base64').toString());
      }
    } catch (decodeError) {
      console.error('Token decode error:', decodeError);
    }

    // Get email from token or request
    const userEmail = email || decodedToken?.email;

    if (!userEmail) {
      return res.status(400).json({
        success: false,
        message: 'Email is required for Apple Sign In'
      });
    }

    // Check if user exists with this Apple ID or email
    let user = await User.findOne({
      where: {
        [require('sequelize').Op.or]: [
          { apple_id: user_identifier },
          { email: userEmail.toLowerCase() }
        ]
      }
    });

    if (user) {
      // Update Apple ID if not set
      if (!user.apple_id) {
        await user.update({ apple_id: user_identifier });
      }

      // Check if account is active
      if (!user.is_active) {
        return res.status(401).json({
          success: false,
          message: 'Account is deactivated. Please contact support.'
        });
      }
    } else {
      // Create new user with Apple ID
      const userName = full_name || userEmail.split('@')[0];

      user = await User.create({
        name: userName,
        email: userEmail.toLowerCase(),
        apple_id: user_identifier,
        password: await bcrypt.hash(require('crypto').randomBytes(32).toString('hex'), 12),
        is_verified: true, // Apple verifies email
        is_active: true
      });

      // Send welcome email
      try {
        await sendWelcomeEmail(user.email, user.name);
      } catch (emailError) {
        console.error('Welcome email error:', emailError);
      }

      // Notify admins of new registration
      await sendNotificationToAdmins(
        NotificationTypes.NEW_USER_REGISTRATION,
        {
          userName: user.name,
          userEmail: user.email,
          userId: user.id,
          registrationMethod: 'Apple'
        }
      );
    }

    // Generate tokens
    const token = generateToken(user.id);
    const refreshTokenValue = generateRefreshToken(user.id);

    // Update last login
    await user.update({
      last_login: new Date(),
      refresh_token: refreshTokenValue
    });

    // Log security event
    await logSecurityEvent('APPLE_SIGN_IN', {
      userId: user.id,
      email: user.email
    }, req);

    res.status(200).json({
      success: true,
      token,
      refresh_token: refreshTokenValue,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role || 'trainee',
        type: user.role || 'trainee',
        avatar: user.avatar,
        is_verified: user.is_verified
      }
    });
  } catch (error) {
    console.error('Apple Sign In error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to authenticate with Apple'
    });
  }
};
