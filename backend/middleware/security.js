const crypto = require('crypto');

// ============== CSRF Protection ==============
// Generate CSRF token
const generateCsrfToken = () => {
  return crypto.randomBytes(32).toString('hex');
};

// CSRF token storage (in production, use Redis)
const csrfTokens = new Map();

// CSRF middleware
const csrfProtection = (req, res, next) => {
  // Skip CSRF for GET, HEAD, OPTIONS requests
  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
    return next();
  }

  // Skip CSRF for API requests with valid JWT (mobile apps)
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    return next();
  }

  const token = req.headers['x-csrf-token'] || req.body._csrf;
  const sessionId = req.headers['x-session-id'] || req.cookies?.sessionId;

  if (!token || !sessionId) {
    return res.status(403).json({
      success: false,
      message: 'CSRF token missing'
    });
  }

  const storedToken = csrfTokens.get(sessionId);
  if (!storedToken || storedToken !== token) {
    return res.status(403).json({
      success: false,
      message: 'Invalid CSRF token'
    });
  }

  next();
};

// Generate and return CSRF token endpoint
const getCsrfToken = (req, res) => {
  const sessionId = crypto.randomBytes(16).toString('hex');
  const token = generateCsrfToken();

  // Store token with expiry (1 hour)
  csrfTokens.set(sessionId, token);
  setTimeout(() => csrfTokens.delete(sessionId), 3600000);

  res.json({
    success: true,
    data: {
      csrfToken: token,
      sessionId: sessionId
    }
  });
};

// ============== Rate Limiting ==============
const rateLimitStore = new Map();

const createRateLimiter = (options = {}) => {
  const {
    windowMs = 60000, // 1 minute
    maxRequests = 100,
    message = 'Too many requests, please try again later',
    keyGenerator = (req) => req.ip || req.connection.remoteAddress
  } = options;

  return (req, res, next) => {
    const key = keyGenerator(req);
    const now = Date.now();

    if (!rateLimitStore.has(key)) {
      rateLimitStore.set(key, { count: 1, startTime: now });
      return next();
    }

    const record = rateLimitStore.get(key);

    // Reset if window has passed
    if (now - record.startTime > windowMs) {
      rateLimitStore.set(key, { count: 1, startTime: now });
      return next();
    }

    // Increment count
    record.count++;

    if (record.count > maxRequests) {
      const retryAfter = Math.ceil((record.startTime + windowMs - now) / 1000);
      res.set('Retry-After', retryAfter);
      return res.status(429).json({
        success: false,
        message,
        retryAfter
      });
    }

    next();
  };
};

// Specific rate limiters
const authRateLimiter = createRateLimiter({
  windowMs: 900000, // 15 minutes
  maxRequests: 5,
  message: 'Too many login attempts, please try again in 15 minutes',
  keyGenerator: (req) => `auth:${req.ip}:${req.body.email || ''}`
});

const registerRateLimiter = createRateLimiter({
  windowMs: 3600000, // 1 hour
  maxRequests: 3,
  message: 'Too many registration attempts, please try again later',
  keyGenerator: (req) => `register:${req.ip}`
});

const apiRateLimiter = createRateLimiter({
  windowMs: 60000, // 1 minute
  maxRequests: 100,
  message: 'Too many requests, please slow down'
});

const passwordResetRateLimiter = createRateLimiter({
  windowMs: 3600000, // 1 hour
  maxRequests: 3,
  message: 'Too many password reset attempts',
  keyGenerator: (req) => `reset:${req.ip}:${req.body.email || ''}`
});

