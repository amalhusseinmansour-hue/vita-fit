<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Trainer extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'avatar',
        'specialization',
        'bio',
        'experience_years',
        'certifications',
        'hourly_rate',
        'training_type',
        'max_trainees',
        'rating',
        'total_reviews',
        'status',
        'fcm_token',
        'zoom_account_id',
        'zoom_client_id',
        'zoom_client_secret',
        'available_hours',
        'email_verified_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'zoom_client_secret',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'certifications' => 'array',
        'available_hours' => 'array',
        'hourly_rate' => 'decimal:2',
        'rating' => 'decimal:2',
        'experience_years' => 'integer',
        'max_trainees' => 'integer',
        'total_reviews' => 'integer',
    ];

    /**
     * Get trainees assigned to this trainer
     */
    public function trainees()
    {
        return $this->hasMany(Trainee::class);
    }

    /**
     * Get trainer's training sessions
     */
    public function sessions()
    {
        return $this->hasMany(TrainingSession::class);
    }

    /**
     * Get trainer's conversations
     */
    public function conversations()
    {
        return $this->hasMany(Conversation::class);
    }

    /**
     * Get upcoming sessions
     */
    public function upcomingSessions()
    {
        return $this->sessions()
            ->where('scheduled_at', '>=', now())
            ->where('status', 'scheduled')
            ->orderBy('scheduled_at');
    }

    /**
     * Get today's sessions
     */
    public function todaySessions()
    {
        return $this->sessions()
            ->whereDate('scheduled_at', today())
            ->orderBy('scheduled_at');
    }

    /**
     * Check if trainer can accept more trainees
     */
    public function canAcceptTrainees(): bool
    {
        return $this->trainees()->count() < $this->max_trainees;
    }

    /**
     * Get available trainees count
     */
    public function getAvailableSlotsAttribute(): int
    {
        return max(0, $this->max_trainees - $this->trainees()->count());
    }

    /**
     * Update rating based on reviews
     */
    public function updateRating(float $newRating): void
    {
        $totalRating = ($this->rating * $this->total_reviews) + $newRating;
        $this->total_reviews++;
        $this->rating = round($totalRating / $this->total_reviews, 2);
        $this->save();
    }

    /**
     * Get morph class for polymorphic relationships
     */
    public function getMorphClass()
    {
        return 'trainer';
    }
}
