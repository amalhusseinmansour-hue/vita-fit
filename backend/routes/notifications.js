const express = require('express');
const router = express.Router();
const { Notification, User } = require('../models');
const { protect, isAdmin } = require('../middleware/auth');

// @route   GET /api/notifications
router.get('/', protect, async (req, res) => {
  try {
    const notifications = await Notification.findAll({
      where: { user_id: req.user.id },
      order: [['created_at', 'DESC']],
      limit: 50
    });
    res.json({ success: true, data: notifications });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/notifications/:id/read
router.put('/:id/read', protect, async (req, res) => {
  try {
    await Notification.update(
      { is_read: true },
      { where: { id: req.params.id, user_id: req.user.id } }
    );
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/notifications/read-all
router.put('/read-all', protect, async (req, res) => {
  try {
    await Notification.update(
      { is_read: true },
      { where: { user_id: req.user.id, is_read: false } }
    );
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/notifications/send (Admin)
router.post('/send', protect, isAdmin, async (req, res) => {
  try {
    const { title, title_ar, body, body_ar, user_id, type } = req.body;

    if (user_id) {
      await Notification.create({ user_id, title, title_ar, body, body_ar, type });
    } else {
      // Broadcast to all users
      const users = await User.findAll({ where: { role: 'user' }, attributes: ['id'] });
      const notifications = users.map(u => ({
        user_id: u.id, title, title_ar, body, body_ar, type: type || 'system'
      }));
      await Notification.bulkCreate(notifications);
    }

    res.json({ success: true, message: 'Notification sent' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
