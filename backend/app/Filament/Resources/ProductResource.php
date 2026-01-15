<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ProductResource\Pages;
use App\Filament\Resources\ProductResource\RelationManagers;
use App\Models\Product;
use App\Models\Category;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Illuminate\Database\Eloquent\Builder;

class ProductResource extends Resource
{
    protected static ?string $model = Product::class;
    protected static ?string $navigationIcon = 'heroicon-o-shopping-bag';
    protected static ?string $navigationGroup = 'المتجر';
    protected static ?string $navigationLabel = 'المنتجات';
    protected static ?string $modelLabel = 'منتج';
    protected static ?string $pluralModelLabel = 'المنتجات';
    protected static ?int $navigationSort = 2;

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('is_active', true)->count();
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Group::make()
                    ->schema([
                        Forms\Components\Section::make('معلومات المنتج')
                            ->schema([
                                Forms\Components\TextInput::make('name')
                                    ->label('اسم المنتج (English)')
                                    ->required()
                                    ->maxLength(255)
                                    ->live(onBlur: true)
                                    ->afterStateUpdated(fn ($state, callable $set) => $set('slug', \Str::slug($state))),
                                Forms\Components\TextInput::make('name_ar')
                                    ->label('اسم المنتج (عربي)')
                                    ->maxLength(255),
                                Forms\Components\TextInput::make('slug')
                                    ->label('الرابط')
                                    ->required()
                                    ->unique(ignoreRecord: true),
                                Forms\Components\Select::make('category_id')
                                    ->label('الفئة')
                                    ->relationship('category', 'name_ar')
                                    ->searchable()
                                    ->preload(),
                                Forms\Components\Textarea::make('description')
                                    ->label('الوصف (English)')
                                    ->rows(3),
                                Forms\Components\Textarea::make('description_ar')
                                    ->label('الوصف (عربي)')
                                    ->rows(3),
                            ])->columns(2),

                        Forms\Components\Section::make('السعر والمخزون')
                            ->schema([
                                Forms\Components\TextInput::make('price')
                                    ->label('السعر')
                                    ->numeric()
                                    ->prefix('ر.س')
                                    ->required(),
                                Forms\Components\TextInput::make('sale_price')
                                    ->label('سعر التخفيض')
                                    ->numeric()
                                    ->prefix('ر.س')
                                    ->lt('price'),
                                Forms\Components\TextInput::make('cost_price')
                                    ->label('سعر التكلفة')
                                    ->numeric()
                                    ->prefix('ر.س'),
                                Forms\Components\TextInput::make('quantity')
                                    ->label('الكمية المتوفرة')
                                    ->numeric()
                                    ->default(0)
                                    ->required(),
                                Forms\Components\TextInput::make('low_stock_threshold')
                                    ->label('حد المخزون المنخفض')
                                    ->numeric()
                                    ->default(10),
                                Forms\Components\TextInput::make('sku')
                                    ->label('رمز المنتج (SKU)')
                                    ->unique(ignoreRecord: true),
                            ])->columns(3),

                        Forms\Components\Section::make('الصور')
                            ->schema([
                                Forms\Components\FileUpload::make('image')
                                    ->label('الصورة الرئيسية')
                                    ->image()
                                    ->directory('products')
                                    ->columnSpanFull(),
                                Forms\Components\FileUpload::make('images')
                                    ->label('صور إضافية')
                                    ->image()
                                    ->multiple()
                                    ->directory('products')
                                    ->columnSpanFull(),
                            ]),
                    ])->columnSpan(['lg' => 2]),

