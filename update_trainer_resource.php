<?php
// Update TrainerResource with password field - DELETE AFTER USE
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');

$basePath = dirname(__DIR__);
$filePath = $basePath . '/app/Filament/Resources/TrainerResource.php';

$content = '<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TrainerResource\Pages;
use App\Models\Trainer;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class TrainerResource extends Resource
{
    protected static ?string $model = Trainer::class;

    protected static ?string $navigationIcon = \'heroicon-o-academic-cap\';

    protected static ?string $navigationGroup = \'إدارة المستخدمين\';

    protected static ?string $navigationLabel = \'المدربات\';

    protected static ?string $modelLabel = \'مدربة\';

    protected static ?string $pluralModelLabel = \'المدربات\';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make(\'المعلومات الأساسية\')
                    ->schema([
                        Forms\Components\TextInput::make(\'name\')
                            ->label(\'الاسم\')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make(\'email\')
                            ->label(\'البريد الإلكتروني\')
                            ->email()
                            ->required()
                            ->unique(ignoreRecord: true),
                        Forms\Components\TextInput::make(\'password\')
                            ->label(\'كلمة المرور\')
                            ->password()
                            ->required(fn (string $context): bool => $context === \'create\')
                            ->dehydrated(fn ($state) => filled($state))
                            ->dehydrateStateUsing(fn ($state) => bcrypt($state))
                            ->helperText(\'اتركها فارغة للإبقاء على كلمة المرور الحالية عند التعديل\'),
                        Forms\Components\TextInput::make(\'phone\')
                            ->label(\'رقم الجوال\')
                            ->tel(),
                        Forms\Components\TextInput::make(\'specialization\')
                            ->label(\'التخصص\'),
                        Forms\Components\FileUpload::make(\'avatar\')
                            ->label(\'الصورة الشخصية\')
                            ->image()
                            ->directory(\'trainers\'),
                    ])->columns(2),

                Forms\Components\Section::make(\'المعلومات المهنية\')
                    ->schema([
                        Forms\Components\Textarea::make(\'bio\')
                            ->label(\'نبذة تعريفية\')
                            ->rows(3),
                        Forms\Components\TextInput::make(\'experience_years\')
                            ->label(\'سنوات الخبرة\')
                            ->numeric()
                            ->default(0),
                        Forms\Components\TagsInput::make(\'certifications\')
                            ->label(\'الشهادات\'),
                        Forms\Components\TextInput::make(\'hourly_rate\')
                            ->label(\'السعر بالساعة\')
                            ->numeric()
                            ->prefix(\'ر.س\'),
                        Forms\Components\TextInput::make(\'max_trainees\')
                            ->label(\'الحد الأقصى للمتدربات\')
                            ->numeric()
                            ->default(20),
                        Forms\Components\Select::make(\'training_type\')
                            ->label(\'نوع التدريب\')
                            ->options([
                                \'online\' => \'أونلاين\',
                                \'gym\' => \'جيم\',
                                \'home\' => \'منزلي\',
                                \'all\' => \'الكل\',
                            ])
                            ->default(\'all\'),
                    ])->columns(2),

                Forms\Components\Section::make(\'الحالة\')
                    ->schema([
                        Forms\Components\Select::make(\'status\')
                            ->label(\'الحالة\')
                            ->options([
                                \'active\' => \'نشطة\',
                                \'inactive\' => \'غير فعالة\',
                                \'on_leave\' => \'في إجازة\',
                            ])
                            ->default(\'active\'),
                        Forms\Components\TextInput::make(\'rating\')
                            ->label(\'التقييم\')
                            ->numeric()
                            ->disabled(),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make(\'avatar\')
                    ->label(\'الصورة\')
                    ->circular(),
                Tables\Columns\TextColumn::make(\'name\')
                    ->label(\'الاسم\')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make(\'email\')
                    ->label(\'البريد\')
                    ->searchable(),
                Tables\Columns\TextColumn::make(\'specialization\')
                    ->label(\'التخصص\'),
                Tables\Columns\TextColumn::make(\'experience_years\')
                    ->label(\'الخبرة\')
                    ->suffix(\' سنة\'),
                Tables\Columns\TextColumn::make(\'trainees_count\')
                    ->label(\'المتدربات\')
                    ->counts(\'trainees\'),
                Tables\Columns\TextColumn::make(\'rating\')
                    ->label(\'التقييم\')
                    ->formatStateUsing(fn ($state) => $state . \'/5\'),
                Tables\Columns\BadgeColumn::make(\'status\')
                    ->label(\'الحالة\')
                    ->colors([
                        \'success\' => \'active\',
                        \'danger\' => \'inactive\',
                        \'warning\' => \'on_leave\',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        \'active\' => \'نشطة\',
                        \'inactive\' => \'غير فعالة\',
                        \'on_leave\' => \'في إجازة\',
                        default => $state,
                    }),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make(\'status\')
                    ->label(\'الحالة\')
                    ->options([
                        \'active\' => \'نشطة\',
                        \'inactive\' => \'غير فعالة\',
                        \'on_leave\' => \'في إجازة\',
                    ]),
                Tables\Filters\SelectFilter::make(\'training_type\')
                    ->label(\'نوع التدريب\')
                    ->options([
                        \'online\' => \'أونلاين\',
                        \'gym\' => \'جيم\',
                        \'home\' => \'منزلي\',
                        \'all\' => \'الكل\',
                    ]),
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

    public static function getPages(): array
    {
        return [
            \'index\' => Pages\ListTrainers::route(\'/\'),
            \'create\' => Pages\CreateTrainer::route(\'/create\'),
            \'edit\' => Pages\EditTrainer::route(\'/{record}/edit\'),
        ];
    }
}
';

try {
    // Ensure directory exists
    $dir = dirname($filePath);
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }

    file_put_contents($filePath, $content);

    // Clear cache
    if (function_exists('opcache_reset')) {
        opcache_reset();
    }

    echo json_encode([
        'success' => true,
        'message' => 'TrainerResource updated with password field',
        'file' => $filePath
    ]);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
