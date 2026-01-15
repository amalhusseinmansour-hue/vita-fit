<?php

namespace App\Filament\Resources\OrderResource\RelationManagers;

use App\Models\Product;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class ItemsRelationManager extends RelationManager
{
    protected static string $relationship = 'items';
    protected static ?string $title = 'منتجات الطلب';
    protected static ?string $modelLabel = 'منتج';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('product_id')
                    ->label('المنتج')
                    ->options(Product::where('is_active', true)->pluck('name_ar', 'id'))
                    ->searchable()
                    ->required()
                    ->reactive()
                    ->afterStateUpdated(function ($state, callable $set) {
                        if ($state) {
                            $product = Product::find($state);
                            if ($product) {
                                $set('product_name', $product->name_ar ?? $product->name);
                                $set('product_sku', $product->sku);
                                $set('price', $product->sale_price ?? $product->price);
                            }
                        }
                    }),
                Forms\Components\TextInput::make('product_name')
                    ->label('اسم المنتج')
                    ->disabled(),
                Forms\Components\TextInput::make('product_sku')
                    ->label('SKU')
                    ->disabled(),
                Forms\Components\TextInput::make('quantity')
                    ->label('الكمية')
                    ->numeric()
                    ->default(1)
                    ->required()
                    ->reactive()
                    ->afterStateUpdated(fn ($state, callable $get, callable $set) =>
                        $set('total', $state * $get('price'))),
                Forms\Components\TextInput::make('price')
                    ->label('السعر')
                    ->numeric()
                    ->prefix('ر.س')
                    ->required()
                    ->reactive()
                    ->afterStateUpdated(fn ($state, callable $get, callable $set) =>
                        $set('total', $state * $get('quantity'))),
                Forms\Components\TextInput::make('total')
                    ->label('الإجمالي')
                    ->numeric()
                    ->prefix('ر.س')
                    ->disabled(),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('product_name')
            ->columns([
                Tables\Columns\ImageColumn::make('product.image')
                    ->label('الصورة')
                    ->square()
                    ->size(40),
                Tables\Columns\TextColumn::make('product_name')
                    ->label('المنتج')
                    ->searchable()
                    ->description(fn ($record) => $record->product_sku),
                Tables\Columns\TextColumn::make('quantity')
                    ->label('الكمية')
                    ->alignCenter(),
                Tables\Columns\TextColumn::make('price')
                    ->label('السعر')
                    ->money('SAR'),
                Tables\Columns\TextColumn::make('total')
                    ->label('الإجمالي')
                    ->money('SAR')
                    ->weight('bold'),
            ])
            ->filters([])
            ->headerActions([
                Tables\Actions\CreateAction::make()
                    ->mutateFormDataUsing(function (array $data): array {
                        $data['total'] = $data['quantity'] * $data['price'];
                        return $data;
                    }),
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
}