                Forms\Components\Group::make()
                    ->schema([
                        Forms\Components\Section::make('الحالة')
                            ->schema([
                                Forms\Components\Toggle::make('is_active')
                                    ->label('نشط')
                                    ->default(true),
                                Forms\Components\Toggle::make('is_featured')
                                    ->label('مميز')
                                    ->default(false),
                            ]),

                        Forms\Components\Section::make('معلومات إضافية')
                            ->schema([
                                Forms\Components\TextInput::make('brand')
                                    ->label('العلامة التجارية'),
                                Forms\Components\TextInput::make('weight')
                                    ->label('الوزن')
                                    ->numeric()
                                    ->suffix('كجم'),
                                Forms\Components\TextInput::make('barcode')
                                    ->label('الباركود'),
                            ]),

                        Forms\Components\Section::make('التقييم')
                            ->schema([
                                Forms\Components\TextInput::make('rating')
                                    ->label('التقييم')
                                    ->numeric()
                                    ->minValue(0)
                                    ->maxValue(5)
                                    ->step(0.1)
                                    ->default(0),
                                Forms\Components\TextInput::make('reviews_count')
                                    ->label('عدد التقييمات')
                                    ->numeric()
                                    ->default(0)
                                    ->disabled(),
                                Forms\Components\TextInput::make('sales_count')
                                    ->label('عدد المبيعات')
                                    ->numeric()
                                    ->default(0)
                                    ->disabled(),
                            ]),

                        Forms\Components\Section::make('المواصفات')
                            ->schema([
                                Forms\Components\KeyValue::make('specifications')
                                    ->label('')
                                    ->keyLabel('الخاصية')
                                    ->valueLabel('القيمة')
                                    ->addActionLabel('إضافة مواصفة'),
                            ]),
                    ])->columnSpan(['lg' => 1]),
            ])->columns(3);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('الصورة')
                    ->square()
                    ->size(50),
                Tables\Columns\TextColumn::make('name_ar')
                    ->label('المنتج')
                    ->searchable(['name', 'name_ar'])
                    ->sortable()
                    ->description(fn ($record) => $record->sku),
                Tables\Columns\TextColumn::make('category.name_ar')
                    ->label('الفئة')
                    ->badge()
                    ->sortable(),
                Tables\Columns\TextColumn::make('price')
                    ->label('السعر')
                    ->money('SAR')
                    ->sortable(),
                Tables\Columns\TextColumn::make('sale_price')
                    ->label('التخفيض')
                    ->money('SAR')
                    ->color('danger')
                    ->placeholder('-'),
                Tables\Columns\TextColumn::make('quantity')
                    ->label('المخزون')
                    ->sortable()
                    ->color(fn ($record) => match(true) {
                        $record->quantity <= 0 => 'danger',
                        $record->quantity <= ($record->low_stock_threshold ?? 10) => 'warning',
                        default => 'success',
                    })
                    ->badge(),
                Tables\Columns\TextColumn::make('sales_count')
                    ->label('المبيعات')
                    ->sortable()
                    ->default(0),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean(),
                Tables\Columns\IconColumn::make('is_featured')
                    ->label('مميز')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category_id')
                    ->label('الفئة')
                    ->relationship('category', 'name_ar'),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('نشط'),
                Tables\Filters\TernaryFilter::make('is_featured')
                    ->label('مميز'),
                Tables\Filters\Filter::make('low_stock')
                    ->label('مخزون منخفض')
                    ->query(fn (Builder $query) => $query->whereColumn('quantity', '<=', 'low_stock_threshold')),
                Tables\Filters\Filter::make('out_of_stock')
                    ->label('نفذ من المخزون')
                    ->query(fn (Builder $query) => $query->where('quantity', '<=', 0)),
            ])
            ->actions([
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make(),
                    Tables\Actions\EditAction::make(),
                    Tables\Actions\Action::make('update_stock')
                        ->label('تحديث المخزون')
                        ->icon('heroicon-o-archive-box')
                        ->color('warning')
                        ->form([
                            Forms\Components\TextInput::make('quantity')
                                ->label('الكمية الجديدة')
                                ->numeric()
                                ->required(),
                        ])
                        ->action(fn ($record, array $data) => $record->update(['quantity' => $data['quantity']])),
                    Tables\Actions\DeleteAction::make(),
                ]),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('activate')
                        ->label('تفعيل')
                        ->icon('heroicon-o-check')
                        ->action(fn ($records) => $records->each->update(['is_active' => true])),
                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('إلغاء التفعيل')
                        ->icon('heroicon-o-x-mark')
                        ->action(fn ($records) => $records->each->update(['is_active' => false])),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\OrdersRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListProducts::route('/'),
            'create' => Pages\CreateProduct::route('/create'),
            'view' => Pages\ViewProduct::route('/{record}'),
            'edit' => Pages\EditProduct::route('/{record}/edit'),
        ];
    }
}
