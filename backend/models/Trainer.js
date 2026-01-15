const mongoose = require('mongoose');

const trainerSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please add a trainer name'],
    trim: true,
  },
  email: {
    type: String,
    required: [true, 'Please add an email'],
    unique: true,
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      'Please add a valid email',
    ],
  },
  phone: {
    type: String,
    required: [true, 'Please add a phone number'],
  },
  specialization: {
    type: [String],
    required: [true, 'Please add specializations'],
    enum: ['قوة', 'كارديو', 'يوغا', 'تغذية', 'تأهيل', 'كروسفيت', 'بناء أجسام'],
  },
  bio: {
    type: String,
    required: [true, 'Please add a bio'],
  },
  experience: {
    type: Number,
    required: [true, 'Please add years of experience'],
  },
  certifications: [String],
  image: {
    type: String,
    default: 'default-trainer.jpg',
  },
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5,
  },
  availability: {
    type: Map,
    of: [String], // day: ['09:00-12:00', '14:00-18:00']
    default: {},
  },
  clients: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Trainer', trainerSchema);
