<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'trainee_id',
        'order_number',
        'subtotal',
        'discount',
        'tax',
        'shipping',
        'total',
        'status',
        'payment_status',
        'payment_method',
        'payment_reference',
        'shipping_address',
        'billing_address',
        'notes',
        'shipped_at',
        'delivered_at',
    ];

    protected $casts = [
        'subtotal' => 'decimal:2',
        'discount' => 'decimal:2',
        'tax' => 'decimal:2',
        'shipping' => 'decimal:2',
        'total' => 'decimal:2',
        'shipping_address' => 'array',
        'billing_address' => 'array',
        'shipped_at' => 'datetime',
        'delivered_at' => 'datetime',
    ];

    /**
     * Boot the model
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($order) {
            $order->order_number = 'ORD-' . strtoupper(uniqid());
        });
    }

    /**
     * Get the trainee who placed the order
     */
    public function trainee()
    {
        return $this->belongsTo(Trainee::class);
    }

    /**
     * Get order items
     */
    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    /**
     * Calculate totals
     */
    public function calculateTotals(): void
    {
        $subtotal = $this->items->sum(function ($item) {
            return $item->price * $item->quantity;
        });

        $this->subtotal = $subtotal;
        $this->total = $subtotal - $this->discount + $this->tax + $this->shipping;
        $this->save();
    }

    /**
     * Mark as paid
     */
    public function markAsPaid(string $paymentReference = null): void
    {
        $this->update([
            'payment_status' => 'paid',
            'payment_reference' => $paymentReference,
        ]);
    }

    /**
     * Mark as shipped
     */
    public function markAsShipped(): void
    {
        $this->update([
            'status' => 'shipped',
            'shipped_at' => now(),
        ]);
    }

    /**
     * Mark as delivered
     */
    public function markAsDelivered(): void
    {
        $this->update([
            'status' => 'delivered',
            'delivered_at' => now(),
        ]);
    }

    /**
     * Cancel order
     */
    public function cancel(): void
    {
        $this->update(['status' => 'cancelled']);

        // Restore stock
        foreach ($this->items as $item) {
            $item->product->increment('stock', $item->quantity);
        }
    }

    /**
     * Check if order is paid
     */
    public function isPaid(): bool
    {
        return $this->payment_status === 'paid';
    }
}
