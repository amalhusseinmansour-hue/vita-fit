const crypto = require('crypto');

// Email verification tokens storage (in production, store in database or Redis)
const verificationTokens = new Map();
const passwordResetTokens = new Map();

// Token expiry times
const VERIFICATION_TOKEN_EXPIRY = 24 * 60 * 60 * 1000; // 24 hours
const PASSWORD_RESET_TOKEN_EXPIRY = 60 * 60 * 1000; // 1 hour

// Generate a secure token
const generateSecureToken = () => {
  return crypto.randomBytes(32).toString('hex');
};

// Generate verification code (6 digits)
const generateVerificationCode = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// Hash token for storage
const hashToken = (token) => {
  return crypto.createHash('sha256').update(token).digest('hex');
};

// ============== Email Verification ==============
const createVerificationToken = (userId, email) => {
  const token = generateSecureToken();
  const code = generateVerificationCode();
  const hashedToken = hashToken(token);

  verificationTokens.set(hashedToken, {
    userId,
    email,
    code,
    expiresAt: Date.now() + VERIFICATION_TOKEN_EXPIRY,
    createdAt: Date.now()
  });

  return { token, code };
};

const verifyEmailToken = (token) => {
  const hashedToken = hashToken(token);
  const record = verificationTokens.get(hashedToken);

  if (!record) {
    return { valid: false, error: 'Invalid verification token' };
  }

  if (Date.now() > record.expiresAt) {
    verificationTokens.delete(hashedToken);
    return { valid: false, error: 'Verification token has expired' };
  }

  return { valid: true, userId: record.userId, email: record.email };
};

const verifyEmailCode = (email, code) => {
  for (const [hashedToken, record] of verificationTokens.entries()) {
    if (record.email === email && record.code === code) {
      if (Date.now() > record.expiresAt) {
        verificationTokens.delete(hashedToken);
        return { valid: false, error: 'Verification code has expired' };
      }
      verificationTokens.delete(hashedToken);
      return { valid: true, userId: record.userId };
    }
  }
  return { valid: false, error: 'Invalid verification code' };
};

const deleteVerificationToken = (token) => {
  const hashedToken = hashToken(token);
  verificationTokens.delete(hashedToken);
};

// ============== Password Reset ==============
const createPasswordResetToken = (userId, email) => {
  // Invalidate any existing tokens for this email
  for (const [hashedToken, record] of passwordResetTokens.entries()) {
    if (record.email === email) {
      passwordResetTokens.delete(hashedToken);
    }
  }

  const token = generateSecureToken();
  const code = generateVerificationCode();
  const hashedToken = hashToken(token);

  passwordResetTokens.set(hashedToken, {
    userId,
    email,
    code,
    expiresAt: Date.now() + PASSWORD_RESET_TOKEN_EXPIRY,
    createdAt: Date.now()
  });

  return { token, code };
};

const verifyPasswordResetToken = (token) => {
  const hashedToken = hashToken(token);
  const record = passwordResetTokens.get(hashedToken);

  if (!record) {
    return { valid: false, error: 'Invalid reset token' };
  }

  if (Date.now() > record.expiresAt) {
    passwordResetTokens.delete(hashedToken);
    return { valid: false, error: 'Reset token has expired' };
  }

  return { valid: true, userId: record.userId, email: record.email };
};

const verifyPasswordResetCode = (email, code) => {
  for (const [hashedToken, record] of passwordResetTokens.entries()) {
    if (record.email === email && record.code === code) {
      if (Date.now() > record.expiresAt) {
        passwordResetTokens.delete(hashedToken);
        return { valid: false, error: 'Reset code has expired' };
      }
      return { valid: true, userId: record.userId, hashedToken };
    }
  }
  return { valid: false, error: 'Invalid reset code' };
};

const deletePasswordResetToken = (token) => {
  const hashedToken = hashToken(token);
  passwordResetTokens.delete(hashedToken);
};

const deletePasswordResetTokenByHash = (hashedToken) => {
  passwordResetTokens.delete(hashedToken);
};

// ============== Email Sending (using nodemailer-like structure) ==============
// You can replace this with actual email sending using nodemailer, sendgrid, etc.
const sendEmail = async (options) => {
  const { to, subject, text, html } = options;

  // For production, implement actual email sending here
  // Using nodemailer, SendGrid, AWS SES, etc.

  console.log('==== EMAIL SENDING ====');
  console.log(`To: ${to}`);
  console.log(`Subject: ${subject}`);
  console.log(`Text: ${text}`);
  console.log('========================');

  // Example with nodemailer (uncomment and configure in production):
  /*
  const nodemailer = require('nodemailer');

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT,
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    }
  });

  await transporter.sendMail({
    from: process.env.EMAIL_FROM || 'VitaFit <noreply@vitafit.online>',
    to,
    subject,
    text,
    html
  });
  */

  return true;
};

