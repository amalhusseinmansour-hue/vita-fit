<?php
/**
 * VitaFit Database Migrations
 *
 * Copy each migration to separate files in database/migrations/
 * with proper timestamps like: 2024_01_01_000001_create_trainees_table.php
 */

// ==================== TRAINEES TABLE ====================
// File: 2024_01_01_000001_create_trainees_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trainees', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('phone')->nullable();
            $table->string('password');
            $table->date('birth_date')->nullable();
            $table->integer('height')->nullable(); // cm
            $table->decimal('current_weight', 5, 2)->nullable(); // kg
            $table->decimal('target_weight', 5, 2)->nullable(); // kg
            $table->decimal('bmi', 5, 2)->nullable();
            $table->decimal('bmr', 8, 2)->nullable();
            $table->decimal('tdee', 8, 2)->nullable();
            $table->enum('activity_level', ['sedentary', 'light', 'moderate', 'active', 'very_active'])->default('moderate');
            $table->json('health_conditions')->nullable();
            $table->json('measurements')->nullable(); // waist, hips, chest, arm, thigh
            $table->string('avatar')->nullable();
            $table->enum('status', ['active', 'inactive', 'suspended'])->default('active');
            $table->foreignId('trainer_id')->nullable()->constrained('trainers');
            $table->rememberToken();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trainees');
    }
};

// ==================== TRAINERS TABLE ====================
// File: 2024_01_01_000002_create_trainers_table.php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trainers', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('phone')->nullable();
            $table->string('password');
            $table->string('specialization')->nullable();
            $table->text('bio')->nullable();
            $table->integer('experience_years')->default(0);
            $table->json('certifications')->nullable();
            $table->string('avatar')->nullable();
            $table->decimal('rating', 3, 2)->default(0);
            $table->integer('max_trainees')->default(20);
            $table->decimal('hourly_rate', 10, 2)->nullable();
            $table->json('available_times')->nullable();
            $table->enum('training_type', ['online', 'gym', 'home', 'all'])->default('all');
            $table->enum('status', ['active', 'inactive', 'on_leave'])->default('active');
            $table->rememberToken();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trainers');
    }
};

// ==================== SUBSCRIPTIONS TABLE ====================
// File: 2024_01_01_000003_create_subscriptions_table.php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trainee_id')->constrained()->onDelete('cascade');
            $table->foreignId('trainer_id')->nullable()->constrained();
            $table->string('plan_type'); // training, nutrition, training_nutrition, full, private, group
            $table->enum('duration_type', ['monthly', 'quarterly', 'semi_annual', 'annual']);
            $table->decimal('price', 10, 2);
            $table->decimal('discount', 5, 2)->default(0);
            $table->decimal('final_price', 10, 2);
            $table->date('start_date');
            $table->date('end_date');
            $table->enum('status', ['active', 'inactive', 'suspended', 'cancelled', 'expired'])->default('active');
            $table->string('payment_method')->nullable();
            $table->string('payment_id')->nullable();
            $table->json('features')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscriptions');
    }
};

// ==================== SESSIONS TABLE ====================
// File: 2024_01_01_000004_create_sessions_table.php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('training_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trainer_id')->constrained();
            $table->foreignId('trainee_id')->constrained();
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('session_type', ['private', 'group'])->default('private');
            $table->enum('training_mode', ['online', 'gym', 'home'])->default('online');
            $table->dateTime('scheduled_at');
            $table->integer('duration_minutes')->default(45);
            $table->integer('actual_duration')->nullable();
            $table->enum('status', ['scheduled', 'in_progress', 'completed', 'cancelled', 'no_show'])->default('scheduled');
            $table->string('zoom_meeting_id')->nullable();
            $table->string('zoom_password')->nullable();
            $table->string('zoom_join_url')->nullable();
            $table->string('zoom_host_url')->nullable();
            $table->text('notes')->nullable();
            $table->integer('rating')->nullable();
            $table->text('feedback')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('training_sessions');
    }
};

// ==================== CONVERSATIONS TABLE ====================
// File: 2024_01_01_000005_create_conversations_table.php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('conversations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trainer_id')->constrained();
            $table->foreignId('trainee_id')->constrained();
            $table->enum('type', ['direct', 'group'])->default('direct');
            $table->timestamp('last_message_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['trainer_id', 'trainee_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('conversations');
    }
};

// ==================== MESSAGES TABLE ====================
// File: 2024_01_01_000006_create_messages_table.php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conversation_id')->constrained()->onDelete('cascade');
            $table->string('sender_type'); // trainer, trainee
            $table->unsignedBigInteger('sender_id');
            $table->text('content');
            $table->enum('type', ['text', 'image', 'voice', 'file', 'video'])->default('text');
            $table->json('metadata')->nullable();
            $table->boolean('is_read')->default(false);
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};

// ==================== PRODUCTS TABLE ====================
// File: 2024_01_01_000007_create_products_table.php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->decimal('price', 10, 2);
            $table->decimal('discount', 5, 2)->default(0);
            $table->string('category'); // clothes, equipment, supplements, accessories, cards, gyms, care
            $table->json('images')->nullable();
            $table->json('sizes')->nullable();
            $table->json('colors')->nullable();
            $table->integer('stock')->default(0);
            $table->decimal('rating', 3, 2)->default(0);
            $table->integer('reviews_count')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};

// ==================== ORDERS TABLE ====================
// File: 2024_01_01_000008_create_orders_table.php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number')->unique();
            $table->foreignId('trainee_id')->constrained();
            $table->decimal('subtotal', 10, 2);
            $table->decimal('discount', 10, 2)->default(0);
            $table->decimal('shipping', 10, 2)->default(0);
            $table->decimal('total', 10, 2);
            $table->enum('status', ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'])->default('pending');
            $table->string('payment_method');
            $table->string('payment_id')->nullable();
            $table->enum('payment_status', ['pending', 'paid', 'failed', 'refunded'])->default('pending');
            $table->json('shipping_address');
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->onDelete('cascade');
            $table->foreignId('product_id')->constrained();
            $table->string('product_name');
            $table->decimal('price', 10, 2);
            $table->integer('quantity');
            $table->string('size')->nullable();
            $table->string('color')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('order_items');
        Schema::dropIfExists('orders');
    }
};

// ==================== SETTINGS TABLE ====================
// File: 2024_01_01_000009_create_settings_table.php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('settings', function (Blueprint $table) {
            $table->id();
            $table->string('group')->default('general');
            $table->string('key')->unique();
            $table->text('value')->nullable();
            $table->string('type')->default('string'); // string, boolean, integer, json
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('settings');
    }
};

// ==================== NOTIFICATIONS TABLE ====================
// File: 2024_01_01_000010_create_notifications_table.php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('app_notifications', function (Blueprint $table) {
            $table->id();
            $table->string('notifiable_type');
            $table->unsignedBigInteger('notifiable_id');
            $table->string('title');
            $table->text('body');
            $table->string('type')->default('general');
            $table->json('data')->nullable();
            $table->boolean('is_read')->default(false);
            $table->timestamp('read_at')->nullable();
            $table->timestamps();

            $table->index(['notifiable_type', 'notifiable_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('app_notifications');
    }
};
