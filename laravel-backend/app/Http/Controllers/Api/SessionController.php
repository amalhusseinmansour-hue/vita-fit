<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TrainingSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Validator;

class SessionController extends Controller
{
    /**
     * Get user's sessions
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $userType = $user->getMorphClass();

        $query = TrainingSession::with(['trainer', 'trainee']);

        if ($userType === 'trainer') {
            $query->where('trainer_id', $user->id);
        } else {
            $query->where('trainee_id', $user->id);
        }

        $sessions = $query->orderBy('scheduled_at', 'desc')
            ->get()
            ->map(function ($session) {
                return [
                    'id' => $session->id,
                    'title' => $session->title,
                    'description' => $session->description,
                    'trainer' => [
                        'id' => $session->trainer->id,
                        'name' => $session->trainer->name,
                        'avatar' => $session->trainer->avatar,
                    ],
                    'trainee' => [
                        'id' => $session->trainee->id,
                        'name' => $session->trainee->name,
                        'avatar' => $session->trainee->avatar,
                    ],
                    'scheduled_at' => $session->scheduled_at->toIso8601String(),
                    'duration_minutes' => $session->duration_minutes,
                    'session_type' => $session->session_type,
                    'training_mode' => $session->training_mode,
                    'status' => $session->status,
                    'zoom_join_url' => $session->zoom_join_url,
                    'can_start' => $session->canStart(),
                ];
            });

        return response()->json([
            'success' => true,
            'sessions' => $sessions,
        ]);
    }

    /**
     * Get upcoming sessions
     */
    public function upcoming(Request $request)
    {
        $user = $request->user();
        $userType = $user->getMorphClass();

        $query = TrainingSession::with(['trainer', 'trainee'])
            ->where('scheduled_at', '>=', now())
            ->where('status', 'scheduled');

        if ($userType === 'trainer') {
            $query->where('trainer_id', $user->id);
        } else {
            $query->where('trainee_id', $user->id);
        }

        $sessions = $query->orderBy('scheduled_at')
            ->take(10)
            ->get()
            ->map(function ($session) {
                return [
                    'id' => $session->id,
                    'title' => $session->title,
                    'trainer_name' => $session->trainer->name,
                    'trainee_name' => $session->trainee->name,
                    'scheduled_at' => $session->scheduled_at->toIso8601String(),
                    'duration_minutes' => $session->duration_minutes,
                    'training_mode' => $session->training_mode,
                    'can_start' => $session->canStart(),
                ];
            });

        return response()->json([
            'success' => true,
            'sessions' => $sessions,
        ]);
    }

