<?php

namespace Database\Seeders;

use App\Models\Trainer;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class TrainerSeeder extends Seeder
{
    public function run(): void
    {
        $trainers = [
            [
                'name' => 'سارة أحمد',
                'email' => 'sara@vitafit.online',
                'password' => Hash::make('123456'),
                'phone' => '+966501234567',
                'specialization' => 'تدريب وظيفي',
                'bio' => 'مدربة معتمدة متخصصة في التدريب الوظيفي وبناء العضلات. حاصلة على شهادة ACE وخبرة 5 سنوات في مجال اللياقة البدنية.',
                'experience_years' => 5,
                'certifications' => ['ACE', 'NASM', 'CPR'],
                'hourly_rate' => 150.00,
                'training_type' => 'both',
                'max_trainees' => 20,
                'rating' => 4.9,
                'total_reviews' => 127,
                'status' => 'active',
                'available_hours' => [
                    ['day' => 0, 'start' => '08:00', 'end' => '12:00'],
                    ['day' => 0, 'start' => '16:00', 'end' => '20:00'],
                    ['day' => 1, 'start' => '08:00', 'end' => '12:00'],
                    ['day' => 1, 'start' => '16:00', 'end' => '20:00'],
                    ['day' => 2, 'start' => '08:00', 'end' => '12:00'],
                    ['day' => 3, 'start' => '08:00', 'end' => '12:00'],
                    ['day' => 3, 'start' => '16:00', 'end' => '20:00'],
                    ['day' => 4, 'start' => '08:00', 'end' => '12:00'],
                ],
            ],
            [
                'name' => 'نورة محمد',
                'email' => 'noura@vitafit.online',
                'password' => Hash::make('123456'),
                'phone' => '+966502345678',
                'specialization' => 'يوغا وبيلاتس',
                'bio' => 'مدربة يوغا معتمدة من RYT-500. متخصصة في اليوغا العلاجية والتأمل. أساعدك على تحقيق التوازن بين الجسم والعقل.',
                'experience_years' => 7,
                'certifications' => ['RYT-500', 'Pilates Certified'],
                'hourly_rate' => 120.00,
                'training_type' => 'online',
                'max_trainees' => 15,
                'rating' => 4.8,
                'total_reviews' => 98,
                'status' => 'active',
                'available_hours' => [
                    ['day' => 0, 'start' => '06:00', 'end' => '10:00'],
                    ['day' => 1, 'start' => '06:00', 'end' => '10:00'],
                    ['day' => 2, 'start' => '06:00', 'end' => '10:00'],
                    ['day' => 3, 'start' => '06:00', 'end' => '10:00'],
                    ['day' => 4, 'start' => '06:00', 'end' => '10:00'],
                ],
            ],
            [
                'name' => 'ريم خالد',
                'email' => 'reem@vitafit.online',
                'password' => Hash::make('123456'),
                'phone' => '+966503456789',
                'specialization' => 'كارديو وحرق الدهون',
                'bio' => 'متخصصة في تمارين الكارديو عالية الكثافة HIIT وبرامج حرق الدهون. سأساعدك على تحقيق أهدافك في إنقاص الوزن.',
                'experience_years' => 4,
                'certifications' => ['HIIT Certified', 'Nutrition Coach'],
                'hourly_rate' => 130.00,
                'training_type' => 'both',
                'max_trainees' => 25,
                'rating' => 4.7,
                'total_reviews' => 76,
                'status' => 'active',
                'available_hours' => [
                    ['day' => 0, 'start' => '17:00', 'end' => '21:00'],
                    ['day' => 1, 'start' => '17:00', 'end' => '21:00'],
                    ['day' => 2, 'start' => '17:00', 'end' => '21:00'],
                    ['day' => 3, 'start' => '17:00', 'end' => '21:00'],
                    ['day' => 4, 'start' => '17:00', 'end' => '21:00'],
                    ['day' => 5, 'start' => '10:00', 'end' => '14:00'],
                ],
            ],
            [
                'name' => 'منى العتيبي',
                'email' => 'mona@vitafit.online',
                'password' => Hash::make('123456'),
                'phone' => '+966504567890',
                'specialization' => 'تدريب القوة',
                'bio' => 'مدربة قوة محترفة ومتخصصة في بناء العضلات للنساء. أؤمن بأن القوة جمال وثقة.',
                'experience_years' => 6,
                'certifications' => ['CSCS', 'Strength Coach'],
                'hourly_rate' => 160.00,
                'training_type' => 'in_person',
                'max_trainees' => 15,
                'rating' => 4.9,
                'total_reviews' => 112,
                'status' => 'active',
                'available_hours' => [
                    ['day' => 0, 'start' => '14:00', 'end' => '20:00'],
                    ['day' => 1, 'start' => '14:00', 'end' => '20:00'],
                    ['day' => 2, 'start' => '14:00', 'end' => '20:00'],
                    ['day' => 3, 'start' => '14:00', 'end' => '20:00'],
                ],
            ],
            [
                'name' => 'هند السعيد',
                'email' => 'hind@vitafit.online',
                'password' => Hash::make('123456'),
                'phone' => '+966505678901',
                'specialization' => 'تغذية ولياقة',
                'bio' => 'أخصائية تغذية ومدربة لياقة. أقدم برامج متكاملة تجمع بين التمارين والتغذية السليمة لنتائج مذهلة.',
                'experience_years' => 8,
                'certifications' => ['Registered Dietitian', 'Personal Trainer'],
                'hourly_rate' => 180.00,
                'training_type' => 'online',
                'max_trainees' => 30,
                'rating' => 4.8,
                'total_reviews' => 156,
                'status' => 'active',
                'available_hours' => [
                    ['day' => 0, 'start' => '09:00', 'end' => '13:00'],
                    ['day' => 0, 'start' => '18:00', 'end' => '22:00'],
                    ['day' => 1, 'start' => '09:00', 'end' => '13:00'],
                    ['day' => 2, 'start' => '09:00', 'end' => '13:00'],
                    ['day' => 2, 'start' => '18:00', 'end' => '22:00'],
                    ['day' => 3, 'start' => '09:00', 'end' => '13:00'],
                    ['day' => 4, 'start' => '09:00', 'end' => '13:00'],
                ],
            ],
        ];

        foreach ($trainers as $trainer) {
            Trainer::create($trainer);
        }
    }
}
