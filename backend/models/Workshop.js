const mongoose = require('mongoose');

const workshopSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a workshop title'],
    trim: true,
  },
  description: {
    type: String,
    required: [true, 'Please add a description'],
  },
  trainer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Trainer',
    required: [true, 'Please add a trainer'],
  },
  category: {
    type: String,
    required: [true, 'Please add a category'],
    enum: ['قوة', 'كارديو', 'يوغا', 'تغذية', 'تأهيل', 'كروسفيت', 'بناء أجسام'],
  },
  date: {
    type: Date,
    required: [true, 'Please add a date'],
  },
  duration: {
    type: Number,
    required: [true, 'Please add duration in minutes'],
  },
  maxParticipants: {
    type: Number,
    required: [true, 'Please add maximum participants'],
    default: 20,
  },
  participants: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  price: {
    type: Number,
    required: [true, 'Please add a price'],
    default: 0,
  },
  location: {
    type: String,
    required: [true, 'Please add a location'],
  },
  image: {
    type: String,
    default: 'default-workshop.jpg',
  },
  status: {
    type: String,
    enum: ['scheduled', 'in_progress', 'completed', 'cancelled'],
    default: 'scheduled',
  },
  requirements: [String],
  level: {
    type: String,
    enum: ['beginner', 'intermediate', 'advanced'],
    default: 'beginner',
  },
}, {
  timestamps: true,
});

// Check if workshop is full
workshopSchema.methods.isFull = function() {
  return this.participants.length >= this.maxParticipants;
};

// Get available spots
workshopSchema.methods.availableSpots = function() {
  return this.maxParticipants - this.participants.length;
};

module.exports = mongoose.model('Workshop', workshopSchema);
