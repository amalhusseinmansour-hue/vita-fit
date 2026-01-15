<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Livewire\Features\SupportFileUploads\TemporaryUploadedFile;

class AppearanceSettings extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = 'heroicon-o-paint-brush';
    protected static ?string $navigationGroup = 'النظام';
    protected static ?string $navigationLabel = 'مظهر التطبيق';
    protected static ?string $title = 'إعدادات المظهر';
    protected static ?int $navigationSort = 90;

    protected static string $view = 'filament.pages.appearance-settings';

    // App Branding
    public ?string $app_name = 'VitaFit';
    public ?string $app_tagline = '';
    public ?string $app_logo = '';
    public ?string $app_logo_dark = '';
    public ?string $app_favicon = '';

    // Theme Colors
    public ?string $primary_color = '#6366F1';
    public ?string $secondary_color = '#EC4899';
    public ?string $accent_color = '#F59E0B';
    public ?string $success_color = '#10B981';
    public ?string $warning_color = '#F59E0B';
    public ?string $error_color = '#EF4444';
    public ?string $background_color = '#FFFFFF';
    public ?string $text_color = '#1F2937';

    // Dark Mode
    public bool $dark_mode_enabled = true;
    public ?string $dark_background_color = '#1F2937';
    public ?string $dark_text_color = '#F9FAFB';
    public ?string $dark_card_color = '#374151';

    // Typography
    public ?string $font_family = 'Cairo';
    public ?string $heading_font = 'Cairo';
    public ?string $font_size_base = '16';

    // Layout
    public ?string $border_radius = '12';
    public bool $card_shadows = true;
    public ?string $spacing_unit = '8';

    // Splash Screen
    public ?string $splash_background = '#6366F1';
    public ?string $splash_logo = '';
    public bool $splash_animation = true;

    public function mount(): void
    {
        $this->loadSettings();
    }

    protected function loadSettings(): void
    {
        // App Branding
        $this->app_name = Setting::getValue('app_name', 'VitaFit');
        $this->app_tagline = Setting::getValue('app_tagline', 'تدريب احترافي');
        $this->app_logo = Setting::getValue('app_logo', '');
        $this->app_logo_dark = Setting::getValue('app_logo_dark', '');
        $this->app_favicon = Setting::getValue('app_favicon', '');

        // Theme Colors
        $this->primary_color = Setting::getValue('primary_color', '#6366F1');
        $this->secondary_color = Setting::getValue('secondary_color', '#EC4899');
        $this->accent_color = Setting::getValue('accent_color', '#F59E0B');
        $this->success_color = Setting::getValue('success_color', '#10B981');
        $this->warning_color = Setting::getValue('warning_color', '#F59E0B');
        $this->error_color = Setting::getValue('error_color', '#EF4444');
        $this->background_color = Setting::getValue('background_color', '#FFFFFF');
        $this->text_color = Setting::getValue('text_color', '#1F2937');

        // Dark Mode
        $this->dark_mode_enabled = Setting::getValue('dark_mode_enabled', true);
        $this->dark_background_color = Setting::getValue('dark_background_color', '#1F2937');
        $this->dark_text_color = Setting::getValue('dark_text_color', '#F9FAFB');
        $this->dark_card_color = Setting::getValue('dark_card_color', '#374151');

        // Typography
        $this->font_family = Setting::getValue('font_family', 'Cairo');
        $this->heading_font = Setting::getValue('heading_font', 'Cairo');
        $this->font_size_base = Setting::getValue('font_size_base', '16');

        // Layout
        $this->border_radius = Setting::getValue('border_radius', '12');
        $this->card_shadows = Setting::getValue('card_shadows', true);
        $this->spacing_unit = Setting::getValue('spacing_unit', '8');

        // Splash Screen
        $this->splash_background = Setting::getValue('splash_background', '#6366F1');
        $this->splash_logo = Setting::getValue('splash_logo', '');
        $this->splash_animation = Setting::getValue('splash_animation', true);
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Tabs::make('المظهر')
                    ->tabs([
                        // Branding Tab
                        Forms\Components\Tabs\Tab::make('الهوية')
                            ->icon('heroicon-o-building-storefront')
                            ->schema([
                                Forms\Components\Section::make('معلومات التطبيق')
                                    ->description('اسم التطبيق والشعار الأساسي')
                                    ->schema([
                                        Forms\Components\TextInput::make('app_name')
                                            ->label('اسم التطبيق')
                                            ->required()
                                            ->maxLength(50),
                                        Forms\Components\TextInput::make('app_tagline')
                                            ->label('الشعار النصي')
                                            ->placeholder('تدريب احترافي لحياة صحية')
                                            ->maxLength(100),
                                    ])->columns(2),

                                Forms\Components\Section::make('الشعارات')
                                    ->description('شعارات التطبيق بصيغة PNG أو SVG')
                                    ->schema([
                                        Forms\Components\FileUpload::make('app_logo')
                                            ->label('الشعار (الوضع الفاتح)')
                                            ->image()
                                            ->directory('logos')
                                            ->imageResizeMode('contain')
                                            ->imageCropAspectRatio('1:1')
                                            ->imageResizeTargetWidth('512')
                                            ->imageResizeTargetHeight('512'),
                                        Forms\Components\FileUpload::make('app_logo_dark')
                                            ->label('الشعار (الوضع الداكن)')
                                            ->image()
                                            ->directory('logos')
                                            ->imageResizeMode('contain')
                                            ->imageCropAspectRatio('1:1')
                                            ->imageResizeTargetWidth('512')
                                            ->imageResizeTargetHeight('512'),
                                        Forms\Components\FileUpload::make('app_favicon')
                                            ->label('الأيقونة (Favicon)')
                                            ->image()
                                            ->directory('logos')
                                            ->imageResizeMode('contain')
                                            ->imageResizeTargetWidth('64')
                                            ->imageResizeTargetHeight('64'),
                                    ])->columns(3),
                            ]),

                        // Colors Tab
                        Forms\Components\Tabs\Tab::make('الألوان')
                            ->icon('heroicon-o-swatch')
                            ->schema([
                                Forms\Components\Section::make('الألوان الرئيسية')
                                    ->description('ألوان الواجهة الأساسية')
                                    ->schema([
                                        Forms\Components\ColorPicker::make('primary_color')
                                            ->label('اللون الرئيسي')
                                            ->required(),
                                        Forms\Components\ColorPicker::make('secondary_color')
                                            ->label('اللون الثانوي')
                                            ->required(),
                                        Forms\Components\ColorPicker::make('accent_color')
                                            ->label('لون التمييز'),
                                    ])->columns(3),

                                Forms\Components\Section::make('ألوان الحالات')
                                    ->schema([
                                        Forms\Components\ColorPicker::make('success_color')
                                            ->label('لون النجاح'),
                                        Forms\Components\ColorPicker::make('warning_color')
                                            ->label('لون التحذير'),
                                        Forms\Components\ColorPicker::make('error_color')
                                            ->label('لون الخطأ'),
                                    ])->columns(3),

                                Forms\Components\Section::make('ألوان الخلفية والنص')
                                    ->schema([
                                        Forms\Components\ColorPicker::make('background_color')
                                            ->label('لون الخلفية'),
                                        Forms\Components\ColorPicker::make('text_color')
                                            ->label('لون النص'),
                                    ])->columns(2),
                            ]),

                        // Dark Mode Tab
                        Forms\Components\Tabs\Tab::make('الوضع الداكن')
                            ->icon('heroicon-o-moon')
                            ->schema([
                                Forms\Components\Section::make('إعدادات الوضع الداكن')
                                    ->schema([
                                        Forms\Components\Toggle::make('dark_mode_enabled')
                                            ->label('تفعيل الوضع الداكن')
                                            ->helperText('السماح للمستخدمين بالتبديل للوضع الداكن')
                                            ->reactive(),
                                    ]),

                                Forms\Components\Section::make('ألوان الوضع الداكن')
                                    ->visible(fn ($get) => $get('dark_mode_enabled'))
                                    ->schema([
                                        Forms\Components\ColorPicker::make('dark_background_color')
                                            ->label('لون الخلفية'),
                                        Forms\Components\ColorPicker::make('dark_text_color')
                                            ->label('لون النص'),
                                        Forms\Components\ColorPicker::make('dark_card_color')
                                            ->label('لون البطاقات'),
                                    ])->columns(3),
                            ]),

                        // Typography Tab
                        Forms\Components\Tabs\Tab::make('الخطوط')
                            ->icon('heroicon-o-language')
                            ->schema([
                                Forms\Components\Section::make('إعدادات الخطوط')
                                    ->schema([
                                        Forms\Components\Select::make('font_family')
                                            ->label('الخط الأساسي')
                                            ->options([
                                                'Cairo' => 'Cairo (كايرو)',
                                                'Tajawal' => 'Tajawal (تجول)',
                                                'Almarai' => 'Almarai (المراعي)',
                                                'Changa' => 'Changa (شنقة)',
                                                'El Messiri' => 'El Messiri (المسيري)',
                                                'Noto Sans Arabic' => 'Noto Sans Arabic',
                                                'IBM Plex Sans Arabic' => 'IBM Plex Sans Arabic',
                                            ])
                                            ->default('Cairo'),
                                        Forms\Components\Select::make('heading_font')
                                            ->label('خط العناوين')
                                            ->options([
                                                'Cairo' => 'Cairo (كايرو)',
                                                'Tajawal' => 'Tajawal (تجول)',
                                                'Almarai' => 'Almarai (المراعي)',
                                                'Changa' => 'Changa (شنقة)',
                                                'El Messiri' => 'El Messiri (المسيري)',
                                                'Noto Sans Arabic' => 'Noto Sans Arabic',
                                                'IBM Plex Sans Arabic' => 'IBM Plex Sans Arabic',
                                            ])
                                            ->default('Cairo'),
                                        Forms\Components\Select::make('font_size_base')
                                            ->label('حجم الخط الأساسي')
                                            ->options([
                                                '14' => '14px (صغير)',
                                                '15' => '15px',
                                                '16' => '16px (متوسط)',
                                                '17' => '17px',
                                                '18' => '18px (كبير)',
                                            ])
                                            ->default('16'),
                                    ])->columns(3),
                            ]),

                        // Layout Tab
                        Forms\Components\Tabs\Tab::make('التخطيط')
                            ->icon('heroicon-o-squares-2x2')
                            ->schema([
                                Forms\Components\Section::make('إعدادات التخطيط')
                                    ->schema([
                                        Forms\Components\Select::make('border_radius')
                                            ->label('انحناء الحواف')
                                            ->options([
                                                '0' => 'بدون (0px)',
                                                '4' => 'صغير (4px)',
                                                '8' => 'متوسط (8px)',
                                                '12' => 'كبير (12px)',
                                                '16' => 'أكبر (16px)',
                                                '20' => 'دائري (20px)',
                                            ])
                                            ->default('12'),
                                        Forms\Components\Toggle::make('card_shadows')
                                            ->label('ظلال البطاقات')
                                            ->helperText('إضافة ظلال للبطاقات والعناصر'),
                                        Forms\Components\Select::make('spacing_unit')
                                            ->label('وحدة التباعد')
                                            ->options([
                                                '4' => 'ضيق (4px)',
                                                '8' => 'متوسط (8px)',
                                                '12' => 'واسع (12px)',
                                            ])
                                            ->default('8'),
                                    ])->columns(3),
                            ]),

                        // Splash Screen Tab
                        Forms\Components\Tabs\Tab::make('شاشة البداية')
                            ->icon('heroicon-o-device-phone-mobile')
                            ->schema([
                                Forms\Components\Section::make('إعدادات شاشة البداية')
                                    ->schema([
                                        Forms\Components\ColorPicker::make('splash_background')
                                            ->label('لون الخلفية'),
                                        Forms\Components\FileUpload::make('splash_logo')
                                            ->label('شعار شاشة البداية')
                                            ->image()
                                            ->directory('splash')
                                            ->imageResizeMode('contain')
                                            ->imageResizeTargetWidth('512')
                                            ->imageResizeTargetHeight('512'),
                                        Forms\Components\Toggle::make('splash_animation')
                                            ->label('تفعيل الحركة')
                                            ->helperText('عرض حركة عند تحميل التطبيق'),
                                    ])->columns(3),
                            ]),
                    ])
                    ->columnSpanFull(),
            ]);
    }

    public function save(): void
    {
        // App Branding
        Setting::setValue('app_name', $this->app_name, 'appearance', 'string');
        Setting::setValue('app_tagline', $this->app_tagline, 'appearance', 'string');
        Setting::setValue('app_logo', $this->app_logo, 'appearance', 'string');
        Setting::setValue('app_logo_dark', $this->app_logo_dark, 'appearance', 'string');
        Setting::setValue('app_favicon', $this->app_favicon, 'appearance', 'string');

        // Theme Colors
        Setting::setValue('primary_color', $this->primary_color, 'appearance', 'string');
        Setting::setValue('secondary_color', $this->secondary_color, 'appearance', 'string');
        Setting::setValue('accent_color', $this->accent_color, 'appearance', 'string');
        Setting::setValue('success_color', $this->success_color, 'appearance', 'string');
        Setting::setValue('warning_color', $this->warning_color, 'appearance', 'string');
        Setting::setValue('error_color', $this->error_color, 'appearance', 'string');
        Setting::setValue('background_color', $this->background_color, 'appearance', 'string');
        Setting::setValue('text_color', $this->text_color, 'appearance', 'string');

        // Dark Mode
        Setting::setValue('dark_mode_enabled', $this->dark_mode_enabled ? '1' : '0', 'appearance', 'boolean');
        Setting::setValue('dark_background_color', $this->dark_background_color, 'appearance', 'string');
        Setting::setValue('dark_text_color', $this->dark_text_color, 'appearance', 'string');
        Setting::setValue('dark_card_color', $this->dark_card_color, 'appearance', 'string');

        // Typography
        Setting::setValue('font_family', $this->font_family, 'appearance', 'string');
        Setting::setValue('heading_font', $this->heading_font, 'appearance', 'string');
        Setting::setValue('font_size_base', $this->font_size_base, 'appearance', 'string');

        // Layout
        Setting::setValue('border_radius', $this->border_radius, 'appearance', 'string');
        Setting::setValue('card_shadows', $this->card_shadows ? '1' : '0', 'appearance', 'boolean');
        Setting::setValue('spacing_unit', $this->spacing_unit, 'appearance', 'string');

        // Splash Screen
        Setting::setValue('splash_background', $this->splash_background, 'appearance', 'string');
        Setting::setValue('splash_logo', $this->splash_logo, 'appearance', 'string');
        Setting::setValue('splash_animation', $this->splash_animation ? '1' : '0', 'appearance', 'boolean');

        Notification::make()
            ->title('تم الحفظ بنجاح')
            ->body('تم حفظ إعدادات المظهر')
            ->success()
            ->send();
    }
}
