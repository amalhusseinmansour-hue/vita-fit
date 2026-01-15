<?php

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
                'success' => false,
                'message' => 'Unauthenticated',
            ], 401);
        }

        // Check if the user type matches
        $userClass = get_class($user);
        $expectedClass = match ($type) {
            'trainee' => 'App\\Models\\Trainee',
            'trainer' => 'App\\Models\\Trainer',
            default => null,
        };

        if ($userClass !== $expectedClass) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        return $next($request);
    }
}
