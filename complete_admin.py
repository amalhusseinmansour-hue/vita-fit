import paramiko

host = "46.202.90.197"
port = 65002
username = "u126213189"
password = "Alenwanapp33510421@"

# ========== NEW MODELS ==========

exercise_model = '''<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use Illuminate\\Database\\Eloquent\\Model;

class Exercise extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'name_en',
        'description',
        'muscle_group',
        'difficulty',
        'video_url',
        'image',
        'calories_per_minute',
        'equipment_needed',
        'instructions',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'calories_per_minute' => 'decimal:2',
    ];
}
'''

workout_plan_model = '''<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use Illuminate\\Database\\Eloquent\\Model;

class WorkoutPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'trainer_id',
        'trainee_id',
        'name',
        'description',
        'goal',
        'difficulty',
        'duration_weeks',
        'days_per_week',
        'exercises',
        'notes',
        'start_date',
        'end_date',
        'status',
    ];

    protected $casts = [
        'exercises' => 'array',
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    public function trainer()
    {
        return $this->belongsTo(Trainer::class);
    }

    public function trainee()
    {
        return $this->belongsTo(Trainee::class);
    }
}
'''

nutrition_plan_model = '''<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use Illuminate\\Database\\Eloquent\\Model;

class NutritionPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'trainer_id',
        'trainee_id',
        'name',
        'description',
        'goal',
        'daily_calories',
        'protein_grams',
        'carbs_grams',
        'fat_grams',
        'meals',
        'notes',
        'start_date',
        'end_date',
        'status',
    ];

    protected $casts = [
        'meals' => 'array',
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    public function trainer()
    {
        return $this->belongsTo(Trainer::class);
    }

    public function trainee()
    {
        return $this->belongsTo(Trainee::class);
    }
}
'''

measurement_model = '''<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use Illuminate\\Database\\Eloquent\\Model;

class Measurement extends Model
{
    use HasFactory;

    protected $fillable = [
        'trainee_id',
        'date',
        'weight',
        'height',
        'body_fat_percentage',
        'muscle_mass',
        'chest',
        'waist',
        'hips',
        'arms',
        'thighs',
        'notes',
        'images',
    ];

    protected $casts = [
        'date' => 'date',
        'weight' => 'decimal:2',
        'height' => 'decimal:2',
        'body_fat_percentage' => 'decimal:2',
        'muscle_mass' => 'decimal:2',
        'images' => 'array',
    ];

    public function trainee()
    {
        return $this->belongsTo(Trainee::class);
    }
}
'''

notification_model = '''<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use Illuminate\\Database\\Eloquent\\Model;

class Notification extends Model
{
    use HasFactory;

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

article_model = '''<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use Illuminate\\Database\\Eloquent\\Model;

class Article extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'slug',
        'content',
        'excerpt',
        'image',
        'category',
        'author_id',
        'is_featured',
        'is_published',
        'published_at',
        'views_count',
    ];

    protected $casts = [
        'is_featured' => 'boolean',
        'is_published' => 'boolean',
        'published_at' => 'datetime',
    ];
}
'''

# ========== MIGRATIONS ==========

exercises_migration = '''<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('exercises', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('name_en')->nullable();
            $table->text('description')->nullable();
            $table->string('muscle_group')->nullable();
            $table->enum('difficulty', ['beginner', 'intermediate', 'advanced'])->default('beginner');
            $table->string('video_url')->nullable();
            $table->string('image')->nullable();
            $table->decimal('calories_per_minute', 5, 2)->nullable();
            $table->string('equipment_needed')->nullable();
            $table->text('instructions')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('exercises');
    }
};
'''

workout_plans_migration = '''<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workout_plans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trainer_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('trainee_id')->nullable()->constrained()->nullOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('goal')->nullable();
            $table->enum('difficulty', ['beginner', 'intermediate', 'advanced'])->default('beginner');
            $table->integer('duration_weeks')->default(4);
            $table->integer('days_per_week')->default(3);
            $table->json('exercises')->nullable();
            $table->text('notes')->nullable();
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->enum('status', ['draft', 'active', 'completed', 'cancelled'])->default('draft');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('workout_plans');
    }
};
'''

nutrition_plans_migration = '''<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('nutrition_plans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trainer_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('trainee_id')->nullable()->constrained()->nullOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('goal')->nullable();
            $table->integer('daily_calories')->nullable();
            $table->integer('protein_grams')->nullable();
            $table->integer('carbs_grams')->nullable();
            $table->integer('fat_grams')->nullable();
            $table->json('meals')->nullable();
            $table->text('notes')->nullable();
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->enum('status', ['draft', 'active', 'completed', 'cancelled'])->default('draft');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('nutrition_plans');
    }
};
'''

measurements_migration = '''<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('measurements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trainee_id')->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->decimal('weight', 5, 2)->nullable();
            $table->decimal('height', 5, 2)->nullable();
            $table->decimal('body_fat_percentage', 5, 2)->nullable();
            $table->decimal('muscle_mass', 5, 2)->nullable();
            $table->decimal('chest', 5, 2)->nullable();
            $table->decimal('waist', 5, 2)->nullable();
            $table->decimal('hips', 5, 2)->nullable();
            $table->decimal('arms', 5, 2)->nullable();
            $table->decimal('thighs', 5, 2)->nullable();
            $table->text('notes')->nullable();
            $table->json('images')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('measurements');
    }
};
'''

notifications_migration = '''<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications_custom', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('body');
            $table->string('type')->default('general');
            $table->string('target_type')->nullable();
            $table->unsignedBigInteger('target_id')->nullable();
            $table->json('data')->nullable();
            $table->timestamp('scheduled_at')->nullable();
            $table->timestamp('sent_at')->nullable();
            $table->enum('status', ['pending', 'sent', 'failed', 'cancelled'])->default('pending');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications_custom');
    }
};
'''

articles_migration = '''<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('articles', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('slug')->unique();
            $table->longText('content');
            $table->text('excerpt')->nullable();
            $table->string('image')->nullable();
            $table->string('category')->nullable();
            $table->unsignedBigInteger('author_id')->nullable();
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_published')->default(false);
            $table->timestamp('published_at')->nullable();
            $table->integer('views_count')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('articles');
    }
};
'''

# ========== FILAMENT RESOURCES ==========

exercise_resource = '''<?php