// ============== Input Sanitization ==============
const sanitizeInput = (req, res, next) => {
  const sanitize = (obj) => {
    if (typeof obj === 'string') {
      // Remove HTML tags
      obj = obj.replace(/<[^>]*>/g, '');
      // Escape special characters
      obj = obj.replace(/[<>'"&]/g, (char) => {
        const entities = {
          '<': '&lt;',
          '>': '&gt;',
          "'": '&#39;',
          '"': '&quot;',
          '&': '&amp;'
        };
        return entities[char];
      });
      // Trim whitespace
      obj = obj.trim();
      return obj;
    }
    if (Array.isArray(obj)) {
      return obj.map(sanitize);
    }
    if (obj && typeof obj === 'object') {
      const sanitized = {};
      for (const key in obj) {
        sanitized[key] = sanitize(obj[key]);
      }
      return sanitized;
    }
    return obj;
  };

  if (req.body) {
    req.body = sanitize(req.body);
  }
  if (req.query) {
    req.query = sanitize(req.query);
  }
  if (req.params) {
    req.params = sanitize(req.params);
  }

  next();
};

// ============== SQL Injection Prevention ==============
const sqlInjectionCheck = (req, res, next) => {
  const sqlPatterns = [
    /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|TRUNCATE|EXEC|UNION|FETCH|DECLARE|CAST)\b)/i,
    /(--)|(;)|(\/\*)|(\*\/)/,
    /(\\x27)|(\\x22)/,
    /(\bOR\b.*=.*\bOR\b)/i,
    /(\bAND\b.*=.*\bAND\b)/i,
  ];

  const checkValue = (value) => {
    if (typeof value === 'string') {
      for (const pattern of sqlPatterns) {
        if (pattern.test(value)) {
          return true;
        }
      }
    }
    return false;
  };

  const checkObject = (obj) => {
    if (!obj) return false;
    for (const key in obj) {
      if (checkValue(obj[key])) return true;
      if (typeof obj[key] === 'object' && checkObject(obj[key])) return true;
    }
    return false;
  };

  if (checkObject(req.body) || checkObject(req.query) || checkObject(req.params)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid input detected'
    });
  }

  next();
};

// ============== XSS Prevention Headers ==============
const xssProtection = (req, res, next) => {
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  res.setHeader('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
  next();
};

// ============== Security Headers (helmet alternative) ==============
const securityHeaders = (req, res, next) => {
  // Content Security Policy
  res.setHeader('Content-Security-Policy',
    "default-src 'self'; " +
    "script-src 'self' 'unsafe-inline'; " +
    "style-src 'self' 'unsafe-inline'; " +
    "img-src 'self' data: https:; " +
    "font-src 'self' https:; " +
    "connect-src 'self' https:; " +
    "frame-ancestors 'none';"
  );

  // Strict Transport Security
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');

  // Additional security headers
  res.setHeader('X-DNS-Prefetch-Control', 'off');
  res.setHeader('X-Download-Options', 'noopen');
  res.setHeader('X-Permitted-Cross-Domain-Policies', 'none');

  next();
};

// ============== Request Size Limiter ==============
const requestSizeLimiter = (maxSize = '10kb') => {
  const parseSize = (size) => {
    const units = { b: 1, kb: 1024, mb: 1024 * 1024, gb: 1024 * 1024 * 1024 };
    const match = size.toString().toLowerCase().match(/^(\d+)(b|kb|mb|gb)?$/);
    if (!match) return 10240; // default 10kb
    const num = parseInt(match[1]);
    const unit = match[2] || 'b';
    return num * units[unit];
  };

  const maxBytes = parseSize(maxSize);

  return (req, res, next) => {
    let size = 0;
    req.on('data', (chunk) => {
      size += chunk.length;
      if (size > maxBytes) {
        res.status(413).json({
          success: false,
          message: 'Request entity too large'
        });
        req.destroy();
      }
    });
    next();
  };
};

// ============== Account Lockout ==============
const loginAttempts = new Map();

const accountLockout = {
  maxAttempts: 5,
  lockoutDuration: 900000, // 15 minutes

  recordFailedAttempt: (email, ip) => {
    const key = `${email}:${ip}`;
    const record = loginAttempts.get(key) || { attempts: 0, lockedUntil: null };

    record.attempts++;
    if (record.attempts >= accountLockout.maxAttempts) {
      record.lockedUntil = Date.now() + accountLockout.lockoutDuration;
    }

    loginAttempts.set(key, record);
    return record;
  },

  resetAttempts: (email, ip) => {
    const key = `${email}:${ip}`;
    loginAttempts.delete(key);
  },

  isLocked: (email, ip) => {
    const key = `${email}:${ip}`;
    const record = loginAttempts.get(key);

    if (!record) return false;

    if (record.lockedUntil && Date.now() < record.lockedUntil) {
      return {
        locked: true,
        remainingTime: Math.ceil((record.lockedUntil - Date.now()) / 1000)
      };
    }

    // Reset if lockout has expired
    if (record.lockedUntil && Date.now() >= record.lockedUntil) {
      loginAttempts.delete(key);
      return false;
    }

    return false;
  },

  getRemainingAttempts: (email, ip) => {
    const key = `${email}:${ip}`;
    const record = loginAttempts.get(key);
    if (!record) return accountLockout.maxAttempts;
    return Math.max(0, accountLockout.maxAttempts - record.attempts);
  }
};

// ============== Password Strength Validation ==============
const validatePasswordStrength = (password) => {
  const errors = [];

  if (password.length < 8) {
    errors.push('Password must be at least 8 characters long');
  }
  if (!/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter');
  }
  if (!/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter');
  }
  if (!/[0-9]/.test(password)) {
    errors.push('Password must contain at least one number');
  }
  if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
    errors.push('Password must contain at least one special character');
  }

  // Check for common weak passwords
  const weakPasswords = ['password', '12345678', 'qwerty', 'abc123', 'password123'];
  if (weakPasswords.includes(password.toLowerCase())) {
    errors.push('Password is too common, please choose a stronger password');
  }

  return {
    isValid: errors.length === 0,
    errors
  };
};

