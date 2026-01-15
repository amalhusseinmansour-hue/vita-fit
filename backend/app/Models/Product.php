<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'name_ar',
        'slug',
        'description',
        'description_ar',
        'category',
        'category_id',
        'sku',
        'barcode',
        'price',
        'sale_price',
        'cost_price',
        'stock',
        'quantity',
        'low_stock_threshold',
        'image',
        'images',
        'specifications',
        'brand',
        'weight',
        'dimensions',
        'is_active',
        'is_featured',
        'rating',
        'reviews_count',
        'sales_count',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'sale_price' => 'decimal:2',
        'cost_price' => 'decimal:2',
        'images' => 'array',
        'specifications' => 'array',
        'dimensions' => 'array',
        'is_active' => 'boolean',
        'is_featured' => 'boolean',
        'rating' => 'decimal:1',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function orders()
    {
        return $this->belongsToMany(Order::class, 'order_items')
            ->withPivot('quantity', 'price', 'total');
    }

    public function getStockStatus(): string
    {
        $stock = $this->stock ?? $this->quantity ?? 0;
        if ($stock <= 0) return 'out_of_stock';
        if ($stock <= ($this->low_stock_threshold ?? 10)) return 'low_stock';
        return 'in_stock';
    }

    public function getCurrentPrice(): float
    {
        return $this->sale_price && $this->sale_price < $this->price
            ? $this->sale_price
            : $this->price;
    }

    public function getDiscountPercentage(): ?int
    {
        if (!$this->sale_price || $this->sale_price >= $this->price) return null;
        return round((($this->price - $this->sale_price) / $this->price) * 100);
    }
}
