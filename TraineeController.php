<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Trainer;
use Illuminate\Http\Request;

class TraineeController extends Controller
{
    public function profile(Request $request)
    {
        return response()->json(['success' => true, 'profile' => $request->user()]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();
        $user->update($request->only(['name', 'phone', 'birth_date']));
        return response()->json(['success' => true, 'profile' => $user->fresh()]);
    }

    public function updateAvatar(Request $request)
    {
        $path = $request->file('avatar')->store('avatars', 'public');
        $request->user()->update(['avatar' => $path]);
        return response()->json(['success' => true, 'avatar' => $path]);
    }

    public function updateHealthInfo(Request $request)
    {
        $user = $request->user();
        $user->update($request->only(['height', 'current_weight', 'target_weight', 'activity_level']));
        return response()->json(['success' => true, 'profile' => $user->fresh()]);
    }

    public function updateMeasurements(Request $request)
    {
        $request->user()->update(['measurements' => $request->measurements]);
        return response()->json(['success' => true]);
    }

    public function dashboard(Request $request)
    {
        $user = $request->user();
        return response()->json([
            'success' => true,
            'dashboard' => [
                'bmi' => $user->bmi,
                'bmr' => $user->bmr,
                'tdee' => $user->tdee,
            ]
        ]);
    }

    public function smartPlan(Request $request)
    {
        $user = $request->user();
        return response()->json([
            'success' => true,
            'plan' => [
                'bmi' => $user->bmi,
                'bmr' => $user->bmr,
                'tdee' => $user->tdee,
                'goal' => $user->fitness_goal,
            ]
        ]);
    }

    public function getTrainer(Request $request)
    {
        return response()->json(['success' => true, 'trainer' => $request->user()->trainer]);
    }

    public function listTrainers()
    {
        $trainers = Trainer::where('status', 'active')->get();
        return response()->json(['success' => true, 'trainers' => $trainers]);
    }

    public function saveSmartPlan(Request $request)
    {
        $user = $request->user();

        $updateData = [];

        if ($request->has('name')) $updateData['name'] = $request->name;
        if ($request->has('age')) $updateData['age'] = $request->age;
        if ($request->has('height')) $updateData['height'] = $request->height;
        if ($request->has('current_weight')) $updateData['current_weight'] = $request->current_weight;
        if ($request->has('target_weight')) $updateData['target_weight'] = $request->target_weight;
        if ($request->has('health_condition')) $updateData['health_condition'] = $request->health_condition;
        if ($request->has('previous_injuries')) $updateData['previous_injuries'] = $request->previous_injuries;
        if ($request->has('surgeries')) $updateData['surgeries'] = $request->surgeries;
        if ($request->has('medications')) $updateData['medications'] = $request->medications;
        if ($request->has('allergies')) $updateData['allergies'] = $request->allergies;
        if ($request->has('activity_level')) $updateData['activity_level'] = $request->activity_level;
        if ($request->has('bmr')) $updateData['bmr'] = $request->bmr;
        if ($request->has('tdee')) $updateData['tdee'] = $request->tdee;
        if ($request->has('training_type')) $updateData['training_type'] = $request->training_type;
        if ($request->has('subscription_type')) $updateData['subscription_type'] = $request->subscription_type;
        if ($request->has('trainer_id')) $updateData['trainer_id'] = $request->trainer_id;

        $measurements = [];
        if ($request->has('waist')) $measurements['waist'] = $request->waist;
        if ($request->has('hips')) $measurements['hips'] = $request->hips;
        if ($request->has('chest')) $measurements['chest'] = $request->chest;
        if ($request->has('arm')) $measurements['arms'] = $request->arm;
        if ($request->has('thigh')) $measurements['thighs'] = $request->thigh;

        if (!empty($measurements)) {
            $updateData['measurements'] = json_encode($measurements);
        }

        if (!empty($updateData)) {
            $user->update($updateData);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم حفظ البيانات بنجاح',
            'user' => $user->fresh()
        ]);
    }

    public function getSmartPlanData(Request $request)
    {
        $user = $request->user();
        $measurements = $user->measurements ? json_decode($user->measurements, true) : [];
        $trainer = $user->trainer_id ? Trainer::find($user->trainer_id) : null;

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'name' => $user->name,
                    'height' => $user->height,
                    'weight' => $user->current_weight,
                    'activity_level' => $user->activity_level,
                ],
                'measurements' => [
                    'waist' => $measurements['waist'] ?? null,
                    'hips' => $measurements['hips'] ?? null,
                    'chest' => $measurements['chest'] ?? null,
                    'arms' => $measurements['arms'] ?? null,
                    'thighs' => $measurements['thighs'] ?? null,
                ],
                'healthData' => [
                    'age' => $user->age,
                    'target_weight' => $user->target_weight,
                    'health_condition' => $user->health_condition,
                    'previous_injuries' => $user->previous_injuries,
                    'surgeries' => $user->surgeries,
                    'medications' => $user->medications,
                    'allergies' => $user->allergies,
                    'training_type' => $user->training_type,
                    'subscription_type' => $user->subscription_type,
                ],
                'trainer' => $trainer ? ['id' => $trainer->id, 'name' => $trainer->name] : null,
            ]
        ]);
    }
}
