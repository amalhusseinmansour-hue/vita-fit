<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = App\Models\User::where('email', 'trainer@vitafit.com')->first();
if ($user) {
    $user->password = bcrypt('123456');
    $user->save();
    echo "Password updated successfully for: " . $user->email . "\n";
} else {
    echo "User not found\n";
}
