<?php

namespace App\Filament\Resources;

use App\Filament\Resources\WorkoutPlanResource\Pages;
use App\Models\WorkoutPlan;
use App\Models\Trainer;
use App\Models\Trainee;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class WorkoutPlanResource extends Resource
{
    protected static ?string $model = WorkoutPlan::class;
    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-list';
    protected static ?string $navigationGroup = 'التمارين';
    protected static ?string $navigationLabel = 'برامج التمرين';
    protected static ?string $modelLabel = 'برنامج تمرين';
    protected static ?string $pluralModelLabel = 'برامج التمرين';
    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('معلومات البرنامج')
                ->schema([
                    Forms\Components\TextInput::make('name')->label('اسم البرنامج')->required(),
                    Forms\Components\Select::make('trainer_id')->label('المدربة')
                        ->options(fn () => Trainer::with('user')->get()->pluck('name', 'id'))->searchable()->preload(),
                    Forms\Components\Select::make('trainee_id')->label('المتدربة')
                        ->relationship('trainee', 'name')->searchable()->preload(),
                    Forms\Components\Select::make('goal')->label('الهدف')
                        ->options([
                            'weight_loss' => 'خسارة الوزن',
                            'muscle_gain' => 'بناء العضلات',
                            'fitness' => 'اللياقة العامة',
                            'strength' => 'القوة',
                            'flexibility' => 'المرونة',
                        ]),
                ])->columns(2),
            Forms\Components\Section::make('تفاصيل البرنامج')
                ->schema([
                    Forms\Components\Select::make('difficulty')->label('المستوى')
                        ->options(['beginner' => 'مبتدئ', 'intermediate' => 'متوسط', 'advanced' => 'متقدم'])
                        ->default('beginner'),
                    Forms\Components\TextInput::make('duration_weeks')->label('المدة (أسابيع)')->numeric()->default(4),
                    Forms\Components\TextInput::make('days_per_week')->label('أيام/أسبوع')->numeric()->default(3),
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
                Tables\Columns\TextColumn::make('name')->label('البرنامج')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('trainee.name')->label('المتدربة')->searchable(),
                Tables\Columns\TextColumn::make('trainer.user.name')->label('المدربة')->searchable(),
                Tables\Columns\TextColumn::make('duration_weeks')->label('المدة')->suffix(' أسبوع'),
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
            'index' => Pages\ListWorkoutPlans::route('/'),
            'create' => Pages\CreateWorkoutPlan::route('/create'),
            'edit' => Pages\EditWorkoutPlan::route('/{record}/edit'),
        ];
    }
}
