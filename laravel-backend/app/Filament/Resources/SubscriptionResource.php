<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SubscriptionResource\Pages;
use App\Models\Subscription;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SubscriptionResource extends Resource
{
    protected static ?string $model = Subscription::class;

    protected static ?string $navigationIcon = 'heroicon-o-credit-card';

    protected static ?string $navigationGroup = 'إدارة الاشتراكات';

    protected static ?string $navigationLabel = 'الاشتراكات';

    protected static ?string $modelLabel = 'اشتراك';

    protected static ?string $pluralModelLabel = 'الاشتراكات';

    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الاشتراك')
                    ->schema([
                        Forms\Components\Select::make('trainee_id')
                            ->label('المتدربة')
                            ->relationship('trainee', 'name')
                            ->required()
                            ->searchable(),
                        Forms\Components\Select::make('trainer_id')
                            ->label('المدربة')
                            ->relationship('trainer', 'name')
                            ->required()
                            ->searchable(),
                        Forms\Components\TextInput::make('plan_name')
                            ->label('اسم الخطة')
                            ->required(),
                        Forms\Components\Select::make('plan_type')
                            ->label('نوع الخطة')
                            ->options([
                                'monthly' => 'شهري',
                                'quarterly' => 'ربع سنوي',
                                'yearly' => 'سنوي',
                                'sessions' => 'بالجلسات',
                            ])
                            ->required(),
                    ])->columns(2),

                Forms\Components\Section::make('الجلسات')
                    ->schema([
                        Forms\Components\TextInput::make('sessions_count')
                            ->label('عدد الجلسات')
                            ->numeric()
                            ->required(),
                        Forms\Components\TextInput::make('sessions_used')
                            ->label('الجلسات المستخدمة')
                            ->numeric()
                            ->default(0),
                        Forms\Components\TextInput::make('price')
                            ->label('السعر')
                            ->numeric()
                            ->prefix('ر.س')
                            ->required(),
                    ])->columns(3),

                Forms\Components\Section::make('المدة')
                    ->schema([
                        Forms\Components\DatePicker::make('start_date')
                            ->label('تاريخ البداية')
                            ->required(),
                        Forms\Components\DatePicker::make('end_date')
                            ->label('تاريخ النهاية')
                            ->required(),
                        Forms\Components\Select::make('status')
                            ->label('الحالة')
                            ->options([
                                'active' => 'نشط',
                                'expired' => 'منتهي',
                                'cancelled' => 'ملغي',
                                'pending' => 'معلق',
                            ])
                            ->default('pending'),
                    ])->columns(3),

                Forms\Components\Section::make('الدفع')
                    ->schema([
                        Forms\Components\Select::make('payment_method')
                            ->label('طريقة الدفع')
                            ->options([
                                'cash' => 'نقدي',
                                'card' => 'بطاقة',
                                'bank_transfer' => 'تحويل بنكي',
                                'paymob' => 'Paymob',
                                'apple_pay' => 'Apple Pay',
                                'google_pay' => 'Google Pay',
                            ]),
                        Forms\Components\TextInput::make('payment_reference')
                            ->label('رقم المرجع'),
                        Forms\Components\Textarea::make('notes')
                            ->label('ملاحظات')
                            ->rows(2),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('trainee.name')
                    ->label('المتدربة')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('trainer.name')
                    ->label('المدربة')
                    ->sortable(),
                Tables\Columns\TextColumn::make('plan_name')
                    ->label('الخطة')
                    ->searchable(),
                Tables\Columns\TextColumn::make('sessions_count')
                    ->label('الجلسات')
                    ->formatStateUsing(fn ($record) => "{$record->sessions_used}/{$record->sessions_count}"),
                Tables\Columns\TextColumn::make('price')
                    ->label('السعر')
                    ->money('SAR'),
                Tables\Columns\TextColumn::make('start_date')
                    ->label('البداية')
                    ->date('Y-m-d'),
                Tables\Columns\TextColumn::make('end_date')
                    ->label('النهاية')
                    ->date('Y-m-d'),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'success' => 'active',
                        'danger' => 'expired',
                        'warning' => 'pending',
                        'gray' => 'cancelled',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'active' => 'نشط',
                        'expired' => 'منتهي',
                        'cancelled' => 'ملغي',
                        'pending' => 'معلق',
                        default => $state,
                    }),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'active' => 'نشط',
                        'expired' => 'منتهي',
                        'cancelled' => 'ملغي',
                        'pending' => 'معلق',
                    ]),
                Tables\Filters\SelectFilter::make('trainer_id')
                    ->label('المدربة')
                    ->relationship('trainer', 'name'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('activate')
                    ->label('تفعيل')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn ($record) => $record->status !== 'active')
                    ->action(fn ($record) => $record->update(['status' => 'active'])),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSubscriptions::route('/'),
            'create' => Pages\CreateSubscription::route('/create'),
            'edit' => Pages\EditSubscription::route('/{record}/edit'),
        ];
    }
}
