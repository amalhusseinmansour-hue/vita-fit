const { sequelize } = require('../config/database');
const { DataTypes } = require('sequelize');

// ============== USER MODEL ==============
const User = sequelize.define('users', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  uuid: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    unique: true
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  email: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    validate: { isEmail: true }
  },
  phone: {
    type: DataTypes.STRING(20),
    allowNull: true
  },
  password: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  role: {
    type: DataTypes.ENUM('user', 'trainer', 'admin', 'super_admin'),
    defaultValue: 'user'
  },
  avatar: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  gender: {
    type: DataTypes.ENUM('male', 'female'),
    allowNull: true
  },
  birth_date: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  height: {
    type: DataTypes.FLOAT,
    allowNull: true,
    comment: 'Height in cm'
  },
  weight: {
    type: DataTypes.FLOAT,
    allowNull: true,
    comment: 'Weight in kg'
  },
  goal: {
    type: DataTypes.ENUM('lose_weight', 'build_muscle', 'maintain', 'improve_fitness'),
    allowNull: true
  },
  activity_level: {
    type: DataTypes.ENUM('sedentary', 'light', 'moderate', 'active', 'very_active'),
    defaultValue: 'moderate'
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  is_verified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  fcm_token: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  last_login: {
    type: DataTypes.DATE,
    allowNull: true
  },
  address: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  city: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  apple_id: {
    type: DataTypes.STRING(255),
    allowNull: true,
    unique: true,
    comment: 'Apple Sign In user identifier'
  },
  refresh_token: {
    type: DataTypes.STRING(500),
    allowNull: true
  }
});

// ============== CATEGORY MODEL ==============
const Category = sequelize.define('categories', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  name_ar: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  slug: {
    type: DataTypes.STRING(100),
    unique: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  image: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  parent_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  sort_order: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
});

// ============== PRODUCT MODEL ==============
const Product = sequelize.define('products', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  uuid: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    unique: true
  },
  name: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  name_ar: {
    type: DataTypes.STRING(200),
    allowNull: true
  },
  slug: {
    type: DataTypes.STRING(200),
    unique: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  description_ar: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  sale_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true
  },
  cost_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true
  },
  sku: {
    type: DataTypes.STRING(50),
    unique: true,
    allowNull: true
  },
  barcode: {
    type: DataTypes.STRING(50),
    allowNull: true
  },
  quantity: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  low_stock_threshold: {
    type: DataTypes.INTEGER,
    defaultValue: 5
  },
  weight: {
    type: DataTypes.FLOAT,
    allowNull: true,
    comment: 'Weight in grams'
  },
  image: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  images: {
    type: DataTypes.JSON,
    allowNull: true,
    comment: 'Array of image URLs'
  },
  category_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  brand: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  is_featured: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  views: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  sales_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  rating: {
    type: DataTypes.FLOAT,
    defaultValue: 0
  },
  reviews_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  meta_title: {
    type: DataTypes.STRING(200),
    allowNull: true
  },
  meta_description: {
    type: DataTypes.TEXT,
    allowNull: true
  }
});

// ============== ORDER MODEL ==============
const Order = sequelize.define('orders', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  order_number: {
    type: DataTypes.STRING(50),
    unique: true,
    allowNull: false
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'),
    defaultValue: 'pending'
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'paid', 'failed', 'refunded'),
    defaultValue: 'pending'
  },
  payment_method: {
    type: DataTypes.ENUM('cash', 'card', 'wallet', 'paymob'),
    defaultValue: 'cash'
  },
  subtotal: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  discount: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0
  },
  shipping_cost: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0
  },
  tax: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0
  },
  total: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  shipping_name: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  shipping_phone: {
    type: DataTypes.STRING(20),
    allowNull: true
  },
  shipping_address: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  shipping_city: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  coupon_code: {
    type: DataTypes.STRING(50),
    allowNull: true
  },
  transaction_id: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  shipped_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  delivered_at: {
    type: DataTypes.DATE,
    allowNull: true
  }
});

// ============== ORDER ITEM MODEL ==============
const OrderItem = sequelize.define('order_items', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  order_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  product_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  product_name: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  product_image: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1
  },
  total: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  }
});

// ============== SUBSCRIPTION PLAN MODEL ==============
const SubscriptionPlan = sequelize.define('subscription_plans', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  name_ar: {
    type: DataTypes.STRING(100),
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
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  duration_days: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: 'Duration in days'
  },
  features: {
    type: DataTypes.JSON,
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  is_featured: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  sort_order: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
});

// ============== SUBSCRIPTION MODEL ==============
const Subscription = sequelize.define('subscriptions', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  plan_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  trainer_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('pending', 'active', 'expired', 'cancelled'),
    defaultValue: 'pending'
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'paid', 'failed', 'refunded'),
    defaultValue: 'pending'
  },
  amount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  start_date: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  end_date: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  transaction_id: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  }
});

