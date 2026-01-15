<?php

namespace Database\Seeders;

use App\Models\SubscriptionPlan;
use Illuminate\Database\Seeder;

class SubscriptionPlanSeeder extends Seeder
{
    public function run(): void
    {
        $plans = [
            [
                'name' => 'الباقة الأساسية',
                'name_en' => 'Basic Plan',
                'description' => 'باقة مثالية للمبتدئين. تشمل برنامج تدريبي أساسي مع متابعة أسبوعية.',
                'description_en' => 'Perfect for beginners. Includes basic training program with weekly follow-up.',
                'type' => 'training',
                'duration_days' => 30,
                'sessions_count' => 8,
                'price' => 299.00,
                'original_price' => null,
                'is_active' => true,
                'is_popular' => false,
                'sort_order' => 1,
                'features' => [
                    '8 جلسات تدريبية شهريًا',
                    'برنامج تدريبي مخصص',
                    'متابعة أسبوعية',
                    'دعم عبر الدردشة',
                ],
            ],
            [
                'name' => 'الباقة المتقدمة',
                'name_en' => 'Advanced Plan',
                'description' => 'باقة شاملة تجمع بين التدريب والتغذية. الأكثر شعبية بين المتدربات.',
                'description_en' => 'Comprehensive plan combining training and nutrition. Most popular among trainees.',
                'type' => 'full',
                'duration_days' => 30,
                'sessions_count' => 12,
                'price' => 499.00,
                'original_price' => 599.00,
                'is_active' => true,
                'is_popular' => true,
                'sort_order' => 2,
                'features' => [
                    '12 جلسة تدريبية شهريًا',
                    'برنامج تدريبي مخصص',
                    'خطة غذائية شاملة',
                    'متابعة يومية',
                    'دعم عبر الدردشة 24/7',
                    'تقارير تقدم أسبوعية',
                ],
            ],
            [
                'name' => 'الباقة الاحترافية',
                'name_en' => 'Professional Plan',
                'description' => 'باقة VIP للجادين في تحقيق أهدافهم. تدريب خاص ومتابعة مكثفة.',
                'description_en' => 'VIP package for those serious about achieving their goals. Private training and intensive follow-up.',
                'type' => 'private',
                'duration_days' => 30,
                'sessions_count' => 20,
                'price' => 899.00,
                'original_price' => 999.00,
                'is_active' => true,
                'is_popular' => false,
                'sort_order' => 3,
                'features' => [
                    '20 جلسة تدريبية شهريًا',
                    'تدريب خاص 1-على-1',
                    'برنامج تدريبي وغذائي مخصص',
                    'متابعة يومية مكثفة',
                    'مكالمات فيديو أسبوعية',
                    'دعم أولوية 24/7',
                    'تحليل تقدم متقدم',
                    'وصول لمحتوى حصري',
                ],
            ],
            [
                'name' => 'باقة 3 أشهر',
                'name_en' => '3 Months Plan',
                'description' => 'وفر 20% مع باقة الثلاثة أشهر. برنامج شامل لتحول حقيقي.',
                'description_en' => 'Save 20% with the 3-month package. Comprehensive program for real transformation.',
                'type' => 'full',
                'duration_days' => 90,
                'sessions_count' => 36,
                'price' => 1199.00,
                'original_price' => 1497.00,
                'is_active' => true,
                'is_popular' => false,
                'sort_order' => 4,
                'features' => [
                    '36 جلسة تدريبية (12 شهريًا)',
                    'برنامج تدريبي وغذائي شامل',
                    'متابعة يومية',
                    'تقارير تقدم شهرية',
                    'دعم عبر الدردشة 24/7',
                    'خصم 20%',
                ],
            ],
            [
                'name' => 'باقة التغذية',
                'name_en' => 'Nutrition Plan',
                'description' => 'باقة متخصصة في التغذية فقط. مثالية لمن لديهم برنامج تدريبي خاص.',
                'description_en' => 'Nutrition-only package. Perfect for those with their own training program.',
                'type' => 'nutrition',
                'duration_days' => 30,
                'sessions_count' => 4,
                'price' => 199.00,
                'original_price' => null,
                'is_active' => true,
                'is_popular' => false,
                'sort_order' => 5,
                'features' => [
                    'خطة غذائية مخصصة',
                    '4 استشارات تغذية شهريًا',
                    'قوائم مشتريات أسبوعية',
                    'وصفات صحية',
                    'متابعة عبر الدردشة',
                ],
            ],
        ];

        foreach ($plans as $plan) {
            SubscriptionPlan::create($plan);
        }
    }
}
