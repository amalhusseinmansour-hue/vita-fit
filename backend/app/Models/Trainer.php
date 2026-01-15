<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Trainer extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'specialization',
        'experience_years',
        'bio',
        'bio_ar',
        'certifications',
        'hourly_rate',
        'rating',
        'reviews_count',
        'clients_count',
        'is_available',
        'working_hours',
    ];

    protected $casts = [
        'certifications' => 'array',
        'working_hours' => 'array',
        'is_available' => 'boolean',
        'hourly_rate' => 'decimal:2',
        'rating' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function subscriptions()
    {
        return $this->hasMany(Subscription::class);
    }
}
