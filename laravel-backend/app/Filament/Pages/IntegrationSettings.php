<?php

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

    protected static ?string $navigationIcon = 'heroicon-o-puzzle-piece';
    protected static ?string $navigationGroup = 'النظام';
    protected static ?string $navigationLabel = 'التكاملات';
    protected static ?string $title = 'إعدادات التكاملات';
    protected static ?int $navigationSort = 99;

    protected static string $view = 'filament.pages.integration-settings';

    // Payment Gateway Settings
    public ?string $active_payment_gateway = 'moyasar';

    // Moyasar
    public ?string $moyasar_publishable_key = '';
    public ?string $moyasar_secret_key = '';
    public bool $moyasar_test_mode = true;

    // Tap
    public ?string $tap_public_key = '';
    public ?string $tap_secret_key = '';
    public bool $tap_test_mode = true;

    // HyperPay
    public ?string $hyperpay_entity_id = '';
    public ?string $hyperpay_access_token = '';
    public bool $hyperpay_test_mode = true;

    // PayTabs
    public ?string $paytabs_profile_id = '';
    public ?string $paytabs_server_key = '';
    public ?string $paytabs_client_key = '';
    public bool $paytabs_test_mode = true;

    // Video Platform Settings
    public ?string $active_video_platform = 'zoom';

    // Zoom
    public ?string $zoom_account_id = '';
    public ?string $zoom_client_id = '';
    public ?string $zoom_client_secret = '';

    // Google Meet
    public ?string $google_client_id = '';
    public ?string $google_client_secret = '';
    public ?string $google_calendar_id = '';

    public function mount(): void
    {
        $this->loadSettings();
    }

    protected function loadSettings(): void
    {
        // Payment Gateway
        $this->active_payment_gateway = Setting::getValue('active_payment_gateway', 'moyasar');

        // Moyasar
        $this->moyasar_publishable_key = Setting::getValue('moyasar_publishable_key', '');
        $this->moyasar_secret_key = Setting::getValue('moyasar_secret_key', '');
        $this->moyasar_test_mode = Setting::getValue('moyasar_test_mode', true);

        // Tap
        $this->tap_public_key = Setting::getValue('tap_public_key', '');
        $this->tap_secret_key = Setting::getValue('tap_secret_key', '');
        $this->tap_test_mode = Setting::getValue('tap_test_mode', true);

        // HyperPay
        $this->hyperpay_entity_id = Setting::getValue('hyperpay_entity_id', '');
        $this->hyperpay_access_token = Setting::getValue('hyperpay_access_token', '');
        $this->hyperpay_test_mode = Setting::getValue('hyperpay_test_mode', true);

        // PayTabs
        $this->paytabs_profile_id = Setting::getValue('paytabs_profile_id', '');
        $this->paytabs_server_key = Setting::getValue('paytabs_server_key', '');
        $this->paytabs_client_key = Setting::getValue('paytabs_client_key', '');
        $this->paytabs_test_mode = Setting::getValue('paytabs_test_mode', true);

        // Video Platform
        $this->active_video_platform = Setting::getValue('active_video_platform', 'zoom');

        // Zoom
        $this->zoom_account_id = Setting::getValue('zoom_account_id', '');
        $this->zoom_client_id = Setting::getValue('zoom_client_id', '');
        $this->zoom_client_secret = Setting::getValue('zoom_client_secret', '');

        // Google Meet
        $this->google_client_id = Setting::getValue('google_client_id', '');
        $this->google_client_secret = Setting::getValue('google_client_secret', '');
        $this->google_calendar_id = Setting::getValue('google_calendar_id', '');
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Tabs::make('التكاملات')
                    ->tabs([
                        // Payment Gateways Tab
                        Forms\Components\Tabs\Tab::make('بوابات الدفع')
                            ->icon('heroicon-o-credit-card')
                            ->schema([
                                Forms\Components\Section::make('البوابة النشطة')
                                    ->description('اختر بوابة الدفع التي تريد استخدامها')
                                    ->schema([
                                        Forms\Components\Radio::make('active_payment_gateway')
                                            ->label('بوابة الدفع')
                                            ->options([
                                                'moyasar' => 'Moyasar - مويسر',
                                                'tap' => 'Tap Payments - تاب',
                                                'hyperpay' => 'HyperPay - هايبر باي',
                                                'paytabs' => 'PayTabs - باي تابز',
                                            ])
                                            ->default('moyasar')
                                            ->reactive()
                                            ->required(),
                                    ]),

                                // Moyasar Settings
                                Forms\Components\Section::make('إعدادات Moyasar')
                                    ->description('الحصول على المفاتيح من: https://moyasar.com')
                                    ->icon('heroicon-o-key')
                                    ->collapsible()
                                    ->collapsed(fn ($get) => $get('active_payment_gateway') !== 'moyasar')
                                    ->schema([
                                        Forms\Components\Toggle::make('moyasar_test_mode')
                                            ->label('وضع الاختبار')
                                            ->helperText('تفعيل للاختبار، تعطيل للإنتاج')
                                            ->default(true),
                                        Forms\Components\TextInput::make('moyasar_publishable_key')
                                            ->label('المفتاح العام (Publishable Key)')
                                            ->placeholder('pk_test_...')
                                            ->prefixIcon('heroicon-o-key'),
                                        Forms\Components\TextInput::make('moyasar_secret_key')
                                            ->label('المفتاح السري (Secret Key)')
                                            ->placeholder('sk_test_...')
                                            ->password()
                                            ->prefixIcon('heroicon-o-lock-closed'),
                                    ])->columns(1),

                                // Tap Settings
                                Forms\Components\Section::make('إعدادات Tap Payments')
                                    ->description('الحصول على المفاتيح من: https://www.tap.company')
                                    ->icon('heroicon-o-key')
                                    ->collapsible()
                                    ->collapsed(fn ($get) => $get('active_payment_gateway') !== 'tap')
                                    ->schema([
                                        Forms\Components\Toggle::make('tap_test_mode')
                                            ->label('وضع الاختبار')
                                            ->helperText('تفعيل للاختبار، تعطيل للإنتاج')
                                            ->default(true),
                                        Forms\Components\TextInput::make('tap_public_key')
                                            ->label('المفتاح العام (Public Key)')
                                            ->placeholder('pk_test_...')
                                            ->prefixIcon('heroicon-o-key'),
                                        Forms\Components\TextInput::make('tap_secret_key')
                                            ->label('المفتاح السري (Secret Key)')
                                            ->placeholder('sk_test_...')
                                            ->password()
                                            ->prefixIcon('heroicon-o-lock-closed'),
                                    ])->columns(1),

                                // HyperPay Settings
                                Forms\Components\Section::make('إعدادات HyperPay')
                                    ->description('الحصول على المفاتيح من: https://www.hyperpay.com')
                                    ->icon('heroicon-o-key')
                                    ->collapsible()
                                    ->collapsed(fn ($get) => $get('active_payment_gateway') !== 'hyperpay')
                                    ->schema([
                                        Forms\Components\Toggle::make('hyperpay_test_mode')
                                            ->label('وضع الاختبار')
                                            ->helperText('تفعيل للاختبار، تعطيل للإنتاج')
                                            ->default(true),
                                        Forms\Components\TextInput::make('hyperpay_entity_id')
                                            ->label('Entity ID')
                                            ->prefixIcon('heroicon-o-identification'),
                                        Forms\Components\TextInput::make('hyperpay_access_token')
                                            ->label('Access Token')
                                            ->password()
                                            ->prefixIcon('heroicon-o-lock-closed'),
                                    ])->columns(1),

                                // PayTabs Settings
                                Forms\Components\Section::make('إعدادات PayTabs')
                                    ->description('الحصول على المفاتيح من: https://www.paytabs.com')
                                    ->icon('heroicon-o-key')
                                    ->collapsible()
                                    ->collapsed(fn ($get) => $get('active_payment_gateway') !== 'paytabs')
                                    ->schema([
                                        Forms\Components\Toggle::make('paytabs_test_mode')
                                            ->label('وضع الاختبار')
                                            ->helperText('تفعيل للاختبار، تعطيل للإنتاج')
                                            ->default(true),
                                        Forms\Components\TextInput::make('paytabs_profile_id')
                                            ->label('Profile ID')
                                            ->prefixIcon('heroicon-o-identification'),
                                        Forms\Components\TextInput::make('paytabs_server_key')
                                            ->label('Server Key')
                                            ->password()
                                            ->prefixIcon('heroicon-o-lock-closed'),
                                        Forms\Components\TextInput::make('paytabs_client_key')
                                            ->label('Client Key')
                                            ->prefixIcon('heroicon-o-key'),
                                    ])->columns(1),
                            ]),

                        // Video Platforms Tab
                        Forms\Components\Tabs\Tab::make('منصات الفيديو')
                            ->icon('heroicon-o-video-camera')
                            ->schema([
                                Forms\Components\Section::make('المنصة النشطة')
                                    ->description('اختر منصة الفيديو للجلسات الأونلاين')
                                    ->schema([
                                        Forms\Components\Radio::make('active_video_platform')
                                            ->label('منصة الفيديو')
                                            ->options([
                                                'zoom' => 'Zoom',
                                                'google_meet' => 'Google Meet',
                                                'both' => 'كلاهما (حسب اختيار المدربة)',
                                            ])
                                            ->default('zoom')
                                            ->reactive()
                                            ->required(),
                                    ]),

                                // Zoom Settings
                                Forms\Components\Section::make('إعدادات Zoom')
                                    ->description('الحصول على المفاتيح من: https://marketplace.zoom.us')
                                    ->icon('heroicon-o-video-camera')
                                    ->collapsible()
                                    ->collapsed(fn ($get) => !in_array($get('active_video_platform'), ['zoom', 'both']))
                                    ->schema([
                                        Forms\Components\Placeholder::make('zoom_instructions')
                                            ->label('')
                                            ->content('1. اذهب إلى Zoom Marketplace
2. أنشئ Server-to-Server OAuth App
3. انسخ المفاتيح من قسم App Credentials'),
                                        Forms\Components\TextInput::make('zoom_account_id')
                                            ->label('Account ID')
                                            ->prefixIcon('heroicon-o-identification'),
                                        Forms\Components\TextInput::make('zoom_client_id')
                                            ->label('Client ID')
                                            ->prefixIcon('heroicon-o-key'),
                                        Forms\Components\TextInput::make('zoom_client_secret')
                                            ->label('Client Secret')
                                            ->password()
                                            ->prefixIcon('heroicon-o-lock-closed'),
                                    ])->columns(1),

                                // Google Meet Settings
                                Forms\Components\Section::make('إعدادات Google Meet')
                                    ->description('الحصول على المفاتيح من: https://console.cloud.google.com')
                                    ->icon('heroicon-o-video-camera')
                                    ->collapsible()
                                    ->collapsed(fn ($get) => !in_array($get('active_video_platform'), ['google_meet', 'both']))
                                    ->schema([
                                        Forms\Components\Placeholder::make('google_instructions')
                                            ->label('')
                                            ->content('1. اذهب إلى Google Cloud Console
2. أنشئ مشروع جديد وفعّل Calendar API
3. أنشئ OAuth 2.0 credentials'),
                                        Forms\Components\TextInput::make('google_client_id')
                                            ->label('Client ID')
                                            ->prefixIcon('heroicon-o-key'),
                                        Forms\Components\TextInput::make('google_client_secret')
                                            ->label('Client Secret')
                                            ->password()
                                            ->prefixIcon('heroicon-o-lock-closed'),
                                        Forms\Components\TextInput::make('google_calendar_id')
                                            ->label('Calendar ID (اختياري)')
                                            ->placeholder('primary')
                                            ->prefixIcon('heroicon-o-calendar'),
                                    ])->columns(1),
                            ]),
                    ])
                    ->columnSpanFull(),
            ]);
    }

    public function save(): void
    {
        // Payment Gateway
        Setting::setValue('active_payment_gateway', $this->active_payment_gateway, 'payment', 'string');

        // Moyasar
        Setting::setValue('moyasar_publishable_key', $this->moyasar_publishable_key, 'payment', 'string');
        Setting::setValue('moyasar_secret_key', $this->moyasar_secret_key, 'payment', 'string');
        Setting::setValue('moyasar_test_mode', $this->moyasar_test_mode ? '1' : '0', 'payment', 'boolean');

        // Tap
        Setting::setValue('tap_public_key', $this->tap_public_key, 'payment', 'string');
        Setting::setValue('tap_secret_key', $this->tap_secret_key, 'payment', 'string');
        Setting::setValue('tap_test_mode', $this->tap_test_mode ? '1' : '0', 'payment', 'boolean');

        // HyperPay
        Setting::setValue('hyperpay_entity_id', $this->hyperpay_entity_id, 'payment', 'string');
        Setting::setValue('hyperpay_access_token', $this->hyperpay_access_token, 'payment', 'string');
        Setting::setValue('hyperpay_test_mode', $this->hyperpay_test_mode ? '1' : '0', 'payment', 'boolean');

        // PayTabs
        Setting::setValue('paytabs_profile_id', $this->paytabs_profile_id, 'payment', 'string');
        Setting::setValue('paytabs_server_key', $this->paytabs_server_key, 'payment', 'string');
        Setting::setValue('paytabs_client_key', $this->paytabs_client_key, 'payment', 'string');
        Setting::setValue('paytabs_test_mode', $this->paytabs_test_mode ? '1' : '0', 'payment', 'boolean');

        // Video Platform
        Setting::setValue('active_video_platform', $this->active_video_platform, 'video', 'string');

        // Zoom
        Setting::setValue('zoom_account_id', $this->zoom_account_id, 'video', 'string');
        Setting::setValue('zoom_client_id', $this->zoom_client_id, 'video', 'string');
        Setting::setValue('zoom_client_secret', $this->zoom_client_secret, 'video', 'string');

        // Google Meet
        Setting::setValue('google_client_id', $this->google_client_id, 'video', 'string');
        Setting::setValue('google_client_secret', $this->google_client_secret, 'video', 'string');
        Setting::setValue('google_calendar_id', $this->google_calendar_id, 'video', 'string');

        Notification::make()
            ->title('تم الحفظ بنجاح')
            ->body('تم حفظ إعدادات التكاملات')
            ->success()
            ->send();
    }
}
