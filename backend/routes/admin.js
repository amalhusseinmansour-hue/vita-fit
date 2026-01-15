const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { Op } = require('sequelize');
const {
  User, Product, Order, OrderItem, Category, Subscription,
  SubscriptionPlan, Trainer, Workout, Meal, Workshop, Coupon,
  Review, Notification, Setting, ActivityLog, sequelize,
  OnlineSession, SessionReport
} = require('../models');
const { protect, isAdmin, isSuperAdmin, authorize } = require('../middleware/auth');

// Protect all routes
router.use(protect);
router.use(authorize('admin', 'super_admin'));

// ==================== DASHBOARD ====================

// @route   GET /api/admin/dashboard
// @desc    Get dashboard statistics
// @access  Admin
router.get('/dashboard', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    // Users stats
    const totalUsers = await User.count({ where: { role: 'user' } });
    const newUsersToday = await User.count({
      where: { role: 'user', created_at: { [Op.gte]: today } }
    });
    const newUsersThisMonth = await User.count({
      where: { role: 'user', created_at: { [Op.gte]: startOfMonth } }
    });

    // Orders stats
    const totalOrders = await Order.count();
    const pendingOrders = await Order.count({ where: { status: 'pending' } });
    const todayOrders = await Order.count({
      where: { created_at: { [Op.gte]: today } }
    });

    // Revenue stats
    const totalRevenue = await Order.sum('total', {
      where: { payment_status: 'paid' }
    }) || 0;
    const todayRevenue = await Order.sum('total', {
      where: { payment_status: 'paid', created_at: { [Op.gte]: today } }
    }) || 0;
    const monthlyRevenue = await Order.sum('total', {
      where: { payment_status: 'paid', created_at: { [Op.gte]: startOfMonth } }
    }) || 0;

    // Products stats
    const totalProducts = await Product.count({ where: { is_active: true } });
    const lowStockProducts = await Product.count({
      where: { is_active: true, quantity: { [Op.lte]: 5, [Op.gt]: 0 } }
    });
    const outOfStockProducts = await Product.count({
      where: { is_active: true, quantity: 0 }
    });

    // Subscriptions stats
    const activeSubscriptions = await Subscription.count({
      where: { status: 'active' }
    });
    const subscriptionRevenue = await Subscription.sum('amount', {
      where: { payment_status: 'paid' }
    }) || 0;

    // Trainers stats
    const totalTrainers = await Trainer.count();

    // Recent orders
    const recentOrders = await Order.findAll({
      include: [{ model: User, attributes: ['id', 'name', 'email'] }],
      order: [['created_at', 'DESC']],
      limit: 5
    });

    // Recent users
    const recentUsers = await User.findAll({
      where: { role: 'user' },
      attributes: { exclude: ['password'] },
      order: [['created_at', 'DESC']],
      limit: 5
    });

    res.json({
      success: true,
      data: {
        users: {
          total: totalUsers,
          new_today: newUsersToday,
          new_this_month: newUsersThisMonth
        },
        orders: {
          total: totalOrders,
          pending: pendingOrders,
          today: todayOrders
        },
        revenue: {
          total: totalRevenue,
          today: todayRevenue,
          monthly: monthlyRevenue
        },
        products: {
          total: totalProducts,
          low_stock: lowStockProducts,
          out_of_stock: outOfStockProducts
        },
        subscriptions: {
          active: activeSubscriptions,
          revenue: subscriptionRevenue
        },
        trainers: {
          total: totalTrainers
        },
        recent_orders: recentOrders,
        recent_users: recentUsers
      }
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Alias for stats
router.get('/stats', async (req, res) => {
  // Redirect to dashboard
  req.url = '/dashboard';
  router.handle(req, res);
});

// ==================== USER MANAGEMENT ====================

// @route   GET /api/admin/users
router.get('/users', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      role,
      search,
      status,
      sort = 'created_at',
      order = 'DESC'
    } = req.query;

    const where = {};

    if (role) where.role = role;
    if (status === 'active') where.is_active = true;
    if (status === 'inactive') where.is_active = false;

    if (search) {
      where[Op.or] = [
        { name: { [Op.like]: `%${search}%` } },
        { email: { [Op.like]: `%${search}%` } },
        { phone: { [Op.like]: `%${search}%` } }
      ];
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);

    const { count, rows: users } = await User.findAndCountAll({
      where,
      attributes: { exclude: ['password'] },
      order: [[sort, order.toUpperCase()]],
      limit: parseInt(limit),
      offset
    });

    res.json({
      success: true,
      data: users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/admin/users/:id
router.get('/users/:id', async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id, {
      attributes: { exclude: ['password'] },
      include: [
        { model: Subscription, include: [SubscriptionPlan], required: false },
        { model: Order, limit: 10, order: [['created_at', 'DESC']], required: false }
      ]
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({ success: true, data: user });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/admin/users
router.post('/users', async (req, res) => {
  try {
    const { name, email, password, phone, role, gender } = req.body;

    // Only super_admin can create admin users
    if (['admin', 'super_admin'].includes(role) && req.user.role !== 'super_admin') {
      return res.status(403).json({
        success: false,
        message: 'Only super admin can create admin accounts'
      });
    }

    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already registered'
      });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      phone,
      role: role || 'user',
      gender,
      is_active: true
    });

    res.status(201).json({
      success: true,
      message: 'User created successfully',
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Create user error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/admin/users/:id
router.put('/users/:id', async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (user.role === 'super_admin' && req.user.role !== 'super_admin') {
      return res.status(403).json({
        success: false,
        message: 'Cannot modify super admin account'
      });
    }

    const { password, role, ...updates } = req.body;

    if (role && ['admin', 'super_admin'].includes(role) && req.user.role !== 'super_admin') {
      return res.status(403).json({
        success: false,
        message: 'Only super admin can assign admin roles'
      });
    }

    if (role) updates.role = role;

    if (password) {
      const salt = await bcrypt.genSalt(10);
      updates.password = await bcrypt.hash(password, salt);
    }

    await user.update(updates);

    res.json({
      success: true,
      message: 'User updated successfully',
      data: user
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/admin/users/:id
router.delete('/users/:id', async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (user.role === 'super_admin') {
      return res.status(403).json({
        success: false,
        message: 'Cannot delete super admin'
      });
    }

    await user.destroy();

    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/admin/users/:id/toggle-status
router.put('/users/:id/toggle-status', async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (user.role === 'super_admin') {
      return res.status(403).json({
        success: false,
        message: 'Cannot deactivate super admin'
      });
    }

    await user.update({ is_active: !user.is_active });

    res.json({
      success: true,
      message: `User ${user.is_active ? 'activated' : 'deactivated'} successfully`,
      data: { is_active: user.is_active }
    });
  } catch (error) {
    console.error('Toggle user status error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== SUBSCRIPTIONS ====================

// @route   GET /api/admin/subscriptions
router.get('/subscriptions', async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query;
    const where = {};
    if (status) where.status = status;

    const offset = (parseInt(page) - 1) * parseInt(limit);

    const { count, rows: subscriptions } = await Subscription.findAndCountAll({
      where,
      include: [
        { model: User, attributes: ['id', 'name', 'email', 'phone'] },
        { model: SubscriptionPlan },
        { model: Trainer, include: [{ model: User, attributes: ['name'] }], required: false }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset
    });

    res.json({
      success: true,
      data: subscriptions,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Get subscriptions error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/admin/subscriptions/:id
router.put('/subscriptions/:id', async (req, res) => {
  try {
    const subscription = await Subscription.findByPk(req.params.id);

    if (!subscription) {
      return res.status(404).json({ success: false, message: 'Subscription not found' });
    }

    await subscription.update(req.body);

    const updated = await Subscription.findByPk(subscription.id, {
      include: [
        { model: User, attributes: ['id', 'name', 'email'] },
        { model: SubscriptionPlan }
      ]
    });

    res.json({
      success: true,
      message: 'Subscription updated successfully',
      data: updated
    });
  } catch (error) {
    console.error('Update subscription error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/admin/subscriptions/:id
router.delete('/subscriptions/:id', async (req, res) => {
  try {
    const subscription = await Subscription.findByPk(req.params.id);

    if (!subscription) {
      return res.status(404).json({ success: false, message: 'Subscription not found' });
    }

    await subscription.destroy();

    res.json({
      success: true,
      message: 'Subscription deleted successfully'
    });
  } catch (error) {
    console.error('Delete subscription error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== SUBSCRIPTION PLANS ====================

// @route   GET /api/admin/plans
router.get('/plans', async (req, res) => {
  try {
    const plans = await SubscriptionPlan.findAll({
      order: [['sort_order', 'ASC'], ['price', 'ASC']]
    });

    res.json({ success: true, data: plans });
  } catch (error) {
    console.error('Get plans error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/admin/plans
router.post('/plans', async (req, res) => {
  try {
    const plan = await SubscriptionPlan.create(req.body);

    res.status(201).json({
      success: true,
      message: 'Plan created successfully',
      data: plan
    });
  } catch (error) {
    console.error('Create plan error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/admin/plans/:id
router.put('/plans/:id', async (req, res) => {
  try {
    const plan = await SubscriptionPlan.findByPk(req.params.id);

    if (!plan) {
      return res.status(404).json({ success: false, message: 'Plan not found' });
    }

    await plan.update(req.body);

    res.json({
      success: true,
      message: 'Plan updated successfully',
      data: plan
    });
  } catch (error) {
    console.error('Update plan error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/admin/plans/:id
router.delete('/plans/:id', async (req, res) => {
  try {
    const plan = await SubscriptionPlan.findByPk(req.params.id);

    if (!plan) {
      return res.status(404).json({ success: false, message: 'Plan not found' });
    }

    // Check if plan has active subscriptions
    const activeCount = await Subscription.count({
      where: { plan_id: plan.id, status: 'active' }
    });

    if (activeCount > 0) {
      return res.status(400).json({
        success: false,
        message: `Cannot delete plan with ${activeCount} active subscriptions`
      });
    }

    await plan.destroy();

    res.json({
      success: true,
      message: 'Plan deleted successfully'
    });
  } catch (error) {
    console.error('Delete plan error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== TRAINERS ====================

// @route   GET /api/admin/trainers
router.get('/trainers', async (req, res) => {
  try {
    const trainers = await Trainer.findAll({
      include: [{ model: User, attributes: { exclude: ['password'] } }],
      order: [['created_at', 'DESC']]
    });

    res.json({ success: true, data: trainers });
  } catch (error) {
    console.error('Get trainers error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/admin/trainers
router.post('/trainers', async (req, res) => {
  try {
    const { user_id, email, name, password, ...trainerData } = req.body;

    let userId = user_id;

    // Create new user if no user_id provided
    if (!userId && email) {
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password || 'trainer123', salt);

      const newUser = await User.create({
        name,
        email,
        password: hashedPassword,
        role: 'trainer',
        is_active: true
      });

      userId = newUser.id;
    } else if (userId) {
      // Update existing user role to trainer
      await User.update({ role: 'trainer' }, { where: { id: userId } });
    }

    const trainer = await Trainer.create({
      user_id: userId,
      ...trainerData
    });

    const fullTrainer = await Trainer.findByPk(trainer.id, {
      include: [{ model: User, attributes: { exclude: ['password'] } }]
    });

    res.status(201).json({
      success: true,
      message: 'Trainer created successfully',
      data: fullTrainer
    });
  } catch (error) {
    console.error('Create trainer error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/admin/trainers/:id
router.put('/trainers/:id', async (req, res) => {
  try {
    const trainer = await Trainer.findByPk(req.params.id);

    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    await trainer.update(req.body);

    const updated = await Trainer.findByPk(trainer.id, {
      include: [{ model: User, attributes: { exclude: ['password'] } }]
    });

    res.json({
      success: true,
      message: 'Trainer updated successfully',
      data: updated
    });
  } catch (error) {
    console.error('Update trainer error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/admin/trainers/:id
router.delete('/trainers/:id', async (req, res) => {
  try {
    const trainer = await Trainer.findByPk(req.params.id);

    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    // Update user role back to user
    await User.update({ role: 'user' }, { where: { id: trainer.user_id } });

    await trainer.destroy();

    res.json({
      success: true,
      message: 'Trainer deleted successfully'
    });
  } catch (error) {
    console.error('Delete trainer error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== PRODUCTS (Admin) ====================

// @route   GET /api/admin/products
router.get('/products', async (req, res) => {
  try {
    const { page = 1, limit = 20, category, search, status } = req.query;
    const where = {};

    if (category) where.category_id = category;
    if (status === 'active') where.is_active = true;
    if (status === 'inactive') where.is_active = false;
    if (search) {
      where[Op.or] = [
        { name: { [Op.like]: `%${search}%` } },
        { sku: { [Op.like]: `%${search}%` } }
      ];
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);

    const { count, rows: products } = await Product.findAndCountAll({
      where,
      include: [{ model: Category, attributes: ['id', 'name', 'name_ar'] }],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset
    });

    res.json({
      success: true,
      data: products,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== ORDERS (Admin) ====================

// @route   GET /api/admin/orders
router.get('/orders', async (req, res) => {
  try {
    const { page = 1, limit = 20, status, payment_status, search } = req.query;
    const where = {};

    if (status) where.status = status;
    if (payment_status) where.payment_status = payment_status;
    if (search) {
      where[Op.or] = [
        { order_number: { [Op.like]: `%${search}%` } },
        { shipping_name: { [Op.like]: `%${search}%` } },
        { shipping_phone: { [Op.like]: `%${search}%` } }
      ];
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);

    const { count, rows: orders } = await Order.findAndCountAll({
      where,
      include: [
        { model: User, attributes: ['id', 'name', 'email', 'phone'] },
        { model: OrderItem }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset
    });

    res.json({
      success: true,
      data: orders,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/admin/orders/:id/status
router.put('/orders/:id/status', async (req, res) => {
  try {
    const { status, payment_status } = req.body;
    const order = await Order.findByPk(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    const updates = {};
    if (status) {
      updates.status = status;
      if (status === 'shipped') updates.shipped_at = new Date();
      if (status === 'delivered') updates.delivered_at = new Date();
    }
    if (payment_status) updates.payment_status = payment_status;

    await order.update(updates);

    res.json({
      success: true,
      message: 'Order updated successfully',
      data: order
    });
  } catch (error) {
    console.error('Update order status error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== REPORTS ====================

// @route   GET /api/admin/reports
router.get('/reports', async (req, res) => {
  try {
    const today = new Date();
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const startOfYear = new Date(today.getFullYear(), 0, 1);

    // Revenue
    const totalRevenue = await Order.sum('total', { where: { payment_status: 'paid' } }) || 0;
    const monthlyRevenue = await Order.sum('total', {
      where: { payment_status: 'paid', created_at: { [Op.gte]: startOfMonth } }
    }) || 0;
    const yearlyRevenue = await Order.sum('total', {
      where: { payment_status: 'paid', created_at: { [Op.gte]: startOfYear } }
    }) || 0;

    // Orders
    const totalOrders = await Order.count();
    const monthlyOrders = await Order.count({
      where: { created_at: { [Op.gte]: startOfMonth } }
    });

    // Users
    const totalUsers = await User.count({ where: { role: 'user' } });
    const monthlyUsers = await User.count({
      where: { role: 'user', created_at: { [Op.gte]: startOfMonth } }
    });

    // Products
    const totalProducts = await Product.count({ where: { is_active: true } });
    const lowStockCount = await Product.count({
      where: { is_active: true, quantity: { [Op.lte]: 5 } }
    });

    // Top products
    const topProducts = await OrderItem.findAll({
      attributes: [
        'product_id',
        'product_name',
        [sequelize.fn('SUM', sequelize.col('quantity')), 'total_sold'],
        [sequelize.fn('SUM', sequelize.col('order_items.total')), 'revenue']
      ],
      include: [{
        model: Order,
        where: { payment_status: 'paid' },
        attributes: []
      }],
      group: ['product_id', 'product_name'],
      order: [[sequelize.fn('SUM', sequelize.col('quantity')), 'DESC']],
      limit: 10
    });

    res.json({
      success: true,
      data: {
        revenue: {
          total: totalRevenue,
          monthly: monthlyRevenue,
          yearly: yearlyRevenue
        },
        orders: {
          total: totalOrders,
          monthly: monthlyOrders
        },
        users: {
          total: totalUsers,
          monthly: monthlyUsers
        },
        products: {
          total: totalProducts,
          low_stock: lowStockCount
        },
        top_products: topProducts
      }
    });
  } catch (error) {
    console.error('Reports error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== ONLINE SESSIONS MANAGEMENT ====================

// @route   GET /api/admin/sessions
// @desc    Get all online sessions with filtering
// @access  Admin
router.get('/sessions', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      status,
      trainer_id,
      trainee_id,
      is_flagged,
      date_from,
      date_to,
      search
    } = req.query;

    const where = {};

    if (status) where.status = status;
    if (trainer_id) where.trainer_id = trainer_id;
    if (trainee_id) where.trainee_id = trainee_id;
    if (is_flagged === 'true') where.is_flagged = true;
    if (is_flagged === 'false') where.is_flagged = false;

    if (date_from || date_to) {
      where.scheduled_at = {};
      if (date_from) where.scheduled_at[Op.gte] = new Date(date_from);
      if (date_to) where.scheduled_at[Op.lte] = new Date(date_to);
    }

    if (search) {
      where[Op.or] = [
        { title: { [Op.iLike]: `%${search}%` } },
        { meeting_id: { [Op.iLike]: `%${search}%` } }
      ];
    }

    const sessions = await OnlineSession.findAndCountAll({
      where,
      include: [
        {
          model: Trainer,
          include: [{ model: User, attributes: ['id', 'name', 'email', 'avatar'] }]
        },
        { model: User, as: 'trainee', attributes: ['id', 'name', 'email', 'avatar'] },
        { model: Subscription, attributes: ['id', 'status', 'plan_id'] }
      ],
      order: [['scheduled_at', 'DESC']],
      limit: parseInt(limit),
      offset: (parseInt(page) - 1) * parseInt(limit)
    });

    res.json({
      success: true,
      data: {
        sessions: sessions.rows,
        pagination: {
          total: sessions.count,
          page: parseInt(page),
          pages: Math.ceil(sessions.count / parseInt(limit))
        }
      }
    });
  } catch (error) {
    console.error('Get sessions error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/admin/sessions/stats
// @desc    Get sessions statistics for dashboard
// @access  Admin
router.get('/sessions/stats', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const endOfToday = new Date(today);
    endOfToday.setHours(23, 59, 59, 999);

    // Total sessions
    const totalSessions = await OnlineSession.count();

    // Sessions by status
    const scheduledSessions = await OnlineSession.count({ where: { status: 'scheduled' } });
    const completedSessions = await OnlineSession.count({ where: { status: 'completed' } });
    const cancelledSessions = await OnlineSession.count({ where: { status: 'cancelled' } });
    const noShowSessions = await OnlineSession.count({ where: { status: 'no_show' } });

    // Today's sessions
    const todaySessions = await OnlineSession.count({
      where: {
        scheduled_at: { [Op.between]: [today, endOfToday] }
      }
    });

    // This month's sessions
    const monthSessions = await OnlineSession.count({
      where: {
        scheduled_at: { [Op.gte]: startOfMonth }
      }
    });

    // Flagged sessions
    const flaggedSessions = await OnlineSession.count({ where: { is_flagged: true } });

    // Pending reports
    const pendingReports = await SessionReport.count({ where: { status: 'pending' } });

    // In progress sessions (live now)
    const inProgressSessions = await OnlineSession.count({ where: { status: 'in_progress' } });

    // Average rating
    const avgRating = await OnlineSession.findOne({
      attributes: [[sequelize.fn('AVG', sequelize.col('rating')), 'avg_rating']],
      where: { rating: { [Op.ne]: null } }
    });

    // Sessions by platform
    const sessionsByPlatform = await OnlineSession.findAll({
      attributes: [
        'meeting_platform',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['meeting_platform']
    });

    res.json({
      success: true,
      data: {
        total: totalSessions,
        scheduled: scheduledSessions,
        completed: completedSessions,
        cancelled: cancelledSessions,
        no_show: noShowSessions,
        in_progress: inProgressSessions,
        today: todaySessions,
        this_month: monthSessions,
        flagged: flaggedSessions,
        pending_reports: pendingReports,
        average_rating: avgRating?.dataValues?.avg_rating || 0,
        by_platform: sessionsByPlatform
      }
    });
  } catch (error) {
    console.error('Sessions stats error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/admin/sessions/:id
// @desc    Get single session details
// @access  Admin
router.get('/sessions/:id', async (req, res) => {
  try {
    const session = await OnlineSession.findByPk(req.params.id, {
      include: [
        {
          model: Trainer,
          include: [{ model: User, attributes: ['id', 'name', 'email', 'avatar', 'phone'] }]
        },
        { model: User, as: 'trainee', attributes: ['id', 'name', 'email', 'avatar', 'phone'] },
        { model: Subscription, include: [{ model: SubscriptionPlan }] },
        { model: SessionReport, include: [
          { model: User, as: 'reporter', attributes: ['id', 'name'] },
          { model: User, as: 'reportedUser', attributes: ['id', 'name'] }
        ]}
      ]
    });

    if (!session) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }

    res.json({ success: true, data: session });
  } catch (error) {
    console.error('Get session error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/admin/sessions
// @desc    Create a new online session
// @access  Admin
router.post('/sessions', async (req, res) => {
  try {
    const {
      trainer_id, trainee_id, subscription_id, title, title_ar,
      description, scheduled_at, duration_minutes, meeting_platform,
      meeting_link, meeting_id, meeting_password, session_type,
      max_participants, notes
    } = req.body;

    const session = await OnlineSession.create({
      trainer_id,
      trainee_id,
      subscription_id,
      title,
      title_ar,
      description,
      scheduled_at,
      duration_minutes: duration_minutes || 45,
      meeting_platform: meeting_platform || 'zoom',
      meeting_link,
      meeting_id,
      meeting_password,
      session_type: session_type || 'individual',
      max_participants: max_participants || 1,
      notes,
      status: 'scheduled'
    });

    // Log activity
    await ActivityLog.create({
      user_id: req.user.id,
      action: 'create_session',
      model: 'OnlineSession',
      model_id: session.id,
      new_values: session.toJSON(),
      ip_address: req.ip,
      user_agent: req.get('user-agent')
    });

    res.status(201).json({ success: true, data: session });
  } catch (error) {
    console.error('Create session error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/admin/sessions/:id
// @desc    Update an online session
// @access  Admin
router.put('/sessions/:id', async (req, res) => {
  try {
    const session = await OnlineSession.findByPk(req.params.id);
    if (!session) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }

    const oldValues = session.toJSON();

    const allowedFields = [
      'trainer_id', 'trainee_id', 'subscription_id', 'title', 'title_ar',
      'description', 'scheduled_at', 'duration_minutes', 'meeting_platform',
      'meeting_link', 'meeting_id', 'meeting_password', 'status',
      'started_at', 'ended_at', 'actual_duration_minutes', 'notes',
      'trainer_notes', 'admin_notes', 'session_type', 'max_participants'
    ];

    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        session[field] = req.body[field];
      }
    });

    await session.save();

    // Log activity
    await ActivityLog.create({
      user_id: req.user.id,
      action: 'update_session',
      model: 'OnlineSession',
      model_id: session.id,
      old_values: oldValues,
      new_values: session.toJSON(),
      ip_address: req.ip,
      user_agent: req.get('user-agent')
    });

    res.json({ success: true, data: session });
  } catch (error) {
    console.error('Update session error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/admin/sessions/:id
// @desc    Delete an online session
// @access  Admin
router.delete('/sessions/:id', async (req, res) => {
  try {
    const session = await OnlineSession.findByPk(req.params.id);
    if (!session) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }

    // Log activity before deletion
    await ActivityLog.create({
      user_id: req.user.id,
      action: 'delete_session',
      model: 'OnlineSession',
      model_id: session.id,
      old_values: session.toJSON(),
      ip_address: req.ip,
      user_agent: req.get('user-agent')
    });

    await session.destroy();

    res.json({ success: true, message: 'Session deleted successfully' });
  } catch (error) {
    console.error('Delete session error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/admin/sessions/:id/flag
// @desc    Flag a session for review
// @access  Admin
router.post('/sessions/:id/flag', async (req, res) => {
  try {
    const session = await OnlineSession.findByPk(req.params.id);
    if (!session) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }

    session.is_flagged = true;
    session.flag_reason = req.body.reason;
    session.flagged_by = req.user.id;
    session.flagged_at = new Date();
    await session.save();

    // Log activity
    await ActivityLog.create({
      user_id: req.user.id,
      action: 'flag_session',
      model: 'OnlineSession',
      model_id: session.id,
      new_values: { flag_reason: req.body.reason },
      ip_address: req.ip,
      user_agent: req.get('user-agent')
    });

    res.json({ success: true, data: session });
  } catch (error) {
    console.error('Flag session error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/admin/sessions/:id/unflag
// @desc    Remove flag from a session
// @access  Admin
router.post('/sessions/:id/unflag', async (req, res) => {
  try {
    const session = await OnlineSession.findByPk(req.params.id);
    if (!session) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }

    session.is_flagged = false;
    session.flag_reason = null;
    session.flagged_by = null;
    session.flagged_at = null;
    await session.save();

    res.json({ success: true, data: session });
  } catch (error) {
    console.error('Unflag session error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== SESSION REPORTS MANAGEMENT ====================

// @route   GET /api/admin/session-reports
// @desc    Get all session reports
// @access  Admin
router.get('/session-reports', async (req, res) => {
  try {
    const { page = 1, limit = 20, status, report_type } = req.query;

    const where = {};
    if (status) where.status = status;
    if (report_type) where.report_type = report_type;

    const reports = await SessionReport.findAndCountAll({
      where,
      include: [
        {
          model: OnlineSession,
          include: [
            { model: Trainer, include: [{ model: User, attributes: ['name'] }] }
          ]
        },
        { model: User, as: 'reporter', attributes: ['id', 'name', 'email'] },
        { model: User, as: 'reportedUser', attributes: ['id', 'name', 'email'] }
      ],
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit),
      offset: (parseInt(page) - 1) * parseInt(limit)
    });

    res.json({
      success: true,
      data: {
        reports: reports.rows,
        pagination: {
          total: reports.count,
          page: parseInt(page),
          pages: Math.ceil(reports.count / parseInt(limit))
        }
      }
    });
  } catch (error) {
    console.error('Get reports error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/admin/session-reports/:id
// @desc    Get single report details
// @access  Admin
router.get('/session-reports/:id', async (req, res) => {
  try {
    const report = await SessionReport.findByPk(req.params.id, {
      include: [
        {
          model: OnlineSession,
          include: [
            { model: Trainer, include: [{ model: User, attributes: ['id', 'name', 'email', 'avatar'] }] },
            { model: User, as: 'trainee', attributes: ['id', 'name', 'email', 'avatar'] }
          ]
        },
        { model: User, as: 'reporter', attributes: ['id', 'name', 'email', 'avatar'] },
        { model: User, as: 'reportedUser', attributes: ['id', 'name', 'email', 'avatar'] }
      ]
    });

    if (!report) {
      return res.status(404).json({ success: false, message: 'Report not found' });
    }

    res.json({ success: true, data: report });
  } catch (error) {
    console.error('Get report error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/admin/session-reports/:id
// @desc    Update report status and take action
// @access  Admin
router.put('/session-reports/:id', async (req, res) => {
  try {
    const report = await SessionReport.findByPk(req.params.id);
    if (!report) {
      return res.status(404).json({ success: false, message: 'Report not found' });
    }

    const { status, admin_notes, action_taken } = req.body;

    if (status) report.status = status;
    if (admin_notes) report.admin_notes = admin_notes;
    if (action_taken) report.action_taken = action_taken;

    report.admin_id = req.user.id;

    if (status === 'resolved') {
      report.resolved_at = new Date();
    }

    await report.save();

    // If action is taken, update the reported user
    if (action_taken === 'suspension' || action_taken === 'ban') {
      const reportedUser = await User.findByPk(report.reported_user_id);
      if (reportedUser) {
        reportedUser.is_active = false;
        await reportedUser.save();
      }
    }

    // Log activity
    await ActivityLog.create({
      user_id: req.user.id,
      action: 'update_session_report',
      model: 'SessionReport',
      model_id: report.id,
      new_values: { status, action_taken, admin_notes },
      ip_address: req.ip,
      user_agent: req.get('user-agent')
    });

    res.json({ success: true, data: report });
  } catch (error) {
    console.error('Update report error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/admin/sessions/live
// @desc    Get currently active/live sessions
// @access  Admin
router.get('/sessions-live', async (req, res) => {
  try {
    const liveSessions = await OnlineSession.findAll({
      where: { status: 'in_progress' },
      include: [
        {
          model: Trainer,
          include: [{ model: User, attributes: ['id', 'name', 'avatar'] }]
        },
        { model: User, as: 'trainee', attributes: ['id', 'name', 'avatar'] }
      ],
      order: [['started_at', 'DESC']]
    });

    res.json({ success: true, data: liveSessions });
  } catch (error) {
    console.error('Get live sessions error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/admin/sessions/upcoming
// @desc    Get upcoming sessions for today and tomorrow
// @access  Admin
router.get('/sessions-upcoming', async (req, res) => {
  try {
    const now = new Date();
    const dayAfterTomorrow = new Date();
    dayAfterTomorrow.setDate(dayAfterTomorrow.getDate() + 2);
    dayAfterTomorrow.setHours(0, 0, 0, 0);

    const upcomingSessions = await OnlineSession.findAll({
      where: {
        status: 'scheduled',
        scheduled_at: {
          [Op.gte]: now,
          [Op.lt]: dayAfterTomorrow
        }
      },
      include: [
        {
          model: Trainer,
          include: [{ model: User, attributes: ['id', 'name', 'avatar'] }]
        },
        { model: User, as: 'trainee', attributes: ['id', 'name', 'avatar'] }
      ],
      order: [['scheduled_at', 'ASC']]
    });

    res.json({ success: true, data: upcomingSessions });
  } catch (error) {
    console.error('Get upcoming sessions error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
