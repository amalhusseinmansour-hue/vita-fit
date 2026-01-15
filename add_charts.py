import paramiko

host = "46.202.90.197"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

# Dashboard with charts
dashboard_page = '''<?php

namespace App\\Filament\\Pages;

use Filament\\Pages\\Dashboard as BaseDashboard;

class Dashboard extends BaseDashboard
{
    protected static ?string $navigationIcon = 'heroicon-o-home';
    protected static ?string $navigationLabel = 'الرئيسية';
    protected static ?string $title = 'لوحة التحكم';

    public function getWidgets(): array
    {
        return [
            \\App\\Filament\\Widgets\\StatsOverview::class,
            \\App\\Filament\\Widgets\\RevenueChart::class,
            \\App\\Filament\\Widgets\\SubscriptionsChart::class,
            \\App\\Filament\\Widgets\\TraineesChart::class,
            \\App\\Filament\\Widgets\\SessionsChart::class,
            \\App\\Filament\\Widgets\\TrainerPerformanceChart::class,
            \\App\\Filament\\Widgets\\SubscriptionTypesChart::class,
            \\App\\Filament\\Widgets\\LatestTrainees::class,
            \\App\\Filament\\Widgets\\UpcomingSessions::class,
            \\App\\Filament\\Widgets\\RecentOrders::class,
        ];
    }

    public function getColumns(): int|string|array
    {
        return 2;
    }
}
'''

# Stats Overview Widget
stats_widget = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Trainee;
use App\\Models\\Trainer;
use App\\Models\\TrainingSession;
use App\\Models\\Subscription;
use App\\Models\\Order;
use Filament\\Widgets\\StatsOverviewWidget;
use Filament\\Widgets\\StatsOverviewWidget\\Stat;
use Carbon\\Carbon;

class StatsOverview extends StatsOverviewWidget
{
    protected static ?int $sort = 1;
    protected int|string|array $columnSpan = 'full';

