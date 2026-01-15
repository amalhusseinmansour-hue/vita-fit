#!/bin/bash

# VitaFit Deployment Script
# Run this from the gym folder: C:\Users\HP\Desktop\gym

SERVER="root@vitafit.online"
REMOTE_PATH="/home/user/public_html"

echo "🚀 Starting deployment to vitafit.online..."

# Upload Controllers
echo "📁 Uploading Controllers..."
scp laravel-backend/app/Http/Controllers/Api/PublicController.php $SERVER:$REMOTE_PATH/app/Http/Controllers/Api/

# Upload Models
echo "📁 Uploading Models..."
scp laravel-backend/app/Models/SubscriptionPlan.php $SERVER:$REMOTE_PATH/app/Models/
scp laravel-backend/app/Models/User.php $SERVER:$REMOTE_PATH/app/Models/
scp laravel-backend/app/Models/Subscription.php $SERVER:$REMOTE_PATH/app/Models/

# Upload Routes
echo "📁 Uploading Routes..."
scp laravel-backend/routes/api.php $SERVER:$REMOTE_PATH/routes/

# Upload Migrations
echo "📁 Uploading Migrations..."
scp laravel-backend/database/migrations/2024_01_01_000000_create_users_table.php $SERVER:$REMOTE_PATH/database/migrations/
scp laravel-backend/database/migrations/2024_01_01_000011_create_subscription_plans_table.php $SERVER:$REMOTE_PATH/database/migrations/

# Upload Seeders
echo "📁 Uploading Seeders..."
scp laravel-backend/database/seeders/DatabaseSeeder.php $SERVER:$REMOTE_PATH/database/seeders/
scp laravel-backend/database/seeders/TrainerSeeder.php $SERVER:$REMOTE_PATH/database/seeders/
scp laravel-backend/database/seeders/ProductSeeder.php $SERVER:$REMOTE_PATH/database/seeders/
scp laravel-backend/database/seeders/SubscriptionPlanSeeder.php $SERVER:$REMOTE_PATH/database/seeders/
scp laravel-backend/database/seeders/AdminSeeder.php $SERVER:$REMOTE_PATH/database/seeders/

echo "✅ Files uploaded successfully!"
echo ""
echo "🔧 Now run these commands on the server:"
echo "ssh $SERVER"
echo "cd $REMOTE_PATH"
echo "php artisan config:clear && php artisan cache:clear && php artisan route:clear"
echo "php artisan migrate --force"
echo "php artisan db:seed --force"
echo "php artisan config:cache && php artisan route:cache"
