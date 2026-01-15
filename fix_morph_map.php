<?php
// Temporary fix script - DELETE AFTER USE
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

header('Content-Type: application/json');

try {
    // Fix tokenable_type in personal_access_tokens table
    DB::table('personal_access_tokens')
        ->where('tokenable_type', 'trainee')
        ->update(['tokenable_type' => 'App\\Models\\Trainee']);

    DB::table('personal_access_tokens')
        ->where('tokenable_type', 'trainer')
        ->update(['tokenable_type' => 'App\\Models\\Trainer']);

    // Count updated rows
    $traineeTokens = DB::table('personal_access_tokens')
        ->where('tokenable_type', 'App\\Models\\Trainee')
        ->count();

    $trainerTokens = DB::table('personal_access_tokens')
        ->where('tokenable_type', 'App\\Models\\Trainer')
        ->count();

    echo json_encode([
        'success' => true,
        'message' => 'Morph types fixed',
        'trainee_tokens' => $traineeTokens,
        'trainer_tokens' => $trainerTokens
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
