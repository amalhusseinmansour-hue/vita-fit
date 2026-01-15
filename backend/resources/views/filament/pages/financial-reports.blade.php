<x-filament-panels::page>
    <div class="space-y-6">
        {{-- Filters --}}
        <x-filament::section>
            <x-slot name="heading">
                فلترة التقرير
            </x-slot>
            <form wire:submit.prevent="$refresh" class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">من تاريخ</label>
                    <input type="date" wire:model.live="dateFrom" class="block w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-900 dark:text-white shadow-sm focus:border-primary-500 focus:ring-primary-500">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">إلى تاريخ</label>
                    <input type="date" wire:model.live="dateTo" class="block w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-900 dark:text-white shadow-sm focus:border-primary-500 focus:ring-primary-500">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">نوع التقرير</label>
                    <select wire:model.live="reportType" class="block w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-900 dark:text-white shadow-sm focus:border-primary-500 focus:ring-primary-500">
                        <option value="all">جميع الطلبات</option>
                        <option value="paid">المدفوعة فقط</option>
                        <option value="pending">المعلقة فقط</option>
                    </select>
                </div>
            </form>
        </x-filament::section>

        {{-- Stats Cards --}}
        @php $stats = $this->getStats(); @endphp
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {{-- Total Revenue --}}
            <x-filament::section>
                <div class="text-center">
                    <div class="text-3xl font-bold text-success-600">{{ number_format($stats['totalRevenue'], 2) }} ر.س</div>
                    <div class="text-sm text-gray-500 dark:text-gray-400 mt-1">إجمالي الإيرادات</div>
                </div>
            </x-filament::section>

            {{-- Orders Revenue --}}
            <x-filament::section>
                <div class="text-center">
                    <div class="text-3xl font-bold text-primary-600">{{ number_format($stats['totalOrdersRevenue'], 2) }} ر.س</div>
                    <div class="text-sm text-gray-500 dark:text-gray-400 mt-1">إيرادات الطلبات ({{ $stats['totalOrders'] }} طلب)</div>
                </div>
            </x-filament::section>

            {{-- Subscriptions Revenue --}}
            <x-filament::section>
                <div class="text-center">
                    <div class="text-3xl font-bold text-info-600">{{ number_format($stats['subscriptionsRevenue'], 2) }} ر.س</div>
                    <div class="text-sm text-gray-500 dark:text-gray-400 mt-1">إيرادات الاشتراكات ({{ $stats['activeSubscriptions'] }} نشط)</div>
                </div>
            </x-filament::section>

            {{-- Pending Payments --}}
            <x-filament::section>
                <div class="text-center">
                    <div class="text-3xl font-bold text-warning-600">{{ number_format($stats['pendingPayments'], 2) }} ر.س</div>
                    <div class="text-sm text-gray-500 dark:text-gray-400 mt-1">مدفوعات معلقة</div>
                </div>
            </x-filament::section>
        </div>

        {{-- Orders Summary --}}
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <x-filament::section>
                <x-slot name="heading">
                    ملخص الطلبات
                </x-slot>
                <div class="space-y-3">
                    <div class="flex justify-between items-center py-2 border-b dark:border-gray-700">
                        <span class="text-gray-600 dark:text-gray-400">إجمالي الطلبات</span>
                        <span class="font-semibold">{{ $stats['totalOrders'] }}</span>
                    </div>
                    <div class="flex justify-between items-center py-2 border-b dark:border-gray-700">
                        <span class="text-gray-600 dark:text-gray-400">طلبات مكتملة</span>
                        <span class="font-semibold text-success-600">{{ $stats['deliveredOrders'] }}</span>
                    </div>
                    <div class="flex justify-between items-center py-2 border-b dark:border-gray-700">
                        <span class="text-gray-600 dark:text-gray-400">طلبات ملغية</span>
                        <span class="font-semibold text-danger-600">{{ $stats['cancelledOrders'] }}</span>
                    </div>
                    <div class="flex justify-between items-center py-2">
                        <span class="text-gray-600 dark:text-gray-400">نسبة النجاح</span>
                        <span class="font-semibold text-primary-600">
                            {{ $stats['totalOrders'] > 0 ? number_format(($stats['deliveredOrders'] / $stats['totalOrders']) * 100, 1) : 0 }}%
                        </span>
                    </div>
                </div>
            </x-filament::section>

            <x-filament::section>
                <x-slot name="heading">
                    طرق الدفع
                </x-slot>
                <div class="space-y-3">
                    @forelse($stats['paymentMethods'] as $method)
                        <div class="flex justify-between items-center py-2 border-b dark:border-gray-700">
                            <span class="text-gray-600 dark:text-gray-400">
                                @switch($method->payment_method)
                                    @case('cash_on_delivery')
                                    @case('cash')
                                        الدفع عند الاستلام
                                        @break
                                    @case('bank_transfer')
                                        تحويل بنكي
                                        @break
                                    @case('wallet')
                                        محفظة إلكترونية
                                        @break
                                    @case('card')
                                        بطاقة ائتمان
                                        @break
                                    @case('paymob')
                                        Paymob
                                        @break
                                    @default
                                        {{ $method->payment_method ?? 'غير محدد' }}
                                @endswitch
                                ({{ $method->count }})
                            </span>
                            <span class="font-semibold">{{ number_format($method->total, 2) }} ر.س</span>
                        </div>
                    @empty
                        <div class="text-center text-gray-500 py-4">لا توجد بيانات</div>
                    @endforelse
                </div>
            </x-filament::section>
        </div>

        {{-- Orders Table --}}
        <x-filament::section>
            <x-slot name="heading">
                تفاصيل الطلبات
            </x-slot>
            {{ $this->table }}
        </x-filament::section>
    </div>
</x-filament-panels::page>
