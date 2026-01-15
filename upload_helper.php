<?php
// Simple file uploader - DELETE IMMEDIATELY AFTER USE
// Access: https://vitafit.online/upload_helper.php?key=VitaFit2024Deploy

error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: text/html; charset=utf-8');

$secretKey = 'VitaFit2024Deploy';

if (!isset($_GET['key']) || $_GET['key'] !== $secretKey) {
    die('Unauthorized');
}

$basePath = dirname(__DIR__);

// Files to create
$files = [
    // IntegrationSettings.php
    'app/Filament/Pages/IntegrationSettings.php' => '<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Notifications\Notification;
use Filament\Pages\Page;

class IntegrationSettings extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = \'heroicon-o-puzzle-piece\';
    protected static ?string $navigationGroup = \'النظام\';
    protected static ?string $navigationLabel = \'التكاملات\';
    protected static ?string $title = \'إعدادات التكاملات\';
    protected static ?int $navigationSort = 99;

    protected static string $view = \'filament.pages.integration-settings\';

    public ?string $active_payment_gateway = \'moyasar\';
    public ?string $moyasar_publishable_key = \'\';
    public ?string $moyasar_secret_key = \'\';
    public bool $moyasar_test_mode = true;
    public ?string $tap_public_key = \'\';
    public ?string $tap_secret_key = \'\';
    public bool $tap_test_mode = true;
    public ?string $hyperpay_entity_id = \'\';
    public ?string $hyperpay_access_token = \'\';
    public bool $hyperpay_test_mode = true;
    public ?string $paytabs_profile_id = \'\';
    public ?string $paytabs_server_key = \'\';
    public ?string $paytabs_client_key = \'\';
    public bool $paytabs_test_mode = true;
    public ?string $active_video_platform = \'zoom\';
    public ?string $zoom_account_id = \'\';
    public ?string $zoom_client_id = \'\';
    public ?string $zoom_client_secret = \'\';
    public ?string $google_client_id = \'\';
    public ?string $google_client_secret = \'\';
    public ?string $google_calendar_id = \'\';

    public function mount(): void
    {
        $this->loadSettings();
    }

    protected function loadSettings(): void
    {
        $this->active_payment_gateway = Setting::getValue(\'active_payment_gateway\', \'moyasar\');
        $this->moyasar_publishable_key = Setting::getValue(\'moyasar_publishable_key\', \'\');
        $this->moyasar_secret_key = Setting::getValue(\'moyasar_secret_key\', \'\');
        $this->moyasar_test_mode = Setting::getValue(\'moyasar_test_mode\', true);
        $this->tap_public_key = Setting::getValue(\'tap_public_key\', \'\');
        $this->tap_secret_key = Setting::getValue(\'tap_secret_key\', \'\');
        $this->tap_test_mode = Setting::getValue(\'tap_test_mode\', true);
        $this->hyperpay_entity_id = Setting::getValue(\'hyperpay_entity_id\', \'\');
        $this->hyperpay_access_token = Setting::getValue(\'hyperpay_access_token\', \'\');
        $this->hyperpay_test_mode = Setting::getValue(\'hyperpay_test_mode\', true);
        $this->paytabs_profile_id = Setting::getValue(\'paytabs_profile_id\', \'\');
        $this->paytabs_server_key = Setting::getValue(\'paytabs_server_key\', \'\');
        $this->paytabs_client_key = Setting::getValue(\'paytabs_client_key\', \'\');
        $this->paytabs_test_mode = Setting::getValue(\'paytabs_test_mode\', true);
        $this->active_video_platform = Setting::getValue(\'active_video_platform\', \'zoom\');
        $this->zoom_account_id = Setting::getValue(\'zoom_account_id\', \'\');
        $this->zoom_client_id = Setting::getValue(\'zoom_client_id\', \'\');
        $this->zoom_client_secret = Setting::getValue(\'zoom_client_secret\', \'\');
        $this->google_client_id = Setting::getValue(\'google_client_id\', \'\');
        $this->google_client_secret = Setting::getValue(\'google_client_secret\', \'\');
        $this->google_calendar_id = Setting::getValue(\'google_calendar_id\', \'\');
    }

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Tabs::make(\'التكاملات\')->tabs([
                Forms\Components\Tabs\Tab::make(\'بوابات الدفع\')->icon(\'heroicon-o-credit-card\')->schema([
                    Forms\Components\Section::make(\'البوابة النشطة\')->schema([
                        Forms\Components\Radio::make(\'active_payment_gateway\')->label(\'بوابة الدفع\')
                            ->options([\'moyasar\' => \'Moyasar\', \'tap\' => \'Tap Payments\', \'hyperpay\' => \'HyperPay\', \'paytabs\' => \'PayTabs\'])
                            ->default(\'moyasar\')->reactive()->required(),
                    ]),
                    Forms\Components\Section::make(\'Moyasar\')->collapsible()->schema([
                        Forms\Components\Toggle::make(\'moyasar_test_mode\')->label(\'وضع الاختبار\'),
                        Forms\Components\TextInput::make(\'moyasar_publishable_key\')->label(\'Publishable Key\'),
                        Forms\Components\TextInput::make(\'moyasar_secret_key\')->label(\'Secret Key\')->password(),
                    ]),
                    Forms\Components\Section::make(\'Tap Payments\')->collapsible()->collapsed()->schema([
                        Forms\Components\Toggle::make(\'tap_test_mode\')->label(\'وضع الاختبار\'),
                        Forms\Components\TextInput::make(\'tap_public_key\')->label(\'Public Key\'),
                        Forms\Components\TextInput::make(\'tap_secret_key\')->label(\'Secret Key\')->password(),
                    ]),
                    Forms\Components\Section::make(\'HyperPay\')->collapsible()->collapsed()->schema([
                        Forms\Components\Toggle::make(\'hyperpay_test_mode\')->label(\'وضع الاختبار\'),
                        Forms\Components\TextInput::make(\'hyperpay_entity_id\')->label(\'Entity ID\'),
                        Forms\Components\TextInput::make(\'hyperpay_access_token\')->label(\'Access Token\')->password(),
                    ]),
                    Forms\Components\Section::make(\'PayTabs\')->collapsible()->collapsed()->schema([
                        Forms\Components\Toggle::make(\'paytabs_test_mode\')->label(\'وضع الاختبار\'),
                        Forms\Components\TextInput::make(\'paytabs_profile_id\')->label(\'Profile ID\'),
                        Forms\Components\TextInput::make(\'paytabs_server_key\')->label(\'Server Key\')->password(),
                        Forms\Components\TextInput::make(\'paytabs_client_key\')->label(\'Client Key\'),
                    ]),
                ]),
                Forms\Components\Tabs\Tab::make(\'منصات الفيديو\')->icon(\'heroicon-o-video-camera\')->schema([
                    Forms\Components\Section::make(\'المنصة النشطة\')->schema([
                        Forms\Components\Radio::make(\'active_video_platform\')->label(\'منصة الفيديو\')
                            ->options([\'zoom\' => \'Zoom\', \'google_meet\' => \'Google Meet\', \'both\' => \'كلاهما\'])
                            ->default(\'zoom\')->reactive()->required(),
                    ]),
                    Forms\Components\Section::make(\'Zoom\')->collapsible()->schema([
                        Forms\Components\TextInput::make(\'zoom_account_id\')->label(\'Account ID\'),
                        Forms\Components\TextInput::make(\'zoom_client_id\')->label(\'Client ID\'),
                        Forms\Components\TextInput::make(\'zoom_client_secret\')->label(\'Client Secret\')->password(),
                    ]),
                    Forms\Components\Section::make(\'Google Meet\')->collapsible()->collapsed()->schema([
                        Forms\Components\TextInput::make(\'google_client_id\')->label(\'Client ID\'),
                        Forms\Components\TextInput::make(\'google_client_secret\')->label(\'Client Secret\')->password(),
                        Forms\Components\TextInput::make(\'google_calendar_id\')->label(\'Calendar ID\'),
                    ]),
                ]),
            ])->columnSpanFull(),
        ]);
    }

    public function save(): void
    {
        Setting::setValue(\'active_payment_gateway\', $this->active_payment_gateway, \'payment\', \'string\');
        Setting::setValue(\'moyasar_publishable_key\', $this->moyasar_publishable_key, \'payment\', \'string\');
        Setting::setValue(\'moyasar_secret_key\', $this->moyasar_secret_key, \'payment\', \'string\');
        Setting::setValue(\'moyasar_test_mode\', $this->moyasar_test_mode ? \'1\' : \'0\', \'payment\', \'boolean\');
        Setting::setValue(\'tap_public_key\', $this->tap_public_key, \'payment\', \'string\');
        Setting::setValue(\'tap_secret_key\', $this->tap_secret_key, \'payment\', \'string\');
        Setting::setValue(\'tap_test_mode\', $this->tap_test_mode ? \'1\' : \'0\', \'payment\', \'boolean\');
        Setting::setValue(\'hyperpay_entity_id\', $this->hyperpay_entity_id, \'payment\', \'string\');
        Setting::setValue(\'hyperpay_access_token\', $this->hyperpay_access_token, \'payment\', \'string\');
        Setting::setValue(\'hyperpay_test_mode\', $this->hyperpay_test_mode ? \'1\' : \'0\', \'payment\', \'boolean\');
        Setting::setValue(\'paytabs_profile_id\', $this->paytabs_profile_id, \'payment\', \'string\');
        Setting::setValue(\'paytabs_server_key\', $this->paytabs_server_key, \'payment\', \'string\');
        Setting::setValue(\'paytabs_client_key\', $this->paytabs_client_key, \'payment\', \'string\');
        Setting::setValue(\'paytabs_test_mode\', $this->paytabs_test_mode ? \'1\' : \'0\', \'payment\', \'boolean\');
        Setting::setValue(\'active_video_platform\', $this->active_video_platform, \'video\', \'string\');
        Setting::setValue(\'zoom_account_id\', $this->zoom_account_id, \'video\', \'string\');
        Setting::setValue(\'zoom_client_id\', $this->zoom_client_id, \'video\', \'string\');
        Setting::setValue(\'zoom_client_secret\', $this->zoom_client_secret, \'video\', \'string\');
        Setting::setValue(\'google_client_id\', $this->google_client_id, \'video\', \'string\');
        Setting::setValue(\'google_client_secret\', $this->google_client_secret, \'video\', \'string\');
        Setting::setValue(\'google_calendar_id\', $this->google_calendar_id, \'video\', \'string\');

        Notification::make()->title(\'تم الحفظ\')->success()->send();
    }
}',

    // View file
    'resources/views/filament/pages/integration-settings.blade.php' => '<x-filament-panels::page>
    <form wire:submit="save">
        {{ $this->form }}
        <div class="mt-6 flex justify-end">
            <x-filament::button type="submit" size="lg">
                حفظ الإعدادات
            </x-filament::button>
        </div>
    </form>
</x-filament-panels::page>',
];

$results = [];

foreach ($files as $path => $content) {
    $fullPath = $basePath . '/' . $path;
    $dir = dirname($fullPath);

    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
        $results[] = "Created directory: $dir";
    }

    if (file_put_contents($fullPath, $content)) {
        $results[] = "✅ Created: $path";
    } else {
        $results[] = "❌ Failed: $path";
    }
}

// Clear cache
if (function_exists('opcache_reset')) {
    opcache_reset();
    $results[] = "Cache cleared";
}

echo "<html dir='rtl'><head><meta charset='utf-8'><title>Deploy Results</title></head><body style='font-family: Arial; padding: 20px; background: #1a1a2e; color: #eee;'>";
echo "<h1 style='color: #FF69B4;'>نتائج النشر</h1>";
echo "<ul>";
foreach ($results as $r) {
    echo "<li style='margin: 10px 0;'>$r</li>";
}
echo "</ul>";
echo "<p style='color: #4CAF50; font-weight: bold;'>✅ تم النشر بنجاح! احذف هذا الملف الآن!</p>";
echo "<p><a href='/admin' style='color: #FF69B4;'>اذهب إلى لوحة التحكم</a></p>";
echo "</body></html>";
