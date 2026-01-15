const express = require('express');
const router = express.Router();
const { User, Trainer, Subscription, SubscriptionPlan, Progress } = require('../models');
const { protect } = require('../middleware/auth');
const { sendNotificationToTrainer, sendNotificationToAdmins, NotificationTypes } = require('../utils/notificationHelper');

// @route   POST /api/smartplan/save
// @desc    Save user's smart plan data (health info, measurements, training type, etc.)
// @access  Private
router.post('/save', protect, async (req, res) => {
  try {
    const {
      // Personal info
      name,
      age,
      height,
      current_weight,
      target_weight,
      // Health info
      health_condition,
      previous_injuries,
      surgeries,
      medications,
      allergies,
      // Activity & BMR
      activity_level,
      bmr,
      tdee,
      // Measurements
      waist,
      hips,
      chest,
      arm,
      thigh,
      // Training preferences
      training_type,
      subscription_type,
      trainer_id
    } = req.body;

    const userId = req.user.id;

    // Update user profile
    const userUpdates = {};
    if (name) userUpdates.name = name;
    if (height) userUpdates.height = height;
    if (current_weight) userUpdates.weight = current_weight;
    if (activity_level) userUpdates.activity_level = activity_level;

    if (Object.keys(userUpdates).length > 0) {
      await User.update(userUpdates, { where: { id: userId } });
    }

    // Save or update progress/measurements
    const today = new Date().toISOString().split('T')[0];
    const existingProgress = await Progress.findOne({
      where: { user_id: userId, date: today }
    });

    const progressData = {
      user_id: userId,
      date: today,
      weight: current_weight,
      waist: waist || null,
      hips: hips || null,
      chest: chest || null,
      arms: arm || null,
      thighs: thigh || null,
      notes: JSON.stringify({
        health_condition,
        previous_injuries,
        surgeries,
        medications,
        allergies,
        age,
        target_weight,
        bmr,
        tdee,
        training_type,
        subscription_type
      })
    };

    if (existingProgress) {
      await existingProgress.update(progressData);
    } else {
      await Progress.create(progressData);
    }

    // If trainer is selected, update subscription and send notification
    if (trainer_id) {
      // Check if user has active subscription
      let subscription = await Subscription.findOne({
        where: { user_id: userId, status: 'active' }
      });

      if (subscription) {
        const oldTrainerId = subscription.trainer_id;
        await subscription.update({ trainer_id });

        // Send notification to trainer
        const userName = req.user.name || 'متدربة';
        await sendNotificationToTrainer(trainer_id, {
          title: 'متدربة جديدة',
          title_ar: 'متدربة جديدة',
          body: `${userName} اختارتك كمدربة لها`,
          body_ar: `${userName} اختارتك كمدربة لها`,
          type: NotificationTypes.TRAINER_SELECTED,
          data: {
            subscriptionId: subscription.id.toString(),
            userId: userId.toString(),
            userName
          }
        });

        // Notify admins
        await sendNotificationToAdmins({
          title: 'اختيار مدربة',
          title_ar: 'اختيار مدربة',
          body: `${userName} اختارت مدربة`,
          body_ar: `${userName} اختارت مدربة`,
          type: NotificationTypes.TRAINER_SELECTED,
          data: {
            subscriptionId: subscription.id.toString(),
            userId: userId.toString(),
            trainerId: trainer_id.toString()
          }
        });
      }
    }

    res.json({
      success: true,
      message: 'تم حفظ البيانات بنجاح'
    });

  } catch (error) {
    console.error('Error saving smart plan:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/smartplan/my-data
// @desc    Get user's smart plan data
// @access  Private
router.get('/my-data', protect, async (req, res) => {
  try {
    const userId = req.user.id;

    // Get user data
    const user = await User.findByPk(userId, {
      attributes: ['id', 'name', 'height', 'weight', 'activity_level', 'birth_date']
    });

    // Get latest progress
    const latestProgress = await Progress.findOne({
      where: { user_id: userId },
      order: [['date', 'DESC']]
    });

    // Get subscription with trainer
    const subscription = await Subscription.findOne({
      where: { user_id: userId, status: 'active' },
      include: [
        { model: SubscriptionPlan },
        { model: Trainer, include: [{ model: User, attributes: ['name', 'avatar'] }] }
      ]
    });

    // Parse notes if exists
    let healthData = {};
    if (latestProgress?.notes) {
      try {
        healthData = JSON.parse(latestProgress.notes);
      } catch (e) {}
    }

    res.json({
      success: true,
      data: {
        user,
        measurements: latestProgress ? {
          weight: latestProgress.weight,
          waist: latestProgress.waist,
          hips: latestProgress.hips,
          chest: latestProgress.chest,
          arms: latestProgress.arms,
          thighs: latestProgress.thighs
        } : null,
        healthData,
        subscription,
        trainer: subscription?.Trainer ? {
          id: subscription.Trainer.id,
          name: subscription.Trainer.User?.name,
          avatar: subscription.Trainer.User?.avatar
        } : null
      }
    });

  } catch (error) {
    console.error('Error getting smart plan data:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
