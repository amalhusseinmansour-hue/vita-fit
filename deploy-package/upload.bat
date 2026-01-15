@echo off
echo ==========================================
echo    VitaFit Deployment Script
echo ==========================================
echo.

set SERVER=root@vitafit.online
set REMOTE_PATH=/home/user/public_html
set LOCAL_PATH=C:\Users\HP\Desktop\gym\laravel-backend

echo [1/5] Uploading Controllers...
scp "%LOCAL_PATH%\app\Http\Controllers\Api\PublicController.php" %SERVER%:%REMOTE_PATH%/app/Http/Controllers/Api/

echo [2/5] Uploading Models...
scp "%LOCAL_PATH%\app\Models\SubscriptionPlan.php" %SERVER%:%REMOTE_PATH%/app/Models/
scp "%LOCAL_PATH%\app\Models\User.php" %SERVER%:%REMOTE_PATH%/app/Models/
scp "%LOCAL_PATH%\app\Models\Subscription.php" %SERVER%:%REMOTE_PATH%/app/Models/

echo [3/5] Uploading Routes...
scp "%LOCAL_PATH%\routes\api.php" %SERVER%:%REMOTE_PATH%/routes/

echo [4/5] Uploading Migrations...
scp "%LOCAL_PATH%\database\migrations\2024_01_01_000000_create_users_table.php" %SERVER%:%REMOTE_PATH%/database/migrations/
scp "%LOCAL_PATH%\database\migrations\2024_01_01_000011_create_subscription_plans_table.php" %SERVER%:%REMOTE_PATH%/database/migrations/

echo [5/5] Uploading Seeders...
scp "%LOCAL_PATH%\database\seeders\DatabaseSeeder.php" %SERVER%:%REMOTE_PATH%/database/seeders/
scp "%LOCAL_PATH%\database\seeders\TrainerSeeder.php" %SERVER%:%REMOTE_PATH%/database/seeders/
scp "%LOCAL_PATH%\database\seeders\ProductSeeder.php" %SERVER%:%REMOTE_PATH%/database/seeders/
scp "%LOCAL_PATH%\database\seeders\SubscriptionPlanSeeder.php" %SERVER%:%REMOTE_PATH%/database/seeders/
scp "%LOCAL_PATH%\database\seeders\AdminSeeder.php" %SERVER%:%REMOTE_PATH%/database/seeders/

echo.
echo ==========================================
echo    Files uploaded successfully!
echo ==========================================
echo.
echo Now connect to server and run:
echo   ssh %SERVER%
echo   cd %REMOTE_PATH%
echo   php artisan migrate --force
echo   php artisan db:seed --force
echo.
pause
