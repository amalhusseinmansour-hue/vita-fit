require('dotenv').config();
const bcrypt = require('bcryptjs');
const { sequelize } = require('./config/database');
const { User } = require('./models');

async function createAdmin() {
  try {
    // Test database connection
    await sequelize.authenticate();
    console.log('✅ Connected to MySQL database');

    // Sync models
    await sequelize.sync();

    // Check if admin exists
    const existingAdmin = await User.findOne({
      where: { email: 'admin@vitafit.com' }
    });

    if (existingAdmin) {
      // Update existing user to admin
      const hashedPassword = await bcrypt.hash('Admin@123456', 12);
      await existingAdmin.update({
        role: 'admin',
        is_active: true,
        email_verified: true,
        password: hashedPassword
      });
      console.log('✅ Updated existing user to admin');
    } else {
      // Create new admin
      const hashedPassword = await bcrypt.hash('Admin@123456', 12);
      await User.create({
        name: 'مدير النظام',
        email: 'admin@vitafit.com',
        password: hashedPassword,
        role: 'admin',
        is_active: true,
        email_verified: true
      });
      console.log('✅ Admin user created successfully!');
    }

    console.log('');
    console.log('========================================');
    console.log('بيانات تسجيل الدخول للوحة التحكم:');
    console.log('========================================');
    console.log('📧 البريد الإلكتروني: admin@vitafit.com');
    console.log('🔑 كلمة المرور: Admin@123456');
    console.log('========================================');
    console.log('');
    console.log('رابط لوحة التحكم: /admin-panel/index');
    console.log('');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

createAdmin();
