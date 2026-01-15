<?php
/**
 * Link trainee to trainer
 * Upload to /var/www/gym/ and access via browser: https://vitafit.online/link_trainee_to_trainer.php
 */

require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\DB;

echo "<pre>";
echo "=== Linking Trainees to Trainer ===\n\n";

// Find the trainer (user with type='trainer')
$trainer = User::where('email', 'trainer@vitafit.com')->first();

if (!$trainer) {
    echo "Trainer not found!\n";
    exit;
}

echo "Found trainer: {$trainer->name} (ID: {$trainer->id})\n";

// Find all trainees (users with type='trainee' or 'user')
$trainees = User::whereIn('type', ['trainee', 'user'])->get();

echo "Found " . $trainees->count() . " trainees\n\n";

// Link trainees to trainer
foreach ($trainees as $trainee) {
    $trainee->trainer_id = $trainer->id;
    $trainee->save();
    echo "✓ Linked {$trainee->name} ({$trainee->email}) to trainer\n";
}

echo "\n=== Done! ===\n";
echo "</pre>";
