<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SubscriptionPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'name_en',
        'description',
        'description_en',
        'type',
        'duration_days',
        'sessions_count',
        'price',
        'original_price',
        'features',
        'is_active',
        'is_popular',
        'sort_order',
    ];

    protected $casts = [
        'features' => 'array',
        'price' => 'decimal:2',
        'original_price' => 'decimal:2',
        'is_active' => 'boolean',
        'is_popular' => 'boolean',
        'duration_days' => 'integer',
        'sessions_count' => 'integer',
        'sort_order' => 'integer',
    ];

    /**
     * Get subscriptions using this plan
     */
    public function subscriptions()
    {
        return $this->hasMany(Subscription::class);
    }

    /**
     * Scope for active plans
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope for popular plans
     */
    public function scopePopular($query)
    {
        return $query->where('is_popular', true);
    }

    /**
     * Check if plan is on sale
     */
    public function isOnSale(): bool
    {
        return $this->original_price !== null && $this->original_price > $this->price;
    }

    /**
     * Get discount percentage
     */
    public function getDiscountPercentage(): int
    {
        if (!$this->isOnSale()) {
            return 0;
        }
        return (int) round((($this->original_price - $this->price) / $this->original_price) * 100);
    }
}