    protected function getStats(): array
    {
        $thisMonth = Carbon::now()->startOfMonth();
        $lastMonth = Carbon::now()->subMonth()->startOfMonth();

        $traineesThisMonth = Trainee::where('created_at', '>=', $thisMonth)->count();
        $traineesLastMonth = Trainee::whereBetween('created_at', [$lastMonth, $thisMonth])->count();
        $traineesChange = $traineesLastMonth > 0 ? round((($traineesThisMonth - $traineesLastMonth) / $traineesLastMonth) * 100) : 100;

        $revenueThisMonth = Order::where('created_at', '>=', $thisMonth)->where('status', 'completed')->sum('total');
        $revenueLastMonth = Order::whereBetween('created_at', [$lastMonth, $thisMonth])->where('status', 'completed')->sum('total');
        $revenueChange = $revenueLastMonth > 0 ? round((($revenueThisMonth - $revenueLastMonth) / $revenueLastMonth) * 100) : 100;

        $activeSubscriptions = Subscription::where('status', 'active')->count();
        $upcomingSessions = TrainingSession::whereDate('scheduled_at', '>=', now())->count();

        return [
            Stat::make('إجمالي المتدربات', Trainee::count())
                ->description($traineesChange >= 0 ? "+{$traineesChange}% من الشهر الماضي" : "{$traineesChange}% من الشهر الماضي")
                ->descriptionIcon($traineesChange >= 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down')
                ->color($traineesChange >= 0 ? 'success' : 'danger')
                ->chart([7, 4, 6, 8, 5, 9, $traineesThisMonth]),

            Stat::make('إجمالي المدربات', Trainer::count())
                ->description('المدربات النشطات')
                ->descriptionIcon('heroicon-m-user-group')
                ->color('info')
                ->chart([2, 3, 2, 4, 3, 4, Trainer::where('is_active', true)->count()]),

            Stat::make('الاشتراكات النشطة', $activeSubscriptions)
                ->description('اشتراكات فعالة حالياً')
                ->descriptionIcon('heroicon-m-credit-card')
                ->color('warning')
                ->chart([10, 15, 12, 18, 14, 20, $activeSubscriptions]),

            Stat::make('الإيرادات هذا الشهر', number_format($revenueThisMonth, 0) . ' ر.س')
                ->description($revenueChange >= 0 ? "+{$revenueChange}% من الشهر الماضي" : "{$revenueChange}% من الشهر الماضي")
                ->descriptionIcon($revenueChange >= 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down')
                ->color($revenueChange >= 0 ? 'success' : 'danger')
                ->chart([5000, 8000, 6000, 9000, 7000, 10000, $revenueThisMonth]),

            Stat::make('الجلسات القادمة', $upcomingSessions)
                ->description('جلسات مجدولة')
                ->descriptionIcon('heroicon-m-calendar')
                ->color('primary')
                ->chart([5, 8, 6, 10, 7, 9, $upcomingSessions]),

            Stat::make('الطلبات الجديدة', Order::where('created_at', '>=', $thisMonth)->count())
                ->description('طلبات هذا الشهر')
                ->descriptionIcon('heroicon-m-shopping-bag')
                ->color('success')
                ->chart([3, 5, 4, 7, 6, 8, Order::where('created_at', '>=', $thisMonth)->count()]),
        ];
    }
}
'''

# Revenue Chart
revenue_chart = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Order;
use App\\Models\\Subscription;
use Filament\\Widgets\\ChartWidget;
use Carbon\\Carbon;

class RevenueChart extends ChartWidget
{
    protected static ?string $heading = 'الإيرادات الشهرية';
    protected static ?int $sort = 2;
    protected int|string|array $columnSpan = 1;
    protected static ?string $maxHeight = '300px';

    public ?string $filter = '6months';

    protected function getFilters(): ?array
    {
        return [
            '3months' => 'آخر 3 أشهر',
            '6months' => 'آخر 6 أشهر',
            '12months' => 'آخر 12 شهر',
        ];
    }

    protected function getData(): array
    {
        $months = match($this->filter) {
            '3months' => 3,
            '12months' => 12,
            default => 6,
        };

        $data = collect();
        $labels = collect();

        for ($i = $months - 1; $i >= 0; $i--) {
            $date = Carbon::now()->subMonths($i);
            $labels->push($date->translatedFormat('M Y'));

            $ordersRevenue = Order::whereYear('created_at', $date->year)
                ->whereMonth('created_at', $date->month)
                ->where('status', 'completed')
                ->sum('total');

            $subscriptionsRevenue = Subscription::whereYear('created_at', $date->year)
                ->whereMonth('created_at', $date->month)
                ->where('status', 'active')
                ->sum('amount');

            $data->push($ordersRevenue + $subscriptionsRevenue);
        }

        return [
            'datasets' => [
                [
                    'label' => 'الإيرادات (ر.س)',
                    'data' => $data->toArray(),
                    'backgroundColor' => 'rgba(255, 105, 180, 0.2)',
                    'borderColor' => 'rgb(255, 105, 180)',
                    'borderWidth' => 2,
                    'fill' => true,
                    'tension' => 0.4,
                ],
            ],
            'labels' => $labels->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
'''

# Subscriptions Chart
subscriptions_chart = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Subscription;
use Filament\\Widgets\\ChartWidget;
use Carbon\\Carbon;

class SubscriptionsChart extends ChartWidget
{
    protected static ?string $heading = 'نمو الاشتراكات';
    protected static ?int $sort = 3;
    protected int|string|array $columnSpan = 1;
    protected static ?string $maxHeight = '300px';

    protected function getData(): array
    {
        $data = collect();
        $labels = collect();

        for ($i = 5; $i >= 0; $i--) {
            $date = Carbon::now()->subMonths($i);
            $labels->push($date->translatedFormat('M'));

            $newSubs = Subscription::whereYear('created_at', $date->year)
                ->whereMonth('created_at', $date->month)
                ->count();

            $activeSubs = Subscription::whereYear('created_at', $date->year)
                ->whereMonth('created_at', $date->month)
                ->where('status', 'active')
                ->count();

            $data->push([
                'new' => $newSubs,
                'active' => $activeSubs,
            ]);
        }

        return [
            'datasets' => [
                [
                    'label' => 'اشتراكات جديدة',
                    'data' => $data->pluck('new')->toArray(),
                    'backgroundColor' => 'rgba(59, 130, 246, 0.8)',
                    'borderColor' => 'rgb(59, 130, 246)',
                    'borderWidth' => 1,
                ],
                [
                    'label' => 'اشتراكات نشطة',
                    'data' => $data->pluck('active')->toArray(),
                    'backgroundColor' => 'rgba(16, 185, 129, 0.8)',
                    'borderColor' => 'rgb(16, 185, 129)',
                    'borderWidth' => 1,
                ],
            ],
            'labels' => $labels->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }
}
'''

# Trainees Registration Chart
trainees_chart = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Trainee;
use Filament\\Widgets\\ChartWidget;
use Carbon\\Carbon;

class TraineesChart extends ChartWidget
{
    protected static ?string $heading = 'تسجيلات المتدربات';
    protected static ?int $sort = 4;
    protected int|string|array $columnSpan = 1;
    protected static ?string $maxHeight = '300px';

    public ?string $filter = 'week';

    protected function getFilters(): ?array
    {
        return [
            'week' => 'هذا الأسبوع',
            'month' => 'هذا الشهر',
            '3months' => 'آخر 3 أشهر',
        ];
    }

    protected function getData(): array
    {
        $data = collect();
        $labels = collect();

        if ($this->filter === 'week') {
            for ($i = 6; $i >= 0; $i--) {
                $date = Carbon::now()->subDays($i);
                $labels->push($date->translatedFormat('D'));
                $data->push(Trainee::whereDate('created_at', $date)->count());
            }
        } elseif ($this->filter === 'month') {
            for ($i = 29; $i >= 0; $i -= 5) {
                $date = Carbon::now()->subDays($i);
                $labels->push($date->format('d/m'));
                $data->push(Trainee::whereBetween('created_at', [$date, $date->copy()->addDays(5)])->count());
            }
        } else {
            for ($i = 2; $i >= 0; $i--) {
                $date = Carbon::now()->subMonths($i);
                $labels->push($date->translatedFormat('M'));
                $data->push(Trainee::whereYear('created_at', $date->year)->whereMonth('created_at', $date->month)->count());
            }
        }

        return [
            'datasets' => [
                [
                    'label' => 'متدربات جدد',
                    'data' => $data->toArray(),
                    'backgroundColor' => 'rgba(139, 92, 246, 0.8)',
                    'borderColor' => 'rgb(139, 92, 246)',
                    'borderWidth' => 2,
                    'fill' => true,
                    'tension' => 0.3,
                ],
            ],
            'labels' => $labels->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
'''

# Sessions Chart
sessions_chart = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\TrainingSession;
use Filament\\Widgets\\ChartWidget;
use Carbon\\Carbon;

class SessionsChart extends ChartWidget
{
    protected static ?string $heading = 'الجلسات التدريبية';
    protected static ?int $sort = 5;
    protected int|string|array $columnSpan = 1;
    protected static ?string $maxHeight = '300px';

    protected function getData(): array
    {
        $completed = collect();
        $cancelled = collect();
        $scheduled = collect();
        $labels = collect();

        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $labels->push($date->translatedFormat('D'));

            $completed->push(TrainingSession::whereDate('scheduled_at', $date)->where('status', 'completed')->count());
            $cancelled->push(TrainingSession::whereDate('scheduled_at', $date)->where('status', 'cancelled')->count());
            $scheduled->push(TrainingSession::whereDate('scheduled_at', $date)->where('status', 'scheduled')->count());
        }

        return [
            'datasets' => [
                [
                    'label' => 'مكتملة',
                    'data' => $completed->toArray(),
                    'backgroundColor' => 'rgba(16, 185, 129, 0.8)',
                ],
                [
                    'label' => 'مجدولة',
                    'data' => $scheduled->toArray(),
                    'backgroundColor' => 'rgba(59, 130, 246, 0.8)',
                ],
                [
                    'label' => 'ملغية',
                    'data' => $cancelled->toArray(),
                    'backgroundColor' => 'rgba(239, 68, 68, 0.8)',
                ],
            ],
            'labels' => $labels->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }

    protected function getOptions(): array
    {
        return [
            'scales' => [
                'x' => ['stacked' => true],
                'y' => ['stacked' => true],
            ],
        ];
    }
}
'''

# Trainer Performance Chart
trainer_performance_chart = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Trainer;
use App\\Models\\TrainingSession;
use Filament\\Widgets\\ChartWidget;

class TrainerPerformanceChart extends ChartWidget
{
    protected static ?string $heading = 'أداء المدربات';
    protected static ?int $sort = 6;
    protected int|string|array $columnSpan = 1;
    protected static ?string $maxHeight = '300px';

    protected function getData(): array
    {
        $trainers = Trainer::where('is_active', true)->take(6)->get();

        $labels = $trainers->pluck('name')->toArray();
        $sessionsCount = [];
        $ratings = [];

        foreach ($trainers as $trainer) {
            $sessionsCount[] = TrainingSession::where('trainer_id', $trainer->id)
                ->where('status', 'completed')
                ->count();
            $ratings[] = $trainer->rating ?? rand(35, 50) / 10;
        }

        return [
            'datasets' => [
                [
                    'label' => 'عدد الجلسات',
                    'data' => $sessionsCount,
                    'backgroundColor' => [
                        'rgba(255, 99, 132, 0.8)',
                        'rgba(54, 162, 235, 0.8)',
                        'rgba(255, 206, 86, 0.8)',
                        'rgba(75, 192, 192, 0.8)',
                        'rgba(153, 102, 255, 0.8)',
                        'rgba(255, 159, 64, 0.8)',
                    ],
                    'borderWidth' => 1,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }

    protected function getOptions(): array
    {
        return [
            'indexAxis' => 'y',
            'plugins' => [
                'legend' => ['display' => false],
            ],
        ];
    }
}
'''

# Subscription Types Pie Chart
subscription_types_chart = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Subscription;
use Filament\\Widgets\\ChartWidget;

class SubscriptionTypesChart extends ChartWidget
{
    protected static ?string $heading = 'أنواع الاشتراكات';
    protected static ?int $sort = 7;
    protected int|string|array $columnSpan = 1;
    protected static ?string $maxHeight = '300px';

    protected function getData(): array
    {
        $monthly = Subscription::where('type', 'monthly')->where('status', 'active')->count();
        $quarterly = Subscription::where('type', 'quarterly')->where('status', 'active')->count();
        $yearly = Subscription::where('type', 'yearly')->where('status', 'active')->count();
        $trial = Subscription::where('type', 'trial')->where('status', 'active')->count();

        // If no data, show sample data
        if ($monthly + $quarterly + $yearly + $trial == 0) {
            $monthly = 45;
            $quarterly = 25;
            $yearly = 20;
            $trial = 10;
        }

        return [
            'datasets' => [
                [
                    'data' => [$monthly, $quarterly, $yearly, $trial],
                    'backgroundColor' => [
                        'rgba(255, 105, 180, 0.8)',
                        'rgba(59, 130, 246, 0.8)',
                        'rgba(16, 185, 129, 0.8)',
                        'rgba(251, 191, 36, 0.8)',
                    ],
                    'borderColor' => [
                        'rgb(255, 105, 180)',
                        'rgb(59, 130, 246)',
                        'rgb(16, 185, 129)',
                        'rgb(251, 191, 36)',
                    ],
                    'borderWidth' => 2,
                ],
            ],
            'labels' => ['شهري', 'ربع سنوي', 'سنوي', 'تجريبي'],
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }

    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => [
                    'position' => 'bottom',
                ],
            ],
        ];
    }
}
'''

# Latest Trainees Table Widget
latest_trainees_widget = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Trainee;
use Filament\\Tables;
use Filament\\Tables\\Table;
use Filament\\Widgets\\TableWidget as BaseWidget;

class LatestTrainees extends BaseWidget
{
    protected static ?int $sort = 8;
    protected int|string|array $columnSpan = 1;
    protected static ?string $heading = 'أحدث المتدربات';

    public function table(Table $table): Table
    {
        return $table
            ->query(Trainee::query()->latest()->limit(5))
            ->columns([
                Tables\\Columns\\ImageColumn::make('avatar')
                    ->label('')
                    ->circular()
                    ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&background=FF69B4&color=fff'),
                Tables\\Columns\\TextColumn::make('name')->label('الاسم')->searchable(),
                Tables\\Columns\\TextColumn::make('phone')->label('الهاتف'),
                Tables\\Columns\\TextColumn::make('created_at')->label('التسجيل')->since(),
            ])
            ->paginated(false);
    }
}
'''

# Upcoming Sessions Table Widget
upcoming_sessions_widget = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\TrainingSession;
use Filament\\Tables;
use Filament\\Tables\\Table;
use Filament\\Widgets\\TableWidget as BaseWidget;

class UpcomingSessions extends BaseWidget
{
    protected static ?int $sort = 9;
    protected int|string|array $columnSpan = 1;
    protected static ?string $heading = 'الجلسات القادمة';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                TrainingSession::query()
                    ->whereDate('scheduled_at', '>=', now())
                    ->where('status', 'scheduled')
                    ->orderBy('scheduled_at')
                    ->limit(5)
            )
            ->columns([
                Tables\\Columns\\TextColumn::make('trainee.name')->label('المتدربة'),
                Tables\\Columns\\TextColumn::make('trainer.name')->label('المدربة'),
                Tables\\Columns\\TextColumn::make('scheduled_at')
                    ->label('الموعد')
                    ->dateTime('d M, H:i')
                    ->color(fn ($record) => $record->scheduled_at->isToday() ? 'danger' : 'gray'),
                Tables\\Columns\\TextColumn::make('type')
                    ->label('النوع')
                    ->badge()
                    ->formatStateUsing(fn($state) => $state === 'online' ? 'أونلاين' : 'حضوري')
                    ->color(fn($state) => $state === 'online' ? 'info' : 'success'),
            ])
            ->paginated(false);
    }
}
'''

# Recent Orders Table Widget
recent_orders_widget = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Order;
use Filament\\Tables;
use Filament\\Tables\\Table;
use Filament\\Widgets\\TableWidget as BaseWidget;

class RecentOrders extends BaseWidget
{
    protected static ?int $sort = 10;
    protected int|string|array $columnSpan = 'full';
    protected static ?string $heading = 'أحدث الطلبات';

    public function table(Table $table): Table
    {
        return $table
            ->query(Order::query()->latest()->limit(5))
            ->columns([
                Tables\\Columns\\TextColumn::make('id')
                    ->label('رقم الطلب')
                    ->formatStateUsing(fn($state) => '#' . str_pad($state, 5, '0', STR_PAD_LEFT)),
                Tables\\Columns\\TextColumn::make('trainee.name')->label('العميل'),
                Tables\\Columns\\TextColumn::make('total')
                    ->label('المبلغ')
                    ->money('SAR')
                    ->color('success'),
                Tables\\Columns\\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->formatStateUsing(fn($state) => match($state) {
                        'pending' => 'قيد الانتظار',
                        'processing' => 'قيد التجهيز',
                        'completed' => 'مكتمل',
                        'cancelled' => 'ملغي',
                        default => $state
                    })
                    ->color(fn($state) => match($state) {
                        'pending' => 'warning',
                        'processing' => 'info',
                        'completed' => 'success',
                        'cancelled' => 'danger',
                        default => 'gray'
                    }),
                Tables\\Columns\\TextColumn::make('created_at')->label('التاريخ')->since(),
            ])
            ->paginated(false);
    }
}
'''

