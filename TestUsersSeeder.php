<?php

namespace Database\Seeders;

use App\Models\Trainer;
use App\Models\Trainee;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class TestUsersSeeder extends Seeder
{
    public function run(): void
    {
        // Create Trainer
        Trainer::updateOrCreate(
            ['email' => 'trainer@vitafit.online'],
            [
                'name' => 'سارة المدربة',
                'phone' => '0501234567',
                'password' => Hash::make('Trainer@2024'),
                'specialization' => 'تدريب لياقة بدنية',
                'bio' => 'مدربة معتمدة بخبرة 5 سنوات',
                'experience_years' => 5,
                'status' => 'active',
                'training_type' => 'all',
                'max_trainees' => 20,
            ]
        );

        // Create Trainee
        Trainee::updateOrCreate(
            ['email' => 'user@vitafit.online'],
            [
                'name' => 'نورة المتدربة',
                'phone' => '0509876543',
                'password' => Hash::make('User@2024'),
                'activity_level' => 'moderate',
                'status' => 'active',
            ]
        );

        echo "Test users created successfully!\n";
    }
}
