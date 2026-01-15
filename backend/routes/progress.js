const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const { Progress, User } = require('../models');
const { protect } = require('../middleware/auth');

// @route   GET /api/progress
router.get('/', protect, async (req, res) => {
  try {
    const { start_date, end_date } = req.query;
    const where = { user_id: req.user.id };

    if (start_date || end_date) {
      where.date = {};
      if (start_date) where.date[Op.gte] = new Date(start_date);
      if (end_date) where.date[Op.lte] = new Date(end_date);
    }

    const progress = await Progress.findAll({
      where,
      order: [['date', 'DESC']]
    });

    res.json({ success: true, data: progress });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/progress/latest
router.get('/latest', protect, async (req, res) => {
  try {
    const progress = await Progress.findOne({
      where: { user_id: req.user.id },
      order: [['date', 'DESC']]
    });

    res.json({ success: true, data: progress });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/progress/stats/summary
router.get('/stats/summary', protect, async (req, res) => {
  try {
    const allProgress = await Progress.findAll({
      where: { user_id: req.user.id },
      order: [['date', 'ASC']]
    });

    if (allProgress.length === 0) {
      return res.json({
        success: true,
        data: { totalEntries: 0, weightChange: 0 }
      });
    }

    const latest = allProgress[allProgress.length - 1];
    const oldest = allProgress[0];
    const weightChange = latest.weight && oldest.weight
      ? (latest.weight - oldest.weight).toFixed(1)
      : 0;

    res.json({
      success: true,
      data: {
        totalEntries: allProgress.length,
        weightChange: parseFloat(weightChange),
        currentWeight: latest.weight,
        startingWeight: oldest.weight
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/progress/stats/weight-history
router.get('/stats/weight-history', protect, async (req, res) => {
  try {
    const { days = 30 } = req.query;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const progress = await Progress.findAll({
      where: {
        user_id: req.user.id,
        date: { [Op.gte]: startDate }
      },
      attributes: ['date', 'weight'],
      order: [['date', 'ASC']]
    });

    res.json({ success: true, data: progress });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/progress/:id
router.get('/:id', protect, async (req, res) => {
  try {
    const progress = await Progress.findOne({
      where: { id: req.params.id, user_id: req.user.id }
    });

    if (!progress) {
      return res.status(404).json({ success: false, message: 'Progress entry not found' });
    }

    res.json({ success: true, data: progress });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/progress
router.post('/', protect, async (req, res) => {
  try {
    const progress = await Progress.create({
      ...req.body,
      user_id: req.user.id
    });

    res.status(201).json({ success: true, data: progress });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/progress/:id
router.put('/:id', protect, async (req, res) => {
  try {
    const progress = await Progress.findOne({
      where: { id: req.params.id, user_id: req.user.id }
    });

    if (!progress) {
      return res.status(404).json({ success: false, message: 'Progress entry not found' });
    }

    await progress.update(req.body);
    res.json({ success: true, data: progress });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/progress/:id
router.delete('/:id', protect, async (req, res) => {
  try {
    const deleted = await Progress.destroy({
      where: { id: req.params.id, user_id: req.user.id }
    });

    if (!deleted) {
      return res.status(404).json({ success: false, message: 'Progress entry not found' });
    }

    res.json({ success: true, message: 'Progress entry deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
