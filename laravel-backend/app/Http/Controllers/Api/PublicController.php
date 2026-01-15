<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Trainer;
use App\Models\SubscriptionPlan;
use App\Models\TrainingSession;
use Illuminate\Http\Request;

class PublicController extends Controller
{
    /**
     * Get all active trainers
     */
    public function trainers(Request $request)
    {
        $query = Trainer::with('user')
            ->whereHas('user', function($q) {
                $q->where('is_active', true);
            });

        // Filter by specialization
        if ($request->has('specialization')) {
            $query->where('specialization', 'like', '%' . $request->specialization . '%');
        }

        $trainers = $query->get()
            ->map(function ($trainer) {
                return [
                    '_id' => (string) $trainer->id,
                    'id' => (string) $trainer->id,
                    'name' => $trainer->name,
                    'image' => $trainer->user->avatar ?? null,
                    'imageUrl' => $trainer->user->avatar ?? null,
                    'avatar' => $trainer->user->avatar ?? null,
                    'specialty' => $trainer->specialization,
                    'specialization' => $trainer->specialization,
                    'bio' => $trainer->bio_ar ?? $trainer->bio,
                    'description' => $trainer->bio_ar ?? $trainer->bio,
                    'experience' => $trainer->experience_years,
                    'yearsOfExperience' => $trainer->experience_years,
                    'rating' => (float) ($trainer->rating ?? 0),
                    'clients' => $trainer->clients_count ?? 0,
                    'reviewCount' => $trainer->reviews_count ?? 0,
                    'price' => (float) ($trainer->hourly_rate ?? 0),
                    'hourly_rate' => (float) ($trainer->hourly_rate ?? 0),
                    'certifications' => is_array($trainer->certifications) ? $trainer->certifications : json_decode($trainer->certifications ?? '[]', true),
                    'is_available' => $trainer->is_available ?? true,
                    'working_hours' => $trainer->working_hours,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $trainers,
        ]);
    }

    /**
     * Get single trainer
     */
    public function trainer($id)
    {
        $trainer = Trainer::with('user')->find($id);

        if (!$trainer || !$trainer->user || !$trainer->user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Trainer not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                '_id' => (string) $trainer->id,
                'id' => (string) $trainer->id,
                'name' => $trainer->name,
                'email' => $trainer->email,
                'phone' => $trainer->user->phone ?? null,
                'image' => $trainer->user->avatar ?? null,
                'avatar' => $trainer->user->avatar ?? null,
                'specialty' => $trainer->specialization,
                'specialization' => $trainer->specialization,
                'bio' => $trainer->bio_ar ?? $trainer->bio,
                'description' => $trainer->bio_ar ?? $trainer->bio,
                'experience' => $trainer->experience_years,
                'yearsOfExperience' => $trainer->experience_years,
                'certifications' => is_array($trainer->certifications) ? $trainer->certifications : json_decode($trainer->certifications ?? '[]', true),
                'rating' => (float) ($trainer->rating ?? 0),
                'reviewCount' => $trainer->reviews_count ?? 0,
                'price' => (float) ($trainer->hourly_rate ?? 0),
                'hourly_rate' => (float) ($trainer->hourly_rate ?? 0),
                'is_available' => $trainer->is_available ?? true,
                'working_hours' => $trainer->working_hours,
                'clients_count' => $trainer->clients_count ?? 0,
            ],
        ]);
    }

    /**
     * Get available classes/sessions
     */
    public function classes(Request $request)
    {
        try {
            $query = TrainingSession::where('status', 'scheduled')
                ->where('scheduled_at', '>=', now());

            $classes = $query->with('trainer.user')
                ->orderBy('scheduled_at')
                ->limit(20)
                ->get()
                ->map(function ($session) {
                    return [
                        '_id' => (string) $session->id,
                        'id' => (string) $session->id,
                        'title' => $session->title ?? 'جلسة تدريبية',
                        'description' => $session->description ?? '',
                        'instructor' => $session->trainer->name ?? '',
                        'trainer' => $session->trainer ? [
                            'id' => $session->trainer->id,
                            'name' => $session->trainer->name,
                            'avatar' => $session->trainer->user->avatar ?? null,
                        ] : null,
                        'date' => $session->scheduled_at ? $session->scheduled_at->toIso8601String() : null,
                        'time' => $session->scheduled_at ? $session->scheduled_at->format('H:i') : null,
                        'duration' => $session->duration_minutes ?? 60,
                        'type' => $session->session_type ?? 'private',
                        'location' => $session->training_mode ?? 'online',
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $classes,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => true,
                'data' => [],
            ]);
        }
    }

    /**
     * Get workshops
     */
    public function workshops(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => [],
        ]);
    }

    /**
     * Get subscription plans
     */
    public function subscriptionPlans(Request $request)
    {
        try {
            $plans = SubscriptionPlan::where('is_active', true)
                ->orderBy('sort_order')
                ->orderBy('price')
                ->get()
                ->map(function ($plan) {
                    return [
                        'id' => $plan->id,
                        'name' => $plan->name_ar ?? $plan->name,
                        'name_en' => $plan->name,
                        'description' => $plan->description_ar ?? $plan->description,
                        'description_en' => $plan->description,
                        'price' => (float) $plan->price,
                        'duration_days' => $plan->duration_days,
                        'features' => is_array($plan->features) ? $plan->features : json_decode($plan->features ?? '[]', true),
                        'is_featured' => $plan->is_featured ?? false,
                        'sort_order' => $plan->sort_order ?? 0,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $plans,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => true,
                'data' => [],
            ]);
        }
    }
}
