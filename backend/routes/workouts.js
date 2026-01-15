const express = require('express');
const router = express.Router();
const { Workout, Trainer, User } = require('../models');
const { protect, authorize } = require('../middleware/auth');

// @route   GET /api/workouts
router.get('/', async (req, res) => {
  try {
    const { type, difficulty, is_premium } = req.query;
    const where = { is_active: true };

    if (type) where.type = type;
    if (difficulty) where.difficulty = difficulty;
    if (is_premium !== undefined) where.is_premium = is_premium === 'true';

    const workouts = await Workout.findAll({
      where,
      include: [{ model: Trainer, include: [{ model: User, attributes: ['name', 'avatar'] }], required: false }],
      order: [['created_at', 'DESC']]
    });

    res.json({ success: true, data: workouts });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/workouts/:id
router.get('/:id', async (req, res) => {
  try {
    const workout = await Workout.findByPk(req.params.id, {
      include: [{ model: Trainer, include: [{ model: User, attributes: ['name', 'avatar'] }], required: false }]
    });

    if (!workout) {
      return res.status(404).json({ success: false, message: 'Workout not found' });
    }

    await workout.increment('views');
    res.json({ success: true, data: workout });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/workouts
router.post('/', protect, authorize('admin', 'super_admin', 'trainer'), async (req, res) => {
  try {
    const workout = await Workout.create(req.body);
    res.status(201).json({ success: true, data: workout });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/workouts/:id
router.put('/:id', protect, authorize('admin', 'super_admin', 'trainer'), async (req, res) => {
  try {
    const workout = await Workout.findByPk(req.params.id);
    if (!workout) return res.status(404).json({ success: false, message: 'Workout not found' });
    await workout.update(req.body);
    res.json({ success: true, data: workout });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/workouts/:id
router.delete('/:id', protect, authorize('admin', 'super_admin'), async (req, res) => {
  try {
    await Workout.destroy({ where: { id: req.params.id } });
    res.json({ success: true, message: 'Workout deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
