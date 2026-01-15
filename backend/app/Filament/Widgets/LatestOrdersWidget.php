<?php

namespace App\Filament\Widgets;

use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Support\Facades\DB;

class LatestOrdersWidget extends BaseWidget
{
    protected static ?string $heading = 'أحدث الطلبات';
    protected static ?int $sort = 6;
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                \App\Models\Order::query()->latest()->limit(10)
            )
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('#'),
                Tables\Columns\TextColumn::make('order_number')
                    ->label('رقم الطلب')
                    ->default(fn ($record) => 'ORD-' . str_pad($record->id, 6, '0', STR_PAD_LEFT)),
                Tables\Columns\TextColumn::make('total')
                    ->label('المبلغ')
                    ->money('SAR'),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'pending',
                        'primary' => 'processing',
                        'info' => 'shipped',
                        'success' => fn ($state) => in_array($state, ['completed', 'delivered']),
                        'danger' => 'cancelled',
                    ])
                    ->formatStateUsing(fn ($state) => match($state) {
                        'pending' => 'معلق',
                        'processing' => 'قيد التجهيز',
                        'shipped' => 'تم الشحن',
                        'completed' => 'مكتمل',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغي',
                        default => $state ?? '-',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->dateTime('d/m/Y H:i'),
            ])
            ->paginated(false);
    }
}
