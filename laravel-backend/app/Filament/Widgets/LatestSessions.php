<?php

namespace App\Filament\Widgets;

use App\Models\TrainingSession;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LatestSessions extends BaseWidget
{
    protected static ?int $sort = 2;

    protected int | string | array $columnSpan = 'full';

    protected static ?string $heading = 'أحدث الجلسات';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                TrainingSession::query()
                    ->with(['trainer', 'trainee'])
                    ->orderBy('scheduled_at', 'desc')
                    ->limit(5)
            )
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable(),
                Tables\Columns\TextColumn::make('trainer.name')
                    ->label('المدربة'),
                Tables\Columns\TextColumn::make('trainee.name')
                    ->label('المتدربة'),
                Tables\Columns\TextColumn::make('scheduled_at')
                    ->label('الموعد')
                    ->dateTime('Y-m-d H:i'),
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
            ->paginated(false);
    }
}
