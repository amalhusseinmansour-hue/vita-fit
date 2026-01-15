<?php

namespace App\Filament\Resources;

use App\Filament\Resources\OrderResource\Pages;
use App\Models\Order;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class OrderResource extends Resource
{
    protected static ?string $model = Order::class;

    protected static ?string $navigationIcon = 'heroicon-o-shopping-cart';

    protected static ?string $navigationGroup = 'المتجر';

    protected static ?string $navigationLabel = 'الطلبات';

    protected static ?string $modelLabel = 'طلب';

    protected static ?string $pluralModelLabel = 'الطلبات';

    protected static ?int $navigationSort = 5;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الطلب')
                    ->schema([
                        Forms\Components\TextInput::make('order_number')
                            ->label('رقم الطلب')
                            ->disabled(),
                        Forms\Components\Select::make('trainee_id')
                            ->label('العميلة')
                            ->relationship('trainee', 'name')
                            ->required()
                            ->searchable(),
                        Forms\Components\Select::make('status')
                            ->label('حالة الطلب')
                            ->options([
                                'pending' => 'قيد الانتظار',
                                'processing' => 'جاري التجهيز',
                                'shipped' => 'تم الشحن',
                                'delivered' => 'تم التسليم',
                                'cancelled' => 'ملغي',
                            ])
                            ->default('pending'),
                        Forms\Components\Select::make('payment_status')
                            ->label('حالة الدفع')
                            ->options([
                                'pending' => 'غير مدفوع',
                                'paid' => 'مدفوع',
                                'refunded' => 'مسترد',
                            ])
                            ->default('pending'),
                    ])->columns(2),

                Forms\Components\Section::make('المبالغ')
                    ->schema([
                        Forms\Components\TextInput::make('subtotal')
                            ->label('المجموع الفرعي')
                            ->numeric()
                            ->prefix('ر.س')
                            ->disabled(),
                        Forms\Components\TextInput::make('discount')
                            ->label('الخصم')
                            ->numeric()
                            ->prefix('ر.س')
                            ->default(0),
                        Forms\Components\TextInput::make('tax')
                            ->label('الضريبة')
                            ->numeric()
                            ->prefix('ر.س')
                            ->default(0),
                        Forms\Components\TextInput::make('shipping')
                            ->label('الشحن')
                            ->numeric()
                            ->prefix('ر.س')
                            ->default(0),
                        Forms\Components\TextInput::make('total')
                            ->label('الإجمالي')
                            ->numeric()
                            ->prefix('ر.س')
                            ->disabled(),
                    ])->columns(5),

                Forms\Components\Section::make('العنوان')
                    ->schema([
                        Forms\Components\Textarea::make('shipping_address')
                            ->label('عنوان الشحن')
                            ->rows(2),
                        Forms\Components\Textarea::make('notes')
                            ->label('ملاحظات')
                            ->rows(2),
                    ])->columns(2),

                Forms\Components\Section::make('الدفع')
                    ->schema([
                        Forms\Components\Select::make('payment_method')
                            ->label('طريقة الدفع')
                            ->options([
                                'cash_on_delivery' => 'الدفع عند الاستلام',
                                'card' => 'بطاقة',
                                'paymob' => 'Paymob',
                                'apple_pay' => 'Apple Pay',
                                'google_pay' => 'Google Pay',
                            ]),
                        Forms\Components\TextInput::make('payment_reference')
                            ->label('رقم المرجع'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('order_number')
                    ->label('رقم الطلب')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('trainee.name')
                    ->label('العميلة')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('total')
                    ->label('الإجمالي')
                    ->money('SAR')
                    ->sortable(),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('حالة الطلب')
                    ->colors([
                        'warning' => 'pending',
                        'info' => 'processing',
                        'primary' => 'shipped',
                        'success' => 'delivered',
                        'danger' => 'cancelled',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'processing' => 'جاري التجهيز',
                        'shipped' => 'تم الشحن',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغي',
                        default => $state,
                    }),
                Tables\Columns\BadgeColumn::make('payment_status')
                    ->label('الدفع')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'paid',
                        'danger' => 'refunded',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'غير مدفوع',
                        'paid' => 'مدفوع',
                        'refunded' => 'مسترد',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الطلب')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('حالة الطلب')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'processing' => 'جاري التجهيز',
                        'shipped' => 'تم الشحن',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغي',
                    ]),
                Tables\Filters\SelectFilter::make('payment_status')
                    ->label('حالة الدفع')
                    ->options([
                        'pending' => 'غير مدفوع',
                        'paid' => 'مدفوع',
                        'refunded' => 'مسترد',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('mark_shipped')
                    ->label('شحن')
                    ->icon('heroicon-o-truck')
                    ->color('info')
                    ->visible(fn ($record) => $record->status === 'processing')
                    ->action(fn ($record) => $record->markAsShipped()),
                Tables\Actions\Action::make('mark_delivered')
                    ->label('تسليم')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn ($record) => $record->status === 'shipped')
                    ->action(fn ($record) => $record->markAsDelivered()),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListOrders::route('/'),
            'create' => Pages\CreateOrder::route('/create'),
            'edit' => Pages\EditOrder::route('/{record}/edit'),
        ];
    }
}
