<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subscription extends Model
{
    use HasFactory;

    protected $fillable = [
        'trainee_id',
        'trainer_id',
        'subscription_plan_id',
        'plan_name',
        'plan_type',
        'sessions_count',
        'sessions_used',
        'sessions_total',
        'sessions_remaining',
        'price',
        'starts_at',
        'ends_at',
        'start_date',
        'end_date',
        'status',
        'payment_method',
        'payment_status',
        'payment_reference',
        'features',
        'notes',
        'cancelled_at',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'price' => 'decimal:2',
        'sessions_count' => 'integer',
        'sessions_used' => 'integer',
        'sessions_total' => 'integer',
        'sessions_remaining' => 'integer',
        'features' => 'array',
    ];

    /**
     * Get the trainee
     */
    public function trainee()
    {
        return $this->belongsTo(Trainee::class);
    }

    /**
     * Get the trainer
     */
    public function trainer()
    {
        return $this->belongsTo(Trainer::class);
    }

    /**
     * Get the subscription plan
     */
    public function plan()
    {
        return $this->belongsTo(SubscriptionPlan::class, 'subscription_plan_id');
    }

    /**
     * Check if subscription is active
     */
    public function isActive(): bool
    {
        return $this->status === 'active'
            && $this->end_date >= now()
            && $this->sessions_used < $this->sessions_count;
    }

    /**
     * Get remaining sessions
     */
    public function getRemainingSessions(): int
    {
        return max(0, $this->sessions_count - $this->sessions_used);
    }

    /**
     * Use a session
     */
    public function useSession(): bool
    {
        if ($this->getRemainingSessions() > 0) {
            $this->increment('sessions_used');
            return true;
        }
        return false;
    }

    /**
     * Check if subscription is expired
     */
    public function isExpired(): bool
    {
        return $this->end_date < now() || $this->status === 'expired';
    }

    /**
     * Scope for active subscriptions
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active')
            ->where('end_date', '>=', now());
    }
}
