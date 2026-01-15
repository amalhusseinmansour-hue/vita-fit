const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config();

// Import database and models
const { sequelize, testConnection } = require('./config/database');
const models = require('./models');

// Import security middleware
const {
  securityHeaders,
  xssProtection,
  apiRateLimiter,
  sanitizeInput,
  sqlInjectionCheck,
  getCsrfToken
} = require('./middleware/security');

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const productRoutes = require('./routes/products');
const categoryRoutes = require('./routes/categories');
const orderRoutes = require('./routes/orders');
const subscriptionRoutes = require('./routes/subscriptions');
const trainerRoutes = require('./routes/trainers');
const workoutRoutes = require('./routes/workouts');
const mealRoutes = require('./routes/meals');
const progressRoutes = require('./routes/progress');
const workshopRoutes = require('./routes/workshops');
const adminRoutes = require('./routes/admin');
const settingsRoutes = require('./routes/settings');
const notificationRoutes = require('./routes/notifications');
const couponRoutes = require('./routes/coupons');
const cartRoutes = require('./routes/cart');
const reviewRoutes = require('./routes/reviews');
const dashboardRoutes = require('./routes/dashboard');
const smartplanRoutes = require('./routes/smartplan');
const traineePlansRoutes = require('./routes/trainee-plans');

// Initialize Express app
const app = express();

// Trust proxy (for rate limiting behind reverse proxy)
app.set('trust proxy', 1);

// ============== SECURITY MIDDLEWARE ==============

// Security headers (Content-Security-Policy, HSTS, etc.)
app.use(securityHeaders);

// XSS Protection headers
app.use(xssProtection);

// CORS configuration
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, curl, etc.)
    if (!origin) return callback(null, true);

    const allowedOrigins = [
      'https://vitafit.online',
      'https://www.vitafit.online',
      'http://localhost:3000',
      'http://localhost:5000',
      'http://127.0.0.1:3000',
      'http://127.0.0.1:5000'
    ];

    if (allowedOrigins.includes(origin) || process.env.NODE_ENV === 'development') {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-CSRF-Token', 'X-Session-ID', 'X-Requested-With'],
  exposedHeaders: ['X-CSRF-Token'],
  maxAge: 86400 // 24 hours
};
app.use(cors(corsOptions));

// Body parser with size limits
app.use(express.json({
  limit: '10mb',
  verify: (req, res, buf) => {
    req.rawBody = buf;
  }
}));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Global rate limiter for all API routes
app.use('/api', apiRateLimiter);

// Input sanitization (applied after body parsing)
app.use(sanitizeInput);

// SQL injection check
app.use(sqlInjectionCheck);

// ============== STATIC FILES ==============

// Static files for uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Static files for admin dashboard (with clean URLs)
app.use('/admin-panel', express.static(path.join(__dirname, 'public/admin')));

// Handle clean URLs for admin panel (without .html)
app.get('/admin-panel/:page', (req, res, next) => {
  const page = req.params.page;
  if (!page.includes('.')) {
    const filePath = path.join(__dirname, 'public/admin', `${page}.html`);
    res.sendFile(filePath, (err) => {
      if (err) next();
    });
  } else {
    next();
  }
});

// Static files for trainer dashboard
app.use('/trainer-panel', express.static(path.join(__dirname, 'public/trainer')));

// Handle clean URLs for trainer panel (without .html)
app.get('/trainer-panel/:page', (req, res, next) => {
  const page = req.params.page;
  if (!page.includes('.')) {
    const filePath = path.join(__dirname, 'public/trainer', `${page}.html`);
    res.sendFile(filePath, (err) => {
      if (err) next();
    });
  } else {
    next();
  }
});

// ============== CSRF TOKEN ENDPOINT ==============
app.get('/api/csrf-token', getCsrfToken);

