<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use App\Models\Trainee;
use App\Models\Trainer;
use App\Models\TrainingSession;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        return [
            Stat::make('المتدربات', Trainee::count())
                ->description('إجمالي المتدربات')
                ->descriptionIcon('heroicon-m-users')
                ->chart([7, 3, 4, 5, 6, 3, 5])
                ->color('success'),

            Stat::make('المدربات', Trainer::count())
                ->description('إجمالي المدربات')
                ->descriptionIcon('heroicon-m-academic-cap')
                ->chart([3, 5, 4, 3, 6, 5, 4])
                ->color('info'),

            Stat::make('الجلسات اليوم', TrainingSession::whereDate('scheduled_at', today())->count())
                ->description('جلسات مجدولة')
                ->descriptionIcon('heroicon-m-video-camera')
                ->chart([5, 3, 6, 4, 5, 7, 4])
                ->color('warning'),

            Stat::make('الطلبات الجديدة', Order::where('status', 'pending')->count())
                ->description('بانتظار المعالجة')
                ->descriptionIcon('heroicon-m-shopping-cart')
                ->chart([4, 6, 3, 5, 4, 6, 5])
                ->color('danger'),
        ];
    }
}
