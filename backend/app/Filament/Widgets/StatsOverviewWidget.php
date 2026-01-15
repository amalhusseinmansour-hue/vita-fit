<?php

namespace App\Filament\Widgets;

use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\DB;

class StatsOverviewWidget extends BaseWidget
{
    protected static ?int $sort = 1;
    protected int | string | array $columnSpan = 'full';

    protected function getStats(): array
    {
        // Safe counts with try-catch
        $totalOrders = $this->safeCount('orders');
        $pendingOrders = $this->safeCount('orders', ['status' => 'pending']);
        $totalTrainees = $this->safeCount('trainees');
        $totalUsers = $this->safeCount('users');
        $totalProducts = $this->safeCount('products', ['is_active' => 1]);
        $todayOrders = DB::table('orders')->whereDate('created_at', today())->count();

        return [
            Stat::make('إجمالي الطلبات', $totalOrders)
                ->description('طلبات معلقة: ' . $pendingOrders)
                ->descriptionIcon('heroicon-m-clock')
                ->color('primary')
                ->chart([7, 3, 4, 5, 6, 3, 5]),

            Stat::make('المستخدمين', $totalUsers)
                ->description('المتدربات: ' . $totalTrainees)
                ->descriptionIcon('heroicon-m-user-group')
                ->color('success')
                ->chart([3, 5, 7, 6, 8, 9, 10]),

            Stat::make('المنتجات النشطة', $totalProducts)
                ->description('طلبات اليوم: ' . $todayOrders)
                ->descriptionIcon('heroicon-m-shopping-bag')
                ->color('warning')
                ->chart([5, 4, 6, 5, 7, 8, 6]),

            Stat::make('طلبات اليوم', $todayOrders)
                ->description('جديد')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('info'),
        ];
    }

    private function safeCount(string $table, array $where = []): int
    {
        try {
            $query = DB::table($table);
            foreach ($where as $column => $value) {
                $query->where($column, $value);
            }
            return $query->count();
        } catch (\Exception $e) {
            return 0;
        }
    }
}