// ============== TRAINER MODEL ==============
const Trainer = sequelize.define('trainers', {
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
  specialization: {
    type: DataTypes.STRING(200),
    allowNull: true
  },
  experience_years: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  bio: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  bio_ar: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  certifications: {
    type: DataTypes.JSON,
    allowNull: true
  },
  hourly_rate: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true
  },
  rating: {
    type: DataTypes.FLOAT,
    defaultValue: 0
  },
  reviews_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  clients_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  is_available: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  working_hours: {
    type: DataTypes.JSON,
    allowNull: true
  }
});

// ============== WORKOUT MODEL ==============
const Workout = sequelize.define('workouts', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  name_ar: {
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
  type: {
    type: DataTypes.ENUM('strength', 'cardio', 'flexibility', 'hiit', 'yoga', 'mixed'),
    defaultValue: 'mixed'
  },
  difficulty: {
    type: DataTypes.ENUM('beginner', 'intermediate', 'advanced'),
    defaultValue: 'beginner'
  },
  duration_minutes: {
    type: DataTypes.INTEGER,
    defaultValue: 30
  },
  calories_burn: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  image: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  video_url: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  exercises: {
    type: DataTypes.JSON,
    allowNull: true
  },
  target_muscles: {
    type: DataTypes.JSON,
    allowNull: true
  },
  equipment: {
    type: DataTypes.JSON,
    allowNull: true
  },
  trainer_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  is_premium: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  views: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
});

// ============== MEAL MODEL ==============
const Meal = sequelize.define('meals', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  name_ar: {
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
  type: {
    type: DataTypes.ENUM('breakfast', 'lunch', 'dinner', 'snack'),
    defaultValue: 'lunch'
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
  fat: {
    type: DataTypes.FLOAT,
    defaultValue: 0
  },
  fiber: {
    type: DataTypes.FLOAT,
    defaultValue: 0
  },
  image: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  ingredients: {
    type: DataTypes.JSON,
    allowNull: true
  },
  instructions: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  instructions_ar: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  prep_time: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'Prep time in minutes'
  },
  cook_time: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'Cook time in minutes'
  },
  servings: {
    type: DataTypes.INTEGER,
    defaultValue: 1
  },
  is_vegetarian: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  is_vegan: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  is_gluten_free: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  is_premium: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
});

// ============== PROGRESS MODEL ==============
const Progress = sequelize.define('progress', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  weight: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  body_fat: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  muscle_mass: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  chest: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  waist: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  hips: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  arms: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  thighs: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  calories_consumed: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  calories_burned: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  water_intake: {
    type: DataTypes.FLOAT,
    defaultValue: 0,
    comment: 'Water in liters'
  },
  steps: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  sleep_hours: {
    type: DataTypes.FLOAT,
    defaultValue: 0
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  photo: {
    type: DataTypes.STRING(255),
    allowNull: true
  }
});

// ============== WORKSHOP MODEL ==============
const Workshop = sequelize.define('workshops', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  title: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  title_ar: {
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
  trainer_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  type: {
    type: DataTypes.ENUM('online', 'offline', 'hybrid'),
    defaultValue: 'online'
  },
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  start_time: {
    type: DataTypes.TIME,
    allowNull: true
  },
  end_time: {
    type: DataTypes.TIME,
    allowNull: true
  },
  location: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  meeting_url: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0
  },
  max_participants: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  current_participants: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  image: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  status: {
    type: DataTypes.ENUM('upcoming', 'ongoing', 'completed', 'cancelled'),
    defaultValue: 'upcoming'
  }
});

// ============== WORKSHOP PARTICIPANT MODEL ==============
const WorkshopParticipant = sequelize.define('workshop_participants', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  workshop_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('registered', 'attended', 'cancelled'),
    defaultValue: 'registered'
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'paid', 'refunded'),
    defaultValue: 'pending'
  }
});

// ============== COUPON MODEL ==============
const Coupon = sequelize.define('coupons', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  code: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true
  },
  type: {
    type: DataTypes.ENUM('percentage', 'fixed'),
    defaultValue: 'percentage'
  },
  value: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  min_order: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0
  },
  max_discount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true
  },
  usage_limit: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  used_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  start_date: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  end_date: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
});

// ============== REVIEW MODEL ==============
const Review = sequelize.define('reviews', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  reviewable_type: {
    type: DataTypes.ENUM('product', 'trainer', 'workout'),
    allowNull: false
  },
  reviewable_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  rating: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: { min: 1, max: 5 }
  },
  comment: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  is_approved: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
});

