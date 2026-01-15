import paramiko

host = "46.202.90.197"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

integration_settings = '''<?php

namespace App\\Filament\\Pages;

use App\\Models\\Setting;
use Filament\\Forms;
use Filament\\Forms\\Form;
use Filament\\Forms\\Concerns\\InteractsWithForms;
use Filament\\Forms\\Contracts\\HasForms;
use Filament\\Notifications\\Notification;
use Filament\\Pages\\Page;

class IntegrationSettings extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = 'heroicon-o-puzzle-piece';
    protected static ?string $navigationGroup = 'النظام';
    protected static ?string $navigationLabel = 'التكاملات';
    protected static ?string $title = 'إعدادات التكاملات';
    protected static ?int $navigationSort = 99;

    protected static string $view = 'filament.pages.integration-settings';

    // Active gateways
    public ?string $active_payment_gateway = 'moyasar';
    public ?string $active_video_platform = 'zoom';

    // Moyasar (Saudi)
    public ?string $moyasar_publishable_key = '';
    public ?string $moyasar_secret_key = '';
    public bool $moyasar_test_mode = true;

    // Tap Payments (GCC)
    public ?string $tap_public_key = '';
    public ?string $tap_secret_key = '';
    public bool $tap_test_mode = true;

    // HyperPay (GCC)
    public ?string $hyperpay_entity_id = '';
    public ?string $hyperpay_access_token = '';
    public bool $hyperpay_test_mode = true;

    // PayTabs (GCC)
    public ?string $paytabs_profile_id = '';
    public ?string $paytabs_server_key = '';
    public ?string $paytabs_client_key = '';
    public bool $paytabs_test_mode = true;

    // Network International (UAE)
    public ?string $network_outlet_id = '';
    public ?string $network_api_key = '';
    public bool $network_test_mode = true;

    // Telr (UAE)
    public ?string $telr_store_id = '';
    public ?string $telr_auth_key = '';
    public bool $telr_test_mode = true;

    // Payfort / Amazon Payment Services (UAE)
    public ?string $payfort_merchant_id = '';
    public ?string $payfort_access_code = '';
    public ?string $payfort_sha_request = '';
    public ?string $payfort_sha_response = '';
    public bool $payfort_test_mode = true;

    // Checkout.com
    public ?string $checkout_public_key = '';
    public ?string $checkout_secret_key = '';
    public bool $checkout_test_mode = true;

    // Tabby (BNPL)
    public ?string $tabby_public_key = '';
    public ?string $tabby_secret_key = '';
    public ?string $tabby_merchant_code = '';
    public bool $tabby_test_mode = true;

    // Tamara (BNPL)
    public ?string $tamara_api_url = '';
    public ?string $tamara_api_token = '';
    public ?string $tamara_notification_token = '';
    public bool $tamara_test_mode = true;

    // Postpay (BNPL)
    public ?string $postpay_merchant_id = '';
    public ?string $postpay_secret_key = '';
    public bool $postpay_test_mode = true;

    // Stripe
    public ?string $stripe_publishable_key = '';
    public ?string $stripe_secret_key = '';
    public bool $stripe_test_mode = true;

    // Zoom
    public ?string $zoom_account_id = '';
    public ?string $zoom_client_id = '';
    public ?string $zoom_client_secret = '';

    // Google Meet
    public ?string $google_client_id = '';
    public ?string $google_client_secret = '';
    public ?string $google_calendar_id = '';

    // Firebase
    public ?string $firebase_server_key = '';
    public ?string $firebase_project_id = '';

    public function mount(): void
    {
        $this->loadSettings();
    }

    protected function loadSettings(): void
    {
        // Active gateways
        $this->active_payment_gateway = Setting::getValue('active_payment_gateway', 'moyasar');
        $this->active_video_platform = Setting::getValue('active_video_platform', 'zoom');

        // Moyasar
        $this->moyasar_publishable_key = Setting::getValue('moyasar_publishable_key', '');
        $this->moyasar_secret_key = Setting::getValue('moyasar_secret_key', '');
        $this->moyasar_test_mode = (bool) Setting::getValue('moyasar_test_mode', true);

        // Tap
        $this->tap_public_key = Setting::getValue('tap_public_key', '');
        $this->tap_secret_key = Setting::getValue('tap_secret_key', '');
        $this->tap_test_mode = (bool) Setting::getValue('tap_test_mode', true);

        // HyperPay
        $this->hyperpay_entity_id = Setting::getValue('hyperpay_entity_id', '');
        $this->hyperpay_access_token = Setting::getValue('hyperpay_access_token', '');
        $this->hyperpay_test_mode = (bool) Setting::getValue('hyperpay_test_mode', true);

        // PayTabs
        $this->paytabs_profile_id = Setting::getValue('paytabs_profile_id', '');
        $this->paytabs_server_key = Setting::getValue('paytabs_server_key', '');
        $this->paytabs_client_key = Setting::getValue('paytabs_client_key', '');
        $this->paytabs_test_mode = (bool) Setting::getValue('paytabs_test_mode', true);

        // Network International
        $this->network_outlet_id = Setting::getValue('network_outlet_id', '');
        $this->network_api_key = Setting::getValue('network_api_key', '');
        $this->network_test_mode = (bool) Setting::getValue('network_test_mode', true);

        // Telr
        $this->telr_store_id = Setting::getValue('telr_store_id', '');
        $this->telr_auth_key = Setting::getValue('telr_auth_key', '');
        $this->telr_test_mode = (bool) Setting::getValue('telr_test_mode', true);

        // Payfort
        $this->payfort_merchant_id = Setting::getValue('payfort_merchant_id', '');
        $this->payfort_access_code = Setting::getValue('payfort_access_code', '');
        $this->payfort_sha_request = Setting::getValue('payfort_sha_request', '');
        $this->payfort_sha_response = Setting::getValue('payfort_sha_response', '');
        $this->payfort_test_mode = (bool) Setting::getValue('payfort_test_mode', true);

        // Checkout.com
        $this->checkout_public_key = Setting::getValue('checkout_public_key', '');
        $this->checkout_secret_key = Setting::getValue('checkout_secret_key', '');
        $this->checkout_test_mode = (bool) Setting::getValue('checkout_test_mode', true);

        // Tabby
        $this->tabby_public_key = Setting::getValue('tabby_public_key', '');
        $this->tabby_secret_key = Setting::getValue('tabby_secret_key', '');
        $this->tabby_merchant_code = Setting::getValue('tabby_merchant_code', '');
        $this->tabby_test_mode = (bool) Setting::getValue('tabby_test_mode', true);

        // Tamara
        $this->tamara_api_url = Setting::getValue('tamara_api_url', '');
        $this->tamara_api_token = Setting::getValue('tamara_api_token', '');
        $this->tamara_notification_token = Setting::getValue('tamara_notification_token', '');
        $this->tamara_test_mode = (bool) Setting::getValue('tamara_test_mode', true);

        // Postpay
        $this->postpay_merchant_id = Setting::getValue('postpay_merchant_id', '');
        $this->postpay_secret_key = Setting::getValue('postpay_secret_key', '');
        $this->postpay_test_mode = (bool) Setting::getValue('postpay_test_mode', true);

        // Stripe
        $this->stripe_publishable_key = Setting::getValue('stripe_publishable_key', '');
        $this->stripe_secret_key = Setting::getValue('stripe_secret_key', '');
        $this->stripe_test_mode = (bool) Setting::getValue('stripe_test_mode', true);

        // Zoom
        $this->zoom_account_id = Setting::getValue('zoom_account_id', '');
        $this->zoom_client_id = Setting::getValue('zoom_client_id', '');
        $this->zoom_client_secret = Setting::getValue('zoom_client_secret', '');

        // Google
        $this->google_client_id = Setting::getValue('google_client_id', '');
        $this->google_client_secret = Setting::getValue('google_client_secret', '');
        $this->google_calendar_id = Setting::getValue('google_calendar_id', '');

        // Firebase
        $this->firebase_server_key = Setting::getValue('firebase_server_key', '');
        $this->firebase_project_id = Setting::getValue('firebase_project_id', '');
    }

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\\Components\\Tabs::make('التكاملات')
                ->tabs([
                    // Payment Gateways Tab
                    Forms\\Components\\Tabs\\Tab::make('بوابات الدفع')
                        ->icon('heroicon-o-credit-card')
                        ->schema([
                            Forms\\Components\\Section::make('البوابة النشطة')
                                ->description('اختر بوابة الدفع الرئيسية')
                                ->schema([
                                    Forms\\Components\\Select::make('active_payment_gateway')
                                        ->label('بوابة الدفع الرئيسية')
                                        ->options([
                                            'moyasar' => 'Moyasar (السعودية)',
                                            'tap' => 'Tap Payments (الخليج)',
                                            'hyperpay' => 'HyperPay (الخليج)',
                                            'paytabs' => 'PayTabs (الخليج)',
                                            'network' => 'Network International (الإمارات)',
                                            'telr' => 'Telr (الإمارات)',
                                            'payfort' => 'Payfort/Amazon (الإمارات)',
                                            'checkout' => 'Checkout.com',
                                            'stripe' => 'Stripe',
                                        ])
                                        ->default('moyasar')
                                        ->required(),
                                ]),

                            // Saudi Payment Gateways
                            Forms\\Components\\Section::make('Moyasar - السعودية')
                                ->description('بوابة دفع سعودية تدعم مدى وفيزا وماستركارد')
                                ->icon('heroicon-o-banknotes')
                                ->collapsible()
                                ->schema([
                                    Forms\\Components\\Toggle::make('moyasar_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('moyasar_publishable_key')->label('Publishable Key'),
                                    Forms\\Components\\TextInput::make('moyasar_secret_key')->label('Secret Key')->password(),
                                ])->columns(3),

                            // GCC Payment Gateways
                            Forms\\Components\\Section::make('Tap Payments - الخليج')
                                ->description('بوابة دفع خليجية تدعم جميع البطاقات')
                                ->icon('heroicon-o-banknotes')
                                ->collapsible()
                                ->collapsed()
                                ->schema([
                                    Forms\\Components\\Toggle::make('tap_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('tap_public_key')->label('Public Key'),
                                    Forms\\Components\\TextInput::make('tap_secret_key')->label('Secret Key')->password(),
                                ])->columns(3),

                            Forms\\Components\\Section::make('HyperPay - الخليج')
                                ->description('بوابة دفع تدعم مدى وApple Pay')
                                ->icon('heroicon-o-banknotes')
                                ->collapsible()
                                ->collapsed()
                                ->schema([
                                    Forms\\Components\\Toggle::make('hyperpay_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('hyperpay_entity_id')->label('Entity ID'),
                                    Forms\\Components\\TextInput::make('hyperpay_access_token')->label('Access Token')->password(),
                                ])->columns(3),

                            Forms\\Components\\Section::make('PayTabs - الخليج')
                                ->icon('heroicon-o-banknotes')
                                ->collapsible()
                                ->collapsed()
                                ->schema([
                                    Forms\\Components\\Toggle::make('paytabs_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('paytabs_profile_id')->label('Profile ID'),
                                    Forms\\Components\\TextInput::make('paytabs_server_key')->label('Server Key')->password(),
                                    Forms\\Components\\TextInput::make('paytabs_client_key')->label('Client Key'),
                                ])->columns(2),

                            // UAE Payment Gateways
                            Forms\\Components\\Section::make('Network International - الإمارات')
                                ->description('أكبر بوابة دفع في الإمارات')
                                ->icon('heroicon-o-building-office')
                                ->collapsible()
                                ->collapsed()
                                ->schema([
                                    Forms\\Components\\Toggle::make('network_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('network_outlet_id')->label('Outlet ID'),
                                    Forms\\Components\\TextInput::make('network_api_key')->label('API Key')->password(),
                                ])->columns(3),

                            Forms\\Components\\Section::make('Telr - الإمارات')
                                ->description('بوابة دفع إماراتية')
                                ->icon('heroicon-o-building-office')
                                ->collapsible()
                                ->collapsed()
                                ->schema([
                                    Forms\\Components\\Toggle::make('telr_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('telr_store_id')->label('Store ID'),
                                    Forms\\Components\\TextInput::make('telr_auth_key')->label('Auth Key')->password(),
                                ])->columns(3),

                            Forms\\Components\\Section::make('Payfort / Amazon Payment Services - الإمارات')
                                ->description('خدمات الدفع من أمازون')
                                ->icon('heroicon-o-building-office')
                                ->collapsible()
                                ->collapsed()
                                ->schema([
                                    Forms\\Components\\Toggle::make('payfort_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('payfort_merchant_id')->label('Merchant ID'),
                                    Forms\\Components\\TextInput::make('payfort_access_code')->label('Access Code'),
                                    Forms\\Components\\TextInput::make('payfort_sha_request')->label('SHA Request Phrase')->password(),
                                    Forms\\Components\\TextInput::make('payfort_sha_response')->label('SHA Response Phrase')->password(),
                                ])->columns(2),

                            Forms\\Components\\Section::make('Checkout.com')
                                ->description('بوابة دفع عالمية')
                                ->icon('heroicon-o-globe-alt')
                                ->collapsible()
                                ->collapsed()
                                ->schema([
                                    Forms\\Components\\Toggle::make('checkout_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('checkout_public_key')->label('Public Key'),
                                    Forms\\Components\\TextInput::make('checkout_secret_key')->label('Secret Key')->password(),
                                ])->columns(3),

                            Forms\\Components\\Section::make('Stripe')
                                ->description('بوابة دفع عالمية')
                                ->icon('heroicon-o-globe-alt')
                                ->collapsible()
                                ->collapsed()
                                ->schema([
                                    Forms\\Components\\Toggle::make('stripe_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('stripe_publishable_key')->label('Publishable Key'),
                                    Forms\\Components\\TextInput::make('stripe_secret_key')->label('Secret Key')->password(),
                                ])->columns(3),
                        ]),

                    // BNPL Tab (Buy Now Pay Later)
                    Forms\\Components\\Tabs\\Tab::make('الدفع الآجل BNPL')
                        ->icon('heroicon-o-clock')
                        ->schema([
                            Forms\\Components\\Section::make('Tabby - تابي')
                                ->description('اشتر الآن وادفع لاحقاً')
                                ->icon('heroicon-o-shopping-bag')
                                ->collapsible()
                                ->schema([
                                    Forms\\Components\\Toggle::make('tabby_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('tabby_public_key')->label('Public Key'),
                                    Forms\\Components\\TextInput::make('tabby_secret_key')->label('Secret Key')->password(),
                                    Forms\\Components\\TextInput::make('tabby_merchant_code')->label('Merchant Code'),
                                ])->columns(2),

                            Forms\\Components\\Section::make('Tamara - تمارا')
                                ->description('قسّم فاتورتك على 4 دفعات')
                                ->icon('heroicon-o-shopping-bag')
                                ->collapsible()
                                ->collapsed()
                                ->schema([
                                    Forms\\Components\\Toggle::make('tamara_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('tamara_api_url')->label('API URL'),
                                    Forms\\Components\\TextInput::make('tamara_api_token')->label('API Token')->password(),
                                    Forms\\Components\\TextInput::make('tamara_notification_token')->label('Notification Token')->password(),
                                ])->columns(2),

                            Forms\\Components\\Section::make('Postpay - بوست باي')
                                ->description('اشتر الآن وادفع لاحقاً')
                                ->icon('heroicon-o-shopping-bag')
                                ->collapsible()
                                ->collapsed()
                                ->schema([
                                    Forms\\Components\\Toggle::make('postpay_test_mode')->label('وضع الاختبار'),
                                    Forms\\Components\\TextInput::make('postpay_merchant_id')->label('Merchant ID'),
                                    Forms\\Components\\TextInput::make('postpay_secret_key')->label('Secret Key')->password(),
                                ])->columns(3),
                        ]),

                    // Video Platforms Tab
                    Forms\\Components\\Tabs\\Tab::make('منصات الفيديو')
                        ->icon('heroicon-o-video-camera')
                        ->schema([
                            Forms\\Components\\Section::make('المنصة النشطة')
                                ->schema([
                                    Forms\\Components\\Select::make('active_video_platform')
                                        ->label('منصة الفيديو الرئيسية')
                                        ->options([
                                            'zoom' => 'Zoom',
                                            'google_meet' => 'Google Meet',
                                            'both' => 'كلاهما',
                                        ])
                                        ->default('zoom')
                                        ->required(),
                                ]),

                            Forms\\Components\\Section::make('Zoom')
                                ->icon('heroicon-o-video-camera')
                                ->collapsible()
                                ->schema([
                                    Forms\\Components\\TextInput::make('zoom_account_id')->label('Account ID'),
                                    Forms\\Components\\TextInput::make('zoom_client_id')->label('Client ID'),
                                    Forms\\Components\\TextInput::make('zoom_client_secret')->label('Client Secret')->password(),
                                ])->columns(3),

                            Forms\\Components\\Section::make('Google Meet')
                                ->icon('heroicon-o-video-camera')
                                ->collapsible()
                                ->collapsed()
                                ->schema([
                                    Forms\\Components\\TextInput::make('google_client_id')->label('Client ID'),
                                    Forms\\Components\\TextInput::make('google_client_secret')->label('Client Secret')->password(),
                                    Forms\\Components\\TextInput::make('google_calendar_id')->label('Calendar ID'),
                                ])->columns(3),
                        ]),

                    // Notifications Tab
                    Forms\\Components\\Tabs\\Tab::make('الإشعارات')
                        ->icon('heroicon-o-bell')
                        ->schema([
                            Forms\\Components\\Section::make('Firebase Cloud Messaging')
                                ->description('لإرسال إشعارات للتطبيق')
                                ->icon('heroicon-o-bell-alert')
                                ->schema([
                                    Forms\\Components\\TextInput::make('firebase_project_id')->label('Project ID'),
                                    Forms\\Components\\Textarea::make('firebase_server_key')->label('Server Key')->rows(3),
                                ]),
                        ]),
                ])
                ->columnSpanFull()
                ->persistTabInQueryString(),
        ]);
    }

    public function save(): void
    {
        // Active gateways
        Setting::setValue('active_payment_gateway', $this->active_payment_gateway, 'payment', 'string');
        Setting::setValue('active_video_platform', $this->active_video_platform, 'video', 'string');

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

        // Network International
        Setting::setValue('network_outlet_id', $this->network_outlet_id, 'payment', 'string');
        Setting::setValue('network_api_key', $this->network_api_key, 'payment', 'string');
        Setting::setValue('network_test_mode', $this->network_test_mode ? '1' : '0', 'payment', 'boolean');

        // Telr
        Setting::setValue('telr_store_id', $this->telr_store_id, 'payment', 'string');
        Setting::setValue('telr_auth_key', $this->telr_auth_key, 'payment', 'string');
        Setting::setValue('telr_test_mode', $this->telr_test_mode ? '1' : '0', 'payment', 'boolean');

        // Payfort
        Setting::setValue('payfort_merchant_id', $this->payfort_merchant_id, 'payment', 'string');
        Setting::setValue('payfort_access_code', $this->payfort_access_code, 'payment', 'string');
        Setting::setValue('payfort_sha_request', $this->payfort_sha_request, 'payment', 'string');
        Setting::setValue('payfort_sha_response', $this->payfort_sha_response, 'payment', 'string');
        Setting::setValue('payfort_test_mode', $this->payfort_test_mode ? '1' : '0', 'payment', 'boolean');

        // Checkout.com
        Setting::setValue('checkout_public_key', $this->checkout_public_key, 'payment', 'string');
        Setting::setValue('checkout_secret_key', $this->checkout_secret_key, 'payment', 'string');
        Setting::setValue('checkout_test_mode', $this->checkout_test_mode ? '1' : '0', 'payment', 'boolean');

        // Tabby
        Setting::setValue('tabby_public_key', $this->tabby_public_key, 'bnpl', 'string');
        Setting::setValue('tabby_secret_key', $this->tabby_secret_key, 'bnpl', 'string');
        Setting::setValue('tabby_merchant_code', $this->tabby_merchant_code, 'bnpl', 'string');
        Setting::setValue('tabby_test_mode', $this->tabby_test_mode ? '1' : '0', 'bnpl', 'boolean');

        // Tamara
        Setting::setValue('tamara_api_url', $this->tamara_api_url, 'bnpl', 'string');
        Setting::setValue('tamara_api_token', $this->tamara_api_token, 'bnpl', 'string');
        Setting::setValue('tamara_notification_token', $this->tamara_notification_token, 'bnpl', 'string');
        Setting::setValue('tamara_test_mode', $this->tamara_test_mode ? '1' : '0', 'bnpl', 'boolean');

        // Postpay
        Setting::setValue('postpay_merchant_id', $this->postpay_merchant_id, 'bnpl', 'string');
        Setting::setValue('postpay_secret_key', $this->postpay_secret_key, 'bnpl', 'string');
        Setting::setValue('postpay_test_mode', $this->postpay_test_mode ? '1' : '0', 'bnpl', 'boolean');

        // Stripe
        Setting::setValue('stripe_publishable_key', $this->stripe_publishable_key, 'payment', 'string');
        Setting::setValue('stripe_secret_key', $this->stripe_secret_key, 'payment', 'string');
        Setting::setValue('stripe_test_mode', $this->stripe_test_mode ? '1' : '0', 'payment', 'boolean');

        // Zoom
        Setting::setValue('zoom_account_id', $this->zoom_account_id, 'video', 'string');
        Setting::setValue('zoom_client_id', $this->zoom_client_id, 'video', 'string');
        Setting::setValue('zoom_client_secret', $this->zoom_client_secret, 'video', 'string');

        // Google
        Setting::setValue('google_client_id', $this->google_client_id, 'video', 'string');
        Setting::setValue('google_client_secret', $this->google_client_secret, 'video', 'string');
        Setting::setValue('google_calendar_id', $this->google_calendar_id, 'video', 'string');

        // Firebase
        Setting::setValue('firebase_server_key', $this->firebase_server_key, 'notification', 'string');
        Setting::setValue('firebase_project_id', $this->firebase_project_id, 'notification', 'string');

        Notification::make()
            ->title('تم الحفظ')
            ->body('تم حفظ إعدادات التكاملات بنجاح')
            ->success()
            ->send();
    }
}
'''

try:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    print("Connecting...")
    ssh.connect(host, port=port, username=username, password=password, timeout=30)
    print("Connected!")

    sftp = ssh.open_sftp()

    with sftp.file('/home/u126213189/domains/vitafit.online/backend/app/Filament/Pages/IntegrationSettings.php', 'w') as f:
        f.write(integration_settings)
    print("Updated IntegrationSettings.php")

    stdin, stdout, stderr = ssh.exec_command("cd /home/u126213189/domains/vitafit.online/backend && php artisan view:clear && php artisan cache:clear")
    print(stdout.read().decode())

    sftp.close()
    ssh.close()
    print("Done!")

except Exception as e:
    print(f"Error: {e}")
