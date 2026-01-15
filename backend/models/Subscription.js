const mongoose = require('mongoose');

const subscriptionSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    plan: {
      type: String,
      enum: ['monthly', 'quarterly', 'yearly'],
      required: true,
    },
    planName: {
      type: String,
      required: true,
    },
    price: {
      type: Number,
      required: true,
    },
    startDate: {
      type: Date,
      required: true,
      default: Date.now,
    },
    endDate: {
      type: Date,
      required: true,
    },
    status: {
      type: String,
      enum: ['active', 'expired', 'cancelled'],
      default: 'active',
    },
    autoRenew: {
      type: Boolean,
      default: true,
    },
    features: [
      {
        type: String,
      },
    ],
    paymentMethod: {
      type: String,
    },
    transactionId: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);

// Index for faster queries
subscriptionSchema.index({ user: 1, status: 1 });

// Check if subscription is active
subscriptionSchema.methods.isActive = function () {
  return this.status === 'active' && this.endDate > Date.now();
};

// Calculate days remaining
subscriptionSchema.methods.daysRemaining = function () {
  const now = new Date();
  const end = new Date(this.endDate);
  const diff = end - now;
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
};

module.exports = mongoose.model('Subscription', subscriptionSchema);
