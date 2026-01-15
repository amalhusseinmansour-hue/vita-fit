<?php
/**
 * Setup script for trainer requests API
 * Upload this file to /var/www/gym/ and run: php setup_trainer_requests.php
 */

require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

echo "=== Setting up Trainer Requests System ===\n\n";

// 1. Create trainer_requests table if not exists
if (!Schema::hasTable('trainer_requests')) {
    Schema::create('trainer_requests', function ($table) {
        $table->id();
        $table->unsignedBigInteger('trainee_id');
        $table->unsignedBigInteger('trainer_id');
        $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
        $table->text('message')->nullable();
        $table->timestamp('responded_at')->nullable();
        $table->timestamps();

        $table->foreign('trainee_id')->references('id')->on('users')->onDelete('cascade');
        $table->foreign('trainer_id')->references('id')->on('users')->onDelete('cascade');
    });
    echo "✓ Created trainer_requests table\n";
} else {
    echo "- trainer_requests table already exists\n";
}

// 2. Create TrainerRequest model
$modelContent = '<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TrainerRequest extends Model
{
    protected $fillable = [
        \'trainee_id\',
        \'trainer_id\',
        \'status\',
        \'message\',
        \'responded_at\',
    ];

    protected $casts = [
        \'responded_at\' => \'datetime\',
    ];

    public function trainee()
    {
        return $this->belongsTo(User::class, \'trainee_id\');
    }

    public function trainer()
    {
        return $this->belongsTo(User::class, \'trainer_id\');
    }
}
';

file_put_contents(__DIR__.'/app/Models/TrainerRequest.php', $modelContent);
echo "✓ Created TrainerRequest model\n";

// 3. Create TrainerRequestController
$controllerContent = '<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TrainerRequest;
use App\Models\User;
use Illuminate\Http\Request;

class TrainerRequestController extends Controller
{
    // Trainee sends request to trainer
    public function store(Request $request)
    {
        $request->validate([
            \'trainer_id\' => \'required|exists:users,id\',
        ]);

        $user = $request->user();

        // Check if already has a pending request to this trainer
        $existing = TrainerRequest::where(\'trainee_id\', $user->id)
            ->where(\'trainer_id\', $request->trainer_id)
            ->where(\'status\', \'pending\')
            ->first();

        if ($existing) {
            return response()->json([
                \'success\' => false,
                \'message\' => \'لديك طلب معلق بالفعل لهذه المدربة\',
            ], 400);
        }

        $trainerRequest = TrainerRequest::create([
            \'trainee_id\' => $user->id,
            \'trainer_id\' => $request->trainer_id,
            \'status\' => \'pending\',
        ]);

        return response()->json([
            \'success\' => true,
            \'message\' => \'تم إرسال طلب الإضافة للمدربة بنجاح\',
            \'data\' => $trainerRequest,
        ]);
    }

    // Trainer gets pending requests
    public function getRequests(Request $request)
    {
        $user = $request->user();

        // Get trainer_id from trainer profile if exists
        $trainerId = $user->id;
        if ($user->trainer) {
            $trainerId = $user->trainer->id;
        }

        $requests = TrainerRequest::with([\'trainee:id,name,email,phone\'])
            ->where(\'trainer_id\', $trainerId)
            ->where(\'status\', \'pending\')
            ->orderBy(\'created_at\', \'desc\')
            ->get();

        return response()->json([
            \'success\' => true,
            \'data\' => $requests,
        ]);
    }

    // Trainer accepts/rejects request
    public function respond(Request $request, $id, $action)
    {
        $trainerRequest = TrainerRequest::findOrFail($id);

        if (!in_array($action, [\'accept\', \'reject\'])) {
            return response()->json([
                \'success\' => false,
                \'message\' => \'إجراء غير صالح\',
            ], 400);
        }

        $trainerRequest->status = $action === \'accept\' ? \'approved\' : \'rejected\';
        $trainerRequest->responded_at = now();
        $trainerRequest->save();

        // If accepted, update trainee\'s trainer_id
        if ($action === \'accept\') {
            $trainee = User::find($trainerRequest->trainee_id);
            if ($trainee) {
                $trainee->trainer_id = $trainerRequest->trainer_id;
                $trainee->save();
            }
        }

        return response()->json([
            \'success\' => true,
            \'message\' => $action === \'accept\' ? \'تم قبول المتدربة بنجاح\' : \'تم رفض الطلب\',
        ]);
    }
}
';

if (!is_dir(__DIR__.'/app/Http/Controllers/Api')) {
    mkdir(__DIR__.'/app/Http/Controllers/Api', 0755, true);
}
file_put_contents(__DIR__.'/app/Http/Controllers/Api/TrainerRequestController.php', $controllerContent);
echo "✓ Created TrainerRequestController\n";

// 4. Add routes to api.php
$routesFile = __DIR__.'/routes/api.php';
$routesContent = file_get_contents($routesFile);

if (strpos($routesContent, 'trainer-requests') === false) {
    $newRoutes = "

// Trainer Requests Routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/trainer-requests', [App\\Http\\Controllers\\Api\\TrainerRequestController::class, 'store']);
    Route::get('/trainer/requests', [App\\Http\\Controllers\\Api\\TrainerRequestController::class, 'getRequests']);
    Route::post('/trainer/requests/{id}/{action}', [App\\Http\\Controllers\\Api\\TrainerRequestController::class, 'respond']);
});
";
    file_put_contents($routesFile, $routesContent . $newRoutes);
    echo "✓ Added routes to api.php\n";
} else {
    echo "- Routes already exist in api.php\n";
}

echo "\n=== Setup Complete! ===\n";
echo "The trainer requests API is now ready.\n";
