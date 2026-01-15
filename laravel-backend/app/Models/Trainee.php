<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Trainee extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'avatar',
        'birth_date',
        'height',
        'current_weight',
        'target_weight',
        'bmi',
        'bmr',
        'tdee',
        'activity_level',
        'fitness_goal',
        'measurements',
        'medical_conditions',
        'trainer_id',
        'status',
        'fcm_token',
        'email_verified_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'birth_date' => 'date',
        'measurements' => 'array',
        'medical_conditions' => 'array',
        'height' => 'float',
        'current_weight' => 'float',
        'target_weight' => 'float',
        'bmi' => 'float',
        'bmr' => 'float',
        'tdee' => 'float',
    ];

    /**
     * Get the trainer assigned to this trainee
     */
    public function trainer()
    {
        return $this->belongsTo(Trainer::class);
    }

    /**
     * Get trainee's subscriptions
     */
    public function subscriptions()
    {
        return $this->hasMany(Subscription::class);
    }

    /**
     * Get active subscription
     */
    public function activeSubscription()
    {
        return $this->hasOne(Subscription::class)
            ->where('status', 'active')
            ->where('end_date', '>=', now());
    }

    /**
     * Get trainee's training sessions
     */
    public function sessions()
    {
        return $this->hasMany(TrainingSession::class);
    }

    /**
     * Get trainee's conversations
     */
    public function conversations()
    {
        return $this->hasMany(Conversation::class);
    }

    /**
     * Get trainee's orders
     */
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Calculate BMI
     */
    public function calculateBMI(): float
    {
        if ($this->height && $this->current_weight) {
            $heightInMeters = $this->height / 100;
            return round($this->current_weight / ($heightInMeters * $heightInMeters), 2);
        }
        return 0;
    }

    /**
     * Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor equation
     */
    public function calculateBMR(): float
    {
        if ($this->height && $this->current_weight && $this->birth_date) {
            $age = $this->birth_date->age;
            // For females: BMR = (10 × weight) + (6.25 × height) - (5 × age) - 161
            return round((10 * $this->current_weight) + (6.25 * $this->height) - (5 * $age) - 161, 2);
        }
        return 0;
    }

    /**
     * Calculate TDEE (Total Daily Energy Expenditure)
     */
    public function calculateTDEE(): float
    {
        $bmr = $this->calculateBMR();
        $multipliers = [
            'sedentary' => 1.2,
            'light' => 1.375,
            'moderate' => 1.55,
            'active' => 1.725,
            'very_active' => 1.9,
        ];

        $multiplier = $multipliers[$this->activity_level] ?? 1.2;
        return round($bmr * $multiplier, 2);
    }

    /**
     * Update health metrics
     */
    public function updateHealthMetrics(): void
    {
        $this->bmi = $this->calculateBMI();
        $this->bmr = $this->calculateBMR();
        $this->tdee = $this->calculateTDEE();
        $this->save();
    }

    /**
     * Get morph class for polymorphic relationships
     */
    public function getMorphClass()
    {
        return 'trainee';
    }
}
