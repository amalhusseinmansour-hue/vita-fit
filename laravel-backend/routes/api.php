<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\SessionController;
use App\Http\Controllers\Api\TraineeController;
use App\Http\Controllers\Api\TrainerController;
use App\Http\Controllers\Api\SubscriptionController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\SettingController;
use App\Http\Controllers\Api\PublicController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes
Route::prefix('auth')->group(function () {
    // Trainee auth
    Route::post('/trainee/register', [AuthController::class, 'traineeRegister']);
    Route::post('/trainee/login', [AuthController::class, 'traineeLogin']);

    // Trainer auth
    Route::post('/trainer/login', [AuthController::class, 'trainerLogin']);

    // Admin auth
    Route::post('/admin/login', [AuthController::class, 'adminLogin']);

    // Common
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);
    Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
});

// App settings (public)
Route::get('/settings', [SettingController::class, 'index']);
Route::get('/settings/{group}', [SettingController::class, 'getByGroup']);

// Public data routes
Route::get('/trainers', [PublicController::class, 'trainers']);
Route::get('/trainers/{id}', [PublicController::class, 'trainer']);
Route::get('/classes', [PublicController::class, 'classes']);
Route::get('/workshops', [PublicController::class, 'workshops']);
Route::get('/subscription-plans', [PublicController::class, 'subscriptionPlans']);

// Products (public)
Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/categories', [ProductController::class, 'categories']);
Route::get('/products/featured', [ProductController::class, 'featured']);
Route::get('/products/{id}', [ProductController::class, 'show']);

// Protected routes - Trainee
Route::middleware(['auth:sanctum', 'type:trainee'])->prefix('trainee')->group(function () {
    // Profile
    Route::get('/profile', [TraineeController::class, 'profile']);
    Route::put('/profile', [TraineeController::class, 'updateProfile']);
    Route::post('/profile/avatar', [TraineeController::class, 'updateAvatar']);
    Route::put('/profile/health', [TraineeController::class, 'updateHealthInfo']);
    Route::put('/profile/measurements', [TraineeController::class, 'updateMeasurements']);

    // Dashboard
    Route::get('/dashboard', [TraineeController::class, 'dashboard']);
    Route::get('/smart-plan', [TraineeController::class, 'smartPlan']);

    // Trainer
    Route::get('/trainer', [TraineeController::class, 'getTrainer']);
    Route::get('/trainers', [TraineeController::class, 'listTrainers']);

    // Sessions
    Route::get('/sessions', [SessionController::class, 'index']);
    Route::get('/sessions/upcoming', [SessionController::class, 'upcoming']);
    Route::get('/sessions/{id}', [SessionController::class, 'show']);
    Route::post('/sessions/{id}/rate', [SessionController::class, 'rate']);

    // Chat
    Route::get('/conversations', [ChatController::class, 'getConversations']);
    Route::get('/conversations/{id}/messages', [ChatController::class, 'getMessages']);
    Route::post('/conversations', [ChatController::class, 'createConversation']);
    Route::post('/messages', [ChatController::class, 'sendMessage']);
    Route::post('/conversations/{id}/read', [ChatController::class, 'markAsRead']);

    // Subscriptions
    Route::get('/subscriptions', [SubscriptionController::class, 'index']);
    Route::get('/subscriptions/active', [SubscriptionController::class, 'active']);

    // Orders
    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/{id}', [OrderController::class, 'show']);

    // Logout
    Route::post('/logout', [AuthController::class, 'logout']);
});

// Protected routes - Trainer
Route::middleware(['auth:sanctum', 'type:trainer'])->prefix('trainer')->group(function () {
    // Profile
    Route::get('/profile', [TrainerController::class, 'profile']);
    Route::put('/profile', [TrainerController::class, 'updateProfile']);
    Route::post('/profile/avatar', [TrainerController::class, 'updateAvatar']);
    Route::put('/profile/availability', [TrainerController::class, 'updateAvailability']);

    // Dashboard
    Route::get('/dashboard', [TrainerController::class, 'dashboard']);
    Route::get('/statistics', [TrainerController::class, 'statistics']);

    // Trainees
    Route::get('/trainees', [TrainerController::class, 'getTrainees']);
    Route::get('/trainees/{id}', [TrainerController::class, 'getTrainee']);
    Route::put('/trainees/{id}/notes', [TrainerController::class, 'updateTraineeNotes']);

    // Sessions
    Route::get('/sessions', [SessionController::class, 'index']);
    Route::get('/sessions/upcoming', [SessionController::class, 'upcoming']);
    Route::get('/sessions/today', [SessionController::class, 'today']);
    Route::post('/sessions', [SessionController::class, 'store']);
    Route::get('/sessions/{id}', [SessionController::class, 'show']);
    Route::post('/sessions/{id}/start', [SessionController::class, 'start']);
    Route::post('/sessions/{id}/end', [SessionController::class, 'end']);
    Route::post('/sessions/{id}/cancel', [SessionController::class, 'cancel']);

    // Chat
    Route::get('/conversations', [ChatController::class, 'getConversations']);
    Route::get('/conversations/{id}/messages', [ChatController::class, 'getMessages']);
    Route::post('/conversations', [ChatController::class, 'createConversation']);
    Route::post('/messages', [ChatController::class, 'sendMessage']);
    Route::post('/conversations/{id}/read', [ChatController::class, 'markAsRead']);

    // Reports
    Route::get('/reports/sessions', [TrainerController::class, 'sessionReports']);
    Route::get('/reports/trainees', [TrainerController::class, 'traineeReports']);

    // Logout
    Route::post('/logout', [AuthController::class, 'logout']);
});

// FCM Token update (both user types)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/fcm-token', [AuthController::class, 'updateFcmToken']);
});
