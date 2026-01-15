<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;

class OrdersChartWidget extends ChartWidget
{
    protected static ?string $heading = 'الطلبات - آخر 7 أيام';
    protected static ?int $sort = 3;
    protected int | string | array $columnSpan = 1;

    protected function getData(): array
    {
        $data = [];
        $labels = [];

        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $labels[] = $date->format('d/m');

            try {
                $data[] = DB::table('orders')->whereDate('created_at', $date)->count();
            } catch (\Exception $e) {
                $data[] = 0;
            }
        }

        return [
            'datasets' => [
                [
                    'label' => 'الطلبات',
                    'data' => $data,
                    'borderColor' => '#ec4899',
                    'backgroundColor' => 'rgba(236, 72, 153, 0.1)',
                    'fill' => true,
                    'tension' => 0.4,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
