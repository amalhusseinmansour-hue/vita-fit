<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TrainerResource\Pages;
use App\Models\Trainer;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Hash;

class TrainerResource extends Resource
{
    protected static ?string $model = Trainer::class;

    protected static ?string $navigationIcon = 'heroicon-o-academic-cap';

    protected static ?string $navigationLabel = 'المدربات';

    protected static ?string $modelLabel = 'مدربة';

    protected static ?string $pluralModelLabel = 'المدربات';

    protected static ?string $navigationGroup = 'إدارة المستخدمين';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('بيانات الحساب')
                    ->description('بيانات تسجيل الدخول للمدربة')
                    ->schema([
                        Forms\Components\TextInput::make('user.name')
                            ->label('الاسم')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('user.email')
                            ->label('البريد الإلكتروني')
                            ->email()
                            ->required()
                            ->unique(table: User::class, column: 'email', ignorable: fn ($record) => $record?->user),
                        Forms\Components\TextInput::make('user.phone')
                            ->label('رقم الهاتف')
                            ->tel(),
                        Forms\Components\TextInput::make('user.password')
                            ->label('كلمة المرور')
                            ->password()
                            ->required(fn (string $context): bool => $context === 'create')
                            ->dehydrated(fn ($state) => filled($state))
                            ->dehydrateStateUsing(fn ($state) => Hash::make($state)),
                        Forms\Components\FileUpload::make('user.avatar')
                            ->label('الصورة الشخصية')
                            ->image()
                            ->directory('avatars'),
                    ])->columns(2),

                Forms\Components\Section::make('بيانات المدربة')
                    ->schema([
                        Forms\Components\TextInput::make('specialization')
                            ->label('التخصص')
                            ->placeholder('مثال: تمارين القوة، اليوغا، الكارديو')
                            ->maxLength(200),
                        Forms\Components\TextInput::make('experience_years')
                            ->label('سنوات الخبرة')
                            ->numeric()
                            ->default(0)
                            ->minValue(0),
                        Forms\Components\TextInput::make('hourly_rate')
                            ->label('السعر بالساعة (ر.س)')
                            ->numeric()
                            ->prefix('ر.س'),
                        Forms\Components\Toggle::make('is_available')
                            ->label('متاحة للحجز')
                            ->default(true),
                    ])->columns(2),

                Forms\Components\Section::make('السيرة الذاتية')
                    ->schema([
                        Forms\Components\Textarea::make('bio')
                            ->label('السيرة الذاتية (إنجليزي)')
                            ->rows(3),
                        Forms\Components\Textarea::make('bio_ar')
                            ->label('السيرة الذاتية (عربي)')
                            ->rows(3),
                        Forms\Components\TagsInput::make('certifications')
                            ->label('الشهادات')
                            ->placeholder('أضف شهادة'),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('user.avatar')
                    ->label('الصورة')
                    ->circular(),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('user.email')
                    ->label('البريد الإلكتروني')
                    ->searchable(),
                Tables\Columns\TextColumn::make('specialization')
                    ->label('التخصص')
                    ->searchable(),
                Tables\Columns\TextColumn::make('experience_years')
                    ->label('الخبرة')
                    ->suffix(' سنوات'),
                Tables\Columns\TextColumn::make('hourly_rate')
                    ->label('السعر/ساعة')
                    ->money('SAR'),
                Tables\Columns\TextColumn::make('rating')
                    ->label('التقييم')
                    ->formatStateUsing(fn ($state) => $state ? number_format($state, 1) . ' ⭐' : '-'),
                Tables\Columns\TextColumn::make('clients_count')
                    ->label('العملاء')
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_available')
                    ->label('متاحة')
                    ->boolean(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإضافة')
                    ->dateTime('d/m/Y')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_available')
                    ->label('الحالة')
                    ->placeholder('الكل')
                    ->trueLabel('متاحة')
                    ->falseLabel('غير متاحة'),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTrainers::route('/'),
            'create' => Pages\CreateTrainer::route('/create'),
            'edit' => Pages\EditTrainer::route('/{record}/edit'),
        ];
    }
}
