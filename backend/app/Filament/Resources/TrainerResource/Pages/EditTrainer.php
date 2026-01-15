<?php

namespace App\Filament\Resources\TrainerResource\Pages;

use App\Filament\Resources\TrainerResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Hash;

class EditTrainer extends EditRecord
{
    protected static string $resource = TrainerResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make()
                ->label('حذف'),
        ];
    }

    protected function mutateFormDataBeforeFill(array $data): array
    {
        // Load user data into the form
        $data['user'] = $this->record->user?->toArray() ?? [];
        return $data;
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Extract and update user data
        $userData = $data['user'] ?? [];
        unset($data['user']);

        if ($this->record->user) {
            $updateData = [
                'name' => $userData['name'],
                'email' => $userData['email'],
                'phone' => $userData['phone'] ?? null,
                'avatar' => $userData['avatar'] ?? null,
            ];

            // Only update password if provided
            if (!empty($userData['password'])) {
                $updateData['password'] = Hash::make($userData['password']);
            }

            $this->record->user->update($updateData);
        }

        return $data;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function getSavedNotificationTitle(): ?string
    {
        return 'تم تحديث بيانات المدربة';
    }
}
