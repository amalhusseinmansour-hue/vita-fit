<?php

namespace App\Filament\Pages;

use App\Models\Order;
use App\Models\Subscription;
use Filament\Pages\Page;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Concerns\InteractsWithTable;
use Filament\Tables\Contracts\HasTable;
use Filament\Tables\Table;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Builder;
use Livewire\Attributes\Url;

class FinancialReports extends Page implements HasForms, HasTable
{
    use InteractsWithForms;
    use InteractsWithTable;

    protected static ?string $navigationIcon = 'heroicon-o-chart-bar';
    protected static ?string $navigationGroup = 'المالية';
    protected static ?string $navigationLabel = 'التقارير المالية';
    protected static ?string $title = 'التقارير المالية';
    protected static ?int $navigationSort = 2;

    protected static string $view = 'filament.pages.financial-reports';

    #[Url]
    public ?string $dateFrom = null;

    #[Url]
    public ?string $dateTo = null;

    #[Url]
    public ?string $reportType = 'all';

    public function mount(): void
    {
        $this->dateFrom = now()->startOfMonth()->format('Y-m-d');
        $this->dateTo = now()->format('Y-m-d');
    }

    public function getStats(): array
    {
        $dateFrom = $this->dateFrom ?? now()->startOfMonth()->format('Y-m-d');
        $dateTo = $this->dateTo ?? now()->format('Y-m-d');

        // Orders stats
        $ordersQuery = DB::table('orders')
            ->whereDate('created_at', '>=', $dateFrom)
            ->whereDate('created_at', '<=', $dateTo);

        $totalOrders = (clone $ordersQuery)->count();
        $totalOrdersRevenue = (clone $ordersQuery)->where('payment_status', 'paid')->sum('total') ?? 0;
        $pendingPayments = (clone $ordersQuery)->where('payment_status', 'pending')->sum('total') ?? 0;
        $cancelledOrders = (clone $ordersQuery)->where('status', 'cancelled')->count();
        $deliveredOrders = (clone $ordersQuery)->where('status', 'delivered')->count();

        // Subscriptions stats
        $subscriptionsQuery = DB::table('subscriptions')
            ->whereDate('created_at', '>=', $dateFrom)
            ->whereDate('created_at', '<=', $dateTo);

        $totalSubscriptions = (clone $subscriptionsQuery)->count();
        $activeSubscriptions = (clone $subscriptionsQuery)->where('status', 'active')->count();
        $subscriptionsRevenue = (clone $subscriptionsQuery)->where('status', 'active')->sum('amount') ?? 0;

        // Total revenue
        $totalRevenue = $totalOrdersRevenue + $subscriptionsRevenue;

        // Payment methods breakdown
        $paymentMethods = DB::table('orders')
            ->whereDate('created_at', '>=', $dateFrom)
            ->whereDate('created_at', '<=', $dateTo)
            ->where('payment_status', 'paid')
            ->select('payment_method', DB::raw('COUNT(*) as count'), DB::raw('SUM(total) as total'))
            ->groupBy('payment_method')
            ->get();

        return [
            'totalOrders' => $totalOrders,
            'totalOrdersRevenue' => $totalOrdersRevenue,
            'pendingPayments' => $pendingPayments,
            'cancelledOrders' => $cancelledOrders,
            'deliveredOrders' => $deliveredOrders,
            'totalSubscriptions' => $totalSubscriptions,
            'activeSubscriptions' => $activeSubscriptions,
            'subscriptionsRevenue' => $subscriptionsRevenue,
            'totalRevenue' => $totalRevenue,
            'paymentMethods' => $paymentMethods,
        ];
    }

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Order::query()
                    ->when($this->dateFrom, fn ($q) => $q->whereDate('created_at', '>=', $this->dateFrom))
                    ->when($this->dateTo, fn ($q) => $q->whereDate('created_at', '<=', $this->dateTo))
                    ->when($this->reportType === 'paid', fn ($q) => $q->where('payment_status', 'paid'))
                    ->when($this->reportType === 'pending', fn ($q) => $q->where('payment_status', 'pending'))
                    ->latest()
            )
            ->columns([
                TextColumn::make('order_number')
                    ->label('رقم الطلب')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('trainee.name')
                    ->label('العميلة')
                    ->searchable()
                    ->default('زائر'),
                TextColumn::make('total')
                    ->label('المبلغ')
                    ->money('SAR')
                    ->sortable(),
                BadgeColumn::make('payment_status')
                    ->label('حالة الدفع')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'paid',
                        'danger' => fn ($state) => in_array($state, ['failed', 'refunded']),
                    ])
                    ->formatStateUsing(fn ($state) => match ($state) {
                        'pending' => 'معلق',
                        'paid' => 'مدفوع',
                        'failed' => 'فشل',
                        'refunded' => 'مسترد',
                        default => $state,
                    }),
                TextColumn::make('payment_method')
                    ->label('طريقة الدفع')
                    ->formatStateUsing(fn ($state) => match ($state) {
                        'cash_on_delivery' => 'عند الاستلام',
                        'bank_transfer' => 'تحويل بنكي',
                        'wallet' => 'محفظة',
                        'card' => 'بطاقة',
                        'cash' => 'نقدي',
                        'paymob' => 'Paymob',
                        default => $state ?? '-',
                    }),
                BadgeColumn::make('status')
                    ->label('حالة الطلب')
                    ->colors([
                        'warning' => 'pending',
                        'info' => fn ($state) => in_array($state, ['confirmed', 'processing']),
                        'primary' => 'shipped',
                        'success' => 'delivered',
                        'danger' => fn ($state) => in_array($state, ['cancelled', 'refunded']),
                    ])
                    ->formatStateUsing(fn ($state) => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'confirmed' => 'تم التأكيد',
                        'processing' => 'جاري التجهيز',
                        'shipped' => 'تم الشحن',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغي',
                        'refunded' => 'مسترد',
                        default => $state,
                    }),
                TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc');
    }

    protected function getFormSchema(): array
    {
        return [
            DatePicker::make('dateFrom')
                ->label('من تاريخ')
                ->default(now()->startOfMonth()),
            DatePicker::make('dateTo')
                ->label('إلى تاريخ')
                ->default(now()),
            Select::make('reportType')
                ->label('نوع التقرير')
                ->options([
                    'all' => 'جميع الطلبات',
                    'paid' => 'المدفوعة فقط',
                    'pending' => 'المعلقة فقط',
                ])
                ->default('all'),
        ];
    }
}
