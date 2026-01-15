import paramiko

host = "46.202.90.197"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

# New General Settings Page
general_settings_page = '''<?php

namespace App\\Filament\\Pages;

use App\\Models\\Setting;
use Filament\\Forms;
use Filament\\Forms\\Form;
use Filament\\Forms\\Concerns\\InteractsWithForms;
use Filament\\Forms\\Contracts\\HasForms;
use Filament\\Notifications\\Notification;
use Filament\\Pages\\Page;

class GeneralSettings extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';
    protected static ?string $navigationGroup = 'النظام';
    protected static ?string $navigationLabel = 'الإعدادات العامة';
    protected static ?string $title = 'الإعدادات العامة';
    protected static ?int $navigationSort = 98;

    protected static string $view = 'filament.pages.general-settings';

    // App Settings
    public ?string $app_name = 'VitaFit';
    public ?string $app_description = '';
    public ?string $app_email = '';
    public ?string $app_phone = '';
    public ?string $app_whatsapp = '';
    public ?string $app_address = '';

    // Social Media
    public ?string $social_instagram = '';
    public ?string $social_twitter = '';
    public ?string $social_snapchat = '';
    public ?string $social_tiktok = '';

    // Subscription Settings
    public ?string $trial_days = '7';
    public ?string $monthly_price = '299';
    public ?string $quarterly_price = '799';
    public ?string $yearly_price = '2499';

    // Session Settings
    public ?string $session_duration = '45';
    public ?string $session_reminder_hours = '24';
    public bool $auto_create_zoom = true;

    public function mount(): void
    {
        $this->app_name = Setting::getValue('app_name', 'VitaFit');
        $this->app_description = Setting::getValue('app_description', '');
        $this->app_email = Setting::getValue('app_email', '');
        $this->app_phone = Setting::getValue('app_phone', '');
        $this->app_whatsapp = Setting::getValue('app_whatsapp', '');
        $this->app_address = Setting::getValue('app_address', '');

        $this->social_instagram = Setting::getValue('social_instagram', '');
        $this->social_twitter = Setting::getValue('social_twitter', '');
        $this->social_snapchat = Setting::getValue('social_snapchat', '');
        $this->social_tiktok = Setting::getValue('social_tiktok', '');

        $this->trial_days = Setting::getValue('trial_days', '7');
        $this->monthly_price = Setting::getValue('monthly_price', '299');
        $this->quarterly_price = Setting::getValue('quarterly_price', '799');
        $this->yearly_price = Setting::getValue('yearly_price', '2499');

        $this->session_duration = Setting::getValue('session_duration', '45');
        $this->session_reminder_hours = Setting::getValue('session_reminder_hours', '24');
        $this->auto_create_zoom = Setting::getValue('auto_create_zoom', true);
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\\Components\\Tabs::make('الإعدادات')
                    ->tabs([
                        // App Info Tab
                        Forms\\Components\\Tabs\\Tab::make('معلومات التطبيق')
                            ->icon('heroicon-o-device-phone-mobile')
                            ->schema([
                                Forms\\Components\\Section::make('البيانات الأساسية')
                                    ->description('معلومات التطبيق الأساسية')
                                    ->icon('heroicon-o-information-circle')
                                    ->schema([
                                        Forms\\Components\\TextInput::make('app_name')
                                            ->label('اسم التطبيق')
                                            ->required()
                                            ->prefixIcon('heroicon-o-sparkles'),
                                        Forms\\Components\\Textarea::make('app_description')
                                            ->label('وصف التطبيق')
                                            ->rows(3),
                                    ]),
                                Forms\\Components\\Section::make('معلومات التواصل')
                                    ->description('بيانات التواصل مع العملاء')
                                    ->icon('heroicon-o-phone')
                                    ->schema([
                                        Forms\\Components\\TextInput::make('app_email')
                                            ->label('البريد الإلكتروني')
                                            ->email()
                                            ->prefixIcon('heroicon-o-envelope'),
                                        Forms\\Components\\TextInput::make('app_phone')
                                            ->label('رقم الهاتف')
                                            ->tel()
                                            ->prefixIcon('heroicon-o-phone'),
                                        Forms\\Components\\TextInput::make('app_whatsapp')
                                            ->label('واتساب')
                                            ->prefixIcon('heroicon-o-chat-bubble-left-right'),
                                        Forms\\Components\\Textarea::make('app_address')
                                            ->label('العنوان')
                                            ->rows(2),
                                    ])->columns(2),
                            ]),

                        // Social Media Tab
                        Forms\\Components\\Tabs\\Tab::make('وسائل التواصل')
                            ->icon('heroicon-o-share')
                            ->schema([
                                Forms\\Components\\Section::make('حسابات التواصل الاجتماعي')
                                    ->description('روابط حسابات التواصل الاجتماعي')
                                    ->icon('heroicon-o-globe-alt')
                                    ->schema([
                                        Forms\\Components\\TextInput::make('social_instagram')
                                            ->label('انستقرام')
                                            ->url()
                                            ->prefixIcon('heroicon-o-camera'),
                                        Forms\\Components\\TextInput::make('social_twitter')
                                            ->label('تويتر / X')
                                            ->url()
                                            ->prefixIcon('heroicon-o-chat-bubble-bottom-center-text'),
                                        Forms\\Components\\TextInput::make('social_snapchat')
                                            ->label('سناب شات')
                                            ->url()
                                            ->prefixIcon('heroicon-o-camera'),
                                        Forms\\Components\\TextInput::make('social_tiktok')
                                            ->label('تيك توك')
                                            ->url()
                                            ->prefixIcon('heroicon-o-play'),
                                    ])->columns(2),
                            ]),

                        // Subscriptions Tab
                        Forms\\Components\\Tabs\\Tab::make('الاشتراكات')
                            ->icon('heroicon-o-credit-card')
                            ->schema([
                                Forms\\Components\\Section::make('إعدادات الاشتراكات')
                                    ->description('أسعار ومدد الاشتراكات')
                                    ->icon('heroicon-o-banknotes')
                                    ->schema([
                                        Forms\\Components\\TextInput::make('trial_days')
                                            ->label('أيام التجربة المجانية')
                                            ->numeric()
                                            ->suffix('يوم')
                                            ->prefixIcon('heroicon-o-clock'),
                                        Forms\\Components\\TextInput::make('monthly_price')
                                            ->label('سعر الاشتراك الشهري')
                                            ->numeric()
                                            ->suffix('ر.س')
                                            ->prefixIcon('heroicon-o-banknotes'),
                                        Forms\\Components\\TextInput::make('quarterly_price')
                                            ->label('سعر الاشتراك الربع سنوي')
                                            ->numeric()
                                            ->suffix('ر.س')
                                            ->prefixIcon('heroicon-o-banknotes'),
                                        Forms\\Components\\TextInput::make('yearly_price')
                                            ->label('سعر الاشتراك السنوي')
                                            ->numeric()
                                            ->suffix('ر.س')
                                            ->prefixIcon('heroicon-o-banknotes'),
                                    ])->columns(2),
                            ]),

                        // Sessions Tab
                        Forms\\Components\\Tabs\\Tab::make('الجلسات')
                            ->icon('heroicon-o-video-camera')
                            ->schema([
                                Forms\\Components\\Section::make('إعدادات الجلسات')
                                    ->description('إعدادات جلسات التدريب')
                                    ->icon('heroicon-o-calendar')
                                    ->schema([
                                        Forms\\Components\\TextInput::make('session_duration')
                                            ->label('مدة الجلسة الافتراضية')
                                            ->numeric()
                                            ->suffix('دقيقة')
                                            ->prefixIcon('heroicon-o-clock'),
                                        Forms\\Components\\TextInput::make('session_reminder_hours')
                                            ->label('التذكير قبل الجلسة')
                                            ->numeric()
                                            ->suffix('ساعة')
                                            ->prefixIcon('heroicon-o-bell'),
                                        Forms\\Components\\Toggle::make('auto_create_zoom')
                                            ->label('إنشاء رابط Zoom تلقائياً')
                                            ->helperText('إنشاء رابط اجتماع تلقائياً عند حجز جلسة أونلاين'),
                                    ])->columns(2),
                            ]),
                    ])
                    ->columnSpanFull()
                    ->persistTabInQueryString(),
            ]);
    }

    public function save(): void
    {
        Setting::setValue('app_name', $this->app_name, 'app', 'string');
        Setting::setValue('app_description', $this->app_description, 'app', 'string');
        Setting::setValue('app_email', $this->app_email, 'app', 'string');
        Setting::setValue('app_phone', $this->app_phone, 'app', 'string');
        Setting::setValue('app_whatsapp', $this->app_whatsapp, 'app', 'string');
        Setting::setValue('app_address', $this->app_address, 'app', 'string');

        Setting::setValue('social_instagram', $this->social_instagram, 'social', 'string');
        Setting::setValue('social_twitter', $this->social_twitter, 'social', 'string');
        Setting::setValue('social_snapchat', $this->social_snapchat, 'social', 'string');
        Setting::setValue('social_tiktok', $this->social_tiktok, 'social', 'string');

        Setting::setValue('trial_days', $this->trial_days, 'subscription', 'string');
        Setting::setValue('monthly_price', $this->monthly_price, 'subscription', 'string');
        Setting::setValue('quarterly_price', $this->quarterly_price, 'subscription', 'string');
        Setting::setValue('yearly_price', $this->yearly_price, 'subscription', 'string');

        Setting::setValue('session_duration', $this->session_duration, 'session', 'string');
        Setting::setValue('session_reminder_hours', $this->session_reminder_hours, 'session', 'string');
        Setting::setValue('auto_create_zoom', $this->auto_create_zoom ? '1' : '0', 'session', 'boolean');

        Notification::make()
            ->title('تم الحفظ')
            ->body('تم حفظ الإعدادات بنجاح')
            ->success()
            ->send();
    }
}
'''

