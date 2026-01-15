const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const { Coupon } = require('../models');
const { protect, isAdmin } = require('../middleware/auth');

// @route   GET /api/coupons/validate/:code
router.get('/validate/:code', protect, async (req, res) => {
  try {
    const coupon = await Coupon.findOne({
      where: {
        code: req.params.code,
        is_active: true,
        [Op.or]: [{ start_date: null }, { start_date: { [Op.lte]: new Date() } }],
        [Op.or]: [{ end_date: null }, { end_date: { [Op.gte]: new Date() } }]
      }
    });

    if (!coupon) {
      return res.status(404).json({ success: false, message: 'Invalid or expired coupon' });
    }

    if (coupon.usage_limit && coupon.used_count >= coupon.usage_limit) {
      return res.status(400).json({ success: false, message: 'Coupon usage limit reached' });
    }

    res.json({ success: true, data: coupon });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Admin routes
router.get('/', protect, isAdmin, async (req, res) => {
  try {
    const coupons = await Coupon.findAll({ order: [['created_at', 'DESC']] });
    res.json({ success: true, data: coupons });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/', protect, isAdmin, async (req, res) => {
  try {
    const coupon = await Coupon.create(req.body);
    res.status(201).json({ success: true, data: coupon });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/:id', protect, isAdmin, async (req, res) => {
  try {
    const coupon = await Coupon.findByPk(req.params.id);
    if (!coupon) return res.status(404).json({ success: false, message: 'Coupon not found' });
    await coupon.update(req.body);
    res.json({ success: true, data: coupon });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/:id', protect, isAdmin, async (req, res) => {
  try {
    await Coupon.destroy({ where: { id: req.params.id } });
    res.json({ success: true, message: 'Coupon deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
