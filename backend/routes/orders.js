const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const { v4: uuidv4 } = require('uuid');
const { Order, OrderItem, Product, User, Coupon, sequelize } = require('../models');
const { protect, isAdmin } = require('../middleware/auth');

// Generate order number
const generateOrderNumber = () => {
  const date = new Date();
  const year = date.getFullYear().toString().slice(-2);
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');
  const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
  return `VF${year}${month}${day}${random}`;
};

// @route   GET /api/orders
// @desc    Get user's orders
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const { page = 1, limit = 10, status } = req.query;
    const where = { user_id: req.user.id };

    if (status) {
      where.status = status;
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);

    const { count, rows: orders } = await Order.findAndCountAll({
      where,
      include: [
        {
          model: OrderItem,
          include: [{ model: Product, attributes: ['id', 'name', 'image'] }]
        }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset
    });

    res.json({
      success: true,
      data: orders,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/orders/:id
// @desc    Get single order
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const where = { id: req.params.id };

    // If not admin, only allow viewing own orders
    if (!['admin', 'super_admin'].includes(req.user.role)) {
      where.user_id = req.user.id;
    }

    const order = await Order.findOne({
      where,
      include: [
        {
          model: OrderItem,
          include: [{ model: Product }]
        },
        {
          model: User,
          attributes: ['id', 'name', 'email', 'phone']
        }
      ]
    });

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    res.json({ success: true, data: order });
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   POST /api/orders
// @desc    Create new order
// @access  Private
router.post('/', protect, async (req, res) => {
  const t = await sequelize.transaction();

  try {
    const {
      items, // Array of { product_id, quantity }
      shipping_name,
      shipping_phone,
      shipping_address,
      shipping_city,
      payment_method,
      coupon_code,
      notes
    } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ success: false, message: 'No items in order' });
    }

    // Calculate totals and validate products
    let subtotal = 0;
    const orderItems = [];

    for (const item of items) {
      const product = await Product.findByPk(item.product_id);

      if (!product) {
        await t.rollback();
        return res.status(400).json({
          success: false,
          message: `Product ${item.product_id} not found`
        });
      }

      if (!product.is_active) {
        await t.rollback();
        return res.status(400).json({
          success: false,
          message: `Product ${product.name} is not available`
        });
      }

      if (product.quantity < item.quantity) {
        await t.rollback();
        return res.status(400).json({
          success: false,
          message: `Insufficient stock for ${product.name}. Available: ${product.quantity}`
        });
      }

      const price = product.sale_price || product.price;
      const itemTotal = parseFloat(price) * item.quantity;
      subtotal += itemTotal;

      orderItems.push({
        product_id: product.id,
        product_name: product.name,
        product_image: product.image,
        price: price,
        quantity: item.quantity,
        total: itemTotal
      });

      // Reduce stock
      await product.decrement('quantity', { by: item.quantity, transaction: t });
      await product.increment('sales_count', { by: item.quantity, transaction: t });
    }

    // Apply coupon discount
    let discount = 0;
    if (coupon_code) {
      const coupon = await Coupon.findOne({
        where: {
          code: coupon_code,
          is_active: true,
          [Op.or]: [
            { start_date: null },
            { start_date: { [Op.lte]: new Date() } }
          ],
          [Op.or]: [
            { end_date: null },
            { end_date: { [Op.gte]: new Date() } }
          ],
          [Op.or]: [
            { usage_limit: null },
            { usage_limit: { [Op.gt]: sequelize.col('used_count') } }
          ]
        }
      });

      if (coupon && subtotal >= coupon.min_order) {
        if (coupon.type === 'percentage') {
          discount = subtotal * (parseFloat(coupon.value) / 100);
          if (coupon.max_discount) {
            discount = Math.min(discount, parseFloat(coupon.max_discount));
          }
        } else {
          discount = parseFloat(coupon.value);
        }

        // Increment coupon usage
        await coupon.increment('used_count', { transaction: t });
      }
    }

    // Calculate shipping (free for orders over 500)
    const shipping_cost = subtotal >= 500 ? 0 : 50;

    // Calculate tax (15% VAT)
    const tax = (subtotal - discount) * 0.15;

    // Calculate total
    const total = subtotal - discount + shipping_cost + tax;

    // Create order
    const order = await Order.create({
      order_number: generateOrderNumber(),
      user_id: req.user.id,
      status: 'pending',
      payment_status: payment_method === 'cash' ? 'pending' : 'pending',
      payment_method,
      subtotal,
      discount,
      shipping_cost,
      tax,
      total,
      shipping_name: shipping_name || req.user.name,
      shipping_phone: shipping_phone || req.user.phone,
      shipping_address,
      shipping_city,
      notes,
      coupon_code
    }, { transaction: t });

    // Create order items
    for (const item of orderItems) {
      await OrderItem.create({
        order_id: order.id,
        ...item
      }, { transaction: t });
    }

    await t.commit();

    // Fetch complete order with items
    const completeOrder = await Order.findByPk(order.id, {
      include: [{ model: OrderItem }]
    });

    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: completeOrder
    });
  } catch (error) {
    await t.rollback();
    console.error('Create order error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/orders/:id/cancel
// @desc    Cancel order
// @access  Private
router.put('/:id/cancel', protect, async (req, res) => {
  const t = await sequelize.transaction();

  try {
    const order = await Order.findOne({
      where: { id: req.params.id, user_id: req.user.id },
      include: [{ model: OrderItem }]
    });

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    if (!['pending', 'confirmed'].includes(order.status)) {
      return res.status(400).json({
        success: false,
        message: 'Cannot cancel order at this stage'
      });
    }

    // Restore stock
    for (const item of order.order_items) {
      await Product.increment('quantity', {
        by: item.quantity,
        where: { id: item.product_id },
        transaction: t
      });
    }

    await order.update({
      status: 'cancelled',
      payment_status: order.payment_status === 'paid' ? 'refunded' : 'pending'
    }, { transaction: t });

    await t.commit();

    res.json({
      success: true,
      message: 'Order cancelled successfully',
      data: order
    });
  } catch (error) {
    await t.rollback();
    console.error('Cancel order error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ==================== ADMIN ROUTES ====================

// @route   GET /api/orders/admin/all
// @desc    Get all orders (Admin)
// @access  Admin
router.get('/admin/all', protect, isAdmin, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      status,
      payment_status,
      search,
      from_date,
      to_date,
      sort = 'created_at',
      order = 'DESC'
    } = req.query;

    const where = {};

    if (status) where.status = status;
    if (payment_status) where.payment_status = payment_status;

    if (search) {
      where[Op.or] = [
        { order_number: { [Op.like]: `%${search}%` } },
        { shipping_name: { [Op.like]: `%${search}%` } },
        { shipping_phone: { [Op.like]: `%${search}%` } }
      ];
    }

    if (from_date || to_date) {
      where.created_at = {};
      if (from_date) where.created_at[Op.gte] = new Date(from_date);
      if (to_date) where.created_at[Op.lte] = new Date(to_date + ' 23:59:59');
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);

    const { count, rows: orders } = await Order.findAndCountAll({
      where,
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'email', 'phone']
        },
        {
          model: OrderItem,
          include: [{ model: Product, attributes: ['id', 'name', 'image'] }]
        }
      ],
      order: [[sort, order.toUpperCase()]],
      limit: parseInt(limit),
      offset
    });

    res.json({
      success: true,
      data: orders,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Get all orders error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   PUT /api/orders/admin/:id/status
// @desc    Update order status (Admin)
// @access  Admin
router.put('/admin/:id/status', protect, isAdmin, async (req, res) => {
  try {
    const { status, payment_status, notes } = req.body;

    const order = await Order.findByPk(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    const updates = {};

    if (status) {
      updates.status = status;
      if (status === 'shipped') updates.shipped_at = new Date();
      if (status === 'delivered') updates.delivered_at = new Date();
    }

    if (payment_status) {
      updates.payment_status = payment_status;
    }

    if (notes) {
      updates.notes = notes;
    }

    await order.update(updates);

    res.json({
      success: true,
      message: 'Order updated successfully',
      data: order
    });
  } catch (error) {
    console.error('Update order status error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// @route   GET /api/orders/admin/stats
// @desc    Get order statistics (Admin)
// @access  Admin
router.get('/admin/stats', protect, isAdmin, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const startOfYear = new Date(today.getFullYear(), 0, 1);

    // Today's orders
    const todayOrders = await Order.count({
      where: { created_at: { [Op.gte]: today } }
    });

    // Today's revenue
    const todayRevenue = await Order.sum('total', {
      where: {
        created_at: { [Op.gte]: today },
        payment_status: 'paid'
      }
    }) || 0;

    // Monthly orders
    const monthlyOrders = await Order.count({
      where: { created_at: { [Op.gte]: startOfMonth } }
    });

    // Monthly revenue
    const monthlyRevenue = await Order.sum('total', {
      where: {
        created_at: { [Op.gte]: startOfMonth },
        payment_status: 'paid'
      }
    }) || 0;

    // Yearly revenue
    const yearlyRevenue = await Order.sum('total', {
      where: {
        created_at: { [Op.gte]: startOfYear },
        payment_status: 'paid'
      }
    }) || 0;

    // Order status counts
    const statusCounts = await Order.findAll({
      attributes: [
        'status',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['status']
    });

    // Pending orders count
    const pendingOrders = await Order.count({
      where: { status: 'pending' }
    });

    res.json({
      success: true,
      data: {
        today: {
          orders: todayOrders,
          revenue: todayRevenue
        },
        monthly: {
          orders: monthlyOrders,
          revenue: monthlyRevenue
        },
        yearly: {
          revenue: yearlyRevenue
        },
        pending_orders: pendingOrders,
        status_breakdown: statusCounts
      }
    });
  } catch (error) {
    console.error('Get order stats error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;