# View for general settings
general_settings_view = '''<x-filament-panels::page>
    <form wire:submit="save">
        {{ $this->form }}

        <div class="mt-6 flex justify-end gap-x-3">
            <x-filament::button type="submit" size="lg" icon="heroicon-o-check">
                حفظ الإعدادات
            </x-filament::button>
        </div>
    </form>
</x-filament-panels::page>
'''

try:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    print("Connecting...")
    ssh.connect(host, port=port, username=username, password=password, timeout=30)
    print("Connected!")

    sftp = ssh.open_sftp()

    # Write GeneralSettings page
    with sftp.file('/home/u126213189/domains/vitafit.online/backend/app/Filament/Pages/GeneralSettings.php', 'w') as f:
        f.write(general_settings_page)
    print("Created GeneralSettings.php")

    # Write view
    with sftp.file('/home/u126213189/domains/vitafit.online/backend/resources/views/filament/pages/general-settings.blade.php', 'w') as f:
        f.write(general_settings_view)
    print("Created general-settings.blade.php")

    # Delete old SettingResource to avoid confusion
    try:
        sftp.remove('/home/u126213189/domains/vitafit.online/backend/app/Filament/Resources/SettingResource.php')
        print("Removed old SettingResource.php")
    except:
        pass

    # Clear cache
    stdin, stdout, stderr = ssh.exec_command("cd /home/u126213189/domains/vitafit.online/backend && php artisan view:clear && php artisan cache:clear")
    print(stdout.read().decode())

    sftp.close()
    ssh.close()
    print("\nSettings page updated successfully!")

except Exception as e:
    print(f"Error: {e}")
