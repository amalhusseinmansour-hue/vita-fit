<?php

namespace Database\Seeders;

use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $products = [
            // Supplements - مكملات غذائية
            [
                'name' => 'واي بروتين جولد ستاندرد',
                'description' => 'بروتين مصل اللبن عالي الجودة لبناء العضلات. 24 جرام بروتين لكل حصة. النكهة: شوكولاتة.',
                'category' => 'supplements',
                'price' => 299.00,
                'sale_price' => 249.00,
                'stock' => 50,
                'sku' => 'SUP-WP-001',
                'is_active' => true,
                'is_featured' => true,
                'specifications' => [
                    'الوزن' => '2.27 كجم',
                    'الحصص' => '74 حصة',
                    'البروتين لكل حصة' => '24 جرام',
                    'النكهة' => 'شوكولاتة'
                ],
            ],
            [
                'name' => 'كرياتين مونوهيدرات',
                'description' => 'كرياتين نقي 100% لزيادة القوة والأداء الرياضي. بدون نكهة.',
                'category' => 'supplements',
                'price' => 89.00,
                'sale_price' => null,
                'stock' => 100,
                'sku' => 'SUP-CR-001',
                'is_active' => true,
                'is_featured' => false,
                'specifications' => [
                    'الوزن' => '500 جرام',
                    'الحصص' => '100 حصة',
                    'النوع' => 'مونوهيدرات'
                ],
            ],
            [
                'name' => 'BCAA أحماض أمينية',
                'description' => 'أحماض أمينية متشعبة السلسلة لتسريع الاستشفاء العضلي ومنع الهدم.',
                'category' => 'supplements',
                'price' => 149.00,
                'sale_price' => 129.00,
                'stock' => 75,
                'sku' => 'SUP-BC-001',
                'is_active' => true,
                'is_featured' => true,
                'specifications' => [
                    'الوزن' => '400 جرام',
                    'الحصص' => '40 حصة',
                    'النسبة' => '2:1:1',
                    'النكهة' => 'توت أزرق'
                ],
            ],

            // Equipment - معدات رياضية
            [
                'name' => 'دمبل قابل للتعديل 24 كجم',
                'description' => 'دمبل ذكي قابل للتعديل من 2.5 إلى 24 كجم. مثالي للتمرين المنزلي.',
                'category' => 'equipment',
                'price' => 899.00,
                'sale_price' => 799.00,
                'stock' => 20,
                'sku' => 'EQP-DB-001',
                'is_active' => true,
                'is_featured' => true,
                'specifications' => [
                    'الوزن الأقصى' => '24 كجم',
                    'الوزن الأدنى' => '2.5 كجم',
                    'المادة' => 'حديد مطلي',
                    'عدد الأوزان' => '15 مستوى'
                ],
            ],
            [
                'name' => 'حبل مقاومة مجموعة 5 قطع',
                'description' => 'مجموعة أحبال مقاومة بمستويات متعددة للتمرين الشامل.',
                'category' => 'equipment',
                'price' => 149.00,
                'sale_price' => null,
                'stock' => 45,
                'sku' => 'EQP-RB-001',
                'is_active' => true,
                'is_featured' => false,
                'specifications' => [
                    'عدد القطع' => '5',
                    'المقاومة' => '5-50 رطل',
                    'يشمل' => 'مقابض + حزام قدم + حقيبة'
                ],
            ],
            [
                'name' => 'سجادة يوغا احترافية',
                'description' => 'سجادة يوغا مضادة للانزلاق بسمك 6 مم. مثالية لليوغا والبيلاتس.',
                'category' => 'equipment',
                'price' => 129.00,
                'sale_price' => 99.00,
                'stock' => 60,
                'sku' => 'EQP-YM-001',
                'is_active' => true,
                'is_featured' => false,
                'specifications' => [
                    'السمك' => '6 مم',
                    'الأبعاد' => '183 × 61 سم',
                    'المادة' => 'TPE صديق للبيئة',
                    'اللون' => 'بنفسجي'
                ],
            ],

            // Clothes - ملابس رياضية
            [
                'name' => 'تيشيرت تدريب نسائي',
                'description' => 'تيشيرت رياضي نسائي خفيف الوزن مع تقنية امتصاص العرق.',
                'category' => 'clothes',
                'price' => 89.00,
                'sale_price' => null,
                'stock' => 100,
                'sku' => 'CLO-TS-001',
                'is_active' => true,
                'is_featured' => false,
                'specifications' => [
                    'المادة' => 'بوليستر 92% + سباندكس 8%',
                    'المقاسات' => 'S, M, L, XL',
                    'الألوان' => 'أسود، رمادي، وردي'
                ],
            ],
            [
                'name' => 'ليقنز رياضي ضاغط',
                'description' => 'ليقنز رياضي عالي الخصر مع جيب للهاتف. مثالي للتمارين عالية الكثافة.',
                'category' => 'clothes',
                'price' => 149.00,
                'sale_price' => 119.00,
                'stock' => 80,
                'sku' => 'CLO-LG-001',
                'is_active' => true,
                'is_featured' => true,
                'specifications' => [
                    'المادة' => 'نايلون 80% + سباندكس 20%',
                    'المقاسات' => 'S, M, L, XL',
                    'الميزات' => 'جيب جانبي، خصر عالي'
                ],
            ],
            [
                'name' => 'حذاء تدريب نسائي',
                'description' => 'حذاء رياضي متعدد الاستخدامات للتدريب والجري. وسادة هوائية للراحة.',
                'category' => 'clothes',
                'price' => 399.00,
                'sale_price' => 349.00,
                'stock' => 40,
                'sku' => 'CLO-SH-001',
                'is_active' => true,
                'is_featured' => true,
                'specifications' => [
                    'المقاسات' => '36-41',
                    'النعل' => 'مطاط مقاوم للانزلاق',
                    'الوسادة' => 'Air Max'
                ],
            ],

            // Accessories - إكسسوارات
            [
                'name' => 'ساعة ذكية للياقة',
                'description' => 'ساعة ذكية لتتبع النشاط البدني ومعدل نبض القلب والنوم.',
                'category' => 'accessories',
                'price' => 599.00,
                'sale_price' => 499.00,
                'stock' => 30,
                'sku' => 'ACC-SW-001',
                'is_active' => true,
                'is_featured' => true,
                'specifications' => [
                    'الشاشة' => 'AMOLED 1.4 بوصة',
                    'البطارية' => '7 أيام',
                    'مقاومة الماء' => '5 ATM',
                    'الميزات' => 'GPS، نبض القلب، SpO2'
                ],
            ],
            [
                'name' => 'قفازات تدريب',
                'description' => 'قفازات رفع أثقال مع دعم للمعصم. حماية كاملة لليدين.',
                'category' => 'accessories',
                'price' => 79.00,
                'sale_price' => null,
                'stock' => 70,
                'sku' => 'ACC-GL-001',
                'is_active' => true,
                'is_featured' => false,
                'specifications' => [
                    'المادة' => 'جلد صناعي + نيوبرين',
                    'المقاسات' => 'S, M, L, XL',
                    'الميزات' => 'دعم معصم، تهوية'
                ],
            ],
            [
                'name' => 'زجاجة مياه ستانلس ستيل',
                'description' => 'زجاجة مياه معزولة حراريًا تحافظ على برودة المياه 24 ساعة.',
                'category' => 'accessories',
                'price' => 69.00,
                'sale_price' => null,
                'stock' => 120,
                'sku' => 'ACC-BT-001',
                'is_active' => true,
                'is_featured' => false,
                'specifications' => [
                    'السعة' => '750 مل',
                    'المادة' => 'ستانلس ستيل 304',
                    'العزل' => '24 ساعة بارد، 12 ساعة ساخن'
                ],
            ],
        ];

        foreach ($products as $product) {
            Product::create($product);
        }
    }
}
