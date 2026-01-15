const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const { User, Order, Product, Subscription, sequelize } = require('../models');
const { protect, isAdmin } = require('../middleware/auth');

// @route   GET /api/dashboard/stats
router.get('/stats', protect, isAdmin, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const stats = {
      users: await User.count({ where: { role: 'user' } }),
      orders: await Order.count(),
      products: await Product.count({ where: { is_active: true } }),
      revenue: await Order.sum('total', { where: { payment_status: 'paid' } }) || 0
    };

    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
