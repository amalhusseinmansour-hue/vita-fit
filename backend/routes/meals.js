const express = require('express');
const router = express.Router();
const { Meal } = require('../models');
const { protect, authorize } = require('../middleware/auth');

// @route   GET /api/meals
router.get('/', async (req, res) => {
  try {
    const { type, is_vegetarian, is_vegan, is_gluten_free } = req.query;
    const where = { is_active: true };

    if (type) where.type = type;
    if (is_vegetarian === 'true') where.is_vegetarian = true;
    if (is_vegan === 'true') where.is_vegan = true;
    if (is_gluten_free === 'true') where.is_gluten_free = true;

    const meals = await Meal.findAll({
      where,
      order: [['created_at', 'DESC']]
    });

    res.json({ success: true, data: meals });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/meals/:id
router.get('/:id', async (req, res) => {
  try {
    const meal = await Meal.findByPk(req.params.id);
    if (!meal) return res.status(404).json({ success: false, message: 'Meal not found' });
    res.json({ success: true, data: meal });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/meals
router.post('/', protect, authorize('admin', 'super_admin', 'trainer'), async (req, res) => {
  try {
    const meal = await Meal.create(req.body);
    res.status(201).json({ success: true, data: meal });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/meals/:id
router.put('/:id', protect, authorize('admin', 'super_admin', 'trainer'), async (req, res) => {
  try {
    const meal = await Meal.findByPk(req.params.id);
    if (!meal) return res.status(404).json({ success: false, message: 'Meal not found' });
    await meal.update(req.body);
    res.json({ success: true, data: meal });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/meals/:id
router.delete('/:id', protect, authorize('admin', 'super_admin'), async (req, res) => {
  try {
    await Meal.destroy({ where: { id: req.params.id } });
    res.json({ success: true, message: 'Meal deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
