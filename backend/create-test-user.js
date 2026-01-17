const bcrypt = require('bcryptjs');
const { sequelize } = require('./config/database');
const { User } = require('./models');

const createTestUser = async () => {
  try {
    // Connect to database
    await sequelize.authenticate();
    console.log('✅ Connected to database');

    // Check if user already exists
    const existingUser = await User.findOne({ where: { email: 'user@vitafit.online' } });

    if (existingUser) {
      console.log('⚠️ User already exists, updating password...');
      const hashedPassword = await bcrypt.hash('User@2024', 12);
      await existingUser.update({
        password: hashedPassword,
        is_verified: true,
        is_active: true
      });
      console.log('✅ User password updated successfully!');
    } else {
      // Hash password
      const hashedPassword = await bcrypt.hash('User@2024', 12);

      // Create user
      const user = await User.create({
        name: 'Test User',
        email: 'user@vitafit.online',
        password: hashedPassword,
        phone: '+971500000000',
        role: 'user',
        gender: 'female',
        is_verified: true,
        is_active: true
      });

      console.log('✅ Test user created successfully!');
      console.log('📧 Email: user@vitafit.online');
      console.log('🔑 Password: User@2024');
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
};

createTestUser();
