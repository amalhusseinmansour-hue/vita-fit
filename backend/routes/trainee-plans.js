const express = require('express');
const router = express.Router();
const { sequelize, User, Trainer, Subscription, Workout, Meal } = require('../models');
const { protect, isTrainer } = require('../middleware/auth');
const { DataTypes } = require('sequelize');

// ============== USER WORKOUT PLAN MODEL ==============
const UserWorkoutPlan = sequelize.define('user_workout_plans', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  trainer_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  day_of_week: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: '0=Sunday, 1=Monday, ..., 6=Saturday'
  },
  workout_name: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  workout_name_ar: {
    type: DataTypes.STRING(200),
    allowNull: true
  },
  exercises: {
    type: DataTypes.JSON,
    allowNull: true,
    comment: 'Array of exercises with sets, reps, etc.'
  },
  duration_minutes: {
    type: DataTypes.INTEGER,
    defaultValue: 45
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'user_workout_plans'
});

// ============== USER MEAL PLAN MODEL ==============
const UserMealPlan = sequelize.define('user_meal_plans', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  trainer_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  day_of_week: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: '0=Sunday, 1=Monday, ..., 6=Saturday. NULL for everyday'
  },
  meal_type: {
    type: DataTypes.ENUM('breakfast', 'lunch', 'dinner', 'snack'),
    allowNull: false
  },
  meal_name: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  meal_name_ar: {
    type: DataTypes.STRING(200),
    allowNull: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  description_ar: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  calories: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  protein: {
    type: DataTypes.FLOAT,
    defaultValue: 0
  },
  carbs: {
    type: DataTypes.FLOAT,
    defaultValue: 0
  },
  fats: {
    type: DataTypes.FLOAT,
    defaultValue: 0
  },
  ingredients: {
    type: DataTypes.JSON,
    allowNull: true
  },
  instructions: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  image: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  time: {
    type: DataTypes.STRING(10),
    allowNull: true,
    comment: 'Time to eat, e.g. 08:00'
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'user_meal_plans'
});

// ============== NUTRITION GOALS MODEL ==============
const UserNutritionGoals = sequelize.define('user_nutrition_goals', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    unique: true
  },
  trainer_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  daily_calories: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  daily_protein: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  daily_carbs: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  daily_fats: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  water_goal_liters: {
    type: DataTypes.FLOAT,
    defaultValue: 2.5
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  tableName: 'user_nutrition_goals'
});

// Sync models (create tables if not exist)
const syncModels = async () => {
  try {
    await UserWorkoutPlan.sync({ alter: true });
    await UserMealPlan.sync({ alter: true });
    await UserNutritionGoals.sync({ alter: true });
  } catch (err) {
    console.log('Error syncing trainee-plans models:', err.message);
  }
};
syncModels();

// =================== TRAINEE ROUTES ===================

