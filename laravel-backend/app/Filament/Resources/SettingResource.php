<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SettingResource\Pages;
use App\Models\Setting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SettingResource extends Resource
{
    protected static ?string $model = Setting::class;

    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static ?string $navigationGroup = 'النظام';

    protected static ?string $navigationLabel = 'الإعدادات';

    protected static ?string $modelLabel = 'إعداد';

    protected static ?string $pluralModelLabel = 'الإعدادات';

    protected static ?int $navigationSort = 100;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الإعداد')
                    ->schema([
                        Forms\Components\Select::make('group')
                            ->label('المجموعة')
                            ->options([
                                'general' => 'عام',
                                'app' => 'التطبيق',
                                'payment' => 'الدفع',
                                'notifications' => 'الإشعارات',
                                'zoom' => 'Zoom',
                                'social' => 'وسائل التواصل',
                            ])
                            ->default('general')
                            ->required(),
                        Forms\Components\TextInput::make('key')
                            ->label('المفتاح')
                            ->required()
                            ->unique(ignoreRecord: true),
                        Forms\Components\Select::make('type')
                            ->label('النوع')
                            ->options([
                                'string' => 'نص',
                                'boolean' => 'منطقي',
                                'integer' => 'رقم',
                                'json' => 'JSON',
                            ])
                            ->default('string')
                            ->reactive(),
                        Forms\Components\Textarea::make('value')
                            ->label('القيمة')
                            ->rows(3),
                        Forms\Components\Textarea::make('description')
                            ->label('الوصف')
                            ->rows(2),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('group')
                    ->label('المجموعة')
                    ->badge()
                    ->sortable(),
                Tables\Columns\TextColumn::make('key')
                    ->label('المفتاح')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('value')
                    ->label('القيمة')
                    ->limit(50),
                Tables\Columns\TextColumn::make('type')
                    ->label('النوع')
                    ->badge(),
                Tables\Columns\TextColumn::make('updated_at')
                    ->label('آخر تحديث')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('group')
                    ->label('المجموعة')
                    ->options([
                        'general' => 'عام',
                        'app' => 'التطبيق',
                        'payment' => 'الدفع',
                        'notifications' => 'الإشعارات',
                        'zoom' => 'Zoom',
                        'social' => 'وسائل التواصل',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
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
            'index' => Pages\ListSettings::route('/'),
            'create' => Pages\CreateSetting::route('/create'),
            'edit' => Pages\EditSetting::route('/{record}/edit'),
        ];
    }
}