namespace App\\Filament\\Resources;

use App\\Filament\\Resources\\ExerciseResource\\Pages;
use App\\Models\\Exercise;
use Filament\\Forms;
use Filament\\Forms\\Form;
use Filament\\Resources\\Resource;
use Filament\\Tables;
use Filament\\Tables\\Table;

class ExerciseResource extends Resource
{
    protected static ?string $model = Exercise::class;
    protected static ?string $navigationIcon = 'heroicon-o-fire';
    protected static ?string $navigationGroup = 'التمارين';
    protected static ?string $navigationLabel = 'مكتبة التمارين';
    protected static ?string $modelLabel = 'تمرين';
    protected static ?string $pluralModelLabel = 'التمارين';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\\Components\\Section::make('معلومات التمرين')
                ->schema([
                    Forms\\Components\\TextInput::make('name')
                        ->label('اسم التمرين')
                        ->required()
                        ->maxLength(255),
                    Forms\\Components\\TextInput::make('name_en')
                        ->label('الاسم بالإنجليزية')
                        ->maxLength(255),
                    Forms\\Components\\Select::make('muscle_group')
                        ->label('المجموعة العضلية')
                        ->options([
                            'chest' => 'الصدر',
                            'back' => 'الظهر',
                            'shoulders' => 'الأكتاف',
                            'arms' => 'الذراعين',
                            'legs' => 'الأرجل',
                            'core' => 'البطن',
                            'cardio' => 'كارديو',
                            'full_body' => 'الجسم كامل',
                        ]),
                    Forms\\Components\\Select::make('difficulty')
                        ->label('المستوى')
                        ->options([
                            'beginner' => 'مبتدئ',
                            'intermediate' => 'متوسط',
                            'advanced' => 'متقدم',
                        ])
                        ->default('beginner'),
                ])->columns(2),
            Forms\\Components\\Section::make('التفاصيل')
                ->schema([
                    Forms\\Components\\Textarea::make('description')
                        ->label('الوصف')
                        ->rows(3),
                    Forms\\Components\\Textarea::make('instructions')
                        ->label('طريقة التنفيذ')
                        ->rows(4),
                    Forms\\Components\\TextInput::make('equipment_needed')
                        ->label('المعدات المطلوبة'),
                    Forms\\Components\\TextInput::make('calories_per_minute')
                        ->label('السعرات/دقيقة')
                        ->numeric(),
                ])->columns(2),
            Forms\\Components\\Section::make('الوسائط')
                ->schema([
                    Forms\\Components\\FileUpload::make('image')
                        ->label('صورة التمرين')
                        ->image()
                        ->directory('exercises'),
                    Forms\\Components\\TextInput::make('video_url')
                        ->label('رابط الفيديو')
                        ->url(),
                    Forms\\Components\\Toggle::make('is_active')
                        ->label('نشط')
                        ->default(true),
                ])->columns(2),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\\Columns\\ImageColumn::make('image')->label('صورة')->circular(),
                Tables\\Columns\\TextColumn::make('name')->label('الاسم')->searchable()->sortable(),
                Tables\\Columns\\TextColumn::make('muscle_group')->label('العضلة')
                    ->formatStateUsing(fn($state) => match($state) {
                        'chest' => 'الصدر', 'back' => 'الظهر', 'shoulders' => 'الأكتاف',
                        'arms' => 'الذراعين', 'legs' => 'الأرجل', 'core' => 'البطن',
                        'cardio' => 'كارديو', 'full_body' => 'كامل', default => $state
                    }),
                Tables\\Columns\\TextColumn::make('difficulty')->label('المستوى')
                    ->badge()
                    ->formatStateUsing(fn($state) => match($state) {
                        'beginner' => 'مبتدئ', 'intermediate' => 'متوسط', 'advanced' => 'متقدم', default => $state
                    })
                    ->color(fn($state) => match($state) {
                        'beginner' => 'success', 'intermediate' => 'warning', 'advanced' => 'danger', default => 'gray'
                    }),
                Tables\\Columns\\IconColumn::make('is_active')->label('نشط')->boolean(),
            ])
            ->filters([
                Tables\\Filters\\SelectFilter::make('muscle_group')->label('العضلة')
                    ->options([
                        'chest' => 'الصدر', 'back' => 'الظهر', 'shoulders' => 'الأكتاف',
                        'arms' => 'الذراعين', 'legs' => 'الأرجل', 'core' => 'البطن',
                    ]),
                Tables\\Filters\\SelectFilter::make('difficulty')->label('المستوى')
                    ->options(['beginner' => 'مبتدئ', 'intermediate' => 'متوسط', 'advanced' => 'متقدم']),
            ])
            ->actions([Tables\\Actions\\EditAction::make(), Tables\\Actions\\DeleteAction::make()])
            ->bulkActions([Tables\\Actions\\BulkActionGroup::make([Tables\\Actions\\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\\ListExercises::route('/'),
            'create' => Pages\\CreateExercise::route('/create'),
            'edit' => Pages\\EditExercise::route('/{record}/edit'),
        ];
    }
}
'''

workout_plan_resource = '''<?php

namespace App\\Filament\\Resources;

use App\\Filament\\Resources\\WorkoutPlanResource\\Pages;
use App\\Models\\WorkoutPlan;
use App\\Models\\Trainer;
use App\\Models\\Trainee;
use Filament\\Forms;
use Filament\\Forms\\Form;
use Filament\\Resources\\Resource;
use Filament\\Tables;
use Filament\\Tables\\Table;

class WorkoutPlanResource extends Resource
{
    protected static ?string $model = WorkoutPlan::class;
    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-list';
    protected static ?string $navigationGroup = 'التمارين';
    protected static ?string $navigationLabel = 'برامج التمرين';
    protected static ?string $modelLabel = 'برنامج تمرين';
    protected static ?string $pluralModelLabel = 'برامج التمرين';
    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\\Components\\Section::make('معلومات البرنامج')
                ->schema([
                    Forms\\Components\\TextInput::make('name')->label('اسم البرنامج')->required(),
                    Forms\\Components\\Select::make('trainer_id')->label('المدربة')
                        ->relationship('trainer', 'name')->searchable()->preload(),
                    Forms\\Components\\Select::make('trainee_id')->label('المتدربة')
                        ->relationship('trainee', 'name')->searchable()->preload(),
                    Forms\\Components\\Select::make('goal')->label('الهدف')
                        ->options([
                            'weight_loss' => 'خسارة الوزن',
                            'muscle_gain' => 'بناء العضلات',
                            'fitness' => 'اللياقة العامة',
                            'strength' => 'القوة',
                            'flexibility' => 'المرونة',
                        ]),
                ])->columns(2),
            Forms\\Components\\Section::make('تفاصيل البرنامج')
                ->schema([
                    Forms\\Components\\Select::make('difficulty')->label('المستوى')
                        ->options(['beginner' => 'مبتدئ', 'intermediate' => 'متوسط', 'advanced' => 'متقدم'])
                        ->default('beginner'),
                    Forms\\Components\\TextInput::make('duration_weeks')->label('المدة (أسابيع)')->numeric()->default(4),
                    Forms\\Components\\TextInput::make('days_per_week')->label('أيام/أسبوع')->numeric()->default(3),
                    Forms\\Components\\Select::make('status')->label('الحالة')
                        ->options(['draft' => 'مسودة', 'active' => 'نشط', 'completed' => 'مكتمل', 'cancelled' => 'ملغي'])
                        ->default('draft'),
                    Forms\\Components\\DatePicker::make('start_date')->label('تاريخ البدء'),
                    Forms\\Components\\DatePicker::make('end_date')->label('تاريخ الانتهاء'),
                ])->columns(3),
            Forms\\Components\\Section::make('المحتوى')
                ->schema([
                    Forms\\Components\\Textarea::make('description')->label('الوصف')->rows(3),
                    Forms\\Components\\Textarea::make('notes')->label('ملاحظات')->rows(3),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\\Columns\\TextColumn::make('name')->label('البرنامج')->searchable()->sortable(),
                Tables\\Columns\\TextColumn::make('trainee.name')->label('المتدربة')->searchable(),
                Tables\\Columns\\TextColumn::make('trainer.name')->label('المدربة')->searchable(),
                Tables\\Columns\\TextColumn::make('duration_weeks')->label('المدة')->suffix(' أسبوع'),
                Tables\\Columns\\TextColumn::make('status')->label('الحالة')->badge()
                    ->formatStateUsing(fn($state) => match($state) {
                        'draft' => 'مسودة', 'active' => 'نشط', 'completed' => 'مكتمل', 'cancelled' => 'ملغي', default => $state
                    })
                    ->color(fn($state) => match($state) {
                        'draft' => 'gray', 'active' => 'success', 'completed' => 'info', 'cancelled' => 'danger', default => 'gray'
                    }),
                Tables\\Columns\\TextColumn::make('created_at')->label('تاريخ الإنشاء')->date(),
            ])
            ->filters([
                Tables\\Filters\\SelectFilter::make('status')->label('الحالة')
                    ->options(['draft' => 'مسودة', 'active' => 'نشط', 'completed' => 'مكتمل']),
            ])
            ->actions([Tables\\Actions\\EditAction::make(), Tables\\Actions\\DeleteAction::make()])
            ->bulkActions([Tables\\Actions\\BulkActionGroup::make([Tables\\Actions\\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\\ListWorkoutPlans::route('/'),
            'create' => Pages\\CreateWorkoutPlan::route('/create'),
            'edit' => Pages\\EditWorkoutPlan::route('/{record}/edit'),
        ];
    }
}
'''

nutrition_plan_resource = '''<?php

namespace App\\Filament\\Resources;

use App\\Filament\\Resources\\NutritionPlanResource\\Pages;
use App\\Models\\NutritionPlan;
use Filament\\Forms;
use Filament\\Forms\\Form;
use Filament\\Resources\\Resource;
use Filament\\Tables;
use Filament\\Tables\\Table;

class NutritionPlanResource extends Resource
{
    protected static ?string $model = NutritionPlan::class;
    protected static ?string $navigationIcon = 'heroicon-o-cake';
    protected static ?string $navigationGroup = 'التغذية';
    protected static ?string $navigationLabel = 'خطط التغذية';
    protected static ?string $modelLabel = 'خطة تغذية';
    protected static ?string $pluralModelLabel = 'خطط التغذية';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\\Components\\Section::make('معلومات الخطة')
                ->schema([
                    Forms\\Components\\TextInput::make('name')->label('اسم الخطة')->required(),
                    Forms\\Components\\Select::make('trainer_id')->label('المدربة')
                        ->relationship('trainer', 'name')->searchable()->preload(),
                    Forms\\Components\\Select::make('trainee_id')->label('المتدربة')
                        ->relationship('trainee', 'name')->searchable()->preload(),
                    Forms\\Components\\Select::make('goal')->label('الهدف')
                        ->options([
                            'weight_loss' => 'خسارة الوزن',
                            'muscle_gain' => 'بناء العضلات',
                            'maintenance' => 'الحفاظ على الوزن',
                            'bulking' => 'التضخيم',
                            'cutting' => 'التنشيف',
                        ]),
                ])->columns(2),
            Forms\\Components\\Section::make('السعرات والماكروز')
                ->schema([
                    Forms\\Components\\TextInput::make('daily_calories')->label('السعرات اليومية')->numeric()->suffix('سعرة'),
                    Forms\\Components\\TextInput::make('protein_grams')->label('البروتين')->numeric()->suffix('جرام'),
                    Forms\\Components\\TextInput::make('carbs_grams')->label('الكربوهيدرات')->numeric()->suffix('جرام'),
                    Forms\\Components\\TextInput::make('fat_grams')->label('الدهون')->numeric()->suffix('جرام'),
                ])->columns(4),
            Forms\\Components\\Section::make('التفاصيل')
                ->schema([
                    Forms\\Components\\Select::make('status')->label('الحالة')
                        ->options(['draft' => 'مسودة', 'active' => 'نشط', 'completed' => 'مكتمل', 'cancelled' => 'ملغي'])
                        ->default('draft'),
                    Forms\\Components\\DatePicker::make('start_date')->label('تاريخ البدء'),
                    Forms\\Components\\DatePicker::make('end_date')->label('تاريخ الانتهاء'),
                ])->columns(3),
            Forms\\Components\\Section::make('المحتوى')
                ->schema([
                    Forms\\Components\\Textarea::make('description')->label('الوصف')->rows(3),
                    Forms\\Components\\Textarea::make('notes')->label('ملاحظات')->rows(3),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\\Columns\\TextColumn::make('name')->label('الخطة')->searchable()->sortable(),
                Tables\\Columns\\TextColumn::make('trainee.name')->label('المتدربة')->searchable(),
                Tables\\Columns\\TextColumn::make('daily_calories')->label('السعرات')->suffix(' سعرة'),
                Tables\\Columns\\TextColumn::make('status')->label('الحالة')->badge()
                    ->formatStateUsing(fn($state) => match($state) {
                        'draft' => 'مسودة', 'active' => 'نشط', 'completed' => 'مكتمل', 'cancelled' => 'ملغي', default => $state
                    })
                    ->color(fn($state) => match($state) {
                        'draft' => 'gray', 'active' => 'success', 'completed' => 'info', 'cancelled' => 'danger', default => 'gray'
                    }),
                Tables\\Columns\\TextColumn::make('created_at')->label('تاريخ الإنشاء')->date(),
            ])
            ->filters([
                Tables\\Filters\\SelectFilter::make('status')->label('الحالة')
                    ->options(['draft' => 'مسودة', 'active' => 'نشط', 'completed' => 'مكتمل']),
            ])
            ->actions([Tables\\Actions\\EditAction::make(), Tables\\Actions\\DeleteAction::make()])
            ->bulkActions([Tables\\Actions\\BulkActionGroup::make([Tables\\Actions\\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\\ListNutritionPlans::route('/'),
            'create' => Pages\\CreateNutritionPlan::route('/create'),
            'edit' => Pages\\EditNutritionPlan::route('/{record}/edit'),
        ];
    }
}
'''

measurement_resource = '''<?php

namespace App\\Filament\\Resources;

use App\\Filament\\Resources\\MeasurementResource\\Pages;
use App\\Models\\Measurement;
use Filament\\Forms;
use Filament\\Forms\\Form;
use Filament\\Resources\\Resource;
use Filament\\Tables;
use Filament\\Tables\\Table;

class MeasurementResource extends Resource
{
    protected static ?string $model = Measurement::class;
    protected static ?string $navigationIcon = 'heroicon-o-chart-bar';
    protected static ?string $navigationGroup = 'المتابعة';
    protected static ?string $navigationLabel = 'القياسات';
    protected static ?string $modelLabel = 'قياس';
    protected static ?string $pluralModelLabel = 'القياسات';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\\Components\\Section::make('معلومات القياس')
                ->schema([
                    Forms\\Components\\Select::make('trainee_id')->label('المتدربة')
                        ->relationship('trainee', 'name')->searchable()->preload()->required(),
                    Forms\\Components\\DatePicker::make('date')->label('التاريخ')->required()->default(now()),
                ])->columns(2),
            Forms\\Components\\Section::make('القياسات الأساسية')
                ->schema([
                    Forms\\Components\\TextInput::make('weight')->label('الوزن')->numeric()->suffix('كجم'),
                    Forms\\Components\\TextInput::make('height')->label('الطول')->numeric()->suffix('سم'),
                    Forms\\Components\\TextInput::make('body_fat_percentage')->label('نسبة الدهون')->numeric()->suffix('%'),
                    Forms\\Components\\TextInput::make('muscle_mass')->label('الكتلة العضلية')->numeric()->suffix('كجم'),
                ])->columns(4),
            Forms\\Components\\Section::make('قياسات الجسم')
                ->schema([
                    Forms\\Components\\TextInput::make('chest')->label('الصدر')->numeric()->suffix('سم'),
                    Forms\\Components\\TextInput::make('waist')->label('الخصر')->numeric()->suffix('سم'),
                    Forms\\Components\\TextInput::make('hips')->label('الأرداف')->numeric()->suffix('سم'),
                    Forms\\Components\\TextInput::make('arms')->label('الذراعين')->numeric()->suffix('سم'),
                    Forms\\Components\\TextInput::make('thighs')->label('الفخذين')->numeric()->suffix('سم'),
                ])->columns(5),
            Forms\\Components\\Section::make('إضافات')
                ->schema([
                    Forms\\Components\\Textarea::make('notes')->label('ملاحظات')->rows(3),
                    Forms\\Components\\FileUpload::make('images')->label('صور التقدم')->image()->multiple()->directory('measurements'),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\\Columns\\TextColumn::make('trainee.name')->label('المتدربة')->searchable()->sortable(),
                Tables\\Columns\\TextColumn::make('date')->label('التاريخ')->date()->sortable(),
                Tables\\Columns\\TextColumn::make('weight')->label('الوزن')->suffix(' كجم'),
                Tables\\Columns\\TextColumn::make('body_fat_percentage')->label('الدهون')->suffix('%'),
                Tables\\Columns\\TextColumn::make('waist')->label('الخصر')->suffix(' سم'),
            ])
            ->defaultSort('date', 'desc')
            ->filters([])
            ->actions([Tables\\Actions\\EditAction::make(), Tables\\Actions\\DeleteAction::make()])
            ->bulkActions([Tables\\Actions\\BulkActionGroup::make([Tables\\Actions\\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\\ListMeasurements::route('/'),
            'create' => Pages\\CreateMeasurement::route('/create'),
            'edit' => Pages\\EditMeasurement::route('/{record}/edit'),
        ];
    }
}
'''

article_resource = '''<?php

namespace App\\Filament\\Resources;

use App\\Filament\\Resources\\ArticleResource\\Pages;
use App\\Models\\Article;
use Filament\\Forms;
use Filament\\Forms\\Form;
use Filament\\Resources\\Resource;
use Filament\\Tables;
use Filament\\Tables\\Table;
use Illuminate\\Support\\Str;

class ArticleResource extends Resource
{
    protected static ?string $model = Article::class;
    protected static ?string $navigationIcon = 'heroicon-o-document-text';
    protected static ?string $navigationGroup = 'المحتوى';
    protected static ?string $navigationLabel = 'المقالات';
    protected static ?string $modelLabel = 'مقال';
    protected static ?string $pluralModelLabel = 'المقالات';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\\Components\\Section::make('معلومات المقال')
                ->schema([
                    Forms\\Components\\TextInput::make('title')->label('العنوان')->required()
                        ->live(onBlur: true)
                        ->afterStateUpdated(fn ($state, $set) => $set('slug', Str::slug($state))),
                    Forms\\Components\\TextInput::make('slug')->label('الرابط')->required()->unique(ignoreRecord: true),
                    Forms\\Components\\Select::make('category')->label('التصنيف')
                        ->options([
                            'fitness' => 'اللياقة',
                            'nutrition' => 'التغذية',
                            'health' => 'الصحة',
                            'motivation' => 'التحفيز',
                            'tips' => 'نصائح',
                        ]),
                    Forms\\Components\\FileUpload::make('image')->label('الصورة')->image()->directory('articles'),
                ])->columns(2),
            Forms\\Components\\Section::make('المحتوى')
                ->schema([
                    Forms\\Components\\Textarea::make('excerpt')->label('المقتطف')->rows(2),
                    Forms\\Components\\RichEditor::make('content')->label('المحتوى')->required()->columnSpanFull(),
                ]),
            Forms\\Components\\Section::make('النشر')
                ->schema([
                    Forms\\Components\\Toggle::make('is_published')->label('منشور')->default(false),
                    Forms\\Components\\Toggle::make('is_featured')->label('مميز')->default(false),
                    Forms\\Components\\DateTimePicker::make('published_at')->label('تاريخ النشر'),
                ])->columns(3),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\\Columns\\ImageColumn::make('image')->label('صورة')->circular(),
                Tables\\Columns\\TextColumn::make('title')->label('العنوان')->searchable()->sortable()->limit(40),
                Tables\\Columns\\TextColumn::make('category')->label('التصنيف')
                    ->formatStateUsing(fn($state) => match($state) {
                        'fitness' => 'اللياقة', 'nutrition' => 'التغذية', 'health' => 'الصحة',
                        'motivation' => 'التحفيز', 'tips' => 'نصائح', default => $state
                    }),
                Tables\\Columns\\IconColumn::make('is_published')->label('منشور')->boolean(),
                Tables\\Columns\\IconColumn::make('is_featured')->label('مميز')->boolean(),
                Tables\\Columns\\TextColumn::make('views_count')->label('المشاهدات')->sortable(),
                Tables\\Columns\\TextColumn::make('created_at')->label('التاريخ')->date(),
            ])
            ->filters([
                Tables\\Filters\\TernaryFilter::make('is_published')->label('منشور'),
                Tables\\Filters\\TernaryFilter::make('is_featured')->label('مميز'),
            ])
            ->actions([Tables\\Actions\\EditAction::make(), Tables\\Actions\\DeleteAction::make()])
            ->bulkActions([Tables\\Actions\\BulkActionGroup::make([Tables\\Actions\\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\\ListArticles::route('/'),
            'create' => Pages\\CreateArticle::route('/create'),
            'edit' => Pages\\EditArticle::route('/{record}/edit'),
        ];
    }
}
'''

push_notification_resource = '''<?php

namespace App\\Filament\\Resources;

use App\\Filament\\Resources\\PushNotificationResource\\Pages;
use App\\Models\\Notification;
use Filament\\Forms;
use Filament\\Forms\\Form;
use Filament\\Resources\\Resource;
use Filament\\Tables;
use Filament\\Tables\\Table;

class PushNotificationResource extends Resource
{
    protected static ?string $model = Notification::class;
    protected static ?string $navigationIcon = 'heroicon-o-bell-alert';
    protected static ?string $navigationGroup = 'التواصل';
    protected static ?string $navigationLabel = 'الإشعارات';
    protected static ?string $modelLabel = 'إشعار';
    protected static ?string $pluralModelLabel = 'الإشعارات';
    protected static ?int $navigationSort = 1;

    public static function getEloquentQuery(): \\Illuminate\\Database\\Eloquent\\Builder
    {
        return parent::getEloquentQuery()->where('type', '!=', 'database');
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\\Components\\Section::make('محتوى الإشعار')
                ->schema([
                    Forms\\Components\\TextInput::make('title')->label('العنوان')->required(),
                    Forms\\Components\\Textarea::make('body')->label('المحتوى')->required()->rows(3),
                    Forms\\Components\\Select::make('type')->label('النوع')
                        ->options([
                            'general' => 'عام',
                            'promotion' => 'عرض',
                            'reminder' => 'تذكير',
                            'update' => 'تحديث',
                        ])
                        ->default('general'),
                ])->columns(1),
            Forms\\Components\\Section::make('الاستهداف')
                ->schema([
                    Forms\\Components\\Select::make('target_type')->label('إرسال إلى')
                        ->options([
                            'all' => 'الجميع',
                            'trainees' => 'المتدربات فقط',
                            'trainers' => 'المدربات فقط',
                            'specific' => 'شخص محدد',
                        ])
                        ->default('all')
                        ->reactive(),
                    Forms\\Components\\TextInput::make('target_id')->label('معرف المستخدم')
                        ->visible(fn ($get) => $get('target_type') === 'specific'),
                ])->columns(2),
            Forms\\Components\\Section::make('الجدولة')
                ->schema([
                    Forms\\Components\\DateTimePicker::make('scheduled_at')->label('وقت الإرسال'),
                    Forms\\Components\\Select::make('status')->label('الحالة')
                        ->options([
                            'pending' => 'في الانتظار',
                            'sent' => 'تم الإرسال',
                            'failed' => 'فشل',
                            'cancelled' => 'ملغي',
                        ])
                        ->default('pending'),
                ])->columns(2),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\\Columns\\TextColumn::make('title')->label('العنوان')->searchable()->limit(30),
                Tables\\Columns\\TextColumn::make('type')->label('النوع')
                    ->badge()
                    ->formatStateUsing(fn($state) => match($state) {
                        'general' => 'عام', 'promotion' => 'عرض', 'reminder' => 'تذكير', 'update' => 'تحديث', default => $state
                    }),
                Tables\\Columns\\TextColumn::make('target_type')->label('الهدف')
                    ->formatStateUsing(fn($state) => match($state) {
                        'all' => 'الجميع', 'trainees' => 'المتدربات', 'trainers' => 'المدربات', 'specific' => 'محدد', default => $state
                    }),
                Tables\\Columns\\TextColumn::make('status')->label('الحالة')
                    ->badge()
                    ->formatStateUsing(fn($state) => match($state) {
                        'pending' => 'في الانتظار', 'sent' => 'تم الإرسال', 'failed' => 'فشل', 'cancelled' => 'ملغي', default => $state
                    })
                    ->color(fn($state) => match($state) {
                        'pending' => 'warning', 'sent' => 'success', 'failed' => 'danger', 'cancelled' => 'gray', default => 'gray'
                    }),
                Tables\\Columns\\TextColumn::make('scheduled_at')->label('موعد الإرسال')->dateTime(),
                Tables\\Columns\\TextColumn::make('sent_at')->label('وقت الإرسال')->dateTime(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\\Filters\\SelectFilter::make('status')->label('الحالة')
                    ->options(['pending' => 'في الانتظار', 'sent' => 'تم الإرسال', 'failed' => 'فشل']),
            ])
            ->actions([Tables\\Actions\\EditAction::make(), Tables\\Actions\\DeleteAction::make()])
            ->bulkActions([Tables\\Actions\\BulkActionGroup::make([Tables\\Actions\\DeleteBulkAction::make()])]);
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

message_resource = '''<?php

namespace App\\Filament\\Resources;

use App\\Filament\\Resources\\MessageResource\\Pages;
use App\\Models\\Message;
use Filament\\Forms;
use Filament\\Forms\\Form;
use Filament\\Resources\\Resource;
use Filament\\Tables;
use Filament\\Tables\\Table;

class MessageResource extends Resource
{
    protected static ?string $model = Message::class;
    protected static ?string $navigationIcon = 'heroicon-o-chat-bubble-left-right';
    protected static ?string $navigationGroup = 'التواصل';
    protected static ?string $navigationLabel = 'الرسائل';
    protected static ?string $modelLabel = 'رسالة';
    protected static ?string $pluralModelLabel = 'الرسائل';
    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\\Components\\Section::make('الرسالة')
                ->schema([
                    Forms\\Components\\Select::make('conversation_id')->label('المحادثة')
                        ->relationship('conversation', 'id')->required(),
                    Forms\\Components\\TextInput::make('sender_type')->label('نوع المرسل'),
                    Forms\\Components\\TextInput::make('sender_id')->label('معرف المرسل'),
                    Forms\\Components\\Textarea::make('content')->label('المحتوى')->rows(4),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\\Columns\\TextColumn::make('conversation_id')->label('المحادثة'),
                Tables\\Columns\\TextColumn::make('sender_type')->label('المرسل'),
                Tables\\Columns\\TextColumn::make('content')->label('المحتوى')->limit(50),
                Tables\\Columns\\TextColumn::make('created_at')->label('التاريخ')->dateTime(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([])
            ->actions([Tables\\Actions\\ViewAction::make()])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\\ListMessages::route('/'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }
}
'''

# Resource Pages Templates
def get_list_page(resource_name, model_name):
    return f'''<?php

namespace App\\Filament\\Resources\\{resource_name}\\Pages;

use App\\Filament\\Resources\\{resource_name};
use Filament\\Actions;
use Filament\\Resources\\Pages\\ListRecords;

class List{model_name}s extends ListRecords
{{
    protected static string $resource = {resource_name}::class;

    protected function getHeaderActions(): array
    {{
        return [
            Actions\\CreateAction::make(),
        ];
    }}
}}
'''

def get_create_page(resource_name, model_name):
    return f'''<?php

namespace App\\Filament\\Resources\\{resource_name}\\Pages;

use App\\Filament\\Resources\\{resource_name};
use Filament\\Resources\\Pages\\CreateRecord;

class Create{model_name} extends CreateRecord
{{
    protected static string $resource = {resource_name}::class;
}}
'''

def get_edit_page(resource_name, model_name):
    return f'''<?php

namespace App\\Filament\\Resources\\{resource_name}\\Pages;

use App\\Filament\\Resources\\{resource_name};
use Filament\\Actions;
use Filament\\Resources\\Pages\\EditRecord;

class Edit{model_name} extends EditRecord
{{
    protected static string $resource = {resource_name}::class;

    protected function getHeaderActions(): array
    {{
        return [
            Actions\\DeleteAction::make(),
        ];
    }}
}}
'''

# Dashboard
dashboard_page = '''<?php

namespace App\\Filament\\Pages;

use App\\Models\\Trainee;
use App\\Models\\Trainer;
use App\\Models\\TrainingSession;
use App\\Models\\Subscription;
use App\\Models\\Order;
use Filament\\Pages\\Dashboard as BaseDashboard;
use Filament\\Widgets\\StatsOverviewWidget\\Stat;
use Filament\\Widgets\\Concerns\\InteractsWithPageFilters;

class Dashboard extends BaseDashboard
{
    protected static ?string $navigationIcon = 'heroicon-o-home';
    protected static ?string $navigationLabel = 'الرئيسية';
    protected static ?string $title = 'لوحة التحكم';

    public function getWidgets(): array
    {
        return [
            \\App\\Filament\\Widgets\\StatsOverview::class,
            \\App\\Filament\\Widgets\\LatestTrainees::class,
            \\App\\Filament\\Widgets\\UpcomingSessions::class,
            \\App\\Filament\\Widgets\\RecentOrders::class,
        ];
    }
}
'''

stats_widget = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Trainee;
use App\\Models\\Trainer;
use App\\Models\\TrainingSession;
use App\\Models\\Subscription;
use App\\Models\\Order;
use Filament\\Widgets\\StatsOverviewWidget;
use Filament\\Widgets\\StatsOverviewWidget\\Stat;

class StatsOverview extends StatsOverviewWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        return [
            Stat::make('المتدربات', Trainee::count())
                ->description('إجمالي المتدربات')
                ->descriptionIcon('heroicon-o-users')
                ->color('success')
                ->chart([7, 3, 4, 5, 6, 3, 5]),
            Stat::make('المدربات', Trainer::count())
                ->description('إجمالي المدربات')
                ->descriptionIcon('heroicon-o-user-group')
                ->color('info'),
            Stat::make('الجلسات', TrainingSession::whereDate('scheduled_at', '>=', now())->count())
                ->description('الجلسات القادمة')
                ->descriptionIcon('heroicon-o-calendar')
                ->color('warning'),
            Stat::make('الاشتراكات النشطة', Subscription::where('status', 'active')->count())
                ->description('اشتراكات فعالة')
                ->descriptionIcon('heroicon-o-credit-card')
                ->color('primary'),
        ];
    }
}
'''

latest_trainees_widget = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Trainee;
use Filament\\Tables;
use Filament\\Tables\\Table;
use Filament\\Widgets\\TableWidget as BaseWidget;

class LatestTrainees extends BaseWidget
{
    protected static ?int $sort = 2;
    protected int|string|array $columnSpan = 'half';
    protected static ?string $heading = 'أحدث المتدربات';

    public function table(Table $table): Table
    {
        return $table
            ->query(Trainee::query()->latest()->limit(5))
            ->columns([
                Tables\\Columns\\TextColumn::make('name')->label('الاسم'),
                Tables\\Columns\\TextColumn::make('phone')->label('الهاتف'),
                Tables\\Columns\\TextColumn::make('created_at')->label('تاريخ التسجيل')->since(),
            ])
            ->paginated(false);
    }
}
'''

upcoming_sessions_widget = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\TrainingSession;
use Filament\\Tables;
use Filament\\Tables\\Table;
use Filament\\Widgets\\TableWidget as BaseWidget;

class UpcomingSessions extends BaseWidget
{
    protected static ?int $sort = 3;
    protected int|string|array $columnSpan = 'half';
    protected static ?string $heading = 'الجلسات القادمة';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                TrainingSession::query()
                    ->whereDate('scheduled_at', '>=', now())
                    ->orderBy('scheduled_at')
                    ->limit(5)
            )
            ->columns([
                Tables\\Columns\\TextColumn::make('trainee.name')->label('المتدربة'),
                Tables\\Columns\\TextColumn::make('trainer.name')->label('المدربة'),
                Tables\\Columns\\TextColumn::make('scheduled_at')->label('الموعد')->dateTime('M d, H:i'),
                Tables\\Columns\\TextColumn::make('status')->label('الحالة')->badge(),
            ])
            ->paginated(false);
    }
}
'''

recent_orders_widget = '''<?php

namespace App\\Filament\\Widgets;

use App\\Models\\Order;
use Filament\\Tables;
use Filament\\Tables\\Table;
use Filament\\Widgets\\TableWidget as BaseWidget;

class RecentOrders extends BaseWidget
{
    protected static ?int $sort = 4;
    protected int|string|array $columnSpan = 'full';
    protected static ?string $heading = 'أحدث الطلبات';

    public function table(Table $table): Table
    {
        return $table
            ->query(Order::query()->latest()->limit(5))
            ->columns([
                Tables\\Columns\\TextColumn::make('id')->label('رقم الطلب'),
                Tables\\Columns\\TextColumn::make('trainee.name')->label('العميل'),
                Tables\\Columns\\TextColumn::make('total')->label('المبلغ')->money('SAR'),
                Tables\\Columns\\TextColumn::make('status')->label('الحالة')->badge(),
                Tables\\Columns\\TextColumn::make('created_at')->label('التاريخ')->since(),
            ])
            ->paginated(false);
    }
}
'''

print("Connecting to server...")
try:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port=port, username=username, password=password, timeout=30)
    print("Connected!")

    sftp = ssh.open_sftp()
    base_path = "/home/u126213189/domains/vitafit.online/backend"

    # Create directories
    dirs = [
        f"{base_path}/app/Filament/Resources/ExerciseResource/Pages",
        f"{base_path}/app/Filament/Resources/WorkoutPlanResource/Pages",
        f"{base_path}/app/Filament/Resources/NutritionPlanResource/Pages",
        f"{base_path}/app/Filament/Resources/MeasurementResource/Pages",
        f"{base_path}/app/Filament/Resources/ArticleResource/Pages",
        f"{base_path}/app/Filament/Resources/PushNotificationResource/Pages",
        f"{base_path}/app/Filament/Resources/MessageResource/Pages",
        f"{base_path}/app/Filament/Widgets",
    ]

    for d in dirs:
        try:
            sftp.mkdir(d)
        except:
            pass

    print("Directories created")

    # Write Models
    models = {
        'Exercise': exercise_model,
        'WorkoutPlan': workout_plan_model,
        'NutritionPlan': nutrition_plan_model,
        'Measurement': measurement_model,
        'Notification': notification_model,
        'Article': article_model,
    }

    for name, content in models.items():
        with sftp.file(f"{base_path}/app/Models/{name}.php", 'w') as f:
            f.write(content)
        print(f"Created Model: {name}")

    # Write Migrations
    migrations = {
        '2024_12_27_000001_create_exercises_table.php': exercises_migration,
        '2024_12_27_000002_create_workout_plans_table.php': workout_plans_migration,
        '2024_12_27_000003_create_nutrition_plans_table.php': nutrition_plans_migration,
        '2024_12_27_000004_create_measurements_table.php': measurements_migration,
        '2024_12_27_000005_create_notifications_custom_table.php': notifications_migration,
        '2024_12_27_000006_create_articles_table.php': articles_migration,
    }

    for name, content in migrations.items():
        with sftp.file(f"{base_path}/database/migrations/{name}", 'w') as f:
            f.write(content)
        print(f"Created Migration: {name}")

    # Write Resources
    resources = {
        'ExerciseResource': (exercise_resource, 'Exercise', 'Exercise'),
        'WorkoutPlanResource': (workout_plan_resource, 'WorkoutPlan', 'WorkoutPlan'),
        'NutritionPlanResource': (nutrition_plan_resource, 'NutritionPlan', 'NutritionPlan'),
        'MeasurementResource': (measurement_resource, 'Measurement', 'Measurement'),
        'ArticleResource': (article_resource, 'Article', 'Article'),
        'PushNotificationResource': (push_notification_resource, 'PushNotification', 'PushNotification'),
        'MessageResource': (message_resource, 'Message', 'Message'),
    }

    for res_name, (content, model, singular) in resources.items():
        with sftp.file(f"{base_path}/app/Filament/Resources/{res_name}.php", 'w') as f:
            f.write(content)
        print(f"Created Resource: {res_name}")

        # Create pages
        with sftp.file(f"{base_path}/app/Filament/Resources/{res_name}/Pages/List{singular}s.php", 'w') as f:
            f.write(get_list_page(res_name, singular))

        if res_name != 'MessageResource':
            with sftp.file(f"{base_path}/app/Filament/Resources/{res_name}/Pages/Create{singular}.php", 'w') as f:
                f.write(get_create_page(res_name, singular))
            with sftp.file(f"{base_path}/app/Filament/Resources/{res_name}/Pages/Edit{singular}.php", 'w') as f:
                f.write(get_edit_page(res_name, singular))

    # Write Dashboard
    with sftp.file(f"{base_path}/app/Filament/Pages/Dashboard.php", 'w') as f:
        f.write(dashboard_page)
    print("Created Dashboard")

    # Write Widgets
    with sftp.file(f"{base_path}/app/Filament/Widgets/StatsOverview.php", 'w') as f:
        f.write(stats_widget)
    with sftp.file(f"{base_path}/app/Filament/Widgets/LatestTrainees.php", 'w') as f:
        f.write(latest_trainees_widget)
    with sftp.file(f"{base_path}/app/Filament/Widgets/UpcomingSessions.php", 'w') as f:
        f.write(upcoming_sessions_widget)
    with sftp.file(f"{base_path}/app/Filament/Widgets/RecentOrders.php", 'w') as f:
        f.write(recent_orders_widget)
    print("Created Widgets")

    sftp.close()

    # Run migrations
    print("\nRunning migrations...")
    stdin, stdout, stderr = ssh.exec_command(f"cd {base_path} && php artisan migrate --force")
    print(stdout.read().decode())
    err = stderr.read().decode()
    if err:
        print(f"Errors: {err}")

    # Clear caches
    print("Clearing caches...")
    stdin, stdout, stderr = ssh.exec_command(f"cd {base_path} && php artisan cache:clear && php artisan view:clear && php artisan config:clear")
    print(stdout.read().decode())

    ssh.close()
    print("\n✅ Admin panel setup complete!")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
