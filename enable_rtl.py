import paramiko

host = "46.202.90.197"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

# Update AdminPanelProvider for RTL
admin_panel_content = '''<?php

namespace App\\Providers\\Filament;

use Filament\\Http\\Middleware\\Authenticate;
use Filament\\Http\\Middleware\\DisableBladeIconComponents;
use Filament\\Http\\Middleware\\DispatchServingFilamentEvent;
use Filament\\Pages;
use Filament\\Panel;
use Filament\\PanelProvider;
use Filament\\Support\\Colors\\Color;
use Filament\\Widgets;
use Illuminate\\Cookie\\Middleware\\AddQueuedCookiesToResponse;
use Illuminate\\Cookie\\Middleware\\EncryptCookies;
use Illuminate\\Foundation\\Http\\Middleware\\VerifyCsrfToken;
use Illuminate\\Routing\\Middleware\\SubstituteBindings;
use Illuminate\\Session\\Middleware\\AuthenticateSession;
use Illuminate\\Session\\Middleware\\StartSession;
use Illuminate\\View\\Middleware\\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            ->colors([
                'primary' => Color::hex('#FF69B4'),
                'danger' => Color::Red,
                'success' => Color::Green,
                'warning' => Color::Orange,
            ])
            ->font('Tajawal')
            ->brandName('VitaFit')
            ->darkMode(true)
            ->sidebarCollapsibleOnDesktop()
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\\\Filament\\\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\\\Filament\\\\Pages')
            ->pages([
                Pages\\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\\\Filament\\\\Widgets')
            ->widgets([
                Widgets\\AccountWidget::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }
}
'''

# Update app.php config for locale
app_config = '''<?php

return [
    'name' => env('APP_NAME', 'VitaFit'),
    'env' => env('APP_ENV', 'production'),
    'debug' => (bool) env('APP_DEBUG', false),
    'url' => env('APP_URL', 'https://vitafit.online'),
    'asset_url' => env('ASSET_URL'),
    'timezone' => 'Asia/Riyadh',
    'locale' => 'ar',
    'fallback_locale' => 'en',
    'faker_locale' => 'ar_SA',
    'key' => env('APP_KEY'),
    'cipher' => 'AES-256-CBC',
    'maintenance' => [
        'driver' => 'file',
    ],
];
'''

try:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    print("Connecting...")
    ssh.connect(host, port=port, username=username, password=password, timeout=30)
    print("Connected!")

    sftp = ssh.open_sftp()

    # Write AdminPanelProvider
    with sftp.file('/home/u126213189/domains/vitafit.online/backend/app/Providers/Filament/AdminPanelProvider.php', 'w') as f:
        f.write(admin_panel_content)
    print("Updated AdminPanelProvider.php")

    # Write app config
    with sftp.file('/home/u126213189/domains/vitafit.online/backend/config/app.php', 'w') as f:
        f.write(app_config)
    print("Updated config/app.php")

    # Clear cache
    stdin, stdout, stderr = ssh.exec_command("cd /home/u126213189/domains/vitafit.online/backend && php artisan config:clear && php artisan view:clear && php artisan cache:clear")
    print(stdout.read().decode())

    sftp.close()
    ssh.close()
    print("\nRTL enabled successfully!")

except Exception as e:
    print(f"Error: {e}")