    /**
     * Create a new session
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'trainee_id' => 'required|exists:trainees,id',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'scheduled_at' => 'required|date|after:now',
            'duration_minutes' => 'required|integer|min:15|max:180',
            'session_type' => 'in:private,group',
            'training_mode' => 'in:online,gym,home',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $trainer = $request->user();

        $session = TrainingSession::create([
            'trainer_id' => $trainer->id,
            'trainee_id' => $request->trainee_id,
            'title' => $request->title,
            'description' => $request->description,
            'scheduled_at' => $request->scheduled_at,
            'duration_minutes' => $request->duration_minutes,
            'session_type' => $request->session_type ?? 'private',
            'training_mode' => $request->training_mode ?? 'online',
            'status' => 'scheduled',
        ]);

        // Create Zoom meeting if online session
        if ($session->training_mode === 'online') {
            $this->createZoomMeeting($session, $trainer);
        }

        return response()->json([
            'success' => true,
            'session' => $session->fresh(['trainer', 'trainee']),
        ], 201);
    }

    /**
     * Start a session
     */
    public function start(Request $request, $id)
    {
        $session = TrainingSession::findOrFail($id);

        if (!$session->canStart()) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot start this session yet',
            ], 400);
        }

        $session->start();

        return response()->json([
            'success' => true,
            'session' => [
                'id' => $session->id,
                'status' => $session->status,
                'started_at' => $session->started_at->toIso8601String(),
                'zoom_join_url' => $session->zoom_join_url,
                'zoom_start_url' => $session->zoom_start_url,
            ],
        ]);
    }

    /**
     * End a session
     */
    public function end(Request $request, $id)
    {
        $session = TrainingSession::findOrFail($id);

        if ($session->status !== 'in_progress') {
            return response()->json([
                'success' => false,
                'message' => 'Session is not in progress',
            ], 400);
        }

        $session->end();

        // Add trainer notes if provided
        if ($request->has('notes')) {
            $session->update(['trainer_notes' => $request->notes]);
        }

        return response()->json([
            'success' => true,
            'session' => [
                'id' => $session->id,
                'status' => $session->status,
                'ended_at' => $session->ended_at->toIso8601String(),
            ],
        ]);
    }

    /**
     * Cancel a session
     */
    public function cancel(Request $request, $id)
    {
        $session = TrainingSession::findOrFail($id);

        if (!in_array($session->status, ['scheduled', 'in_progress'])) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot cancel this session',
            ], 400);
        }

        $session->cancel($request->reason);

        // TODO: Send notification to the other party

        return response()->json([
            'success' => true,
            'message' => 'Session cancelled successfully',
        ]);
    }

    /**
     * Rate a completed session
     */
    public function rate(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'rating' => 'required|integer|min:1|max:5',
            'feedback' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $session = TrainingSession::findOrFail($id);

        if ($session->status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'Can only rate completed sessions',
            ], 400);
        }

        $session->update([
            'rating' => $request->rating,
            'trainee_feedback' => $request->feedback,
        ]);

        // Update trainer's overall rating
        $session->trainer->updateRating($request->rating);

        return response()->json([
            'success' => true,
            'message' => 'Rating submitted successfully',
        ]);
    }

    /**
     * Get session details
     */
    public function show($id)
    {
        $session = TrainingSession::with(['trainer', 'trainee'])->findOrFail($id);

        return response()->json([
            'success' => true,
            'session' => [
                'id' => $session->id,
                'title' => $session->title,
                'description' => $session->description,
                'trainer' => [
                    'id' => $session->trainer->id,
                    'name' => $session->trainer->name,
                    'avatar' => $session->trainer->avatar,
                    'specialization' => $session->trainer->specialization,
                ],
                'trainee' => [
                    'id' => $session->trainee->id,
                    'name' => $session->trainee->name,
                    'avatar' => $session->trainee->avatar,
                ],
                'scheduled_at' => $session->scheduled_at->toIso8601String(),
                'duration_minutes' => $session->duration_minutes,
                'session_type' => $session->session_type,
                'training_mode' => $session->training_mode,
                'status' => $session->status,
                'zoom_join_url' => $session->zoom_join_url,
                'zoom_meeting_id' => $session->zoom_meeting_id,
                'started_at' => $session->started_at?->toIso8601String(),
                'ended_at' => $session->ended_at?->toIso8601String(),
                'trainer_notes' => $session->trainer_notes,
                'rating' => $session->rating,
                'can_start' => $session->canStart(),
            ],
        ]);
    }

    /**
     * Create Zoom meeting for session
     */
    private function createZoomMeeting(TrainingSession $session, $trainer)
    {
        // Check if trainer has Zoom credentials
        if (!$trainer->zoom_account_id || !$trainer->zoom_client_id || !$trainer->zoom_client_secret) {
            return;
        }

        try {
            // Get Zoom access token
            $tokenResponse = Http::withBasicAuth($trainer->zoom_client_id, $trainer->zoom_client_secret)
                ->asForm()
                ->post('https://zoom.us/oauth/token', [
                    'grant_type' => 'account_credentials',
                    'account_id' => $trainer->zoom_account_id,
                ]);

            if (!$tokenResponse->successful()) {
                return;
            }

            $accessToken = $tokenResponse->json('access_token');

            // Create meeting
            $meetingResponse = Http::withToken($accessToken)
                ->post('https://api.zoom.us/v2/users/me/meetings', [
                    'topic' => $session->title,
                    'type' => 2, // Scheduled meeting
                    'start_time' => $session->scheduled_at->toIso8601String(),
                    'duration' => $session->duration_minutes,
                    'timezone' => 'Asia/Riyadh',
                    'settings' => [
                        'host_video' => true,
                        'participant_video' => true,
                        'join_before_host' => false,
                        'mute_upon_entry' => true,
                        'waiting_room' => true,
                    ],
                ]);

            if ($meetingResponse->successful()) {
                $meeting = $meetingResponse->json();
                $session->update([
                    'zoom_meeting_id' => $meeting['id'],
                    'zoom_password' => $meeting['password'] ?? null,
                    'zoom_join_url' => $meeting['join_url'],
                    'zoom_start_url' => $meeting['start_url'],
                ]);
            }
        } catch (\Exception $e) {
            \Log::error('Failed to create Zoom meeting: ' . $e->getMessage());
        }
    }
}
