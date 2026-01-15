const bcrypt = require('bcryptjs');
const {
  sequelize,
  User,
  Category,
  Product,
  SubscriptionPlan,
  Trainer,
  Workout,
  Meal,
  Setting,
  Coupon
} = require('../models');

const seedDatabase = async () => {
  try {
    console.log('Starting database seeding...');

    // Sync database (create tables)
    await sequelize.sync({ force: true });
    console.log('Database synchronized');

    // ============== SEED USERS ==============
    const hashedPassword = await bcrypt.hash('password123', 10);

    const users = await User.bulkCreate([
      {
        name: 'Super Admin',
        email: 'superadmin@vitafit.com',
        password: hashedPassword,
        role: 'super_admin',
        is_verified: true,
        phone: '+201000000001'
      },
      {
        name: 'Admin User',
        email: 'admin@vitafit.com',
        password: hashedPassword,
        role: 'admin',
        is_verified: true,
        phone: '+201000000002'
      },
      {
        name: 'Ahmed Trainer',
        email: 'trainer@vitafit.com',
        password: hashedPassword,
        role: 'trainer',
        is_verified: true,
        phone: '+201000000003'
      },
      {
        name: 'Mohamed User',
        email: 'user@vitafit.com',
        password: hashedPassword,
        role: 'user',
        is_verified: true,
        phone: '+201000000004',
        gender: 'male',
        height: 175,
        weight: 80,
        goal: 'build_muscle',
        activity_level: 'active'
      },
      {
        name: 'Sara User',
        email: 'sara@vitafit.com',
        password: hashedPassword,
        role: 'user',
        is_verified: true,
        phone: '+201000000005',
        gender: 'female',
        height: 165,
        weight: 60,
        goal: 'maintain',
        activity_level: 'moderate'
      }
    ]);
    console.log('Users seeded: ' + users.length);

    // ============== SEED TRAINERS ==============
    const trainers = await Trainer.bulkCreate([
      {
        user_id: users[2].id,
        specialization: 'Weight Training, HIIT',
        experience_years: 5,
        bio: 'Certified personal trainer with 5 years of experience in weight training and HIIT workouts.',
        bio_ar: 'مدرب شخصي معتمد مع 5 سنوات من الخبرة في تدريب الأوزان وتمارين HIIT.',
        certifications: JSON.stringify(['NASM-CPT', 'CrossFit L1']),
        hourly_rate: 200,
        rating: 4.8,
        reviews_count: 25,
        clients_count: 15,
        is_available: true
      }
    ]);
    console.log('Trainers seeded: ' + trainers.length);

    // ============== SEED CATEGORIES ==============
    const categories = await Category.bulkCreate([
      {
        name: 'Supplements',
        name_ar: 'المكملات الغذائية',
        slug: 'supplements',
        description: 'Protein powders, vitamins, and fitness supplements',
        is_active: true,
        sort_order: 1
      },
      {
        name: 'Equipment',
        name_ar: 'المعدات الرياضية',
        slug: 'equipment',
        description: 'Gym equipment and fitness accessories',
        is_active: true,
        sort_order: 2
      },
      {
        name: 'Apparel',
        name_ar: 'الملابس الرياضية',
        slug: 'apparel',
        description: 'Workout clothes and sportswear',
        is_active: true,
        sort_order: 3
      },
      {
        name: 'Accessories',
        name_ar: 'الإكسسوارات',
        slug: 'accessories',
        description: 'Water bottles, bags, and gym accessories',
        is_active: true,
        sort_order: 4
      }
    ]);
    console.log('Categories seeded: ' + categories.length);

    // Add subcategories
    const subcategories = await Category.bulkCreate([
      { name: 'Protein', name_ar: 'البروتين', slug: 'protein', parent_id: categories[0].id, is_active: true },
      { name: 'Creatine', name_ar: 'الكرياتين', slug: 'creatine', parent_id: categories[0].id, is_active: true },
      { name: 'Pre-Workout', name_ar: 'ما قبل التمرين', slug: 'pre-workout', parent_id: categories[0].id, is_active: true },
      { name: 'Vitamins', name_ar: 'الفيتامينات', slug: 'vitamins', parent_id: categories[0].id, is_active: true },
      { name: 'Dumbbells', name_ar: 'الدمبلز', slug: 'dumbbells', parent_id: categories[1].id, is_active: true },
      { name: 'Resistance Bands', name_ar: 'أحزمة المقاومة', slug: 'resistance-bands', parent_id: categories[1].id, is_active: true }
    ]);
    console.log('Subcategories seeded: ' + subcategories.length);

    // ============== SEED PRODUCTS ==============
    const products = await Product.bulkCreate([
      {
        name: 'Whey Protein Isolate 2.5kg',
        name_ar: 'واي بروتين أيزوليت 2.5 كيلو',
        slug: 'whey-protein-isolate-2-5kg',
        description: 'Premium whey protein isolate for muscle building and recovery.',
        description_ar: 'واي بروتين أيزوليت ممتاز لبناء العضلات والتعافي.',
        price: 1500,
        sale_price: 1350,
        cost_price: 900,
        sku: 'WPI-001',
        quantity: 50,
        low_stock_threshold: 10,
        category_id: subcategories[0].id,
        brand: 'VitaFit',
        is_active: true,
        is_featured: true,
        rating: 4.5,
        reviews_count: 120
      },
      {
        name: 'Creatine Monohydrate 500g',
        name_ar: 'كرياتين مونوهيدرات 500 جرام',
        slug: 'creatine-monohydrate-500g',
        description: 'Pure creatine monohydrate for strength and power.',
        description_ar: 'كرياتين مونوهيدرات نقي للقوة والطاقة.',
        price: 350,
        cost_price: 200,
        sku: 'CRE-001',
        quantity: 100,
        low_stock_threshold: 15,
        category_id: subcategories[1].id,
        brand: 'VitaFit',
        is_active: true,
        is_featured: true,
        rating: 4.8,
        reviews_count: 85
      },
      {
        name: 'Pre-Workout Energy 300g',
        name_ar: 'بري وركاوت للطاقة 300 جرام',
        slug: 'pre-workout-energy-300g',
        description: 'High-intensity pre-workout formula for explosive workouts.',
        description_ar: 'تركيبة ما قبل التمرين عالية الكثافة للتمارين المكثفة.',
        price: 450,
        sale_price: 399,
        cost_price: 250,
        sku: 'PRE-001',
        quantity: 75,
        low_stock_threshold: 10,
        category_id: subcategories[2].id,
        brand: 'VitaFit',
        is_active: true,
        is_featured: false,
        rating: 4.3,
        reviews_count: 45
      },
      {
        name: 'Adjustable Dumbbells Set',
        name_ar: 'طقم دمبلز قابل للتعديل',
        slug: 'adjustable-dumbbells-set',
        description: 'Adjustable dumbbells set from 2.5kg to 25kg.',
        description_ar: 'طقم دمبلز قابل للتعديل من 2.5 كيلو إلى 25 كيلو.',
        price: 2500,
        sale_price: 2200,
        cost_price: 1500,
        sku: 'DUM-001',
        quantity: 20,
        low_stock_threshold: 5,
        category_id: subcategories[4].id,
        brand: 'FitPro',
        is_active: true,
        is_featured: true,
        rating: 4.7,
        reviews_count: 30
      },
      {
        name: 'Resistance Bands Set (5 Levels)',
        name_ar: 'طقم أحزمة المقاومة (5 مستويات)',
        slug: 'resistance-bands-set-5-levels',
        description: 'Set of 5 resistance bands with different levels for all exercises.',
        description_ar: 'طقم من 5 أحزمة مقاومة بمستويات مختلفة لجميع التمارين.',
        price: 250,
        cost_price: 120,
        sku: 'RES-001',
        quantity: 150,
        low_stock_threshold: 20,
        category_id: subcategories[5].id,
        brand: 'FlexBand',
        is_active: true,
        is_featured: false,
        rating: 4.4,
        reviews_count: 65
      },
      {
        name: 'Multivitamin Complex 60 Tabs',
        name_ar: 'فيتامينات متعددة 60 قرص',
        slug: 'multivitamin-complex-60-tabs',
        description: 'Complete multivitamin formula for athletes.',
        description_ar: 'تركيبة فيتامينات متكاملة للرياضيين.',
        price: 180,
        cost_price: 90,
        sku: 'VIT-001',
        quantity: 200,
        low_stock_threshold: 30,
        category_id: subcategories[3].id,
        brand: 'VitaFit',
        is_active: true,
        is_featured: false,
        rating: 4.6,
        reviews_count: 95
      }
    ]);
    console.log('Products seeded: ' + products.length);

    // ============== SEED SUBSCRIPTION PLANS ==============
    const plans = await SubscriptionPlan.bulkCreate([
      {
        name: 'Basic Plan',
        name_ar: 'الخطة الأساسية',
        description: 'Access to basic workout videos and meal plans',
        description_ar: 'الوصول إلى فيديوهات التمارين الأساسية وخطط الوجبات',
        price: 99,
        duration_days: 30,
        features: JSON.stringify(['Basic workout videos', 'Meal plan access', 'Progress tracking']),
        is_active: true,
        is_featured: false,
        sort_order: 1
      },
      {
        name: 'Premium Plan',
        name_ar: 'الخطة المميزة',
        description: 'Full access to all features including trainer support',
        description_ar: 'وصول كامل لجميع الميزات بما في ذلك دعم المدرب',
        price: 199,
        duration_days: 30,
        features: JSON.stringify(['All workout videos', 'Custom meal plans', 'Trainer chat support', 'Progress analytics', 'Premium content']),
        is_active: true,
        is_featured: true,
        sort_order: 2
      },
      {
        name: 'Annual Premium',
        name_ar: 'الخطة السنوية المميزة',
        description: 'Best value! Full access for a year with personal trainer',
        description_ar: 'أفضل قيمة! وصول كامل لمدة سنة مع مدرب شخصي',
        price: 1999,
        duration_days: 365,
        features: JSON.stringify(['All premium features', 'Personal trainer sessions', '1-on-1 consultations', 'Priority support', 'Exclusive workshops']),
        is_active: true,
        is_featured: true,
        sort_order: 3
      }
    ]);
    console.log('Subscription Plans seeded: ' + plans.length);

    // ============== SEED WORKOUTS ==============
    const workouts = await Workout.bulkCreate([
      {
        name: 'Full Body HIIT',
        name_ar: 'تمرين HIIT للجسم كامل',
        description: 'High-intensity interval training for full body fat burn.',
        description_ar: 'تمارين متقطعة عالية الكثافة لحرق دهون الجسم بالكامل.',
        type: 'hiit',
        difficulty: 'intermediate',
        duration_minutes: 30,
        calories_burn: 400,
        exercises: JSON.stringify([
          { name: 'Jumping Jacks', reps: 30, sets: 3 },
          { name: 'Burpees', reps: 10, sets: 3 },
          { name: 'Mountain Climbers', reps: 20, sets: 3 },
          { name: 'Squat Jumps', reps: 15, sets: 3 }
        ]),
        target_muscles: JSON.stringify(['Full Body', 'Core', 'Legs']),
        trainer_id: trainers[0].id,
        is_premium: false,
        is_active: true
      },
      {
        name: 'Upper Body Strength',
        name_ar: 'تمرين قوة الجزء العلوي',
        description: 'Build upper body strength with this dumbbell workout.',
        description_ar: 'بناء قوة الجزء العلوي من الجسم بتمرين الدمبلز.',
        type: 'strength',
        difficulty: 'beginner',
        duration_minutes: 45,
        calories_burn: 300,
        exercises: JSON.stringify([
          { name: 'Dumbbell Press', reps: 12, sets: 4 },
          { name: 'Bent Over Rows', reps: 12, sets: 4 },
          { name: 'Shoulder Press', reps: 10, sets: 3 },
          { name: 'Bicep Curls', reps: 15, sets: 3 },
          { name: 'Tricep Extensions', reps: 12, sets: 3 }
        ]),
        target_muscles: JSON.stringify(['Chest', 'Back', 'Shoulders', 'Arms']),
        equipment: JSON.stringify(['Dumbbells', 'Bench']),
        trainer_id: trainers[0].id,
        is_premium: false,
        is_active: true
      },
      {
        name: 'Core & Abs Blast',
        name_ar: 'تمرين البطن والمركز',
        description: 'Intense core workout for defined abs.',
        description_ar: 'تمرين مكثف للمركز للحصول على عضلات بطن محددة.',
        type: 'strength',
        difficulty: 'advanced',
        duration_minutes: 25,
        calories_burn: 250,
        exercises: JSON.stringify([
          { name: 'Plank', duration: '60 seconds', sets: 3 },
          { name: 'Crunches', reps: 25, sets: 4 },
          { name: 'Leg Raises', reps: 15, sets: 4 },
          { name: 'Russian Twists', reps: 30, sets: 3 },
          { name: 'Bicycle Crunches', reps: 20, sets: 3 }
        ]),
        target_muscles: JSON.stringify(['Abs', 'Obliques', 'Core']),
        trainer_id: trainers[0].id,
        is_premium: true,
        is_active: true
      },
      {
        name: 'Leg Day Power',
        name_ar: 'يوم الأرجل القوي',
        description: 'Complete lower body workout for strong legs.',
        description_ar: 'تمرين كامل للجزء السفلي لأرجل قوية.',
        type: 'strength',
        difficulty: 'intermediate',
        duration_minutes: 50,
        calories_burn: 450,
        exercises: JSON.stringify([
          { name: 'Squats', reps: 15, sets: 4 },
          { name: 'Lunges', reps: 12, sets: 4 },
          { name: 'Leg Press', reps: 12, sets: 4 },
          { name: 'Calf Raises', reps: 20, sets: 4 },
          { name: 'Leg Curls', reps: 12, sets: 3 }
        ]),
        target_muscles: JSON.stringify(['Quadriceps', 'Hamstrings', 'Glutes', 'Calves']),
        equipment: JSON.stringify(['Barbell', 'Leg Press Machine']),
        trainer_id: trainers[0].id,
        is_premium: true,
        is_active: true
      }
    ]);
    console.log('Workouts seeded: ' + workouts.length);

    // ============== SEED MEALS ==============
    const meals = await Meal.bulkCreate([
      {
        name: 'High Protein Breakfast Bowl',
        name_ar: 'وجبة إفطار عالية البروتين',
        description: 'Protein-packed breakfast with eggs and oats.',
        description_ar: 'إفطار غني بالبروتين مع البيض والشوفان.',
        type: 'breakfast',
        calories: 450,
        protein: 35,
        carbs: 40,
        fat: 15,
        fiber: 6,
        ingredients: JSON.stringify(['3 eggs', '50g oats', '100ml milk', '1 banana', '20g almonds']),
        instructions: 'Cook oats with milk. Scramble eggs separately. Serve together with sliced banana and almonds.',
        instructions_ar: 'اطبخ الشوفان مع الحليب. اخفق البيض بشكل منفصل. قدم مع الموز المقطع واللوز.',
        prep_time: 5,
        cook_time: 15,
        servings: 1,
        is_vegetarian: true,
        is_active: true
      },
      {
        name: 'Grilled Chicken Salad',
        name_ar: 'سلطة الدجاج المشوي',
        description: 'Fresh salad with grilled chicken breast.',
        description_ar: 'سلطة طازجة مع صدر دجاج مشوي.',
        type: 'lunch',
        calories: 380,
        protein: 40,
        carbs: 20,
        fat: 12,
        fiber: 8,
        ingredients: JSON.stringify(['200g chicken breast', 'Mixed greens', 'Cherry tomatoes', 'Cucumber', 'Olive oil dressing']),
        instructions: 'Grill chicken breast until cooked. Slice and serve over fresh salad with olive oil dressing.',
        instructions_ar: 'اشوِ صدر الدجاج حتى ينضج. قطعه وقدمه فوق السلطة الطازجة مع صلصة زيت الزيتون.',
        prep_time: 10,
        cook_time: 20,
        servings: 1,
        is_gluten_free: true,
        is_active: true
      },
      {
        name: 'Salmon with Vegetables',
        name_ar: 'سلمون مع الخضار',
        description: 'Baked salmon with roasted vegetables.',
        description_ar: 'سلمون مخبوز مع خضار محمصة.',
        type: 'dinner',
        calories: 520,
        protein: 45,
        carbs: 25,
        fat: 25,
        fiber: 7,
        ingredients: JSON.stringify(['200g salmon fillet', 'Broccoli', 'Sweet potato', 'Asparagus', 'Lemon', 'Olive oil']),
        instructions: 'Season salmon with lemon and herbs. Bake at 200°C for 20 minutes. Roast vegetables alongside.',
        instructions_ar: 'تبّل السلمون بالليمون والأعشاب. اخبزه على 200 درجة لمدة 20 دقيقة. حمّص الخضار بجانبه.',
        prep_time: 15,
        cook_time: 25,
        servings: 1,
        is_gluten_free: true,
        is_premium: true,
        is_active: true
      },
      {
        name: 'Protein Shake',
        name_ar: 'شيك البروتين',
        description: 'Quick and easy post-workout protein shake.',
        description_ar: 'شيك بروتين سريع وسهل بعد التمرين.',
        type: 'snack',
        calories: 280,
        protein: 30,
        carbs: 25,
        fat: 5,
        fiber: 3,
        ingredients: JSON.stringify(['1 scoop whey protein', '1 banana', '200ml almond milk', '1 tbsp peanut butter']),
        instructions: 'Blend all ingredients until smooth. Serve immediately.',
        instructions_ar: 'اخلط جميع المكونات حتى تصبح ناعمة. قدم فوراً.',
        prep_time: 5,
        cook_time: 0,
        servings: 1,
        is_vegetarian: true,
        is_gluten_free: true,
        is_active: true
      }
    ]);
    console.log('Meals seeded: ' + meals.length);

    // ============== SEED COUPONS ==============
    const coupons = await Coupon.bulkCreate([
      {
        code: 'WELCOME10',
        type: 'percentage',
        value: 10,
        min_order: 100,
        max_discount: 100,
        usage_limit: 1000,
        used_count: 0,
        start_date: new Date(),
        end_date: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
        is_active: true
      },
      {
        code: 'NEWYEAR25',
        type: 'percentage',
        value: 25,
        min_order: 500,
        max_discount: 250,
        usage_limit: 500,
        used_count: 0,
        start_date: new Date(),
        end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        is_active: true
      },
      {
        code: 'FLAT50',
        type: 'fixed',
        value: 50,
        min_order: 300,
        usage_limit: 200,
        used_count: 0,
        start_date: new Date(),
        end_date: new Date(Date.now() + 60 * 24 * 60 * 60 * 1000),
        is_active: true
      }
    ]);
    console.log('Coupons seeded: ' + coupons.length);

    // ============== SEED SETTINGS ==============
    const settings = await Setting.bulkCreate([
      { key: 'app_name', value: 'VitaFit', type: 'string', group: 'general' },
      { key: 'app_name_ar', value: 'فيتافيت', type: 'string', group: 'general' },
      { key: 'currency', value: 'EGP', type: 'string', group: 'general' },
      { key: 'currency_symbol', value: 'ج.م', type: 'string', group: 'general' },
      { key: 'tax_rate', value: '14', type: 'number', group: 'payment' },
      { key: 'shipping_cost', value: '50', type: 'number', group: 'payment' },
      { key: 'free_shipping_threshold', value: '500', type: 'number', group: 'payment' },
      { key: 'contact_email', value: 'support@vitafit.com', type: 'string', group: 'contact' },
      { key: 'contact_phone', value: '+201000000000', type: 'string', group: 'contact' },
      { key: 'address', value: 'Cairo, Egypt', type: 'string', group: 'contact' },
      { key: 'facebook_url', value: 'https://facebook.com/vitafit', type: 'string', group: 'social' },
      { key: 'instagram_url', value: 'https://instagram.com/vitafit', type: 'string', group: 'social' },
      { key: 'maintenance_mode', value: 'false', type: 'boolean', group: 'system' }
    ]);
    console.log('Settings seeded: ' + settings.length);

    console.log('\n========================================');
    console.log('Database seeding completed successfully!');
    console.log('========================================');
    console.log('\nDefault accounts:');
    console.log('Super Admin: superadmin@vitafit.com / password123');
    console.log('Admin: admin@vitafit.com / password123');
    console.log('Trainer: trainer@vitafit.com / password123');
    console.log('User: user@vitafit.com / password123');
    console.log('========================================\n');

    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
};

seedDatabase();
