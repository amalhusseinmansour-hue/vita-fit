<?php

namespace App\Filament\Widgets;

use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\DB;

class FinancialStatsWidget extends BaseWidget
{
    protected static ?int $sort = 2;
    protected int | string | array $columnSpan = 'full';

    protected function getStats(): array
    {
        try {
            // Today's revenue (paid orders)
            $todayRevenue = DB::table('orders')
                ->whereDate('created_at', today())
                ->where('payment_status', 'paid')
                ->sum('total') ?? 0;

            // This month's revenue from orders
            $monthOrdersRevenue = DB::table('orders')
                ->whereMonth('created_at', now()->month)
                ->whereYear('created_at', now()->year)
                ->where('payment_status', 'paid')
                ->sum('total') ?? 0;

            // This month's revenue from subscriptions
            $monthSubscriptionsRevenue = DB::table('subscriptions')
                ->whereMonth('created_at', now()->month)
                ->whereYear('created_at', now()->year)
                ->where('status', 'active')
                ->sum('amount') ?? 0;

            // Total month revenue
            $monthRevenue = $monthOrdersRevenue + $monthSubscriptionsRevenue;

            // Last month's revenue
            $lastMonthOrdersRevenue = DB::table('orders')
                ->whereMonth('created_at', now()->subMonth()->month)
                ->whereYear('created_at', now()->subMonth()->year)
                ->where('payment_status', 'paid')
                ->sum('total') ?? 0;

            $lastMonthSubscriptionsRevenue = DB::table('subscriptions')
                ->whereMonth('created_at', now()->subMonth()->month)
                ->whereYear('created_at', now()->subMonth()->year)
                ->where('status', 'active')
                ->sum('amount') ?? 0;

            $lastMonthRevenue = $lastMonthOrdersRevenue + $lastMonthSubscriptionsRevenue;

            // Pending payments
            $pendingPayments = DB::table('orders')
                ->where('payment_status', 'pending')
                ->whereNotIn('status', ['cancelled', 'refunded'])
                ->sum('total') ?? 0;

            $pendingCount = DB::table('orders')
                ->where('payment_status', 'pending')
                ->whereNotIn('status', ['cancelled', 'refunded'])
                ->count();

            // Calculate growth
            $growth = $lastMonthRevenue > 0
                ? round((($monthRevenue - $lastMonthRevenue) / $lastMonthRevenue) * 100, 1)
                : ($monthRevenue > 0 ? 100 : 0);

            $growthIcon = $growth >= 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down';
            $growthColor = $growth >= 0 ? 'success' : 'danger';

        } catch (\Exception $e) {
            $todayRevenue = 0;
            $monthRevenue = 0;
            $monthSubscriptionsRevenue = 0;
            $pendingPayments = 0;
            $pendingCount = 0;
            $growth = 0;
            $growthIcon = 'heroicon-m-minus';
            $growthColor = 'gray';
        }

        return [
            Stat::make('إيرادات اليوم', number_format($todayRevenue, 2) . ' ر.س')
                ->description('الطلبات المدفوعة')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('success'),

            Stat::make('إيرادات الشهر', number_format($monthRevenue, 2) . ' ر.س')
                ->description(($growth >= 0 ? '+' : '') . $growth . '% من الشهر الماضي')
                ->descriptionIcon($growthIcon)
                ->color($growthColor),

            Stat::make('الاشتراكات', number_format($monthSubscriptionsRevenue, 2) . ' ر.س')
                ->description('إيرادات الاشتراكات')
                ->descriptionIcon('heroicon-m-credit-card')
                ->color('info'),

            Stat::make('مدفوعات معلقة', number_format($pendingPayments, 2) . ' ر.س')
                ->description($pendingCount . ' طلب بانتظار الدفع')
                ->descriptionIcon('heroicon-m-clock')
                ->color('warning'),
        ];
    }
}
