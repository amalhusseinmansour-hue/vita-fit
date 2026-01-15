<?php

namespace App\Filament\Resources\ProductResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class OrdersRelationManager extends RelationManager
{
    protected static string $relationship = 'orders';
    protected static ?string $title = 'الطلبات';
    protected static ?string $modelLabel = 'طلب';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('order_number')
            ->columns([
                Tables\Columns\TextColumn::make('order_number')
                    ->label('رقم الطلب')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('trainee.name')
                    ->label('العميلة')
                    ->default('زائر'),
                Tables\Columns\TextColumn::make('pivot.quantity')
                    ->label('الكمية'),
                Tables\Columns\TextColumn::make('pivot.price')
                    ->label('السعر')
                    ->money('SAR'),
                Tables\Columns\TextColumn::make('pivot.total')
                    ->label('الإجمالي')
                    ->money('SAR'),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'pending',
                        'info' => fn ($state) => in_array($state, ['confirmed', 'processing']),
                        'primary' => 'shipped',
                        'success' => 'delivered',
                        'danger' => fn ($state) => in_array($state, ['cancelled', 'refunded']),
                    ])
                    ->formatStateUsing(fn ($state) => match($state) {
                        'pending' => 'معلق',
                        'confirmed' => 'مؤكد',
                        'processing' => 'جاري التجهيز',
                        'shipped' => 'شُحن',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغي',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'معلق',
                        'confirmed' => 'مؤكد',
                        'processing' => 'جاري التجهيز',
                        'shipped' => 'شُحن',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغي',
                    ]),
            ])
            ->headerActions([])
            ->actions([
                Tables\Actions\Action::make('view_order')
                    ->label('عرض الطلب')
                    ->icon('heroicon-o-eye')
                    ->url(fn ($record) => route('filament.admin.resources.orders.edit', $record)),
            ])
            ->bulkActions([])
            ->defaultSort('created_at', 'desc');
    }
}
