<?php

namespace App\Filament\Resources;

use App\Filament\Resources\OrderResource\Pages;
use App\Filament\Resources\OrderResource\RelationManagers;
use App\Models\Order;
use App\Models\PaymentAccount;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;

class OrderResource extends Resource
{
    protected static ?string $model = Order::class;
    protected static ?string $navigationIcon = 'heroicon-o-shopping-cart';
    protected static ?string $navigationGroup = 'المتجر';
    protected static ?string $navigationLabel = 'الطلبات';
    protected static ?string $modelLabel = 'طلب';
    protected static ?string $pluralModelLabel = 'الطلبات';
    protected static ?int $navigationSort = 1;

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'pending')->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Group::make()
                    ->schema([
                        Forms\Components\Section::make('معلومات الطلب')
                            ->schema([
                                Forms\Components\TextInput::make('order_number')
                                    ->label('رقم الطلب')
                                    ->disabled()
                                    ->dehydrated(false),
                                Forms\Components\Select::make('trainee_id')
                                    ->label('العميلة')
                                    ->relationship('trainee', 'name')
                                    ->searchable()
                                    ->preload(),
                                Forms\Components\Select::make('status')
                                    ->label('حالة الطلب')
                                    ->options([
                                        'pending' => 'قيد الانتظار',
                                        'confirmed' => 'تم التأكيد',
                                        'processing' => 'جاري التجهيز',
                                        'shipped' => 'تم الشحن',
                                        'delivered' => 'تم التسليم',
                                        'cancelled' => 'ملغي',
                                        'refunded' => 'مسترد',
                                    ])
                                    ->default('pending')
                                    ->required(),
                                Forms\Components\DateTimePicker::make('created_at')
                                    ->label('تاريخ الطلب')
                                    ->disabled(),
                            ])->columns(2),

                        Forms\Components\Section::make('المبالغ')
                            ->schema([
                                Forms\Components\TextInput::make('subtotal')
                                    ->label('المجموع الفرعي')
                                    ->numeric()
                                    ->prefix('ر.س')
                                    ->default(0),
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
                                    ->required(),
                            ])->columns(5),

                        Forms\Components\Section::make('عنوان الشحن')
                            ->schema([
                                Forms\Components\TextInput::make('customer_name')
                                    ->label('اسم المستلم'),
                                Forms\Components\TextInput::make('customer_phone')
                                    ->label('رقم الجوال')
                                    ->tel(),
                                Forms\Components\Textarea::make('shipping_address')
                                    ->label('العنوان')
                                    ->rows(2)
                                    ->columnSpanFull(),
                                Forms\Components\TextInput::make('city')
                                    ->label('المدينة'),
                                Forms\Components\TextInput::make('postal_code')
                                    ->label('الرمز البريدي'),
                            ])->columns(2),
                    ])->columnSpan(['lg' => 2]),

                Forms\Components\Group::make()
                    ->schema([
                        Forms\Components\Section::make('الدفع')
                            ->schema([
                                Forms\Components\Select::make('payment_status')
                                    ->label('حالة الدفع')
                                    ->options([
                                        'pending' => 'في انتظار الدفع',
                                        'paid' => 'مدفوع',
                                        'failed' => 'فشل الدفع',
                                        'refunded' => 'مسترد',
                                    ])
                                    ->default('pending')
                                    ->required(),
                                Forms\Components\Select::make('payment_method')
                                    ->label('طريقة الدفع')
                                    ->options([
                                        'cash_on_delivery' => 'الدفع عند الاستلام',
                                        'bank_transfer' => 'تحويل بنكي',
                                        'wallet' => 'محفظة إلكترونية',
                                        'card' => 'بطاقة ائتمان',
                                    ]),
                                Forms\Components\Select::make('payment_account_id')
                                    ->label('حساب الدفع')
                                    ->options(PaymentAccount::active()->ordered()->pluck('name_ar', 'id'))
                                    ->searchable(),
                                Forms\Components\TextInput::make('payment_reference')
                                    ->label('رقم المرجع/التحويل'),
                                Forms\Components\FileUpload::make('payment_proof')
                                    ->label('إثبات الدفع')
                                    ->image()
                                    ->directory('payment-proofs'),
                            ]),

                        Forms\Components\Section::make('التتبع')
                            ->schema([
                                Forms\Components\TextInput::make('tracking_number')
                                    ->label('رقم التتبع'),
                                Forms\Components\TextInput::make('shipping_company')
                                    ->label('شركة الشحن'),
                                Forms\Components\DateTimePicker::make('shipped_at')
                                    ->label('تاريخ الشحن'),
                                Forms\Components\DateTimePicker::make('delivered_at')
                                    ->label('تاريخ التسليم'),
                            ]),

                        Forms\Components\Section::make('ملاحظات')
                            ->schema([
                                Forms\Components\Textarea::make('notes')
                                    ->label('ملاحظات العميل')
                                    ->rows(2),
                                Forms\Components\Textarea::make('admin_notes')
                                    ->label('ملاحظات الإدارة')
                                    ->rows(2),
                            ]),
                    ])->columnSpan(['lg' => 1]),
            ])->columns(3);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('order_number')
                    ->label('رقم الطلب')
                    ->searchable()
                    ->sortable()
                    ->copyable()
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('trainee.name')
                    ->label('العميلة')
                    ->searchable()
                    ->sortable()
                    ->default('زائر'),
                Tables\Columns\TextColumn::make('total')
                    ->label('الإجمالي')
                    ->money('SAR')
                    ->sortable()
                    ->weight('bold'),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('حالة الطلب')
                    ->colors([
                        'warning' => 'pending',
                        'info' => fn ($state) => in_array($state, ['confirmed', 'processing']),
                        'primary' => 'shipped',
                        'success' => 'delivered',
                        'danger' => fn ($state) => in_array($state, ['cancelled', 'refunded']),
                    ])
                    ->icons([
                        'heroicon-m-clock' => 'pending',
                        'heroicon-m-check' => 'confirmed',
                        'heroicon-m-cog-6-tooth' => 'processing',
                        'heroicon-m-truck' => 'shipped',
                        'heroicon-m-check-circle' => 'delivered',
                        'heroicon-m-x-circle' => 'cancelled',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'confirmed' => 'تم التأكيد',
                        'processing' => 'جاري التجهيز',
                        'shipped' => 'تم الشحن',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغي',
                        'refunded' => 'مسترد',
                        default => $state,
                    }),
                Tables\Columns\BadgeColumn::make('payment_status')
                    ->label('الدفع')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'paid',
                        'danger' => fn ($state) => in_array($state, ['failed', 'refunded']),
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'في الانتظار',
                        'paid' => 'مدفوع',
                        'failed' => 'فشل',
                        'refunded' => 'مسترد',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('payment_method')
                    ->label('طريقة الدفع')
                    ->formatStateUsing(fn ($state) => match ($state) {
                        'cash_on_delivery' => 'عند الاستلام',
                        'bank_transfer' => 'تحويل بنكي',
                        'wallet' => 'محفظة',
                        'card' => 'بطاقة',
                        default => $state ?? '-',
                    })
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('tracking_number')
                    ->label('رقم التتبع')
                    ->copyable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('حالة الطلب')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'confirmed' => 'تم التأكيد',
                        'processing' => 'جاري التجهيز',
                        'shipped' => 'تم الشحن',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغي',
                    ])
                    ->multiple(),
                Tables\Filters\SelectFilter::make('payment_status')
                    ->label('حالة الدفع')
                    ->options([
                        'pending' => 'في الانتظار',
                        'paid' => 'مدفوع',
                        'failed' => 'فشل',
                        'refunded' => 'مسترد',
                    ]),
                Tables\Filters\Filter::make('created_at')
                    ->form([
                        Forms\Components\DatePicker::make('from')->label('من'),
                        Forms\Components\DatePicker::make('to')->label('إلى'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when($data['from'], fn (Builder $query, $date): Builder => $query->whereDate('created_at', '>=', $date))
                            ->when($data['to'], fn (Builder $query, $date): Builder => $query->whereDate('created_at', '<=', $date));
                    }),
            ])
            ->actions([
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make(),
                    Tables\Actions\EditAction::make(),
                    Tables\Actions\Action::make('confirm')
                        ->label('تأكيد الطلب')
                        ->icon('heroicon-o-check')
                        ->color('info')
                        ->visible(fn ($record) => $record->status === 'pending')
                        ->action(function ($record) {
                            $record->update(['status' => 'confirmed']);
                            Notification::make()->title('تم تأكيد الطلب')->success()->send();
                        }),
                    Tables\Actions\Action::make('process')
                        ->label('بدء التجهيز')
                        ->icon('heroicon-o-cog-6-tooth')
                        ->color('warning')
                        ->visible(fn ($record) => $record->status === 'confirmed')
                        ->action(function ($record) {
                            $record->update(['status' => 'processing']);
                            Notification::make()->title('تم بدء تجهيز الطلب')->success()->send();
                        }),
                    Tables\Actions\Action::make('ship')
                        ->label('شحن الطلب')
                        ->icon('heroicon-o-truck')
                        ->color('primary')
                        ->visible(fn ($record) => $record->status === 'processing')
                        ->form([
                            Forms\Components\TextInput::make('tracking_number')->label('رقم التتبع'),
                            Forms\Components\TextInput::make('shipping_company')->label('شركة الشحن'),
                        ])
                        ->action(function ($record, array $data) {
                            $record->update([
                                'status' => 'shipped',
                                'tracking_number' => $data['tracking_number'] ?? null,
                                'shipping_company' => $data['shipping_company'] ?? null,
                                'shipped_at' => now(),
                            ]);
                            Notification::make()->title('تم شحن الطلب')->success()->send();
                        }),
                    Tables\Actions\Action::make('deliver')
                        ->label('تم التسليم')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->visible(fn ($record) => $record->status === 'shipped')
                        ->requiresConfirmation()
                        ->action(function ($record) {
                            $record->update([
                                'status' => 'delivered',
                                'delivered_at' => now(),
                            ]);
                            Notification::make()->title('تم تسليم الطلب')->success()->send();
                        }),
                    Tables\Actions\Action::make('mark_paid')
                        ->label('تأكيد الدفع')
                        ->icon('heroicon-o-banknotes')
                        ->color('success')
                        ->visible(fn ($record) => $record->payment_status === 'pending')
                        ->requiresConfirmation()
                        ->action(function ($record) {
                            $record->update(['payment_status' => 'paid']);
                            Notification::make()->title('تم تأكيد الدفع')->success()->send();
                        }),
                    Tables\Actions\Action::make('cancel')
                        ->label('إلغاء الطلب')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->visible(fn ($record) => !in_array($record->status, ['delivered', 'cancelled']))
                        ->requiresConfirmation()
                        ->action(function ($record) {
                            $record->update(['status' => 'cancelled']);
                            Notification::make()->title('تم إلغاء الطلب')->warning()->send();
                        }),
                ]),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('mark_processing')
                        ->label('تحديد كـ جاري التجهيز')
                        ->icon('heroicon-o-cog-6-tooth')
                        ->action(fn ($records) => $records->each->update(['status' => 'processing'])),
                ]),
            ])
            ->defaultSort('created_at', 'desc')
            ->poll('30s');
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\ItemsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListOrders::route('/'),
            'create' => Pages\CreateOrder::route('/create'),
            'view' => Pages\ViewOrder::route('/{record}'),
            'edit' => Pages\EditOrder::route('/{record}/edit'),
        ];
    }
}
