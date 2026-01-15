<?php

namespace App\Filament\Resources\TraineeResource\Pages;

use App\Filament\Resources\TraineeResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListTrainees extends ListRecords
{
    protected static string $resource = TraineeResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
