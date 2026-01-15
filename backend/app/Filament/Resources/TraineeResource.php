<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TraineeResource\Pages;
use App\Models\Trainee;
use App\Models\Trainer;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class TraineeResource extends Resource
{
    protected static ?string $model = Trainee::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $navigationGroup = 'إدارة المستخدمين';

    protected static ?string $navigationLabel = 'المتدربات';

    protected static ?string $modelLabel = 'متدربة';

    protected static ?string $pluralModelLabel = 'المتدربات';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('المعلومات الأساسية')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('الاسم')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('email')
                            ->label('البريد الإلكتروني')
                            ->email()
                            ->required()
                            ->unique(ignoreRecord: true),
                        Forms\Components\TextInput::make('phone')
                            ->label('رقم الجوال')
                            ->tel(),
                        Forms\Components\DatePicker::make('birth_date')
                            ->label('تاريخ الميلاد'),
                        Forms\Components\FileUpload::make('avatar')
                            ->label('الصورة الشخصية')
                            ->image()
                            ->directory('avatars'),
                    ])->columns(2),

                Forms\Components\Section::make('المعلومات الصحية')
                    ->schema([
                        Forms\Components\TextInput::make('height')
                            ->label('الطول (سم)')
                            ->numeric()
                            ->suffix('سم'),
                        Forms\Components\TextInput::make('current_weight')
                            ->label('الوزن الحالي (كجم)')
                            ->numeric()
                            ->suffix('كجم'),
                        Forms\Components\TextInput::make('target_weight')
                            ->label('الوزن المستهدف (كجم)')
                            ->numeric()
                            ->suffix('كجم'),
                        Forms\Components\TextInput::make('bmi')
                            ->label('مؤشر كتلة الجسم')
                            ->numeric()
                            ->disabled(),
                        Forms\Components\TextInput::make('bmr')
                            ->label('معدل الأيض الأساسي')
                            ->numeric()
                            ->disabled(),
                        Forms\Components\TextInput::make('tdee')
                            ->label('السعرات اليومية')
                            ->numeric()
                            ->disabled(),
                        Forms\Components\Select::make('activity_level')
                            ->label('مستوى النشاط')
                            ->options([
                                'sedentary' => 'قليلة النشاط',
                                'light' => 'خفيفة النشاط',
                                'moderate' => 'متوسطة النشاط',
                                'active' => 'عالية النشاط',
                                'very_active' => 'عالية النشاط جداً',
                            ]),
                    ])->columns(3),

                Forms\Components\Section::make('القياسات')
                    ->schema([
                        Forms\Components\TextInput::make('measurements.waist')
                            ->label('محيط الخصر')
                            ->numeric()
                            ->suffix('سم'),
                        Forms\Components\TextInput::make('measurements.hips')
                            ->label('محيط الأرداف')
                            ->numeric()
                            ->suffix('سم'),
                        Forms\Components\TextInput::make('measurements.chest')
                            ->label('محيط الصدر')
                            ->numeric()
                            ->suffix('سم'),
                        Forms\Components\TextInput::make('measurements.arm')
                            ->label('محيط الذراع')
                            ->numeric()
                            ->suffix('سم'),
                        Forms\Components\TextInput::make('measurements.thigh')
                            ->label('محيط الفخذ')
                            ->numeric()
                            ->suffix('سم'),
                    ])->columns(5),

                Forms\Components\Section::make('الإدارة')
                    ->schema([
                        Forms\Components\Select::make('trainer_id')
                            ->label('المدربة')
                            ->options(function () {
                                return Trainer::with('user')->get()->pluck('name', 'id');
                            })
                            ->searchable()
                            ->preload(),
                        Forms\Components\Select::make('status')
                            ->label('الحالة')
                            ->options([
                                'active' => 'نشطة',
                                'inactive' => 'غير فعالة',
                                'suspended' => 'موقوفة',
                            ])
                            ->default('active'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('avatar')
                    ->label('الصورة')
                    ->circular(),
                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('email')
                    ->label('البريد')
                    ->searchable(),
                Tables\Columns\TextColumn::make('phone')
                    ->label('الجوال')
                    ->searchable(),
                Tables\Columns\TextColumn::make('trainer.user.name')
                    ->label('المدربة')
                    ->sortable(),
                Tables\Columns\TextColumn::make('bmi')
                    ->label('BMI')
                    ->numeric(2),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'success' => 'active',
                        'danger' => 'inactive',
                        'warning' => 'suspended',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'active' => 'نشطة',
                        'inactive' => 'غير فعالة',
                        'suspended' => 'موقوفة',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ التسجيل')
                    ->dateTime('Y-m-d')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'active' => 'نشطة',
                        'inactive' => 'غير فعالة',
                        'suspended' => 'موقوفة',
                    ]),
                Tables\Filters\SelectFilter::make('trainer_id')
                    ->label('المدربة')
                    ->options(function () {
                        return Trainer::with('user')->get()->pluck('name', 'id');
                    }),
                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\ForceDeleteBulkAction::make(),
                    Tables\Actions\RestoreBulkAction::make(),
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
            'index' => Pages\ListTrainees::route('/'),
            'create' => Pages\CreateTrainee::route('/create'),
            'edit' => Pages\EditTrainee::route('/{record}/edit'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->withoutGlobalScopes([
                SoftDeletingScope::class,
            ]);
    }
}
