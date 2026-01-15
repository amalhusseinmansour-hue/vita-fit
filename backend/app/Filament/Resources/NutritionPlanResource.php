<?php

namespace App\Filament\Resources;

use App\Filament\Resources\NutritionPlanResource\Pages;
use App\Models\NutritionPlan;
use App\Models\Trainer;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class NutritionPlanResource extends Resource
{
    protected static ?string $model = NutritionPlan::class;
    protected static ?string $navigationIcon = 'heroicon-o-cake';
    protected static ?string $navigationGroup = 'التغذية';
    protected static ?string $navigationLabel = 'خطط التغذية';
    protected static ?string $modelLabel = 'خطة تغذية';
    protected static ?string $pluralModelLabel = 'خطط التغذية';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('معلومات الخطة')
                ->schema([
                    Forms\Components\TextInput::make('name')->label('اسم الخطة')->required(),
                    Forms\Components\Select::make('trainer_id')->label('المدربة')
                        ->options(fn () => Trainer::with('user')->get()->pluck('name', 'id'))->searchable()->preload(),
                    Forms\Components\Select::make('trainee_id')->label('المتدربة')
                        ->relationship('trainee', 'name')->searchable()->preload(),
                    Forms\Components\Select::make('goal')->label('الهدف')
                        ->options([
                            'weight_loss' => 'خسارة الوزن',
                            'muscle_gain' => 'بناء العضلات',
                            'maintenance' => 'الحفاظ على الوزن',
                            'bulking' => 'التضخيم',
                            'cutting' => 'التنشيف',
                        ]),
                ])->columns(2),
            Forms\Components\Section::make('السعرات والماكروز')
                ->schema([
                    Forms\Components\TextInput::make('daily_calories')->label('السعرات اليومية')->numeric()->suffix('سعرة'),
                    Forms\Components\TextInput::make('protein_grams')->label('البروتين')->numeric()->suffix('جرام'),
                    Forms\Components\TextInput::make('carbs_grams')->label('الكربوهيدرات')->numeric()->suffix('جرام'),
                    Forms\Components\TextInput::make('fat_grams')->label('الدهون')->numeric()->suffix('جرام'),
                ])->columns(4),
            Forms\Components\Section::make('التفاصيل')
                ->schema([
                    Forms\Components\Select::make('status')->label('الحالة')
                        ->options(['draft' => 'مسودة', 'active' => 'نشط', 'completed' => 'مكتمل', 'cancelled' => 'ملغي'])
                        ->default('draft'),
                    Forms\Components\DatePicker::make('start_date')->label('تاريخ البدء'),
                    Forms\Components\DatePicker::make('end_date')->label('تاريخ الانتهاء'),
                ])->columns(3),
            Forms\Components\Section::make('المحتوى')
                ->schema([
                    Forms\Components\Textarea::make('description')->label('الوصف')->rows(3),
                    Forms\Components\Textarea::make('notes')->label('ملاحظات')->rows(3),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->label('الخطة')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('trainee.name')->label('المتدربة')->searchable(),
                Tables\Columns\TextColumn::make('daily_calories')->label('السعرات')->suffix(' سعرة'),
                Tables\Columns\TextColumn::make('status')->label('الحالة')->badge()
                    ->formatStateUsing(fn($state) => match($state) {
                        'draft' => 'مسودة', 'active' => 'نشط', 'completed' => 'مكتمل', 'cancelled' => 'ملغي', default => $state
                    })
                    ->color(fn($state) => match($state) {
                        'draft' => 'gray', 'active' => 'success', 'completed' => 'info', 'cancelled' => 'danger', default => 'gray'
                    }),
                Tables\Columns\TextColumn::make('created_at')->label('تاريخ الإنشاء')->date(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')->label('الحالة')
                    ->options(['draft' => 'مسودة', 'active' => 'نشط', 'completed' => 'مكتمل']),
            ])
            ->actions([Tables\Actions\EditAction::make(), Tables\Actions\DeleteAction::make()])
            ->bulkActions([Tables\Actions\BulkActionGroup::make([Tables\Actions\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListNutritionPlans::route('/'),
            'create' => Pages\CreateNutritionPlan::route('/create'),
            'edit' => Pages\EditNutritionPlan::route('/{record}/edit'),
        ];
    }
}