// ============== Email Templates ==============
const sendVerificationEmail = async (email, name, code, token) => {
  const verificationUrl = `https://vitafit.online/verify-email?token=${token}`;

  const subject = 'Verify Your Email - VitaFit | تأكيد بريدك الإلكتروني';
  const text = `
Hello ${name},

Your verification code is: ${code}

Or click this link to verify your email:
${verificationUrl}

This code will expire in 24 hours.

If you didn't create an account with VitaFit, please ignore this email.

---

مرحباً ${name}،

رمز التحقق الخاص بك هو: ${code}

أو انقر على هذا الرابط للتحقق من بريدك الإلكتروني:
${verificationUrl}

سينتهي صلاحية هذا الرمز خلال 24 ساعة.

إذا لم تقم بإنشاء حساب في VitaFit، يرجى تجاهل هذا البريد الإلكتروني.
  `;

  const html = `
<!DOCTYPE html>
<html dir="rtl">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #ec4899, #a855f7); padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
    .header h1 { color: white; margin: 0; }
    .content { background: #f9fafb; padding: 30px; border-radius: 0 0 10px 10px; }
    .code { font-size: 32px; font-weight: bold; color: #ec4899; text-align: center; padding: 20px; background: white; border-radius: 10px; margin: 20px 0; letter-spacing: 5px; }
    .button { display: inline-block; background: linear-gradient(135deg, #ec4899, #a855f7); color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; margin: 20px 0; }
    .footer { text-align: center; color: #6b7280; font-size: 12px; margin-top: 20px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>VitaFit</h1>
    </div>
    <div class="content">
      <h2>مرحباً ${name} 👋</h2>
      <p>شكراً لتسجيلك في VitaFit! للتحقق من بريدك الإلكتروني، استخدم الرمز التالي:</p>
      <div class="code">${code}</div>
      <p>أو انقر على الزر أدناه:</p>
      <center>
        <a href="${verificationUrl}" class="button">تأكيد البريد الإلكتروني</a>
      </center>
      <p style="color: #6b7280; font-size: 14px;">سينتهي صلاحية هذا الرمز خلال 24 ساعة.</p>
      <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 20px 0;">
      <h2>Hello ${name} 👋</h2>
      <p>Thank you for registering with VitaFit! To verify your email, use this code:</p>
      <div class="code">${code}</div>
      <p>Or click the button above to verify your email.</p>
    </div>
    <div class="footer">
      <p>If you didn't create an account, please ignore this email.</p>
      <p>&copy; 2024 VitaFit. All rights reserved.</p>
    </div>
  </div>
</body>
</html>
  `;

  return sendEmail({ to: email, subject, text, html });
};

const sendPasswordResetEmail = async (email, name, code, token) => {
  const resetUrl = `https://vitafit.online/reset-password?token=${token}`;

  const subject = 'Reset Your Password - VitaFit | إعادة تعيين كلمة المرور';
  const text = `
Hello ${name},

You requested to reset your password. Your reset code is: ${code}

Or click this link to reset your password:
${resetUrl}

This code will expire in 1 hour.

If you didn't request a password reset, please ignore this email and your password will remain unchanged.

---

مرحباً ${name}،

لقد طلبت إعادة تعيين كلمة المرور الخاصة بك. رمز إعادة التعيين هو: ${code}

أو انقر على هذا الرابط لإعادة تعيين كلمة المرور:
${resetUrl}

سينتهي صلاحية هذا الرمز خلال ساعة واحدة.

إذا لم تطلب إعادة تعيين كلمة المرور، يرجى تجاهل هذا البريد الإلكتروني.
  `;

  const html = `
<!DOCTYPE html>
<html dir="rtl">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #ec4899, #a855f7); padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
    .header h1 { color: white; margin: 0; }
    .content { background: #f9fafb; padding: 30px; border-radius: 0 0 10px 10px; }
    .code { font-size: 32px; font-weight: bold; color: #ec4899; text-align: center; padding: 20px; background: white; border-radius: 10px; margin: 20px 0; letter-spacing: 5px; }
    .button { display: inline-block; background: linear-gradient(135deg, #ec4899, #a855f7); color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; margin: 20px 0; }
    .warning { background: #fef3c7; border: 1px solid #f59e0b; padding: 15px; border-radius: 10px; color: #92400e; }
    .footer { text-align: center; color: #6b7280; font-size: 12px; margin-top: 20px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>VitaFit</h1>
    </div>
    <div class="content">
      <h2>إعادة تعيين كلمة المرور 🔐</h2>
      <p>مرحباً ${name}،</p>
      <p>لقد تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بك. استخدم الرمز التالي:</p>
      <div class="code">${code}</div>
      <center>
        <a href="${resetUrl}" class="button">إعادة تعيين كلمة المرور</a>
      </center>
      <div class="warning">
        ⚠️ سينتهي صلاحية هذا الرمز خلال ساعة واحدة.
      </div>
      <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 20px 0;">
      <h2>Password Reset 🔐</h2>
      <p>Hello ${name},</p>
      <p>We received a request to reset your password. Use this code:</p>
      <div class="code">${code}</div>
      <p>Or click the button above to reset your password.</p>
      <p style="color: #6b7280;">This code will expire in 1 hour.</p>
    </div>
    <div class="footer">
      <p>If you didn't request this, please ignore this email.</p>
      <p>&copy; 2024 VitaFit. All rights reserved.</p>
    </div>
  </div>
</body>
</html>
  `;

  return sendEmail({ to: email, subject, text, html });
};

