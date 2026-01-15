<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Conversation extends Model
{
    use HasFactory;

    protected $fillable = [
        'trainer_id',
        'trainee_id',
        'last_message_at',
    ];

    protected $casts = [
        'last_message_at' => 'datetime',
    ];

    /**
     * Get the trainer in this conversation
     */
    public function trainer()
    {
        return $this->belongsTo(Trainer::class);
    }

    /**
     * Get the trainee in this conversation
     */
    public function trainee()
    {
        return $this->belongsTo(Trainee::class);
    }

    /**
     * Get all messages in this conversation
     */
    public function messages()
    {
        return $this->hasMany(Message::class)->orderBy('created_at');
    }

    /**
     * Get the last message
     */
    public function lastMessage()
    {
        return $this->hasOne(Message::class)->latest();
    }

    /**
     * Get unread messages count for a user
     */
    public function unreadCountFor(string $userType): int
    {
        return $this->messages()
            ->where('sender_type', '!=', $userType)
            ->where('is_read', false)
            ->count();
    }
}
