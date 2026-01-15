const express = require('express');
const router = express.Router();
const { Trainer, User, Subscription, Review } = require('../models');
const { protect, authorize } = require('../middleware/auth');

// @route   GET /api/trainers
router.get('/', async (req, res) => {
  try {
    const { specialization, is_available } = req.query;
    const where = {};

    if (specialization) where.specialization = specialization;
    if (is_available !== undefined) where.is_available = is_available === 'true';

    const trainers = await Trainer.findAll({
      where,
      include: [{ model: User, attributes: ['id', 'name', 'email', 'avatar', 'phone'] }],
      order: [['rating', 'DESC']]
    });

    res.json({ success: true, data: trainers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/trainers/:id
router.get('/:id', async (req, res) => {
  try {
    const trainer = await Trainer.findByPk(req.params.id, {
      include: [
        { model: User, attributes: ['id', 'name', 'email', 'avatar', 'phone'] },
        {
          model: Review,
          where: { reviewable_type: 'trainer', is_approved: true },
          required: false,
          include: [{ model: User, attributes: ['name', 'avatar'] }]
        }
      ]
    });

    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    res.json({ success: true, data: trainer });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/trainers
router.post('/', protect, authorize('admin', 'super_admin'), async (req, res) => {
  try {
    const trainer = await Trainer.create(req.body);

    // Update user role
    if (req.body.user_id) {
      await User.update({ role: 'trainer' }, { where: { id: req.body.user_id } });
    }

    const result = await Trainer.findByPk(trainer.id, {
      include: [{ model: User, attributes: { exclude: ['password'] } }]
    });

    res.status(201).json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/trainers/:id
router.put('/:id', protect, authorize('admin', 'super_admin', 'trainer'), async (req, res) => {
  try {
    const trainer = await Trainer.findByPk(req.params.id);

    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    // Trainers can only update their own profile
    if (req.user.role === 'trainer' && trainer.user_id !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Access denied' });
    }

    await trainer.update(req.body);

    const result = await Trainer.findByPk(trainer.id, {
      include: [{ model: User, attributes: { exclude: ['password'] } }]
    });

    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/trainers/:id
router.delete('/:id', protect, authorize('admin', 'super_admin'), async (req, res) => {
  try {
    const trainer = await Trainer.findByPk(req.params.id);

    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    // Revert user role
    await User.update({ role: 'user' }, { where: { id: trainer.user_id } });

    await trainer.destroy();

    res.json({ success: true, message: 'Trainer deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/trainers/:id/clients
router.get('/:id/clients', protect, async (req, res) => {
  try {
    const trainer = await Trainer.findByPk(req.params.id);

    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    // Check access
    if (req.user.role === 'trainer' && trainer.user_id !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Access denied' });
    }

    const clients = await Subscription.findAll({
      where: { trainer_id: trainer.id, status: 'active' },
      include: [{ model: User, attributes: ['id', 'name', 'email', 'avatar', 'phone'] }]
    });

    res.json({ success: true, data: clients });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
