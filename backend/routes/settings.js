const express = require('express');
const router = express.Router();
const { Setting } = require('../models');
const { protect, isAdmin } = require('../middleware/auth');

// @route   GET /api/settings
router.get('/', async (req, res) => {
  try {
    const settings = await Setting.findAll();
    const settingsObj = {};
    settings.forEach(s => {
      let value = s.value;
      if (s.type === 'number') value = parseFloat(value);
      else if (s.type === 'boolean') value = value === 'true';
      else if (s.type === 'json') value = JSON.parse(value);
      settingsObj[s.key] = value;
    });
    res.json({ success: true, data: settingsObj });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/settings/:key
router.get('/:key', async (req, res) => {
  try {
    const setting = await Setting.findOne({ where: { key: req.params.key } });
    if (!setting) {
      return res.status(404).json({ success: false, message: 'Setting not found' });
    }
    res.json({ success: true, data: setting });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/settings/:key
router.put('/:key', protect, isAdmin, async (req, res) => {
  try {
    const { value, type } = req.body;
    const [setting, created] = await Setting.findOrCreate({
      where: { key: req.params.key },
      defaults: { value, type: type || 'string' }
    });
    if (!created) {
      await setting.update({ value });
    }
    res.json({ success: true, data: setting });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/settings
router.put('/', protect, isAdmin, async (req, res) => {
  try {
    const updates = req.body;
    for (const [key, value] of Object.entries(updates)) {
      await Setting.upsert({ key, value: String(value) });
    }
    res.json({ success: true, message: 'Settings updated' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
