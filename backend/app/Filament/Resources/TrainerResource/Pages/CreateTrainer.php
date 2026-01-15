<?php

namespace App\Filament\Resources\TrainerResource\Pages;

use App\Filament\Resources\TrainerResource;
use App\Models\User;
use App\Models\Trainer;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\Hash;

class CreateTrainer extends CreateRecord
{
    protected static string $resource = TrainerResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Extract user data
        $userData = $data['user'] ?? [];
        unset($data['user']);

        // Create user first
        $user = User::create([
            'name' => $userData['name'],
            'email' => $userData['email'],
            'phone' => $userData['phone'] ?? null,
            'password' => Hash::make($userData['password']),
            'avatar' => $userData['avatar'] ?? null,
            'role' => 'trainer',
            'is_verified' => true,
        ]);

        // Set user_id for trainer
        $data['user_id'] = $user->id;

        return $data;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function getCreatedNotificationTitle(): ?string
    {
        return 'تم إضافة المدربة بنجاح';
    }
}
