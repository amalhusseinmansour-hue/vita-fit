const express = require('express');
const router = express.Router();
const { Cart, Product } = require('../models');
const { protect } = require('../middleware/auth');

// @route   GET /api/cart
router.get('/', protect, async (req, res) => {
  try {
    const items = await Cart.findAll({
      where: { user_id: req.user.id },
      include: [{ model: Product }]
    });

    const total = items.reduce((sum, item) => {
      const price = item.product.sale_price || item.product.price;
      return sum + (parseFloat(price) * item.quantity);
    }, 0);

    res.json({ success: true, data: { items, total } });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/cart
router.post('/', protect, async (req, res) => {
  try {
    const { product_id, quantity = 1 } = req.body;

    const product = await Product.findByPk(product_id);
    if (!product || !product.is_active) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    const [cartItem, created] = await Cart.findOrCreate({
      where: { user_id: req.user.id, product_id },
      defaults: { quantity }
    });

    if (!created) {
      await cartItem.update({ quantity: cartItem.quantity + quantity });
    }

    res.json({ success: true, data: cartItem });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/cart/:id
router.put('/:id', protect, async (req, res) => {
  try {
    const { quantity } = req.body;
    const item = await Cart.findOne({
      where: { id: req.params.id, user_id: req.user.id }
    });

    if (!item) return res.status(404).json({ success: false, message: 'Item not found' });

    if (quantity <= 0) {
      await item.destroy();
      return res.json({ success: true, message: 'Item removed' });
    }

    await item.update({ quantity });
    res.json({ success: true, data: item });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/cart/:id
router.delete('/:id', protect, async (req, res) => {
  try {
    await Cart.destroy({ where: { id: req.params.id, user_id: req.user.id } });
    res.json({ success: true, message: 'Item removed' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/cart (clear cart)
router.delete('/', protect, async (req, res) => {
  try {
    await Cart.destroy({ where: { user_id: req.user.id } });
    res.json({ success: true, message: 'Cart cleared' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
