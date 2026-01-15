<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        $admins = [
            [
                'name' => 'مدير النظام',
                'email' => 'admin@vitafit.online',
                'password' => Hash::make('Admin@123456'),
                'role' => 'super_admin',
                'is_active' => true,
            ],
            [
                'name' => 'مدير العمليات',
                'email' => 'operations@vitafit.online',
                'password' => Hash::make('Operations@123'),
                'role' => 'admin',
                'is_active' => true,
            ],
        ];

        foreach ($admins as $admin) {
            User::create($admin);
        }
    }
}
