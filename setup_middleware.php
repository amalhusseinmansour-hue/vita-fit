<?php
// Setup middleware - DELETE AFTER USE
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

header('Content-Type: application/json');

try {
    // Create CheckUserType middleware
    $middlewareContent = '<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckUserType
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, string $type): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                \'success\' => false,
                \'message\' => \'Unauthenticated\',
            ], 401);
        }

        // Check if the user type matches
        $userClass = get_class($user);
        $expectedClass = match ($type) {
            \'trainee\' => \'App\\\\Models\\\\Trainee\',
            \'trainer\' => \'App\\\\Models\\\\Trainer\',
            default => null,
        };

        if ($userClass !== $expectedClass) {
            return response()->json([
                \'success\' => false,
                \'message\' => \'Unauthorized access\',
            ], 403);
        }

        return $next($request);
    }
}
';

    $middlewarePath = base_path('app/Http/Middleware/CheckUserType.php');
    if (!is_dir(dirname($middlewarePath))) {
        mkdir(dirname($middlewarePath), 0755, true);
    }
    file_put_contents($middlewarePath, $middlewareContent);

    // Update bootstrap/app.php
    $bootstrapContent = '<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.\'/../routes/web.php\',
        api: __DIR__.\'/../routes/api.php\',
        commands: __DIR__.\'/../routes/console.php\',
        health: \'/up\',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->statefulApi();

        // Register custom middleware alias
        $middleware->alias([
            \'type\' => \\App\\Http\\Middleware\\CheckUserType::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
';

    $bootstrapPath = base_path('bootstrap/app.php');
    file_put_contents($bootstrapPath, $bootstrapContent);

    echo json_encode([
        'success' => true,
        'message' => 'Middleware created and registered',
        'middleware_path' => $middlewarePath,
        'bootstrap_path' => $bootstrapPath
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
