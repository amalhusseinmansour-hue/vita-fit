const mongoose = require('mongoose');

const progressSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  date: {
    type: Date,
    default: Date.now,
  },
  weight: {
    type: Number,
    required: [true, 'Please add weight'],
  },
  bodyMeasurements: {
    chest: Number,
    waist: Number,
    hips: Number,
    arms: Number,
    thighs: Number,
  },
  bodyFatPercentage: Number,
  muscleMass: Number,
  photos: [{
    url: String,
    type: {
      type: String,
      enum: ['front', 'side', 'back'],
    },
  }],
  notes: String,
  mood: {
    type: String,
    enum: ['ممتاز', 'جيد', 'متوسط', 'سيء'],
  },
  energyLevel: {
    type: Number,
    min: 1,
    max: 10,
  },
  sleepHours: Number,
  waterIntake: Number, // in liters
}, {
  timestamps: true,
});

// Calculate BMI
progressSchema.methods.calculateBMI = function(height) {
  if (!height || !this.weight) return null;
  const heightInMeters = height / 100;
  return (this.weight / (heightInMeters * heightInMeters)).toFixed(1);
};

// Get weight change from previous entry
progressSchema.methods.getWeightChange = async function() {
  const previous = await this.constructor.findOne({
    user: this.user,
    date: { $lt: this.date },
  }).sort('-date');

  if (!previous) return null;
  return (this.weight - previous.weight).toFixed(1);
};

module.exports = mongoose.model('Progress', progressSchema);
