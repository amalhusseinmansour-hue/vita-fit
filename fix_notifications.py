import paramiko

host = "46.202.90.197"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

# Fixed Notification model with correct table name
notification_model = '''<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use Illuminate\\Database\\Eloquent\\Model;

class PushNotification extends Model
{
    use HasFactory;

    protected $table = 'notifications_custom';

    protected $fillable = [
        'title',
        'body',
        'type',
        'target_type',
        'target_id',
        'data',
        'scheduled_at',
        'sent_at',
        'status',
    ];

    protected $casts = [
        'data' => 'array',
        'scheduled_at' => 'datetime',
        'sent_at' => 'datetime',
    ];
}
'''

# Updated PushNotificationResource
push_notification_resource = '''<?php

namespace App\\Filament\\Resources;

use App\\Filament\\Resources\\PushNotificationResource\\Pages;
use App\\Models\\PushNotification;
use Filament\\Forms;
use Filament\\Forms\\Form;
use Filament\\Resources\\Resource;
use Filament\\Tables;
use Filament\\Tables\\Table;

class PushNotificationResource extends Resource
{
    protected static ?string $model = PushNotification::class;
    protected static ?string $navigationIcon = 'heroicon-o-bell-alert';
    protected static ?string $navigationGroup = 'التواصل';
    protected static ?string $navigationLabel = 'الإشعارات';
    protected static ?string $modelLabel = 'إشعار';
    protected static ?string $pluralModelLabel = 'الإشعارات';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\\Components\\Section::make('محتوى الإشعار')
                ->icon('heroicon-o-bell')
                ->schema([
                    Forms\\Components\\TextInput::make('title')
                        ->label('العنوان')
                        ->required()
                        ->maxLength(255)
                        ->columnSpanFull(),
                    Forms\\Components\\Textarea::make('body')
                        ->label('المحتوى')
                        ->required()
                        ->rows(3)
                        ->columnSpanFull(),
                    Forms\\Components\\Select::make('type')
                        ->label('النوع')
                        ->options([
                            'general' => 'عام',
                            'promotion' => 'عرض ترويجي',
                            'reminder' => 'تذكير',
                            'update' => 'تحديث',
                            'session' => 'جلسة تدريبية',
                            'subscription' => 'اشتراك',
                        ])
                        ->default('general')
                        ->required(),
                ]),
            Forms\\Components\\Section::make('الاستهداف')
                ->icon('heroicon-o-users')
                ->schema([
                    Forms\\Components\\Select::make('target_type')
                        ->label('إرسال إلى')
                        ->options([
                            'all' => 'الجميع',
                            'trainees' => 'جميع المتدربات',
                            'trainers' => 'جميع المدربات',
                            'active_subscribers' => 'المشتركات النشطات',
                            'specific' => 'شخص محدد',
                        ])
                        ->default('all')
                        ->required()
                        ->reactive(),
                    Forms\\Components\\TextInput::make('target_id')
                        ->label('معرف المستخدم')
                        ->numeric()
                        ->visible(fn ($get) => $get('target_type') === 'specific')
                        ->requiredIf('target_type', 'specific'),
                ])->columns(2),
            Forms\\Components\\Section::make('الجدولة والحالة')
                ->icon('heroicon-o-clock')
                ->schema([
                    Forms\\Components\\DateTimePicker::make('scheduled_at')
                        ->label('وقت الإرسال')
                        ->helperText('اتركه فارغاً للإرسال فوراً'),
                    Forms\\Components\\Select::make('status')
                        ->label('الحالة')
                        ->options([
                            'pending' => 'في الانتظار',
                            'sent' => 'تم الإرسال',
                            'failed' => 'فشل الإرسال',
                            'cancelled' => 'ملغي',
                        ])
                        ->default('pending')
                        ->required(),
                ])->columns(2),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\\Columns\\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable()
                    ->limit(40)
                    ->tooltip(fn ($record) => $record->title),
                Tables\\Columns\\TextColumn::make('type')
                    ->label('النوع')
                    ->badge()
                    ->formatStateUsing(fn($state) => match($state) {
                        'general' => 'عام',
                        'promotion' => 'عرض',
                        'reminder' => 'تذكير',
                        'update' => 'تحديث',
                        'session' => 'جلسة',
                        'subscription' => 'اشتراك',
                        default => $state
                    })
                    ->color(fn($state) => match($state) {
                        'general' => 'gray',
                        'promotion' => 'success',
                        'reminder' => 'warning',
                        'update' => 'info',
                        'session' => 'primary',
                        'subscription' => 'danger',
                        default => 'gray'
                    }),
                Tables\\Columns\\TextColumn::make('target_type')
                    ->label('الهدف')
                    ->formatStateUsing(fn($state) => match($state) {
                        'all' => 'الجميع',
                        'trainees' => 'المتدربات',
                        'trainers' => 'المدربات',
                        'active_subscribers' => 'المشتركات',
                        'specific' => 'محدد',
                        default => $state
                    }),
                Tables\\Columns\\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->formatStateUsing(fn($state) => match($state) {
                        'pending' => 'في الانتظار',
                        'sent' => 'تم الإرسال',
                        'failed' => 'فشل',
                        'cancelled' => 'ملغي',
                        default => $state
                    })
                    ->color(fn($state) => match($state) {
                        'pending' => 'warning',
                        'sent' => 'success',
                        'failed' => 'danger',
                        'cancelled' => 'gray',
                        default => 'gray'
                    }),
                Tables\\Columns\\TextColumn::make('scheduled_at')
                    ->label('موعد الإرسال')
                    ->dateTime('d/m/Y H:i')
                    ->placeholder('فوري'),
                Tables\\Columns\\TextColumn::make('sent_at')
                    ->label('وقت الإرسال')
                    ->dateTime('d/m/Y H:i')
                    ->placeholder('-'),
                Tables\\Columns\\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime('d/m/Y')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\\Filters\\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'في الانتظار',
                        'sent' => 'تم الإرسال',
                        'failed' => 'فشل',
                        'cancelled' => 'ملغي',
                    ]),
                Tables\\Filters\\SelectFilter::make('type')
                    ->label('النوع')
                    ->options([
                        'general' => 'عام',
                        'promotion' => 'عرض',
                        'reminder' => 'تذكير',
                        'update' => 'تحديث',
                    ]),
            ])
            ->actions([
                Tables\\Actions\\Action::make('send')
                    ->label('إرسال الآن')
                    ->icon('heroicon-o-paper-airplane')
                    ->color('success')
                    ->visible(fn ($record) => $record->status === 'pending')
                    ->requiresConfirmation()
                    ->modalHeading('إرسال الإشعار')
                    ->modalDescription('هل أنت متأكد من إرسال هذا الإشعار الآن؟')
                    ->action(function ($record) {
                        $record->update([
                            'status' => 'sent',
                            'sent_at' => now(),
                        ]);
                    }),
                Tables\\Actions\\EditAction::make(),
                Tables\\Actions\\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\\Actions\\BulkActionGroup::make([
                    Tables\\Actions\\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\\ListPushNotifications::route('/'),
            'create' => Pages\\CreatePushNotification::route('/create'),
            'edit' => Pages\\EditPushNotification::route('/{record}/edit'),
        ];
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
    base_path = "/home/u126213189/domains/vitafit.online/backend"

    # Write new PushNotification model
    with sftp.file(f"{base_path}/app/Models/PushNotification.php", 'w') as f:
        f.write(notification_model)
    print("Created PushNotification.php model")

    # Update resource
    with sftp.file(f"{base_path}/app/Filament/Resources/PushNotificationResource.php", 'w') as f:
        f.write(push_notification_resource)
    print("Updated PushNotificationResource.php")

    # Remove old Notification model
    try:
        sftp.remove(f"{base_path}/app/Models/Notification.php")
        print("Removed old Notification.php")
    except:
        pass

    sftp.close()

    # Clear caches
    print("\nClearing caches...")
    stdin, stdout, stderr = ssh.exec_command(f"cd {base_path} && php artisan cache:clear && php artisan view:clear")
    print(stdout.read().decode())

    ssh.close()
    print("\nNotifications fixed!")

except Exception as e:
    print(f"Error: {e}")
