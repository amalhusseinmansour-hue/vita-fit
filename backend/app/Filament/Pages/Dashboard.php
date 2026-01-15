<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\FinancialStatsWidget;
use App\Filament\Widgets\LatestOrdersWidget;
use App\Filament\Widgets\OrdersChartWidget;
use App\Filament\Widgets\RevenueChartWidget;
use App\Filament\Widgets\StatsOverviewWidget;
use App\Filament\Widgets\TraineesChartWidget;
use Filament\Pages\Dashboard as BaseDashboard;

class Dashboard extends BaseDashboard
{
    protected static ?string $navigationIcon = 'heroicon-o-home';
    protected static ?string $navigationLabel = 'لوحة التحكم';
    protected static ?string $title = 'لوحة التحكم';

    public function getWidgets(): array
    {
        return [
            StatsOverviewWidget::class,
            FinancialStatsWidget::class,
            OrdersChartWidget::class,
            RevenueChartWidget::class,
            TraineesChartWidget::class,
            LatestOrdersWidget::class,
        ];
    }

    public function getColumns(): int|string|array
    {
        return 2;
    }
}
