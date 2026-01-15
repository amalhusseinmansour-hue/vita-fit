<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SessionResource\Pages;
use App\Models\TrainingSession;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SessionResource extends Resource
{
    protected static ?string $model = TrainingSession::class;

    protected static ?string $navigationIcon = 'heroicon-o-video-camera';

    protected static ?string $navigationGroup = 'إدارة التدريب';

    protected static ?string $navigationLabel = 'الجلسات';

    protected static ?string $modelLabel = 'جلسة';

    protected static ?string $pluralModelLabel = 'الجلسات';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الجلسة')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('عنوان الجلسة')
                            ->required(),
                        Forms\Components\Textarea::make('description')
                            ->label('الوصف')
                            ->rows(2),
                        Forms\Components\Select::make('trainer_id')
                            ->label('المدربة')
                            ->relationship('trainer', 'name')
                            ->required()
                            ->searchable(),
                        Forms\Components\Select::make('trainee_id')
                            ->label('المتدربة')
                            ->relationship('trainee', 'name')
                            ->required()
                            ->searchable(),
                    ])->columns(2),

                Forms\Components\Section::make('الموعد')
                    ->schema([
                        Forms\Components\DateTimePicker::make('scheduled_at')
                            ->label('موعد الجلسة')
                            ->required(),
                        Forms\Components\TextInput::make('duration_minutes')
                            ->label('المدة (دقيقة)')
                            ->numeric()
                            ->default(45),
                        Forms\Components\Select::make('session_type')
                            ->label('نوع الجلسة')
                            ->options([
                                'private' => 'خاصة',
                                'group' => 'جماعية',
                            ])
                            ->default('private'),
                        Forms\Components\Select::make('training_mode')
                            ->label('طريقة التدريب')
                            ->options([
                                'online' => 'أونلاين',
                                'gym' => 'جيم',
                                'home' => 'منزلي',
                            ])
                            ->default('online'),
                    ])->columns(2),

                Forms\Components\Section::make('معلومات Zoom')
                    ->schema([
                        Forms\Components\TextInput::make('zoom_meeting_id')
                            ->label('رقم الاجتماع'),
                        Forms\Components\TextInput::make('zoom_password')
                            ->label('كلمة المرور'),
                        Forms\Components\TextInput::make('zoom_join_url')
                            ->label('رابط الانضمام')
                            ->url(),
                    ])->columns(3),

                Forms\Components\Section::make('الحالة')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('الحالة')
                            ->options([
                                'scheduled' => 'مجدولة',
                                'in_progress' => 'جارية',
                                'completed' => 'مكتملة',
                                'cancelled' => 'ملغية',
                                'no_show' => 'لم تحضر',
                            ])
                            ->default('scheduled'),
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
                Tables\Columns\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable(),
                Tables\Columns\TextColumn::make('trainer.name')
                    ->label('المدربة')
                    ->sortable(),
                Tables\Columns\TextColumn::make('trainee.name')
                    ->label('المتدربة')
                    ->sortable(),
                Tables\Columns\TextColumn::make('scheduled_at')
                    ->label('الموعد')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('duration_minutes')
                    ->label('المدة')
                    ->suffix(' دقيقة'),
                Tables\Columns\BadgeColumn::make('session_type')
                    ->label('النوع')
                    ->colors([
                        'primary' => 'private',
                        'success' => 'group',
                    ])
                    ->formatStateUsing(fn ($state) => $state === 'private' ? 'خاصة' : 'جماعية'),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'scheduled',
                        'info' => 'in_progress',
                        'success' => 'completed',
                        'danger' => ['cancelled', 'no_show'],
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'scheduled' => 'مجدولة',
                        'in_progress' => 'جارية',
                        'completed' => 'مكتملة',
                        'cancelled' => 'ملغية',
                        'no_show' => 'لم تحضر',
                        default => $state,
                    }),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'scheduled' => 'مجدولة',
                        'in_progress' => 'جارية',
                        'completed' => 'مكتملة',
                        'cancelled' => 'ملغية',
                    ]),
                Tables\Filters\SelectFilter::make('trainer_id')
                    ->label('المدربة')
                    ->relationship('trainer', 'name'),
            ])
            ->actions([
                Tables\Actions\Action::make('start_session')
                    ->label('بدء الجلسة')
                    ->icon('heroicon-o-play')
                    ->color('success')
                    ->visible(fn ($record) => $record->status === 'scheduled')
                    ->action(fn ($record) => $record->update(['status' => 'in_progress'])),
                Tables\Actions\EditAction::make(),
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
            'index' => Pages\ListSessions::route('/'),
            'create' => Pages\CreateSession::route('/create'),
            'edit' => Pages\EditSession::route('/{record}/edit'),
        ];
    }
}
