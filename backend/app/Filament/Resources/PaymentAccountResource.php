<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PaymentAccountResource\Pages;
use App\Models\PaymentAccount;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class PaymentAccountResource extends Resource
{
    protected static ?string $model = PaymentAccount::class;
    protected static ?string $navigationIcon = 'heroicon-o-credit-card';
    protected static ?string $navigationGroup = 'المالية';
    protected static ?string $navigationLabel = 'حسابات الدفع';
    protected static ?string $modelLabel = 'حساب دفع';
    protected static ?string $pluralModelLabel = 'حسابات الدفع';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('معلومات الحساب')
                ->schema([
                    Forms\Components\TextInput::make('name')
                        ->label('اسم الحساب (English)')
                        ->required()
                        ->maxLength(255),
                    Forms\Components\TextInput::make('name_ar')
                        ->label('اسم الحساب (عربي)')
                        ->maxLength(255),
                    Forms\Components\Select::make('type')
                        ->label('نوع الحساب')
                        ->options([
                            'bank' => 'تحويل بنكي',
                            'wallet' => 'محفظة إلكترونية',
                            'cash' => 'دفع عند الاستلام',
                        ])
                        ->required()
                        ->reactive(),
                ])->columns(3),

            Forms\Components\Section::make('تفاصيل البنك')
                ->schema([
                    Forms\Components\TextInput::make('bank_name')
                        ->label('اسم البنك')
                        ->maxLength(255),
                    Forms\Components\TextInput::make('account_number')
                        ->label('رقم الحساب')
                        ->maxLength(100),
                    Forms\Components\TextInput::make('iban')
                        ->label('IBAN')
                        ->maxLength(100),
                    Forms\Components\TextInput::make('account_holder')
                        ->label('اسم صاحب الحساب')
                        ->maxLength(255),
                ])
                ->columns(2)
                ->visible(fn (callable $get) => $get('type') === 'bank'),

            Forms\Components\Section::make('تفاصيل المحفظة')
                ->schema([
                    Forms\Components\TextInput::make('phone')
                        ->label('رقم الجوال')
                        ->tel()
                        ->maxLength(20),
                    Forms\Components\TextInput::make('account_holder')
                        ->label('اسم المستخدم')
                        ->maxLength(255),
                ])
                ->columns(2)
                ->visible(fn (callable $get) => $get('type') === 'wallet'),

            Forms\Components\Section::make('تعليمات الدفع')
                ->schema([
                    Forms\Components\Textarea::make('instructions')
                        ->label('تعليمات (English)')
                        ->rows(3),
                    Forms\Components\Textarea::make('instructions_ar')
                        ->label('تعليمات (عربي)')
                        ->rows(3),
                ])->columns(2),

            Forms\Components\Section::make('الإعدادات')
                ->schema([
                    Forms\Components\Toggle::make('is_active')
                        ->label('مفعّل')
                        ->default(true),
                    Forms\Components\TextInput::make('sort_order')
                        ->label('الترتيب')
                        ->numeric()
                        ->default(0),
                ])->columns(2),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name_ar')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\BadgeColumn::make('type')
                    ->label('النوع')
                    ->colors([
                        'primary' => 'bank',
                        'success' => 'wallet',
                        'warning' => 'cash',
                    ])
                    ->formatStateUsing(fn ($state) => match($state) {
                        'bank' => 'بنكي',
                        'wallet' => 'محفظة',
                        'cash' => 'كاش',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('bank_name')
                    ->label('البنك')
                    ->placeholder('-'),
                Tables\Columns\TextColumn::make('account_number')
                    ->label('رقم الحساب')
                    ->placeholder('-'),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('مفعّل')
                    ->boolean(),
                Tables\Columns\TextColumn::make('sort_order')
                    ->label('الترتيب')
                    ->sortable(),
            ])
            ->defaultSort('sort_order')
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('النوع')
                    ->options([
                        'bank' => 'بنكي',
                        'wallet' => 'محفظة',
                        'cash' => 'كاش',
                    ]),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('مفعّل'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->reorderable('sort_order');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPaymentAccounts::route('/'),
            'create' => Pages\CreatePaymentAccount::route('/create'),
            'edit' => Pages\EditPaymentAccount::route('/{record}/edit'),
        ];
    }
}
