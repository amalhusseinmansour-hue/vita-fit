<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TrainingSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'trainer_id',
        'trainee_id',
        'title',
        'description',
        'scheduled_at',
        'duration_minutes',
        'session_type',
        'training_mode',
        'zoom_meeting_id',
        'zoom_password',
        'zoom_join_url',
        'zoom_start_url',
        'status',
        'started_at',
        'ended_at',
        'trainer_notes',
        'trainee_feedback',
        'rating',
        'price',
        'is_paid',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
        'started_at' => 'datetime',
        'ended_at' => 'datetime',
        'duration_minutes' => 'integer',
        'rating' => 'integer',
        'price' => 'decimal:2',
        'is_paid' => 'boolean',
    ];

    /**
     * Get the trainer for this session
     */
    public function trainer()
    {
        return $this->belongsTo(Trainer::class);
    }

    /**
     * Get the trainee for this session
     */
    public function trainee()
    {
        return $this->belongsTo(Trainee::class);
    }

    /**
     * Scope for upcoming sessions
     */
    public function scopeUpcoming($query)
    {
        return $query->where('scheduled_at', '>=', now())
            ->where('status', 'scheduled');
    }

    /**
     * Scope for today's sessions
     */
    public function scopeToday($query)
    {
        return $query->whereDate('scheduled_at', today());
    }

    /**
     * Scope for completed sessions
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    /**
     * Start the session
     */
    public function start(): void
    {
        $this->update([
            'status' => 'in_progress',
            'started_at' => now(),
        ]);
    }

    /**
     * End the session
     */
    public function end(): void
    {
        $this->update([
            'status' => 'completed',
            'ended_at' => now(),
        ]);
    }

    /**
     * Cancel the session
     */
    public function cancel(string $reason = null): void
    {
        $this->update([
            'status' => 'cancelled',
            'trainer_notes' => $reason,
        ]);
    }

    /**
     * Check if session can be started
     */
    public function canStart(): bool
    {
        return $this->status === 'scheduled'
            && $this->scheduled_at->diffInMinutes(now()) <= 15;
    }

    /**
     * Check if session is ongoing
     */
    public function isOngoing(): bool
    {
        return $this->status === 'in_progress';
    }
}
