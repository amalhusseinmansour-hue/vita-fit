<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Trainee;
use App\Models\Trainer;
use App\Models\User;
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

        $user = User::where('email', $request->email)
                    ->where('role', 'trainer')
                    ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials',
            ], 401);
        }

        if (!$user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Account is not active',
            ], 403);
        }

        $trainer = Trainer::where('user_id', $user->id)->first();

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'user' => [
                'id' => $user->id,
                'trainer_id' => $trainer ? $trainer->id : null,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'avatar' => $user->avatar,
                'type' => 'trainer',
                'specialization' => $trainer ? $trainer->specialization : null,
                'experience_years' => $trainer ? $trainer->experience_years : null,
                'rating' => $trainer ? $trainer->rating : 0,
                'clients_count' => $trainer ? $trainer->clients_count : 0,
            ],
            'token' => $token,
        ]);
    }

    /**
     * Update FCM token for push notifications
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

        $user = $request->user();

        // Check if user is a Trainee
        if ($user instanceof Trainee) {
            $user->fcm_token = $request->fcm_token;
            $user->save();
        } elseif ($user instanceof User) {
            // For trainers/admins stored in users table
            $user->fcm_token = $request->fcm_token;
            $user->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'FCM token updated successfully',
        ]);
    }

    /**
     * Logout user
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
     * Get current user profile
     */
    public function profile(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'user' => $user,
        ]);
    }

    /**
     * Forgot password - send OTP
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        // Check in trainees first
        $trainee = Trainee::where('email', $request->email)->first();
        if ($trainee) {
            // Generate OTP
            $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
            $trainee->reset_otp = $otp;
            $trainee->reset_otp_expires_at = now()->addMinutes(15);
            $trainee->save();

            // In production, send email here
            // Mail::to($trainee->email)->send(new ResetPasswordOtp($otp));

            return response()->json([
                'success' => true,
                'message' => 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
                'email' => $request->email,
                // Remove this in production - for testing only
                'otp_for_testing' => $otp,
            ]);
        }

        // Check in users (trainers)
        $user = User::where('email', $request->email)->first();
        if ($user) {
            $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
            $user->reset_otp = $otp;
            $user->reset_otp_expires_at = now()->addMinutes(15);
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
                'email' => $request->email,
                'otp_for_testing' => $otp,
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'البريد الإلكتروني غير مسجل',
        ], 404);
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

        // Check trainees
        $trainee = Trainee::where('email', $request->email)
            ->where('reset_otp', $request->otp)
            ->where('reset_otp_expires_at', '>', now())
            ->first();

        if ($trainee) {
            return response()->json([
                'success' => true,
                'message' => 'رمز التحقق صحيح',
                'reset_token' => base64_encode($request->email . ':' . $request->otp),
            ]);
        }

        // Check users
        $user = User::where('email', $request->email)
            ->where('reset_otp', $request->otp)
            ->where('reset_otp_expires_at', '>', now())
            ->first();

        if ($user) {
            return response()->json([
                'success' => true,
                'message' => 'رمز التحقق صحيح',
                'reset_token' => base64_encode($request->email . ':' . $request->otp),
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'رمز التحقق غير صحيح أو منتهي الصلاحية',
        ], 400);
    }

    /**
     * Reset password
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'otp' => 'required|string|size:6',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        // Check trainees
        $trainee = Trainee::where('email', $request->email)
            ->where('reset_otp', $request->otp)
            ->where('reset_otp_expires_at', '>', now())
            ->first();

        if ($trainee) {
            $trainee->password = Hash::make($request->password);
            $trainee->reset_otp = null;
            $trainee->reset_otp_expires_at = null;
            $trainee->save();

            return response()->json([
                'success' => true,
                'message' => 'تم تغيير كلمة المرور بنجاح',
            ]);
        }

        // Check users
        $user = User::where('email', $request->email)
            ->where('reset_otp', $request->otp)
            ->where('reset_otp_expires_at', '>', now())
            ->first();

        if ($user) {
            $user->password = Hash::make($request->password);
            $user->reset_otp = null;
            $user->reset_otp_expires_at = null;
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'تم تغيير كلمة المرور بنجاح',
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'رمز التحقق غير صحيح أو منتهي الصلاحية',
        ], 400);
    }
}