// ============== IP Whitelist/Blacklist ==============
const ipBlacklist = new Set();
const ipWhitelist = new Set();

const ipFilter = (req, res, next) => {
  const clientIp = req.ip || req.connection.remoteAddress;

  // Check blacklist
  if (ipBlacklist.has(clientIp)) {
    return res.status(403).json({
      success: false,
      message: 'Access denied'
    });
  }

  // If whitelist is not empty, check if IP is whitelisted
  if (ipWhitelist.size > 0 && !ipWhitelist.has(clientIp)) {
    return res.status(403).json({
      success: false,
      message: 'Access denied'
    });
  }

  next();
};

// ============== Session Fingerprinting ==============
const generateFingerprint = (req) => {
  const components = [
    req.headers['user-agent'] || '',
    req.headers['accept-language'] || '',
    req.headers['accept-encoding'] || '',
    req.ip || ''
  ];

  return crypto.createHash('sha256').update(components.join('|')).digest('hex');
};

const validateFingerprint = (req, storedFingerprint) => {
  const currentFingerprint = generateFingerprint(req);
  return currentFingerprint === storedFingerprint;
};

// ============== Secure Cookie Options ==============
const secureCookieOptions = {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  maxAge: 24 * 60 * 60 * 1000 // 24 hours
};

// ============== Activity Logging ==============
const logSecurityEvent = async (eventType, details, req) => {
  const { ActivityLog } = require('../models');

  try {
    await ActivityLog.create({
      user_id: req.user?.id || null,
      action: eventType,
      ip_address: req.ip || req.connection.remoteAddress,
      user_agent: req.headers['user-agent'],
      new_values: details
    });
  } catch (error) {
    console.error('Failed to log security event:', error);
  }
};

module.exports = {
  // CSRF
  csrfProtection,
  getCsrfToken,
  generateCsrfToken,

  // Rate Limiting
  createRateLimiter,
  authRateLimiter,
  registerRateLimiter,
  apiRateLimiter,
  passwordResetRateLimiter,

  // Input Security
  sanitizeInput,
  sqlInjectionCheck,

  // Headers
  xssProtection,
  securityHeaders,

  // Request Limiting
  requestSizeLimiter,

  // Account Security
  accountLockout,
  validatePasswordStrength,

  // IP Security
  ipFilter,
  ipBlacklist,
  ipWhitelist,

  // Session Security
  generateFingerprint,
  validateFingerprint,
  secureCookieOptions,

  // Logging
  logSecurityEvent
};
