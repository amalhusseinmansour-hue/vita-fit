<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Trainee;
use App\Models\Trainer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    /**
     * Register a new trainee
     */
    public function traineeRegister(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:trainees,email',
            'password' => 'required|string|min:6|confirmed',
            'phone' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $trainee = Trainee::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phone' => $request->phone,
            'status' => 'active',
        ]);

        $token = $trainee->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registration successful',
            'user' => [
                'id' => $trainee->id,
                'name' => $trainee->name,
                'email' => $trainee->email,
                'phone' => $trainee->phone,
                'type' => 'trainee',
            ],
            'token' => $token,
        ], 201);
    }

    /**
     * Login trainee
     */
    public function traineeLogin(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $trainee = Trainee::where('email', $request->email)->first();

        if (!$trainee || !Hash::check($request->password, $trainee->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials',
            ], 401);
        }

        if ($trainee->status !== 'active') {
            return response()->json([
                'success' => false,
                'message' => 'Account is not active',
            ], 403);
        }

        $token = $trainee->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'user' => [
                'id' => $trainee->id,
                'name' => $trainee->name,
                'email' => $trainee->email,
                'phone' => $trainee->phone,
                'avatar' => $trainee->avatar,
                'type' => 'trainee',
                'has_trainer' => $trainee->trainer_id !== null,
            ],
            'token' => $token,
        ]);
    }

    /**
     * Login trainer
     */
    public function trainerLogin(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $trainer = Trainer::where('email', $request->email)->first();

        if (!$trainer || !Hash::check($request->password, $trainer->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials',
            ], 401);
        }

        if ($trainer->status !== 'active') {
            return response()->json([
                'success' => false,
                'message' => 'Account is not active',
            ], 403);
        }

        $token = $trainer->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'user' => [
                'id' => $trainer->id,
                'name' => $trainer->name,
                'email' => $trainer->email,
                'phone' => $trainer->phone,
                'avatar' => $trainer->avatar,
                'specialization' => $trainer->specialization,
                'type' => 'trainer',
                'trainees_count' => $trainer->trainees()->count(),
            ],
            'token' => $token,
        ]);
    }

    /**
     * Login admin (using Filament admin)
     */
    public function adminLogin(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        // Check if using User model for admin
        $admin = \App\Models\User::where('email', $request->email)->first();

        if (!$admin || !Hash::check($request->password, $admin->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials',
            ], 401);
        }

        $token = $admin->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'user' => [
                'id' => $admin->id,
                'name' => $admin->name,
                'email' => $admin->email,
                'type' => 'admin',
            ],
            'token' => $token,
        ]);
    }

    /**
     * Logout
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ]);
    }

    /**
     * Update FCM token
     */
    public function updateFcmToken(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'fcm_token' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $request->user()->update(['fcm_token' => $request->fcm_token]);

        return response()->json([
            'success' => true,
            'message' => 'FCM token updated',
        ]);
    }

    /**
     * Forgot password - send OTP
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'type' => 'required|in:trainee,trainer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $model = $request->type === 'trainee' ? Trainee::class : Trainer::class;
        $user = $model::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email not found',
            ], 404);
        }

        // Generate OTP
        $otp = rand(100000, 999999);

        // Store OTP (you might want to use cache or database)
        cache()->put("otp_{$request->email}", $otp, now()->addMinutes(10));

        // TODO: Send OTP via email or SMS

        return response()->json([
            'success' => true,
            'message' => 'OTP sent to your email',
        ]);
    }

    /**
     * Verify OTP
     */
    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'otp' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $storedOtp = cache()->get("otp_{$request->email}");

        if (!$storedOtp || $storedOtp != $request->otp) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid OTP',
            ], 400);
        }

        // Generate reset token
        $resetToken = bin2hex(random_bytes(32));
        cache()->put("reset_token_{$request->email}", $resetToken, now()->addMinutes(30));
        cache()->forget("otp_{$request->email}");

        return response()->json([
            'success' => true,
            'message' => 'OTP verified',
            'reset_token' => $resetToken,
        ]);
    }

    /**
     * Reset password
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'reset_token' => 'required|string',
            'password' => 'required|string|min:6|confirmed',
            'type' => 'required|in:trainee,trainer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $storedToken = cache()->get("reset_token_{$request->email}");

        if (!$storedToken || $storedToken !== $request->reset_token) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired reset token',
            ], 400);
        }

        $model = $request->type === 'trainee' ? Trainee::class : Trainer::class;
        $user = $model::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }

        $user->update(['password' => Hash::make($request->password)]);
        cache()->forget("reset_token_{$request->email}");

        return response()->json([
            'success' => true,
            'message' => 'Password reset successfully',
        ]);
    }
}