// ============== NOTIFICATION MODEL ==============
const Notification = sequelize.define('notifications', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: 'NULL for broadcast notifications'
  },
  title: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  title_ar: {
    type: DataTypes.STRING(200),
    allowNull: true
  },
  body: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  body_ar: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  type: {
    type: DataTypes.ENUM('order', 'subscription', 'workout', 'promotion', 'system'),
    defaultValue: 'system'
  },
  data: {
    type: DataTypes.JSON,
    allowNull: true
  },
  is_read: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
});

// ============== SETTING MODEL ==============
const Setting = sequelize.define('settings', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  key: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true
  },
  value: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  type: {
    type: DataTypes.ENUM('string', 'number', 'boolean', 'json'),
    defaultValue: 'string'
  },
  group: {
    type: DataTypes.STRING(50),
    defaultValue: 'general'
  }
});

// ============== CART MODEL ==============
const Cart = sequelize.define('carts', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  product_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  quantity: {
    type: DataTypes.INTEGER,
    defaultValue: 1
  }
});

// ============== WISHLIST MODEL ==============
const Wishlist = sequelize.define('wishlists', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  product_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  }
});

// ============== ACTIVITY LOG MODEL ==============
const ActivityLog = sequelize.define('activity_logs', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  action: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  model: {
    type: DataTypes.STRING(50),
    allowNull: true
  },
  model_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  old_values: {
    type: DataTypes.JSON,
    allowNull: true
  },
  new_values: {
    type: DataTypes.JSON,
    allowNull: true
  },
  ip_address: {
    type: DataTypes.STRING(45),
    allowNull: true
  },
  user_agent: {
    type: DataTypes.TEXT,
    allowNull: true
  }
});

// ============== RELATIONSHIPS ==============

// Category self-reference (subcategories)
Category.hasMany(Category, { as: 'subcategories', foreignKey: 'parent_id' });
Category.belongsTo(Category, { as: 'parent', foreignKey: 'parent_id' });

// Product - Category
Category.hasMany(Product, { foreignKey: 'category_id' });
Product.belongsTo(Category, { foreignKey: 'category_id' });

// User - Orders
User.hasMany(Order, { foreignKey: 'user_id' });
Order.belongsTo(User, { foreignKey: 'user_id' });

// Order - OrderItems
Order.hasMany(OrderItem, { foreignKey: 'order_id' });
OrderItem.belongsTo(Order, { foreignKey: 'order_id' });

// OrderItem - Product
Product.hasMany(OrderItem, { foreignKey: 'product_id' });
OrderItem.belongsTo(Product, { foreignKey: 'product_id' });

// User - Trainer (1:1)
User.hasOne(Trainer, { foreignKey: 'user_id' });
Trainer.belongsTo(User, { foreignKey: 'user_id' });

// User - Subscriptions
User.hasMany(Subscription, { foreignKey: 'user_id' });
Subscription.belongsTo(User, { foreignKey: 'user_id' });

// SubscriptionPlan - Subscriptions
SubscriptionPlan.hasMany(Subscription, { foreignKey: 'plan_id' });
Subscription.belongsTo(SubscriptionPlan, { foreignKey: 'plan_id' });

// Trainer - Subscriptions
Trainer.hasMany(Subscription, { foreignKey: 'trainer_id' });
Subscription.belongsTo(Trainer, { foreignKey: 'trainer_id' });

// Trainer - Workouts
Trainer.hasMany(Workout, { foreignKey: 'trainer_id' });
Workout.belongsTo(Trainer, { foreignKey: 'trainer_id' });

// Trainer - Workshops
Trainer.hasMany(Workshop, { foreignKey: 'trainer_id' });
Workshop.belongsTo(Trainer, { foreignKey: 'trainer_id' });

// User - Progress
User.hasMany(Progress, { foreignKey: 'user_id' });
Progress.belongsTo(User, { foreignKey: 'user_id' });

// User - Reviews
User.hasMany(Review, { foreignKey: 'user_id' });
Review.belongsTo(User, { foreignKey: 'user_id' });

// User - Notifications
User.hasMany(Notification, { foreignKey: 'user_id' });
Notification.belongsTo(User, { foreignKey: 'user_id' });

// User - Cart
User.hasMany(Cart, { foreignKey: 'user_id' });
Cart.belongsTo(User, { foreignKey: 'user_id' });
Product.hasMany(Cart, { foreignKey: 'product_id' });
Cart.belongsTo(Product, { foreignKey: 'product_id' });

// User - Wishlist
User.hasMany(Wishlist, { foreignKey: 'user_id' });
Wishlist.belongsTo(User, { foreignKey: 'user_id' });
Product.hasMany(Wishlist, { foreignKey: 'product_id' });
Wishlist.belongsTo(Product, { foreignKey: 'product_id' });

// User - ActivityLog
User.hasMany(ActivityLog, { foreignKey: 'user_id' });
ActivityLog.belongsTo(User, { foreignKey: 'user_id' });

