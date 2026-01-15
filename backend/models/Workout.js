const mongoose = require('mongoose');

const workoutSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    title: {
      type: String,
      required: [true, 'Please provide a workout title'],
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    category: {
      type: String,
      enum: ['cardio', 'strength', 'flexibility', 'sports', 'other'],
      required: true,
    },
    duration: {
      type: Number, // in minutes
      required: [true, 'Please provide workout duration'],
    },
    caloriesBurned: {
      type: Number,
      default: 0,
    },
    difficulty: {
      type: String,
      enum: ['beginner', 'intermediate', 'advanced'],
      default: 'beginner',
    },
    exercises: [
      {
        name: String,
        sets: Number,
        reps: Number,
        duration: Number, // in seconds
        restTime: Number, // in seconds
        notes: String,
      },
    ],
    date: {
      type: Date,
      default: Date.now,
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

// Index for faster queries
workoutSchema.index({ user: 1, date: -1 });

module.exports = mongoose.model('Workout', workoutSchema);
