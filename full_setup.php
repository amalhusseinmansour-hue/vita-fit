<?php
// Full Setup Script - DELETE AFTER USE
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');

$basePath = dirname(__DIR__);
$results = [];

try {
    // 1. Create CheckUserType Middleware
    $middlewareDir = $basePath . '/app/Http/Middleware';
    if (!is_dir($middlewareDir)) {
        mkdir($middlewareDir, 0755, true);
        $results[] = "Created middleware directory";
    }

    $middlewareContent = '<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckUserType
{
    public function handle(Request $request, Closure $next, string $type): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                \'success\' => false,
                \'message\' => \'Unauthenticated\',
            ], 401);
        }

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
    file_put_contents($middlewareDir . '/CheckUserType.php', $middlewareContent);
    $results[] = "Created CheckUserType middleware";

    // 2. Update bootstrap/app.php
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
        $middleware->alias([
            \'type\' => \App\Http\Middleware\CheckUserType::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
';
    file_put_contents($basePath . '/bootstrap/app.php', $bootstrapContent);
    $results[] = "Updated bootstrap/app.php";

    // 3. Update AppServiceProvider with morph map
    $providerContent = '<?php

namespace App\Providers;

use Illuminate\Database\Eloquent\Relations\Relation;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        Relation::morphMap([
            \'trainee\' => \'App\Models\Trainee\',
            \'trainer\' => \'App\Models\Trainer\',
        ]);
    }
}
';
    file_put_contents($basePath . '/app/Providers/AppServiceProvider.php', $providerContent);
    $results[] = "Updated AppServiceProvider";

    // 4. Clear config cache if artisan is available
    if (function_exists('opcache_reset')) {
        opcache_reset();
        $results[] = "OPCache cleared";
    }

    echo json_encode([
        'success' => true,
        'message' => 'Full setup completed',
        'results' => $results
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
}