// @route   GET /api/trainee-plans/my-workouts
// @desc    Get trainee's workout plan assigned by trainer
// @access  Private
router.get('/my-workouts', protect, async (req, res) => {
  try {
    const workouts = await UserWorkoutPlan.findAll({
      where: { user_id: req.user.id, is_active: true },
      order: [['day_of_week', 'ASC']]
    });

    // Get trainer info
    const subscription = await Subscription.findOne({
      where: { user_id: req.user.id, status: 'active' },
      include: [{ model: Trainer, include: [{ model: User, attributes: ['name', 'avatar'] }] }]
    });

    res.json({
      success: true,
      data: {
        workouts,
        trainer: subscription?.Trainer ? {
          name: subscription.Trainer.User?.name,
          avatar: subscription.Trainer.User?.avatar
        } : null
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/trainee-plans/my-meals
// @desc    Get trainee's meal plan assigned by trainer
// @access  Private
router.get('/my-meals', protect, async (req, res) => {
  try {
    const meals = await UserMealPlan.findAll({
      where: { user_id: req.user.id, is_active: true },
      order: [['day_of_week', 'ASC'], ['meal_type', 'ASC']]
    });

    // Get nutrition goals
    const goals = await UserNutritionGoals.findOne({
      where: { user_id: req.user.id }
    });

    // Get trainer info
    const subscription = await Subscription.findOne({
      where: { user_id: req.user.id, status: 'active' },
      include: [{ model: Trainer, include: [{ model: User, attributes: ['name', 'avatar'] }] }]
    });

    res.json({
      success: true,
      data: {
        meals,
        goals: goals ? {
          calories: goals.daily_calories,
          protein: goals.daily_protein,
          carbs: goals.daily_carbs,
          fats: goals.daily_fats,
          water: goals.water_goal_liters
        } : null,
        trainer: subscription?.Trainer ? {
          name: subscription.Trainer.User?.name,
          avatar: subscription.Trainer.User?.avatar
        } : null
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/trainee-plans/nutrition-goals
// @desc    Get trainee's nutrition goals
// @access  Private
router.get('/nutrition-goals', protect, async (req, res) => {
  try {
    const goals = await UserNutritionGoals.findOne({
      where: { user_id: req.user.id }
    });

    res.json({
      success: true,
      data: goals ? {
        calories: goals.daily_calories,
        protein: goals.daily_protein,
        carbs: goals.daily_carbs,
        fats: goals.daily_fats,
        water: goals.water_goal_liters
      } : { calories: 0, protein: 0, carbs: 0, fats: 0, water: 2.5 }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// =================== TRAINER ROUTES ===================

// @route   GET /api/trainee-plans/trainer/clients
// @desc    Get trainer's clients with their plans
// @access  Trainer only
router.get('/trainer/clients', protect, isTrainer, async (req, res) => {
  try {
    const trainer = await Trainer.findOne({ where: { user_id: req.user.id } });
    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    const subscriptions = await Subscription.findAll({
      where: { trainer_id: trainer.id, status: 'active' },
      include: [{ model: User, attributes: ['id', 'name', 'email', 'avatar', 'phone'] }]
    });

    const clients = subscriptions.map(sub => ({
      id: sub.User.id,
      name: sub.User.name,
      email: sub.User.email,
      avatar: sub.User.avatar,
      phone: sub.User.phone,
      subscriptionId: sub.id
    }));

    res.json({ success: true, data: clients });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/trainee-plans/trainer/assign-workout
// @desc    Assign workout to trainee
// @access  Trainer only
router.post('/trainer/assign-workout', protect, isTrainer, async (req, res) => {
  try {
    const trainer = await Trainer.findOne({ where: { user_id: req.user.id } });
    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    const { user_id, day_of_week, workout_name, workout_name_ar, exercises, duration_minutes, notes } = req.body;

    // Check if user is trainer's client
    const subscription = await Subscription.findOne({
      where: { user_id, trainer_id: trainer.id, status: 'active' }
    });

    if (!subscription) {
      return res.status(403).json({ success: false, message: 'User is not your client' });
    }

    const workout = await UserWorkoutPlan.create({
      user_id,
      trainer_id: trainer.id,
      day_of_week,
      workout_name,
      workout_name_ar,
      exercises,
      duration_minutes: duration_minutes || 45,
      notes
    });

    res.status(201).json({
      success: true,
      message: 'تم إضافة التمرين بنجاح',
      data: workout
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/trainee-plans/trainer/assign-meal
// @desc    Assign meal to trainee
// @access  Trainer only
router.post('/trainer/assign-meal', protect, isTrainer, async (req, res) => {
  try {
    const trainer = await Trainer.findOne({ where: { user_id: req.user.id } });
    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    const {
      user_id, day_of_week, meal_type, meal_name, meal_name_ar,
      description, description_ar, calories, protein, carbs, fats,
      ingredients, instructions, image, time
    } = req.body;

    // Check if user is trainer's client
    const subscription = await Subscription.findOne({
      where: { user_id, trainer_id: trainer.id, status: 'active' }
    });

    if (!subscription) {
      return res.status(403).json({ success: false, message: 'User is not your client' });
    }

    const meal = await UserMealPlan.create({
      user_id,
      trainer_id: trainer.id,
      day_of_week,
      meal_type,
      meal_name,
      meal_name_ar,
      description,
      description_ar,
      calories: calories || 0,
      protein: protein || 0,
      carbs: carbs || 0,
      fats: fats || 0,
      ingredients,
      instructions,
      image,
      time
    });

    res.status(201).json({
      success: true,
      message: 'تم إضافة الوجبة بنجاح',
      data: meal
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/trainee-plans/trainer/set-nutrition-goals
// @desc    Set nutrition goals for trainee
// @access  Trainer only
router.post('/trainer/set-nutrition-goals', protect, isTrainer, async (req, res) => {
  try {
    const trainer = await Trainer.findOne({ where: { user_id: req.user.id } });
    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    const { user_id, daily_calories, daily_protein, daily_carbs, daily_fats, water_goal_liters, notes } = req.body;

    // Check if user is trainer's client
    const subscription = await Subscription.findOne({
      where: { user_id, trainer_id: trainer.id, status: 'active' }
    });

    if (!subscription) {
      return res.status(403).json({ success: false, message: 'User is not your client' });
    }

    const [goals, created] = await UserNutritionGoals.upsert({
      user_id,
      trainer_id: trainer.id,
      daily_calories: daily_calories || 0,
      daily_protein: daily_protein || 0,
      daily_carbs: daily_carbs || 0,
      daily_fats: daily_fats || 0,
      water_goal_liters: water_goal_liters || 2.5,
      notes
    });

    res.json({
      success: true,
      message: 'تم تحديث أهداف التغذية بنجاح',
      data: goals
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/trainee-plans/trainer/workout/:id
// @desc    Delete workout from trainee's plan
// @access  Trainer only
router.delete('/trainer/workout/:id', protect, isTrainer, async (req, res) => {
  try {
    const trainer = await Trainer.findOne({ where: { user_id: req.user.id } });
    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    const workout = await UserWorkoutPlan.findOne({
      where: { id: req.params.id, trainer_id: trainer.id }
    });

    if (!workout) {
      return res.status(404).json({ success: false, message: 'Workout not found' });
    }

    await workout.destroy();

    res.json({ success: true, message: 'تم حذف التمرين' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/trainee-plans/trainer/meal/:id
// @desc    Delete meal from trainee's plan
// @access  Trainer only
router.delete('/trainer/meal/:id', protect, isTrainer, async (req, res) => {
  try {
    const trainer = await Trainer.findOne({ where: { user_id: req.user.id } });
    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    const meal = await UserMealPlan.findOne({
      where: { id: req.params.id, trainer_id: trainer.id }
    });

    if (!meal) {
      return res.status(404).json({ success: false, message: 'Meal not found' });
    }

    await meal.destroy();

    res.json({ success: true, message: 'تم حذف الوجبة' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/trainee-plans/trainer/client/:userId
// @desc    Get specific client's plans
// @access  Trainer only
router.get('/trainer/client/:userId', protect, isTrainer, async (req, res) => {
  try {
    const trainer = await Trainer.findOne({ where: { user_id: req.user.id } });
    if (!trainer) {
      return res.status(404).json({ success: false, message: 'Trainer not found' });
    }

    const userId = req.params.userId;

    // Check if user is trainer's client
    const subscription = await Subscription.findOne({
      where: { user_id: userId, trainer_id: trainer.id, status: 'active' },
      include: [{ model: User, attributes: ['id', 'name', 'email', 'avatar'] }]
    });

    if (!subscription) {
      return res.status(403).json({ success: false, message: 'User is not your client' });
    }

    const workouts = await UserWorkoutPlan.findAll({
      where: { user_id: userId, trainer_id: trainer.id, is_active: true },
      order: [['day_of_week', 'ASC']]
    });

    const meals = await UserMealPlan.findAll({
      where: { user_id: userId, trainer_id: trainer.id, is_active: true },
      order: [['day_of_week', 'ASC'], ['meal_type', 'ASC']]
    });

    const goals = await UserNutritionGoals.findOne({
      where: { user_id: userId }
    });

    res.json({
      success: true,
      data: {
        client: subscription.User,
        workouts,
        meals,
        nutritionGoals: goals
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