// Workshop - WorkshopParticipant - User
Workshop.hasMany(WorkshopParticipant, { foreignKey: 'workshop_id' });
WorkshopParticipant.belongsTo(Workshop, { foreignKey: 'workshop_id' });
User.hasMany(WorkshopParticipant, { foreignKey: 'user_id' });
WorkshopParticipant.belongsTo(User, { foreignKey: 'user_id' });

// Trainer - Review
Trainer.hasMany(Review, { foreignKey: 'reviewable_id', constraints: false, scope: { reviewable_type: 'trainer' } });

// ============== ONLINE SESSION MODEL ==============
const OnlineSession = sequelize.define('online_sessions', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  trainer_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  trainee_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: 'NULL for group sessions'
  },
  subscription_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  title: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  title_ar: {
    type: DataTypes.STRING(200),
    allowNull: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  scheduled_at: {
    type: DataTypes.DATE,
    allowNull: false
  },
  duration_minutes: {
    type: DataTypes.INTEGER,
    defaultValue: 45
  },
  meeting_platform: {
    type: DataTypes.ENUM('zoom', 'google_meet', 'teams', 'other'),
    defaultValue: 'zoom'
  },
  meeting_link: {
    type: DataTypes.STRING(500),
    allowNull: true
  },
  meeting_id: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  meeting_password: {
    type: DataTypes.STRING(50),
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('scheduled', 'in_progress', 'completed', 'cancelled', 'no_show', 'rescheduled'),
    defaultValue: 'scheduled'
  },
  started_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  ended_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  actual_duration_minutes: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  trainer_notes: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'Private notes from trainer'
  },
  admin_notes: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'Notes from admin for monitoring'
  },
  rating: {
    type: DataTypes.INTEGER,
    allowNull: true,
    validate: { min: 1, max: 5 }
  },
  trainee_feedback: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  is_flagged: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  flag_reason: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  flagged_by: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  flagged_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  is_recorded: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  recording_url: {
    type: DataTypes.STRING(500),
    allowNull: true
  },
  max_participants: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
    comment: '1 for 1-on-1, more for group sessions'
  },
  session_type: {
    type: DataTypes.ENUM('individual', 'group'),
    defaultValue: 'individual'
  }
});

// ============== SESSION REPORT MODEL ==============
const SessionReport = sequelize.define('session_reports', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  session_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  reporter_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: 'User who reported'
  },
  reported_user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: 'User being reported'
  },
  report_type: {
    type: DataTypes.ENUM('inappropriate_behavior', 'harassment', 'no_show', 'technical_issues', 'unprofessional', 'spam', 'other'),
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  evidence_urls: {
    type: DataTypes.JSON,
    allowNull: true,
    comment: 'Screenshots or recordings as evidence'
  },
  status: {
    type: DataTypes.ENUM('pending', 'under_review', 'resolved', 'dismissed'),
    defaultValue: 'pending'
  },
  admin_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: 'Admin who handled the report'
  },
  admin_notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  action_taken: {
    type: DataTypes.ENUM('none', 'warning', 'suspension', 'ban', 'refund'),
    allowNull: true
  },
  resolved_at: {
    type: DataTypes.DATE,
    allowNull: true
  }
});

// OnlineSession Relationships
Trainer.hasMany(OnlineSession, { foreignKey: 'trainer_id' });
OnlineSession.belongsTo(Trainer, { foreignKey: 'trainer_id' });

User.hasMany(OnlineSession, { as: 'traineeSessions', foreignKey: 'trainee_id' });
OnlineSession.belongsTo(User, { as: 'trainee', foreignKey: 'trainee_id' });

Subscription.hasMany(OnlineSession, { foreignKey: 'subscription_id' });
OnlineSession.belongsTo(Subscription, { foreignKey: 'subscription_id' });

// SessionReport Relationships
OnlineSession.hasMany(SessionReport, { foreignKey: 'session_id' });
SessionReport.belongsTo(OnlineSession, { foreignKey: 'session_id' });

User.hasMany(SessionReport, { as: 'reportsMade', foreignKey: 'reporter_id' });
SessionReport.belongsTo(User, { as: 'reporter', foreignKey: 'reporter_id' });

User.hasMany(SessionReport, { as: 'reportsReceived', foreignKey: 'reported_user_id' });
SessionReport.belongsTo(User, { as: 'reportedUser', foreignKey: 'reported_user_id' });

module.exports = {
  sequelize,
  User,
  Category,
  Product,
  Order,
  OrderItem,
  SubscriptionPlan,
  Subscription,
  Trainer,
  Workout,
  Meal,
  Progress,
  Workshop,
  Coupon,
  Review,
  Notification,
  Setting,
  Cart,
  Wishlist,
  ActivityLog,
  WorkshopParticipant,
  OnlineSession,
  SessionReport
};
