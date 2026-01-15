const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const slugify = require('slugify');
const { Product, Category, Review, User } = require('../models');
const { protect, isAdmin, optionalAuth } = require('../middleware/auth');
const upload = require('../middleware/upload');

// @route   GET /api/products
// @desc    Get all products with filters
// @access  Public
router.get('/', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      category,
      search,
      min_price,
      max_price,
      brand,
      sort = 'created_at',
      order = 'DESC',
      featured,
      in_stock
    } = req.query;

    const where = { is_active: true };

    // Category filter
    if (category) {
      where.category_id = category;
    }

    // Search filter
    if (search) {
      where[Op.or] = [
        { name: { [Op.like]: `%${search}%` } },
        { name_ar: { [Op.like]: `%${search}%` } },
        { description: { [Op.like]: `%${search}%` } }
      ];
    }

    // Price range filter
    if (min_price || max_price) {
      where.price = {};
      if (min_price) where.price[Op.gte] = parseFloat(min_price);
      if (max_price) where.price[Op.lte] = parseFloat(max_price);
    }

    // Brand filter
    if (brand) {
      where.brand = brand;
    }

    // Featured filter
    if (featured === 'true') {
      where.is_featured = true;
    }

    // In stock filter
    if (in_stock === 'true') {
      where.quantity = { [Op.gt]: 0 };
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);

    const { count, rows: products } = await Product.findAndCountAll({
      where,
      include: [{ model: Category, attributes: ['id', 'name', 'name_ar', 'slug'] }],
      order: [[sort, order.toUpperCase()]],
      limit: parseInt(limit),
      offset
    });

    res.json({
      success: true,
      data: products,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/products/featured
// @desc    Get featured products
// @access  Public
router.get('/featured', async (req, res) => {
  try {
    const products = await Product.findAll({
      where: { is_active: true, is_featured: true },
      include: [{ model: Category, attributes: ['id', 'name', 'name_ar'] }],
      limit: 10,
      order: [['created_at', 'DESC']]
    });

    res.json({ success: true, data: products });
  } catch (error) {
    console.error('Get featured products error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/products/best-sellers
// @desc    Get best selling products
// @access  Public
router.get('/best-sellers', async (req, res) => {
  try {
    const products = await Product.findAll({
      where: { is_active: true },
      include: [{ model: Category, attributes: ['id', 'name', 'name_ar'] }],
      order: [['sales_count', 'DESC']],
      limit: 10
    });

    res.json({ success: true, data: products });
  } catch (error) {
    console.error('Get best sellers error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/products/:id
// @desc    Get single product
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findOne({
      where: {
        [Op.or]: [
          { id: req.params.id },
          { uuid: req.params.id },
          { slug: req.params.id }
        ]
      },
      include: [
        { model: Category, attributes: ['id', 'name', 'name_ar', 'slug'] },
        {
          model: Review,
          where: { reviewable_type: 'product', is_approved: true },
          required: false,
          include: [{ model: User, attributes: ['id', 'name', 'avatar'] }]
        }
      ]
    });

    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    // Increment views
    await product.increment('views');

    res.json({ success: true, data: product });
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   POST /api/products
// @desc    Create product
// @access  Admin
router.post('/', protect, isAdmin, upload.single('image'), async (req, res) => {
  try {
    const {
      name, name_ar, description, description_ar,
      price, sale_price, cost_price, sku, barcode,
      quantity, category_id, brand, weight,
      is_featured, low_stock_threshold
    } = req.body;

    // Generate slug
    const slug = slugify(name, { lower: true, strict: true });

    // Check if slug exists
    const existingProduct = await Product.findOne({ where: { slug } });
    const finalSlug = existingProduct ? `${slug}-${Date.now()}` : slug;

    const product = await Product.create({
      name,
      name_ar,
      slug: finalSlug,
      description,
      description_ar,
      price,
      sale_price,
      cost_price,
      sku,
      barcode,
      quantity: quantity || 0,
      category_id,
      brand,
      weight,
      is_featured: is_featured === 'true' || is_featured === true,
      low_stock_threshold: low_stock_threshold || 5,
      image: req.file ? `/uploads/products/${req.file.filename}` : null
    });

    res.status(201).json({
      success: true,
      message: 'Product created successfully',
      data: product
    });
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/products/:id
// @desc    Update product
// @access  Admin
router.put('/:id', protect, isAdmin, upload.single('image'), async (req, res) => {
  try {
    const product = await Product.findByPk(req.params.id);

    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    const updates = { ...req.body };

    // Handle boolean fields
    if (updates.is_featured !== undefined) {
      updates.is_featured = updates.is_featured === 'true' || updates.is_featured === true;
    }
    if (updates.is_active !== undefined) {
      updates.is_active = updates.is_active === 'true' || updates.is_active === true;
    }

    // Handle image upload
    if (req.file) {
      updates.image = `/uploads/products/${req.file.filename}`;
    }

    // Update slug if name changed
    if (updates.name && updates.name !== product.name) {
      updates.slug = slugify(updates.name, { lower: true, strict: true });
    }

    await product.update(updates);

    res.json({
      success: true,
      message: 'Product updated successfully',
      data: product
    });
  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/products/:id
// @desc    Delete product
// @access  Admin
router.delete('/:id', protect, isAdmin, async (req, res) => {
  try {
    const product = await Product.findByPk(req.params.id);

    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    await product.destroy();

    res.json({
      success: true,
      message: 'Product deleted successfully'
    });
  } catch (error) {
    console.error('Delete product error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   PUT /api/products/:id/stock
// @desc    Update product stock
// @access  Admin
router.put('/:id/stock', protect, isAdmin, async (req, res) => {
  try {
    const { quantity, action } = req.body; // action: 'add', 'subtract', 'set'
    const product = await Product.findByPk(req.params.id);

    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    let newQuantity;
    switch (action) {
      case 'add':
        newQuantity = product.quantity + parseInt(quantity);
        break;
      case 'subtract':
        newQuantity = Math.max(0, product.quantity - parseInt(quantity));
        break;
      default:
        newQuantity = parseInt(quantity);
    }

    await product.update({ quantity: newQuantity });

    res.json({
      success: true,
      message: 'Stock updated successfully',
      data: { quantity: newQuantity }
    });
  } catch (error) {
    console.error('Update stock error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/products/low-stock
// @desc    Get low stock products
// @access  Admin
router.get('/admin/low-stock', protect, isAdmin, async (req, res) => {
  try {
    const products = await Product.findAll({
      where: {
        is_active: true,
        [Op.and]: [
          { quantity: { [Op.lte]: sequelize.col('low_stock_threshold') } }
        ]
      },
      include: [{ model: Category, attributes: ['id', 'name'] }],
      order: [['quantity', 'ASC']]
    });

    res.json({ success: true, data: products });
  } catch (error) {
    console.error('Get low stock error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;
