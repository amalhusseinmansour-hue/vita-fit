const express = require('express');
const router = express.Router();
const { Subscription, SubscriptionPlan, User, Trainer } = require('../models');
const { protect, isAdmin } = require('../middleware/auth');
const { sendNotificationToTrainer, sendNotificationToAdmins, NotificationTypes } = require('../utils/notificationHelper');

// @route   GET /api/subscriptions/plans
router.get('/plans', async (req, res) => {
  try {
    const plans = await SubscriptionPlan.findAll({
      where: { is_active: true },
      order: [['sort_order', 'ASC'], ['price', 'ASC']]
    });
    res.json({ success: true, data: plans });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/subscriptions/my-subscription
router.get('/my-subscription', protect, async (req, res) => {
  try {
    const subscription = await Subscription.findOne({
      where: { user_id: req.user.id, status: 'active' },
      include: [
        { model: SubscriptionPlan },
        { model: Trainer, include: [{ model: User, attributes: ['name', 'avatar'] }], required: false }
      ]
    });
    res.json({ success: true, data: subscription });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/subscriptions/history
router.get('/history', protect, async (req, res) => {
  try {
    const subscriptions = await Subscription.findAll({
      where: { user_id: req.user.id },
      include: [{ model: SubscriptionPlan }],
      order: [['created_at', 'DESC']]
    });
    res.json({ success: true, data: subscriptions });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/subscriptions/subscribe
router.post('/subscribe', protect, async (req, res) => {
  try {
    const { plan_id, trainer_id, payment_method } = req.body;

    const plan = await SubscriptionPlan.findByPk(plan_id);
    if (!plan || !plan.is_active) {
      return res.status(404).json({ success: false, message: 'Plan not found' });
    }

    // Check for existing active subscription
    const existing = await Subscription.findOne({
      where: { user_id: req.user.id, status: 'active' }
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'You already have an active subscription'
      });
    }

    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + plan.duration_days);

    const subscription = await Subscription.create({
      user_id: req.user.id,
      plan_id,
      trainer_id: trainer_id || null,
      status: payment_method === 'cash' ? 'pending' : 'pending',
      payment_status: 'pending',
      amount: plan.price,
      start_date: startDate,
      end_date: endDate
    });

    const result = await Subscription.findByPk(subscription.id, {
      include: [{ model: SubscriptionPlan }]
    });

    // Get user name for notifications
    const userName = req.user.name || 'متدربة جديدة';
    const planName = plan.name_ar || plan.name;

    // Send notification to trainer if selected
    if (trainer_id) {
      await sendNotificationToTrainer(trainer_id, {
        title: 'New Client',
        title_ar: 'متدربة جديدة',
        body: `${userName} has selected you as their trainer`,
        body_ar: `${userName} اختارتك كمدربة لها`,
        type: NotificationTypes.TRAINER_SELECTED,
        data: {
          subscriptionId: subscription.id.toString(),
          userId: req.user.id.toString(),
          userName
        }
      });
    }

    // Send notification to admins
    await sendNotificationToAdmins({
      title: 'New Subscription',
      title_ar: 'اشتراك جديد',
      body: `${userName} subscribed to ${planName}`,
      body_ar: `${userName} اشتركت في ${planName}`,
      type: NotificationTypes.NEW_SUBSCRIPTION,
      data: {
        subscriptionId: subscription.id.toString(),
        userId: req.user.id.toString(),
        planId: plan_id.toString(),
        trainerId: trainer_id?.toString() || ''
      }
    });

    res.status(201).json({
      success: true,
      message: 'Subscription created successfully',
      data: result
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/subscriptions/:id/pay
router.post('/:id/pay', protect, async (req, res) => {
  try {
    const { transaction_id } = req.body;

    const subscription = await Subscription.findOne({
      where: { id: req.params.id, user_id: req.user.id }
    });

    if (!subscription) {
      return res.status(404).json({ success: false, message: 'Subscription not found' });
    }

    await subscription.update({
      status: 'active',
      payment_status: 'paid',
      transaction_id
    });

    res.json({
      success: true,
      message: 'Payment successful',
      data: subscription
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/subscriptions/:id/select-trainer
// @desc    Select or change trainer for subscription
router.post('/:id/select-trainer', protect, async (req, res) => {
  try {
    const { trainer_id } = req.body;

    const subscription = await Subscription.findOne({
      where: { id: req.params.id, user_id: req.user.id, status: 'active' }
    });

    if (!subscription) {
      return res.status(404).json({ success: false, message: 'Subscription not found' });
    }

    // Verify trainer exists
    const trainer = await Trainer.findByPk(trainer_id, {
      include: [{ model: User, attributes: ['name'] }]
    });

    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    const oldTrainerId = subscription.trainer_id;
    await subscription.update({ trainer_id });

    const userName = req.user.name || 'متدربة';
    const trainerName = trainer.user?.name || 'المدربة';

    // Notify the new trainer
    await sendNotificationToTrainer(trainer_id, {
      title: 'New Client',
      title_ar: 'متدربة جديدة',
      body: `${userName} has selected you as their trainer`,
      body_ar: `${userName} اختارتك كمدربة لها`,
      type: NotificationTypes.TRAINER_SELECTED,
      data: {
        subscriptionId: subscription.id.toString(),
        userId: req.user.id.toString(),
        userName
      }
    });

    // Notify admins
    await sendNotificationToAdmins({
      title: 'Trainer Selection',
      title_ar: 'اختيار مدربة',
      body: `${userName} selected ${trainerName} as their trainer`,
      body_ar: `${userName} اختارت ${trainerName} كمدربة`,
      type: NotificationTypes.TRAINER_SELECTED,
      data: {
        subscriptionId: subscription.id.toString(),
        userId: req.user.id.toString(),
        trainerId: trainer_id.toString()
      }
    });

    res.json({
      success: true,
      message: 'Trainer selected successfully',
      data: subscription
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/subscriptions/:id/cancel
router.post('/:id/cancel', protect, async (req, res) => {
  try {
    const subscription = await Subscription.findOne({
      where: { id: req.params.id, user_id: req.user.id }
    });

    if (!subscription) {
      return res.status(404).json({ success: false, message: 'Subscription not found' });
    }

    await subscription.update({ status: 'cancelled' });

    res.json({
      success: true,
      message: 'Subscription cancelled'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
