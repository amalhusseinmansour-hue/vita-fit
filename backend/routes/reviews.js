const express = require('express');
const router = express.Router();
const { Review, User, Product, Trainer, Workout } = require('../models');
const { protect, isAdmin } = require('../middleware/auth');

// @route   GET /api/reviews/:type/:id
router.get('/:type/:id', async (req, res) => {
  try {
    const reviews = await Review.findAll({
      where: {
        reviewable_type: req.params.type,
        reviewable_id: req.params.id,
        is_approved: true
      },
      include: [{ model: User, attributes: ['id', 'name', 'avatar'] }],
      order: [['created_at', 'DESC']]
    });
    res.json({ success: true, data: reviews });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/reviews
router.post('/', protect, async (req, res) => {
  try {
    const { reviewable_type, reviewable_id, rating, comment } = req.body;

    // Check if user already reviewed
    const existing = await Review.findOne({
      where: { user_id: req.user.id, reviewable_type, reviewable_id }
    });

    if (existing) {
      return res.status(400).json({ success: false, message: 'Already reviewed' });
    }

    const review = await Review.create({
      user_id: req.user.id,
      reviewable_type,
      reviewable_id,
      rating,
      comment,
      is_approved: false
    });

    res.status(201).json({ success: true, data: review });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Admin: Get pending reviews
router.get('/admin/pending', protect, isAdmin, async (req, res) => {
  try {
    const reviews = await Review.findAll({
      where: { is_approved: false },
      include: [{ model: User, attributes: ['id', 'name'] }],
      order: [['created_at', 'DESC']]
    });
    res.json({ success: true, data: reviews });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Admin: Approve review
router.put('/admin/:id/approve', protect, isAdmin, async (req, res) => {
  try {
    const review = await Review.findByPk(req.params.id);
    if (!review) return res.status(404).json({ success: false, message: 'Review not found' });

    await review.update({ is_approved: true });

    // Update product/trainer rating
    const reviews = await Review.findAll({
      where: {
        reviewable_type: review.reviewable_type,
        reviewable_id: review.reviewable_id,
        is_approved: true
      }
    });

    const avgRating = reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length;

    if (review.reviewable_type === 'product') {
      await Product.update(
        { rating: avgRating, reviews_count: reviews.length },
        { where: { id: review.reviewable_id } }
      );
    } else if (review.reviewable_type === 'trainer') {
      await Trainer.update(
        { rating: avgRating, reviews_count: reviews.length },
        { where: { id: review.reviewable_id } }
      );
    }

    res.json({ success: true, message: 'Review approved' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Admin: Delete review
router.delete('/admin/:id', protect, isAdmin, async (req, res) => {
  try {
    await Review.destroy({ where: { id: req.params.id } });
    res.json({ success: true, message: 'Review deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
