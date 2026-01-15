<x-filament-panels::page>
    <form wire:submit="save">
        {{ $this->form }}

        <div class="mt-6">
            <x-filament::button type="submit" size="lg">
                <x-slot name="icon">
                    <x-heroicon-o-check class="w-5 h-5" />
                </x-slot>
                حفظ الإعدادات
            </x-filament::button>
        </div>
    </form>

    <div class="mt-8 p-4 bg-gray-100 dark:bg-gray-800 rounded-lg">
        <h3 class="text-lg font-semibold mb-3">معاينة الألوان</h3>
        <div class="flex flex-wrap gap-4">
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-lg shadow" style="background-color: {{ $this->primary_color }}"></div>
                <span class="text-sm">الرئيسي</span>
            </div>
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-lg shadow" style="background-color: {{ $this->secondary_color }}"></div>
                <span class="text-sm">الثانوي</span>
            </div>
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-lg shadow" style="background-color: {{ $this->accent_color }}"></div>
                <span class="text-sm">التمييز</span>
            </div>
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-lg shadow" style="background-color: {{ $this->success_color }}"></div>
                <span class="text-sm">النجاح</span>
            </div>
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-lg shadow" style="background-color: {{ $this->warning_color }}"></div>
                <span class="text-sm">التحذير</span>
            </div>
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-lg shadow" style="background-color: {{ $this->error_color }}"></div>
                <span class="text-sm">الخطأ</span>
            </div>
        </div>
    </div>
</x-filament-panels::page>
