<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Trainer;
use App\Models\Trainee;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class TrainerController extends Controller
{
    /**
     * Get trainer profile
     */
    public function profile(Request $request)
    {
        $trainer = $request->user();

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
                'certifications' => $trainer->certifications,
                'hourly_rate' => $trainer->hourly_rate,
                'training_type' => $trainer->training_type,
                'max_trainees' => $trainer->max_trainees,
                'rating' => $trainer->rating,
                'total_reviews' => $trainer->total_reviews,
                'available_hours' => $trainer->available_hours,
                'trainees_count' => $trainer->trainees()->count(),
                'created_at' => $trainer->created_at,
            ],
        ]);
    }

    /**
     * Update trainer profile
     */
    public function updateProfile(Request $request)
    {
        $trainer = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:20',
            'bio' => 'sometimes|string|max:1000',
            'specialization' => 'sometimes|string|max:255',
            'experience_years' => 'sometimes|integer|min:0',
            'hourly_rate' => 'sometimes|numeric|min:0',
            'training_type' => 'sometimes|in:online,in_person,both',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $trainer->update($request->only([
            'name', 'phone', 'bio', 'specialization',
            'experience_years', 'hourly_rate', 'training_type'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => $trainer->fresh(),
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

        $trainer = $request->user();

        if ($trainer->avatar) {
            Storage::disk('public')->delete($trainer->avatar);
        }

        $path = $request->file('avatar')->store('avatars/trainers', 'public');
        $trainer->update(['avatar' => $path]);

        return response()->json([
            'success' => true,
            'message' => 'Avatar updated successfully',
            'avatar' => Storage::url($path),
        ]);
    }

    /**
     * Update availability
     */
    public function updateAvailability(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'available_hours' => 'required|array',
            'available_hours.*.day' => 'required|integer|between:0,6',
            'available_hours.*.start' => 'required|date_format:H:i',
            'available_hours.*.end' => 'required|date_format:H:i',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $trainer = $request->user();
        $trainer->update(['available_hours' => $request->available_hours]);

        return response()->json([
            'success' => true,
            'message' => 'Availability updated successfully',
        ]);
    }

    /**
     * Get dashboard data
     */
    public function dashboard(Request $request)
    {
        $trainer = $request->user();

        $todaySessions = $trainer->sessions()
            ->whereDate('scheduled_at', today())
            ->orderBy('scheduled_at')
            ->with('trainee:id,name,avatar')
            ->get();

        $upcomingSessions = $trainer->sessions()
            ->where('scheduled_at', '>=', now())
            ->where('status', 'scheduled')
            ->orderBy('scheduled_at')
            ->limit(5)
            ->with('trainee:id,name,avatar')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'stats' => [
                    'total_trainees' => $trainer->trainees()->count(),
                    'active_trainees' => $trainer->trainees()->where('status', 'active')->count(),
                    'total_sessions' => $trainer->sessions()->count(),
                    'completed_sessions' => $trainer->sessions()->where('status', 'completed')->count(),
                    'rating' => $trainer->rating,
                    'total_reviews' => $trainer->total_reviews,
                ],
                'today_sessions' => $todaySessions,
                'upcoming_sessions' => $upcomingSessions,
            ],
        ]);
    }

    /**
     * Get statistics
     */
    public function statistics(Request $request)
    {
        $trainer = $request->user();

        $thisMonth = now()->startOfMonth();
        $lastMonth = now()->subMonth()->startOfMonth();

        return response()->json([
            'success' => true,
            'data' => [
                'trainees' => [
                    'total' => $trainer->trainees()->count(),
                    'new_this_month' => $trainer->trainees()->where('created_at', '>=', $thisMonth)->count(),
                    'new_last_month' => $trainer->trainees()
                        ->whereBetween('created_at', [$lastMonth, $thisMonth])
                        ->count(),
                ],
                'sessions' => [
                    'total' => $trainer->sessions()->count(),
                    'this_month' => $trainer->sessions()->where('scheduled_at', '>=', $thisMonth)->count(),
                    'completed' => $trainer->sessions()->where('status', 'completed')->count(),
                    'cancelled' => $trainer->sessions()->where('status', 'cancelled')->count(),
                ],
                'rating' => [
                    'average' => $trainer->rating,
                    'total_reviews' => $trainer->total_reviews,
                ],
                'earnings' => [
                    'this_month' => $trainer->sessions()
                        ->where('scheduled_at', '>=', $thisMonth)
                        ->where('status', 'completed')
                        ->sum('price'),
                ],
            ],
        ]);
    }

    /**
     * Get all trainees
     */
    public function getTrainees(Request $request)
    {
        $trainer = $request->user();

        $trainees = $trainer->trainees()
            ->select(['id', 'name', 'email', 'phone', 'avatar', 'status', 'created_at'])
            ->withCount(['sessions', 'sessions as completed_sessions_count' => function ($query) {
                $query->where('status', 'completed');
            }])
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $trainees,
        ]);
    }

    /**
     * Get single trainee details
     */
    public function getTrainee(Request $request, $id)
    {
        $trainer = $request->user();

        $trainee = $trainer->trainees()->find($id);

        if (!$trainee) {
            return response()->json([
                'success' => false,
                'message' => 'Trainee not found',
            ], 404);
        }

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
                'fitness_goal' => $trainee->fitness_goal,
                'health_conditions' => $trainee->health_conditions,
                'notes' => $trainee->trainer_notes,
                'sessions_count' => $trainee->sessions()->count(),
                'completed_sessions' => $trainee->sessions()->where('status', 'completed')->count(),
                'created_at' => $trainee->created_at,
            ],
        ]);
    }

    /**
     * Update trainee notes
     */
    public function updateTraineeNotes(Request $request, $id)
    {
        $trainer = $request->user();

        $trainee = $trainer->trainees()->find($id);

        if (!$trainee) {
            return response()->json([
                'success' => false,
                'message' => 'Trainee not found',
            ], 404);
        }

        $trainee->update(['trainer_notes' => $request->notes]);

        return response()->json([
            'success' => true,
            'message' => 'Notes updated successfully',
        ]);
    }

    /**
     * Get session reports
     */
    public function sessionReports(Request $request)
    {
        $trainer = $request->user();

        $startDate = $request->get('start_date', now()->subMonth());
        $endDate = $request->get('end_date', now());

        $sessions = $trainer->sessions()
            ->whereBetween('scheduled_at', [$startDate, $endDate])
            ->with('trainee:id,name')
            ->orderBy('scheduled_at', 'desc')
            ->get()
            ->groupBy(function ($session) {
                return $session->scheduled_at->format('Y-m-d');
            });

        return response()->json([
            'success' => true,
            'data' => [
                'sessions' => $sessions,
                'summary' => [
                    'total' => $trainer->sessions()->whereBetween('scheduled_at', [$startDate, $endDate])->count(),
                    'completed' => $trainer->sessions()->whereBetween('scheduled_at', [$startDate, $endDate])->where('status', 'completed')->count(),
                    'cancelled' => $trainer->sessions()->whereBetween('scheduled_at', [$startDate, $endDate])->where('status', 'cancelled')->count(),
                ],
            ],
        ]);
    }

    /**
     * Get trainee reports
     */
    public function traineeReports(Request $request)
    {
        $trainer = $request->user();

        $trainees = $trainer->trainees()
            ->withCount(['sessions', 'sessions as completed_sessions_count' => function ($query) {
                $query->where('status', 'completed');
            }])
            ->get()
            ->map(function ($trainee) {
                return [
                    'id' => $trainee->id,
                    'name' => $trainee->name,
                    'avatar' => $trainee->avatar,
                    'total_sessions' => $trainee->sessions_count,
                    'completed_sessions' => $trainee->completed_sessions_count,
                    'completion_rate' => $trainee->sessions_count > 0
                        ? round(($trainee->completed_sessions_count / $trainee->sessions_count) * 100)
                        : 0,
                    'joined_at' => $trainee->created_at,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $trainees,
        ]);
    }
}
