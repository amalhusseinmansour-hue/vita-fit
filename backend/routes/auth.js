const express = require('express');
const {
  register,
  login,
  getMe,
  updatePassword,
  logout,
  verifyEmail,
  resendVerification,
  forgotPassword,
  resetPassword,
  refreshToken,
  updateProfile,
  updateFcmToken,
  changeEmail,
  deleteAccount,
  appleSignIn
} = require('../controllers/authController');
const { protect } = require('../middleware/auth');
const {
  authRateLimiter,
  registerRateLimiter,
  passwordResetRateLimiter,
  sanitizeInput
} = require('../middleware/security');

const router = express.Router();

// Apply input sanitization to all routes
router.use(sanitizeInput);

// Public routes with rate limiting
router.post('/register', registerRateLimiter, register);
router.post('/login', authRateLimiter, login);
router.post('/apple', authRateLimiter, appleSignIn);
router.post('/verify-email', verifyEmail);
router.post('/resend-verification', resendVerification);
router.post('/forgot-password', passwordResetRateLimiter, forgotPassword);
router.post('/reset-password', passwordResetRateLimiter, resetPassword);
router.post('/refresh-token', refreshToken);

// Protected routes
router.get('/me', protect, getMe);
router.put('/profile', protect, updateProfile);
router.put('/updatepassword', protect, updatePassword);
router.put('/fcm-token', protect, updateFcmToken);
router.put('/change-email', protect, changeEmail);
router.post('/logout', protect, logout);
router.delete('/delete-account', protect, deleteAccount);

module.exports = router;
