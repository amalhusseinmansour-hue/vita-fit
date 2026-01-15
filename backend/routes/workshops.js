const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const { Workshop, Trainer, User, WorkshopParticipant } = require('../models');
const { protect, authorize } = require('../middleware/auth');

// @route   GET /api/workshops
router.get('/', async (req, res) => {
  try {
    const { category, status, upcoming } = req.query;
    const where = { is_active: true };

    if (category) where.category = category;
    if (status) where.status = status;
    if (upcoming === 'true') where.date = { [Op.gte]: new Date() };

    const workshops = await Workshop.findAll({
      where,
      include: [{
        model: Trainer,
        include: [{ model: User, attributes: ['name', 'avatar'] }],
        required: false
      }],
      order: [['date', 'ASC']]
    });

    res.json({ success: true, data: workshops });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/workshops/my-workshops
router.get('/my-workshops', protect, async (req, res) => {
  try {
    const participations = await WorkshopParticipant.findAll({
      where: { user_id: req.user.id },
      include: [{
        model: Workshop,
        include: [{
          model: Trainer,
          include: [{ model: User, attributes: ['name', 'avatar'] }],
          required: false
        }]
      }],
      order: [[Workshop, 'date', 'ASC']]
    });

    const workshops = participations.map(p => p.Workshop);
    res.json({ success: true, data: workshops });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/workshops/:id
router.get('/:id', async (req, res) => {
  try {
    const workshop = await Workshop.findByPk(req.params.id, {
      include: [
        {
          model: Trainer,
          include: [{ model: User, attributes: ['name', 'avatar', 'email'] }],
          required: false
        },
        {
          model: WorkshopParticipant,
          include: [{ model: User, attributes: ['id', 'name', 'email', 'avatar'] }]
        }
      ]
    });

    if (!workshop) {
      return res.status(404).json({ success: false, message: 'Workshop not found' });
    }

    res.json({ success: true, data: workshop });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/workshops
router.post('/', protect, authorize('admin', 'super_admin'), async (req, res) => {
  try {
    const workshop = await Workshop.create(req.body);

    const result = await Workshop.findByPk(workshop.id, {
      include: [{
        model: Trainer,
        include: [{ model: User, attributes: ['name', 'avatar'] }],
        required: false
      }]
    });

    res.status(201).json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/workshops/:id
router.put('/:id', protect, authorize('admin', 'super_admin'), async (req, res) => {
  try {
    const workshop = await Workshop.findByPk(req.params.id);

    if (!workshop) {
      return res.status(404).json({ success: false, message: 'Workshop not found' });
    }

    await workshop.update(req.body);

    const result = await Workshop.findByPk(workshop.id, {
      include: [{
        model: Trainer,
        include: [{ model: User, attributes: ['name', 'avatar'] }],
        required: false
      }]
    });

    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/workshops/:id
router.delete('/:id', protect, authorize('admin', 'super_admin'), async (req, res) => {
  try {
    const workshop = await Workshop.findByPk(req.params.id);

    if (!workshop) {
      return res.status(404).json({ success: false, message: 'Workshop not found' });
    }

    // Delete all participants first
    await WorkshopParticipant.destroy({ where: { workshop_id: workshop.id } });
    await workshop.destroy();

    res.json({ success: true, message: 'Workshop deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/workshops/:id/register
router.post('/:id/register', protect, async (req, res) => {
  try {
    const workshop = await Workshop.findByPk(req.params.id, {
      include: [{ model: WorkshopParticipant }]
    });

    if (!workshop) {
      return res.status(404).json({ success: false, message: 'Workshop not found' });
    }

    // Check if workshop is full
    const participantCount = workshop.WorkshopParticipants ? workshop.WorkshopParticipants.length : 0;
    if (workshop.max_participants && participantCount >= workshop.max_participants) {
      return res.status(400).json({ success: false, message: 'Workshop is full' });
    }

    // Check if already registered
    const existingParticipant = await WorkshopParticipant.findOne({
      where: { workshop_id: workshop.id, user_id: req.user.id }
    });

    if (existingParticipant) {
      return res.status(400).json({ success: false, message: 'Already registered' });
    }

    if (workshop.status !== 'scheduled') {
      return res.status(400).json({ success: false, message: 'Workshop not available for registration' });
    }

    await WorkshopParticipant.create({
      workshop_id: workshop.id,
      user_id: req.user.id
    });

    // Increment current_participants
    await workshop.increment('current_participants');

    res.json({ success: true, message: 'Successfully registered' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/workshops/:id/unregister
router.post('/:id/unregister', protect, async (req, res) => {
  try {
    const workshop = await Workshop.findByPk(req.params.id);

    if (!workshop) {
      return res.status(404).json({ success: false, message: 'Workshop not found' });
    }

    const participant = await WorkshopParticipant.findOne({
      where: { workshop_id: workshop.id, user_id: req.user.id }
    });

    if (!participant) {
      return res.status(400).json({ success: false, message: 'Not registered for this workshop' });
    }

    await participant.destroy();

    // Decrement current_participants
    if (workshop.current_participants > 0) {
      await workshop.decrement('current_participants');
    }

    res.json({ success: true, message: 'Successfully unregistered' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/workshops/:id/participants
router.get('/:id/participants', protect, authorize('admin', 'super_admin', 'trainer'), async (req, res) => {
  try {
    const workshop = await Workshop.findByPk(req.params.id);

    if (!workshop) {
      return res.status(404).json({ success: false, message: 'Workshop not found' });
    }

    const participants = await WorkshopParticipant.findAll({
      where: { workshop_id: workshop.id },
      include: [{ model: User, attributes: ['id', 'name', 'email', 'avatar', 'phone'] }]
    });

    res.json({ success: true, data: participants });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
