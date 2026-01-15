<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ProductResource\Pages;
use App\Models\Product;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class ProductResource extends Resource
{
    protected static ?string $model = Product::class;

    protected static ?string $navigationIcon = 'heroicon-o-shopping-bag';

    protected static ?string $navigationGroup = 'المتجر';

    protected static ?string $navigationLabel = 'المنتجات';

    protected static ?string $modelLabel = 'منتج';

    protected static ?string $pluralModelLabel = 'المنتجات';

    protected static ?int $navigationSort = 4;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات المنتج')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('اسم المنتج')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\Textarea::make('description')
                            ->label('الوصف')
                            ->rows(3),
                        Forms\Components\Select::make('category')
                            ->label('الفئة')
                            ->options([
                                'supplements' => 'مكملات غذائية',
                                'equipment' => 'معدات رياضية',
                                'clothing' => 'ملابس رياضية',
                                'accessories' => 'إكسسوارات',
                                'nutrition' => 'أغذية صحية',
                            ])
                            ->required(),
                        Forms\Components\TextInput::make('sku')
                            ->label('رمز المنتج')
                            ->unique(ignoreRecord: true),
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
                            ->prefix('ر.س'),
                        Forms\Components\TextInput::make('stock')
                            ->label('المخزون')
                            ->numeric()
                            ->default(0),
                    ])->columns(3),

                Forms\Components\Section::make('الصور')
                    ->schema([
                        Forms\Components\FileUpload::make('image')
                            ->label('الصورة الرئيسية')
                            ->image()
                            ->directory('products'),
                        Forms\Components\FileUpload::make('images')
                            ->label('صور إضافية')
                            ->image()
                            ->multiple()
                            ->directory('products'),
                    ])->columns(2),

                Forms\Components\Section::make('الإعدادات')
                    ->schema([
                        Forms\Components\Toggle::make('is_active')
                            ->label('نشط')
                            ->default(true),
                        Forms\Components\Toggle::make('is_featured')
                            ->label('مميز')
                            ->default(false),
                        Forms\Components\KeyValue::make('specifications')
                            ->label('المواصفات')
                            ->keyLabel('الخاصية')
                            ->valueLabel('القيمة'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('الصورة')
                    ->square(),
                Tables\Columns\TextColumn::make('name')
                    ->label('المنتج')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('category')
                    ->label('الفئة')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'supplements' => 'مكملات',
                        'equipment' => 'معدات',
                        'clothing' => 'ملابس',
                        'accessories' => 'إكسسوارات',
                        'nutrition' => 'أغذية',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('price')
                    ->label('السعر')
                    ->money('SAR')
                    ->sortable(),
                Tables\Columns\TextColumn::make('sale_price')
                    ->label('التخفيض')
                    ->money('SAR'),
                Tables\Columns\TextColumn::make('stock')
                    ->label('المخزون')
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean(),
                Tables\Columns\IconColumn::make('is_featured')
                    ->label('مميز')
                    ->boolean(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category')
                    ->label('الفئة')
                    ->options([
                        'supplements' => 'مكملات غذائية',
                        'equipment' => 'معدات رياضية',
                        'clothing' => 'ملابس رياضية',
                        'accessories' => 'إكسسوارات',
                        'nutrition' => 'أغذية صحية',
                    ]),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('نشط'),
                Tables\Filters\TernaryFilter::make('is_featured')
                    ->label('مميز'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListProducts::route('/'),
            'create' => Pages\CreateProduct::route('/create'),
            'edit' => Pages\EditProduct::route('/{record}/edit'),
        ];
    }
}
