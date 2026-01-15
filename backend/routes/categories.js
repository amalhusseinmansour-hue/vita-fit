const express = require('express');
const router = express.Router();
const slugify = require('slugify');
const { Category, Product } = require('../models');
const { protect, isAdmin } = require('../middleware/auth');
const upload = require('../middleware/upload');
const { Op } = require('sequelize');

// @route   GET /api/categories
// @desc    Get all categories
// @access  Public
router.get('/', async (req, res) => {
  try {
    const { include_inactive, parent_id } = req.query;

    const where = {};
    if (!include_inactive || include_inactive !== 'true') {
      where.is_active = true;
    }
    if (parent_id !== undefined) {
      where.parent_id = parent_id === 'null' ? null : parent_id;
    }

    const categories = await Category.findAll({
      where,
      include: [
        {
          model: Category,
          as: 'subcategories',
          required: false,
          where: include_inactive !== 'true' ? { is_active: true } : {}
        }
      ],
      order: [['sort_order', 'ASC'], ['name', 'ASC']]
    });

    res.json({ success: true, data: categories });
  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/categories/tree
// @desc    Get categories as tree structure
// @access  Public
router.get('/tree', async (req, res) => {
  try {
    const categories = await Category.findAll({
      where: { is_active: true, parent_id: null },
      include: [
        {
          model: Category,
          as: 'subcategories',
          where: { is_active: true },
          required: false,
          include: [
            {
              model: Category,
              as: 'subcategories',
              where: { is_active: true },
              required: false
            }
          ]
        }
      ],
      order: [
        ['sort_order', 'ASC'],
        [{ model: Category, as: 'subcategories' }, 'sort_order', 'ASC']
      ]
    });

    res.json({ success: true, data: categories });
  } catch (error) {
    console.error('Get categories tree error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/categories/:id
// @desc    Get single category
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const category = await Category.findOne({
      where: {
        [Op.or]: [
          { id: req.params.id },
          { slug: req.params.id }
        ]
      },
      include: [
        {
          model: Category,
          as: 'subcategories',
          where: { is_active: true },
          required: false
        },
        {
          model: Category,
          as: 'parent',
          required: false
        }
      ]
    });

    if (!category) {
      return res.status(404).json({ success: false, message: 'Category not found' });
    }

    res.json({ success: true, data: category });
  } catch (error) {
    console.error('Get category error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/categories/:id/products
// @desc    Get products in category
// @access  Public
router.get('/:id/products', async (req, res) => {
  try {
    const { page = 1, limit = 20, sort = 'created_at', order = 'DESC' } = req.query;

    const category = await Category.findOne({
      where: {
        [Op.or]: [
          { id: req.params.id },
          { slug: req.params.id }
        ]
      }
    });

    if (!category) {
      return res.status(404).json({ success: false, message: 'Category not found' });
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);

    const { count, rows: products } = await Product.findAndCountAll({
      where: { category_id: category.id, is_active: true },
      order: [[sort, order.toUpperCase()]],
      limit: parseInt(limit),
      offset
    });

    res.json({
      success: true,
      data: {
        category,
        products,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: count,
          pages: Math.ceil(count / parseInt(limit))
        }
      }
    });
  } catch (error) {
    console.error('Get category products error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   POST /api/categories
// @desc    Create category
// @access  Admin
router.post('/', protect, isAdmin, upload.single('image'), async (req, res) => {
  try {
    const { name, name_ar, description, parent_id, sort_order } = req.body;

    // Generate slug
    const slug = slugify(name, { lower: true, strict: true });

    // Check if slug exists
    const existingCategory = await Category.findOne({ where: { slug } });
    const finalSlug = existingCategory ? `${slug}-${Date.now()}` : slug;

    const category = await Category.create({
      name,
      name_ar,
      slug: finalSlug,
      description,
      parent_id: parent_id || null,
      sort_order: sort_order || 0,
      image: req.file ? `/uploads/categories/${req.file.filename}` : null
    });

    res.status(201).json({
      success: true,
      message: 'Category created successfully',
      data: category
    });
  } catch (error) {
    console.error('Create category error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/categories/:id
// @desc    Update category
// @access  Admin
router.put('/:id', protect, isAdmin, upload.single('image'), async (req, res) => {
  try {
    const category = await Category.findByPk(req.params.id);

    if (!category) {
      return res.status(404).json({ success: false, message: 'Category not found' });
    }

    const updates = { ...req.body };

    // Handle boolean fields
    if (updates.is_active !== undefined) {
      updates.is_active = updates.is_active === 'true' || updates.is_active === true;
    }

    // Handle image upload
    if (req.file) {
      updates.image = `/uploads/categories/${req.file.filename}`;
    }

    // Update slug if name changed
    if (updates.name && updates.name !== category.name) {
      updates.slug = slugify(updates.name, { lower: true, strict: true });
    }

    await category.update(updates);

    res.json({
      success: true,
      message: 'Category updated successfully',
      data: category
    });
  } catch (error) {
    console.error('Update category error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/categories/:id
// @desc    Delete category
// @access  Admin
router.delete('/:id', protect, isAdmin, async (req, res) => {
  try {
    const category = await Category.findByPk(req.params.id);

    if (!category) {
      return res.status(404).json({ success: false, message: 'Category not found' });
    }

    // Check if category has products
    const productCount = await Product.count({ where: { category_id: category.id } });
    if (productCount > 0) {
      return res.status(400).json({
        success: false,
        message: `Cannot delete category with ${productCount} products. Please move or delete products first.`
      });
    }

    // Check if category has subcategories
    const subCount = await Category.count({ where: { parent_id: category.id } });
    if (subCount > 0) {
      return res.status(400).json({
        success: false,
        message: `Cannot delete category with ${subCount} subcategories. Please delete subcategories first.`
      });
    }

    await category.destroy();

    res.json({
      success: true,
      message: 'Category deleted successfully'
    });
  } catch (error) {
    console.error('Delete category error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   PUT /api/categories/reorder
// @desc    Reorder categories
// @access  Admin
router.put('/reorder', protect, isAdmin, async (req, res) => {
  try {
    const { categories } = req.body; // Array of { id, sort_order }

    for (const cat of categories) {
      await Category.update(
        { sort_order: cat.sort_order },
        { where: { id: cat.id } }
      );
    }

    res.json({
      success: true,
      message: 'Categories reordered successfully'
    });
  } catch (error) {
    console.error('Reorder categories error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;
