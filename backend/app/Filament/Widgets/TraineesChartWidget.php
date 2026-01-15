<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;

class TraineesChartWidget extends ChartWidget
{
    protected static ?string $heading = 'المستخدمين الجدد - آخر 7 أيام';
    protected static ?int $sort = 5;
    protected int | string | array $columnSpan = 1;

    protected function getData(): array
    {
        $data = [];
        $labels = [];

        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $labels[] = $date->format('d/m');

            try {
                $data[] = DB::table('users')->whereDate('created_at', $date)->count();
            } catch (\Exception $e) {
                $data[] = 0;
            }
        }

        return [
            'datasets' => [
                [
                    'label' => 'مستخدمين جدد',
                    'data' => $data,
                    'borderColor' => '#8b5cf6',
                    'backgroundColor' => 'rgba(139, 92, 246, 0.1)',
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
