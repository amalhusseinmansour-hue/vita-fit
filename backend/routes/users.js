const express = require('express');
const router = express.Router();
const { User, Subscription, SubscriptionPlan, Progress } = require('../models');
const { protect, authorize } = require('../middleware/auth');

// @route   GET /api/users
router.get('/', protect, authorize('admin', 'super_admin'), async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: { exclude: ['password'] },
      order: [['created_at', 'DESC']]
    });
    res.json({ success: true, data: users });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/users/:id
router.get('/:id', protect, async (req, res) => {
  try {
    // Users can only view their own profile unless admin
    if (req.user.id !== parseInt(req.params.id) && !['admin', 'super_admin'].includes(req.user.role)) {
      return res.status(403).json({ success: false, message: 'Access denied' });
    }

    const user = await User.findByPk(req.params.id, {
      attributes: { exclude: ['password'] },
      include: [
        { model: Subscription, include: [SubscriptionPlan], required: false },
        { model: Progress, limit: 10, order: [['date', 'DESC']], required: false }
      ]
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/users/:id
router.put('/:id', protect, async (req, res) => {
  try {
    // Users can only update their own profile unless admin
    if (req.user.id !== parseInt(req.params.id) && !['admin', 'super_admin'].includes(req.user.role)) {
      return res.status(403).json({ success: false, message: 'Access denied' });
    }

    const user = await User.findByPk(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Don't allow changing role unless admin
    const { role, password, ...updates } = req.body;
    if (role && ['admin', 'super_admin'].includes(req.user.role)) {
      updates.role = role;
    }

    await user.update(updates);

    const updated = await User.findByPk(user.id, {
      attributes: { exclude: ['password'] }
    });

    res.json({ success: true, data: updated });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/users/:id
router.delete('/:id', protect, authorize('admin', 'super_admin'), async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (user.role === 'super_admin') {
      return res.status(403).json({ success: false, message: 'Cannot delete super admin' });
    }

    await user.destroy();
    res.json({ success: true, message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