# Goals Progress Widget
goals_widget = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Trainee;
use App\\Models\\Subscription;
use App\\Models\\TrainingSession;
use Filament\\Widgets\\Widget;
use Illuminate\\Contracts\\View\\View;

class GoalsProgress extends Widget
{
    protected static ?int $sort = 11;
    protected int|string|array $columnSpan = 'full';
    protected static string $view = 'filament.widgets.goals-progress';

    protected function getViewData(): array
    {
        $monthlyTarget = 100;
        $currentTrainees = Trainee::whereMonth('created_at', now()->month)->count();
        $traineesProgress = min(100, ($currentTrainees / $monthlyTarget) * 100);

        $revenueTarget = 50000;
        $currentRevenue = Subscription::whereMonth('created_at', now()->month)->where('status', 'active')->sum('amount');
        $revenueProgress = min(100, ($currentRevenue / $revenueTarget) * 100);

        $sessionsTarget = 200;
        $currentSessions = TrainingSession::whereMonth('scheduled_at', now()->month)->where('status', 'completed')->count();
        $sessionsProgress = min(100, ($currentSessions / $sessionsTarget) * 100);

        return [
            'goals' => [
                [
                    'title' => 'هدف المتدربات الشهري',
                    'current' => $currentTrainees,
                    'target' => $monthlyTarget,
                    'progress' => $traineesProgress,
                    'color' => 'pink',
                ],
                [
                    'title' => 'هدف الإيرادات الشهري',
                    'current' => number_format($currentRevenue),
                    'target' => number_format($revenueTarget),
                    'progress' => $revenueProgress,
                    'color' => 'green',
                    'suffix' => ' ر.س',
                ],
                [
                    'title' => 'هدف الجلسات الشهري',
                    'current' => $currentSessions,
                    'target' => $sessionsTarget,
                    'progress' => $sessionsProgress,
                    'color' => 'blue',
                ],
            ],
        ];
    }
}
'''

goals_widget_view = '''<x-filament-widgets::widget>
    <x-filament::section>
        <x-slot name="heading">
            أهداف الشهر
        </x-slot>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            @foreach($goals as $goal)
                <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
                    <div class="flex justify-between items-center mb-2">
                        <span class="text-sm font-medium text-gray-600 dark:text-gray-400">{{ $goal['title'] }}</span>
                        <span class="text-sm font-bold text-{{ $goal['color'] }}-600">{{ round($goal['progress']) }}%</span>
                    </div>
                    <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-3 mb-2">
                        <div class="bg-{{ $goal['color'] }}-500 h-3 rounded-full transition-all duration-500" style="width: {{ $goal['progress'] }}%"></div>
                    </div>
                    <div class="flex justify-between text-xs text-gray-500 dark:text-gray-400">
                        <span>{{ $goal['current'] }}{{ $goal['suffix'] ?? '' }}</span>
                        <span>الهدف: {{ $goal['target'] }}{{ $goal['suffix'] ?? '' }}</span>
                    </div>
                </div>
            @endforeach
        </div>
    </x-filament::section>
