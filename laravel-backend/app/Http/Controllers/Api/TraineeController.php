<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Trainee;
use App\Models\Trainer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class TraineeController extends Controller
{
    /**
     * Get trainee profile
     */
    public function profile(Request $request)
    {
        $trainee = $request->user();

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $trainee->id,
                'name' => $trainee->name,
                'email' => $trainee->email,
                'phone' => $trainee->phone,
                'avatar' => $trainee->avatar,
                'date_of_birth' => $trainee->date_of_birth,
                'gender' => $trainee->gender,
                'height' => $trainee->height,
                'weight' => $trainee->weight,
                'target_weight' => $trainee->target_weight,
                'activity_level' => $trainee->activity_level,
                'fitness_goal' => $trainee->fitness_goal,
                'health_conditions' => $trainee->health_conditions,
                'trainer_id' => $trainee->trainer_id,
                'subscription_status' => $trainee->subscription_status,
                'created_at' => $trainee->created_at,
            ],
        ]);
    }

    /**
     * Update trainee profile
     */
    public function updateProfile(Request $request)
    {
        $trainee = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:20',
            'date_of_birth' => 'sometimes|date',
            'gender' => 'sometimes|in:male,female',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $trainee->update($request->only(['name', 'phone', 'date_of_birth', 'gender']));

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => $trainee->fresh(),
        ]);
    }

    /**
     * Update avatar
     */
    public function updateAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'avatar' => 'required|image|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $trainee = $request->user();

        // Delete old avatar
        if ($trainee->avatar) {
            Storage::disk('public')->delete($trainee->avatar);
        }

        // Store new avatar
        $path = $request->file('avatar')->store('avatars/trainees', 'public');
        $trainee->update(['avatar' => $path]);

        return response()->json([
            'success' => true,
            'message' => 'Avatar updated successfully',
            'avatar' => Storage::url($path),
        ]);
    }

    /**
     * Update health info
     */
    public function updateHealthInfo(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'height' => 'sometimes|numeric|min:50|max:300',
            'weight' => 'sometimes|numeric|min:20|max:500',
            'target_weight' => 'sometimes|numeric|min:20|max:500',
            'health_conditions' => 'sometimes|array',
            'allergies' => 'sometimes|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $trainee = $request->user();
        $trainee->update($request->only([
            'height', 'weight', 'target_weight',
            'health_conditions', 'allergies'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Health info updated successfully',
        ]);
    }

    /**
     * Update measurements
     */
    public function updateMeasurements(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'weight' => 'sometimes|numeric',
            'body_fat' => 'sometimes|numeric',
            'muscle_mass' => 'sometimes|numeric',
            'chest' => 'sometimes|numeric',
            'waist' => 'sometimes|numeric',
            'hips' => 'sometimes|numeric',
            'arms' => 'sometimes|numeric',
            'thighs' => 'sometimes|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $trainee = $request->user();

        // Update current measurements
        $trainee->update($request->only([
            'weight', 'body_fat', 'muscle_mass',
            'chest', 'waist', 'hips', 'arms', 'thighs'
        ]));

        // Log measurement history
        $trainee->measurementHistory()->create([
            'weight' => $request->weight,
            'body_fat' => $request->body_fat,
            'measurements' => $request->only(['chest', 'waist', 'hips', 'arms', 'thighs']),
            'recorded_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Measurements updated successfully',
        ]);
    }

    /**
     * Get dashboard data
     */
    public function dashboard(Request $request)
    {
        $trainee = $request->user();

        $upcomingSessions = $trainee->sessions()
            ->where('scheduled_at', '>=', now())
            ->where('status', 'scheduled')
            ->with('trainer:id,name,avatar,specialization')
            ->orderBy('scheduled_at')
            ->limit(5)
            ->get();

        $trainer = $trainee->trainer;

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'name' => $trainee->name,
                    'avatar' => $trainee->avatar,
                    'subscription_status' => $trainee->subscription_status,
                ],
                'stats' => [
                    'total_sessions' => $trainee->sessions()->count(),
                    'completed_sessions' => $trainee->sessions()->where('status', 'completed')->count(),
                    'current_weight' => $trainee->weight,
                    'target_weight' => $trainee->target_weight,
                    'streak_days' => $trainee->streak_days ?? 0,
                ],
                'trainer' => $trainer ? [
                    'id' => $trainer->id,
                    'name' => $trainer->name,
                    'avatar' => $trainer->avatar,
                    'specialization' => $trainer->specialization,
                    'rating' => $trainer->rating,
                ] : null,
                'upcoming_sessions' => $upcomingSessions,
            ],
        ]);
    }

    /**
     * Get smart plan data
     */
    public function smartPlan(Request $request)
    {
        $trainee = $request->user();

        return response()->json([
            'success' => true,
            'data' => [
                'current_weight' => $trainee->weight,
                'target_weight' => $trainee->target_weight,
                'height' => $trainee->height,
                'activity_level' => $trainee->activity_level,
                'fitness_goal' => $trainee->fitness_goal,
                'daily_calories' => $trainee->daily_calories ?? 1800,
                'protein_goal' => $trainee->protein_goal ?? 100,
                'carbs_goal' => $trainee->carbs_goal ?? 200,
                'fat_goal' => $trainee->fat_goal ?? 60,
            ],
        ]);
    }

    /**
     * Get assigned trainer
     */
    public function getTrainer(Request $request)
    {
        $trainee = $request->user();
        $trainer = $trainee->trainer;

        if (!$trainer) {
            return response()->json([
                'success' => false,
                'message' => 'No trainer assigned',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $trainer->id,
                'name' => $trainer->name,
                'email' => $trainer->email,
                'phone' => $trainer->phone,
                'avatar' => $trainer->avatar,
                'specialization' => $trainer->specialization,
                'bio' => $trainer->bio,
                'experience_years' => $trainer->experience_years,
                'rating' => $trainer->rating,
                'total_reviews' => $trainer->total_reviews,
            ],
        ]);
    }

    /**
     * List all available trainers
     */
    public function listTrainers(Request $request)
    {
        $query = Trainer::where('status', 'active');

        // Filter by specialization
        if ($request->has('specialization')) {
            $query->where('specialization', $request->specialization);
        }

        // Filter by training type
        if ($request->has('training_type')) {
            $query->where('training_type', $request->training_type);
        }

        $trainers = $query->select([
            'id', 'name', 'avatar', 'specialization', 'bio',
            'experience_years', 'rating', 'total_reviews',
            'hourly_rate', 'training_type', 'max_trainees'
        ])
        ->withCount('trainees')
        ->orderBy('rating', 'desc')
        ->get()
        ->map(function ($trainer) {
            $trainer->available_slots = $trainer->max_trainees - $trainer->trainees_count;
            $trainer->is_available = $trainer->available_slots > 0;
            return $trainer;
        });

        return response()->json([
            'success' => true,
            'data' => $trainers,
        ]);
    }
}
