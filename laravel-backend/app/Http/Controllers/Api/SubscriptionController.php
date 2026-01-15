<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SubscriptionController extends Controller
{
    /**
     * Get user's subscriptions
     */
    public function index(Request $request)
    {
        $subscriptions = $request->user()->subscriptions()
            ->with('plan')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $subscriptions,
        ]);
    }

    /**
     * Get active subscription
     */
    public function active(Request $request)
    {
        $subscription = $request->user()->subscriptions()
            ->where('status', 'active')
            ->where('ends_at', '>', now())
            ->with('plan', 'trainer')
            ->first();

        if (!$subscription) {
            return response()->json([
                'success' => false,
                'message' => 'No active subscription',
                'data' => null,
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $subscription->id,
                'plan' => $subscription->plan,
                'trainer' => $subscription->trainer ? [
                    'id' => $subscription->trainer->id,
                    'name' => $subscription->trainer->name,
                    'avatar' => $subscription->trainer->avatar,
                ] : null,
                'starts_at' => $subscription->starts_at,
                'ends_at' => $subscription->ends_at,
                'sessions_remaining' => $subscription->sessions_remaining,
                'status' => $subscription->status,
                'days_remaining' => now()->diffInDays($subscription->ends_at, false),
            ],
        ]);
    }

    /**
     * Get available plans
     */
    public function plans()
    {
        $plans = SubscriptionPlan::where('is_active', true)
            ->orderBy('price')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $plans,
        ]);
    }

    /**
     * Subscribe to a plan
     */
    public function subscribe(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'plan_id' => 'required|exists:subscription_plans,id',
            'trainer_id' => 'nullable|exists:trainers,id',
            'payment_method' => 'required|in:card,apple_pay,google_pay',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $plan = SubscriptionPlan::find($request->plan_id);

        // Check for existing active subscription
        $existingSubscription = $user->subscriptions()
            ->where('status', 'active')
            ->where('ends_at', '>', now())
            ->first();

        if ($existingSubscription) {
            return response()->json([
                'success' => false,
                'message' => 'You already have an active subscription',
            ], 400);
        }

        // Calculate dates
        $startsAt = now();
        $endsAt = now()->addDays($plan->duration_days);

        // Create subscription
        $subscription = Subscription::create([
            'trainee_id' => $user->id,
            'subscription_plan_id' => $plan->id,
            'trainer_id' => $request->trainer_id,
            'starts_at' => $startsAt,
            'ends_at' => $endsAt,
            'sessions_total' => $plan->sessions_count,
            'sessions_remaining' => $plan->sessions_count,
            'price' => $plan->price,
            'status' => 'active',
            'payment_method' => $request->payment_method,
            'payment_status' => 'pending', // Will be updated after payment
        ]);

        // Assign trainer if provided
        if ($request->trainer_id) {
            $user->update(['trainer_id' => $request->trainer_id]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Subscription created successfully',
            'data' => $subscription->load('plan'),
        ], 201);
    }

    /**
     * Cancel subscription
     */
    public function cancel(Request $request)
    {
        $subscription = $request->user()->subscriptions()
            ->where('status', 'active')
            ->first();

        if (!$subscription) {
            return response()->json([
                'success' => false,
                'message' => 'No active subscription to cancel',
            ], 404);
        }

        $subscription->update([
            'status' => 'cancelled',
            'cancelled_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Subscription cancelled successfully',
        ]);
    }
}