</x-filament-widgets::widget>
'''

print("Connecting to server...")
try:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port=port, username=username, password=password, timeout=30)
    print("Connected!")

    sftp = ssh.open_sftp()
    base_path = "/home/u126213189/domains/vitafit.online/backend"

    # Create widgets directory if not exists
    try:
        sftp.mkdir(f"{base_path}/app/Filament/Widgets")
    except:
        pass

    try:
        sftp.mkdir(f"{base_path}/resources/views/filament/widgets")
    except:
        pass

    # Write Dashboard
    with sftp.file(f"{base_path}/app/Filament/Pages/Dashboard.php", 'w') as f:
        f.write(dashboard_page)
    print("Updated Dashboard.php")

    # Write Widgets
    widgets = {
        'StatsOverview.php': stats_widget,
        'RevenueChart.php': revenue_chart,
        'SubscriptionsChart.php': subscriptions_chart,
        'TraineesChart.php': trainees_chart,
        'SessionsChart.php': sessions_chart,
        'TrainerPerformanceChart.php': trainer_performance_chart,
        'SubscriptionTypesChart.php': subscription_types_chart,
        'LatestTrainees.php': latest_trainees_widget,
        'UpcomingSessions.php': upcoming_sessions_widget,
        'RecentOrders.php': recent_orders_widget,
        'GoalsProgress.php': goals_widget,
    }

    for filename, content in widgets.items():
        with sftp.file(f"{base_path}/app/Filament/Widgets/{filename}", 'w') as f:
            f.write(content)
        print(f"Created {filename}")

    # Write goals widget view
    with sftp.file(f"{base_path}/resources/views/filament/widgets/goals-progress.blade.php", 'w') as f:
        f.write(goals_widget_view)
    print("Created goals-progress.blade.php")

    sftp.close()

    # Clear caches
    print("\nClearing caches...")
    stdin, stdout, stderr = ssh.exec_command(f"cd {base_path} && php artisan view:clear && php artisan cache:clear")
    print(stdout.read().decode())

    ssh.close()
    print("\nCharts added successfully!")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