// ============== API ROUTES ==============
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/products', productRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/trainers', trainerRoutes);
app.use('/api/workouts', workoutRoutes);
app.use('/api/meals', mealRoutes);
app.use('/api/progress', progressRoutes);
app.use('/api/workshops', workshopRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/settings', settingsRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/coupons', couponRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/smartplan', smartplanRoutes);
app.use('/api/trainee-plans', traineePlansRoutes);

// ============== HEALTH CHECK ==============
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// ============== WELCOME ROUTES ==============
app.get('/', (req, res) => {
  res.json({
    message: 'VitaFit API Server',
    version: '2.1.0',
    status: 'Running',
    database: 'MySQL',
    security: 'Enhanced',
    documentation: '/api/docs'
  });
});

app.get('/api', (req, res) => {
  res.json({
    message: 'VitaFit API v2.1 - Security Enhanced',
    endpoints: {
      auth: '/api/auth - Authentication (login, register, verify-email, reset-password)',
      users: '/api/users - User management',
      products: '/api/products - Product catalog',
      categories: '/api/categories - Product categories',
      orders: '/api/orders - Order management',
      subscriptions: '/api/subscriptions - Subscription plans',
      trainers: '/api/trainers - Trainer management',
      workouts: '/api/workouts - Workout programs',
      meals: '/api/meals - Meal plans & nutrition',
      progress: '/api/progress - Progress tracking',
      workshops: '/api/workshops - Workshops & events',
      admin: '/api/admin - Admin operations',
      settings: '/api/settings - App settings',
      notifications: '/api/notifications - Push notifications',
      coupons: '/api/coupons - Discount coupons',
      cart: '/api/cart - Shopping cart',
      reviews: '/api/reviews - Product reviews',
      dashboard: '/api/dashboard - Dashboard statistics',
      smartplan: '/api/smartplan - Smart plan data',
      traineePlans: '/api/trainee-plans - Trainer workout/meal plans'
    },
    security: {
      rateLimit: '100 requests per minute',
      authentication: 'JWT with refresh tokens',
      emailVerification: 'Required for login',
      passwordPolicy: 'Min 8 chars, uppercase, lowercase, number, special char',
      inputSanitization: 'Enabled',
      sqlInjectionProtection: 'Enabled',
      xssProtection: 'Enabled',
      csrfProtection: 'Available at /api/csrf-token'
    }
  });
});

// ============== 404 HANDLER ==============
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// ============== ERROR HANDLER ==============
app.use((err, req, res, next) => {
  // Log error for monitoring
  console.error('Error:', err.message);
  if (process.env.NODE_ENV !== 'production') {
    console.error('Stack:', err.stack);
  }

  // Handle CORS errors
  if (err.message === 'Not allowed by CORS') {
    return res.status(403).json({
      success: false,
      message: 'CORS policy violation'
    });
  }

  // Handle JSON parse errors
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      success: false,
      message: 'Invalid JSON format'
    });
  }

  // Generic error response (hide details in production)
  res.status(err.status || 500).json({
    success: false,
    message: process.env.NODE_ENV === 'production'
      ? 'Internal Server Error'
      : err.message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// ============== START SERVER ==============
const startServer = async () => {
  try {
    // Test database connection
    await testConnection();

    // Sync database (create tables if not exist)
    const syncOptions = {
      alter: process.env.NODE_ENV === 'development' ? true : false
    };

    await sequelize.sync(syncOptions);
    console.log('✅ Database synchronized');

    // Start server
    const PORT = process.env.PORT || 5000;
    const HOST = '0.0.0.0';

    app.listen(PORT, HOST, () => {
      console.log('========================================');
      console.log('🚀 VitaFit API Server Started!');
      console.log('========================================');
      console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`🌐 Server: http://${HOST}:${PORT}`);
      console.log(`📁 API Docs: http://localhost:${PORT}/api`);
      console.log(`🔒 Security: Enhanced`);
      console.log('========================================');
      console.log('Security Features Enabled:');
      console.log('  ✅ Rate Limiting');
      console.log('  ✅ Input Sanitization');
      console.log('  ✅ SQL Injection Protection');
      console.log('  ✅ XSS Protection');
      console.log('  ✅ Security Headers');
      console.log('  ✅ CORS Protection');
      console.log('  ✅ Email Verification');
      console.log('  ✅ Password Strength Validation');
      console.log('  ✅ Account Lockout');
      console.log('========================================');
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('Unhandled Rejection:', err);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

module.exports = app;
