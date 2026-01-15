const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

async function createTestUsers() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Create Admin User
    const adminExists = await User.findOne({ email: 'admin@gym.com' });
    if (!adminExists) {
      await User.create({
        name: 'Admin',
        email: 'admin@gym.com',
        password: 'admin123',
        role: 'admin',
        isActive: true
      });
      console.log('✅ Admin user created');
      console.log('   📧 Email: admin@gym.com');
      console.log('   🔑 Password: admin123');
    } else {
      console.log('ℹ️  Admin user already exists');
    }

    // Create Trainer User
    const trainerExists = await User.findOne({ email: 'trainer@gym.com' });
    if (!trainerExists) {
      await User.create({
        name: 'المدرب أحمد',
        email: 'trainer@gym.com',
        password: 'trainer123',
        role: 'trainer',
        isActive: true
      });
      console.log('✅ Trainer user created');
      console.log('   📧 Email: trainer@gym.com');
      console.log('   🔑 Password: trainer123');
    } else {
      console.log('ℹ️  Trainer user already exists');
    }

    // Create Regular User
    const userExists = await User.findOne({ email: 'user@gym.com' });
    if (!userExists) {
      await User.create({
        name: 'مستخدم تجريبي',
        email: 'user@gym.com',
        password: 'user123',
        role: 'user',
        isActive: true
      });
      console.log('✅ Regular user created');
      console.log('   📧 Email: user@gym.com');
      console.log('   🔑 Password: user123');
    } else {
      console.log('ℹ️  Regular user already exists');
    }

    console.log('\n🎉 All test users are ready!');
    console.log('\n📝 Summary:');
    console.log('   - Admin: admin@gym.com / admin123');
    console.log('   - Trainer: trainer@gym.com / trainer123');
    console.log('   - User: user@gym.com / user123');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

createTestUsers();
