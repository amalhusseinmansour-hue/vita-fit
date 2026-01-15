const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Please provide a name'],
      trim: true,
    },
    email: {
      type: String,
      required: [true, 'Please provide an email'],
      unique: true,
      lowercase: true,
      match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email'],
    },
    password: {
      type: String,
      required: [true, 'Please provide a password'],
      minlength: 6,
      select: false,
    },
    phone: {
      type: String,
      trim: true,
    },
    age: {
      type: Number,
      min: 13,
      max: 120,
    },
    gender: {
      type: String,
      enum: ['male', 'female'],
    },
    height: {
      type: Number, // in cm
    },
    weight: {
      type: Number, // in kg
    },
    profileImage: {
      type: String,
      default: null,
    },
    role: {
      type: String,
      enum: ['user', 'trainer', 'admin'],
      default: 'user',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    subscription: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Subscription',
      default: null,
    },
    goals: [
      {
        type: String,
      },
    ],
    stats: {
      totalWorkouts: { type: Number, default: 0 },
      totalCaloriesBurned: { type: Number, default: 0 },
      totalWorkoutTime: { type: Number, default: 0 }, // in minutes
      currentStreak: { type: Number, default: 0 },
    },
  },
  {
    timestamps: true,
  }
);

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    return next();
  }

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Calculate BMI
userSchema.methods.calculateBMI = function () {
  if (this.height && this.weight) {
    const heightInMeters = this.height / 100;
    return (this.weight / (heightInMeters * heightInMeters)).toFixed(1);
  }
  return null;
};

module.exports = mongoose.model('User', userSchema);