const sendWelcomeEmail = async (email, name) => {
  const subject = 'Welcome to VitaFit! | مرحباً بك في VitaFit!';
  const text = `
Welcome to VitaFit, ${name}!

Your email has been verified successfully. You can now enjoy all the features of VitaFit.

Start your fitness journey today!

---

مرحباً بك في VitaFit، ${name}!

تم التحقق من بريدك الإلكتروني بنجاح. يمكنك الآن الاستمتاع بجميع ميزات VitaFit.

ابدأ رحلتك الصحية اليوم!
  `;

  const html = `
<!DOCTYPE html>
<html dir="rtl">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #ec4899, #a855f7); padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
    .header h1 { color: white; margin: 0; }
    .content { background: #f9fafb; padding: 30px; border-radius: 0 0 10px 10px; }
    .success { background: #d1fae5; border: 1px solid #10b981; padding: 15px; border-radius: 10px; color: #065f46; text-align: center; }
    .footer { text-align: center; color: #6b7280; font-size: 12px; margin-top: 20px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>VitaFit</h1>
    </div>
    <div class="content">
      <div class="success">
        ✅ تم التحقق من بريدك الإلكتروني بنجاح!
      </div>
      <h2>مرحباً بك ${name}! 🎉</h2>
      <p>أنت الآن جزء من مجتمع VitaFit. ابدأ رحلتك نحو حياة أكثر صحة ولياقة!</p>
      <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 20px 0;">
      <h2>Welcome ${name}! 🎉</h2>
      <p>You're now part of the VitaFit community. Start your journey to a healthier, fitter you!</p>
    </div>
    <div class="footer">
      <p>&copy; 2024 VitaFit. All rights reserved.</p>
    </div>
  </div>
</body>
</html>
  `;

  return sendEmail({ to: email, subject, text, html });
};

const sendLoginAlertEmail = async (email, name, loginInfo) => {
  const subject = 'New Login Alert - VitaFit | تنبيه تسجيل دخول جديد';
  const text = `
Hello ${name},

A new login was detected on your VitaFit account.

Device: ${loginInfo.userAgent}
IP Address: ${loginInfo.ip}
Time: ${loginInfo.time}
Location: ${loginInfo.location || 'Unknown'}

If this was you, you can ignore this email.
If you didn't login, please change your password immediately.

---

مرحباً ${name}،

تم اكتشاف تسجيل دخول جديد على حسابك في VitaFit.

الجهاز: ${loginInfo.userAgent}
عنوان IP: ${loginInfo.ip}
الوقت: ${loginInfo.time}

إذا كان هذا أنت، يمكنك تجاهل هذا البريد الإلكتروني.
إذا لم تقم بتسجيل الدخول، يرجى تغيير كلمة المرور فوراً.
  `;

  return sendEmail({ to: email, subject, text, html: text.replace(/\n/g, '<br>') });
};

module.exports = {
  // Token generation
  generateSecureToken,
  generateVerificationCode,
  hashToken,

  // Email verification
  createVerificationToken,
  verifyEmailToken,
  verifyEmailCode,
  deleteVerificationToken,

  // Password reset
  createPasswordResetToken,
  verifyPasswordResetToken,
  verifyPasswordResetCode,
  deletePasswordResetToken,
  deletePasswordResetTokenByHash,

  // Email sending
  sendEmail,
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendWelcomeEmail,
  sendLoginAlertEmail
};
