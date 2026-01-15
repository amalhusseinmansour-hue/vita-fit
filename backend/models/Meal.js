const mongoose = require('mongoose');

const mealSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    mealType: {
      type: String,
      enum: ['breakfast', 'lunch', 'dinner', 'snack'],
      required: true,
    },
    title: {
      type: String,
      required: [true, 'Please provide a meal title'],
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    foods: [
      {
        name: {
          type: String,
          required: true,
        },
        quantity: Number,
        unit: String, // grams, pieces, cups, etc.
        calories: Number,
        protein: Number,
        carbs: Number,
        fat: Number,
      },
    ],
    totalNutrition: {
      calories: { type: Number, default: 0 },
      protein: { type: Number, default: 0 },
      carbs: { type: Number, default: 0 },
      fat: { type: Number, default: 0 },
    },
    date: {
      type: Date,
      default: Date.now,
    },
    time: {
      type: String,
    },
    image: {
      type: String,
    },
    completed: {
      type: Boolean,
      default: false,
    },
    notes: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

// Calculate total nutrition before saving
mealSchema.pre('save', function (next) {
  if (this.foods && this.foods.length > 0) {
    this.totalNutrition = this.foods.reduce(
      (acc, food) => {
        acc.calories += food.calories || 0;
        acc.protein += food.protein || 0;
        acc.carbs += food.carbs || 0;
        acc.fat += food.fat || 0;
        return acc;
      },
      { calories: 0, protein: 0, carbs: 0, fat: 0 }
    );
  }
  next();
});

// Index for faster queries
mealSchema.index({ user: 1, date: -1 });

module.exports = mongoose.model('Meal', mealSchema);
