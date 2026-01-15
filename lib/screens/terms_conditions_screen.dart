import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'الشروط والأحكام',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: AppTheme.fontXl,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppTheme.lg),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.md),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: AppTheme.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الشروط والأحكام',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: AppTheme.fontLg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'آخر تحديث: ديسمبر 2024',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: AppTheme.fontSm,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),

              const SizedBox(height: AppTheme.xl),

              _buildSection(
                title: 'القبول بالشروط',
                content: '''
مرحباً بك في تطبيق VitaFit. باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام.

إذا كنت لا توافق على أي من هذه الشروط، يرجى عدم استخدام التطبيق.

يجب أن يكون عمرك 18 عاماً على الأقل لاستخدام هذا التطبيق، أو أن تحصل على موافقة ولي الأمر.
''',
                delay: 100,
              ),

              _buildSection(
                title: 'وصف الخدمة',
                content: '''
VitaFit هو تطبيق لياقة بدنية يقدم:

• برامج تمارين رياضية متنوعة
• خطط غذائية مخصصة
• متابعة شخصية مع مدربات معتمدات
• جلسات تدريب أونلاين
• متجر منتجات رياضية ومكملات غذائية
• تتبع التقدم والإحصائيات

قد نقوم بتعديل أو إضافة خدمات جديدة في أي وقت.
''',
                delay: 200,
              ),

              _buildSection(
                title: 'التسجيل والحساب',
                content: '''
لاستخدام خدماتنا، يجب عليك:

• تقديم معلومات صحيحة ودقيقة عند التسجيل
• الحفاظ على سرية بيانات حسابك
• إخطارنا فوراً بأي استخدام غير مصرح به
• تحديث معلوماتك عند تغييرها

أنت مسؤول عن جميع الأنشطة التي تحدث تحت حسابك.

نحتفظ بالحق في تعليق أو إنهاء حسابك في حالة انتهاك هذه الشروط.
''',
                delay: 300,
              ),

              _buildSection(
                title: 'الاشتراكات والدفع',
                content: '''
1. أنواع الاشتراكات:
   • نقدم خطط اشتراك متنوعة (شهرية، ربع سنوية، سنوية)
   • تختلف المميزات حسب نوع الاشتراك

2. الدفع:
   • يتم الدفع مقدماً
   • نقبل البطاقات الائتمانية والدفع عند الاستلام للمنتجات
   • الأسعار بالريال السعودي شاملة الضريبة

3. التجديد التلقائي:
   • يتم تجديد الاشتراكات تلقائياً ما لم يتم إلغاؤها
   • يجب إلغاء التجديد قبل 24 ساعة من تاريخ التجديد

4. سياسة الاسترداد:
   • يمكن طلب استرداد خلال 7 أيام من الاشتراك
   • لا يشمل الاسترداد الخدمات المستخدمة
''',
                delay: 400,
              ),

              _buildSection(
                title: 'قواعد الاستخدام',
                content: '''
يجب عليك الالتزام بما يلي:

الممنوعات:
• استخدام التطبيق لأغراض غير قانونية
• مشاركة حسابك مع آخرين
• نسخ أو توزيع محتوى التطبيق
• محاولة اختراق أو إتلاف أنظمتنا
• التحرش أو الإساءة للمستخدمين الآخرين أو المدربات
• نشر محتوى مسيء أو غير لائق
• استخدام برامج آلية للوصول للتطبيق

المسموحات:
• استخدام التطبيق للأغراض الشخصية
• مشاركة تقدمك على وسائل التواصل الاجتماعي
• التواصل المحترم مع المدربات والدعم
''',
                delay: 500,
              ),

              _buildSection(
                title: 'المحتوى والملكية الفكرية',
                content: '''
جميع المحتويات في التطبيق محمية بحقوق الملكية الفكرية:

• التمارين والفيديوهات
• الخطط الغذائية والوصفات
• التصاميم والشعارات
• النصوص والصور

يُمنع:
• نسخ أو استنساخ أي محتوى
• استخدام المحتوى لأغراض تجارية
• إزالة علامات حقوق النشر

المحتوى الذي تنشئه (مثل الصور والتقييمات) يبقى ملكك، لكنك تمنحنا ترخيصاً لاستخدامه في التطبيق.
''',
                delay: 600,
              ),

              _buildSection(
                title: 'إخلاء المسؤولية الصحية',
                content: '''
تنبيه مهم:

• المحتوى في التطبيق للأغراض التعليمية فقط
• لا يُعد بديلاً عن الاستشارة الطبية المتخصصة
• استشيري طبيبك قبل البدء بأي برنامج رياضي
• أبلغي المدربة بأي حالات صحية لديك

نحن غير مسؤولين عن:
• أي إصابات ناتجة عن ممارسة التمارين
• نتائج اتباع الخطط الغذائية
• أي مضاعفات صحية

التمرين على مسؤوليتك الشخصية.
''',
                delay: 700,
              ),

              _buildSection(
                title: 'المنتجات والشحن',
                content: '''
فيما يخص منتجات المتجر:

1. المنتجات:
   • نسعى لعرض معلومات دقيقة
   • الألوان قد تختلف قليلاً عن الصور
   • نحتفظ بحق رفض أو إلغاء الطلبات

2. الشحن:
   • التوصيل داخل المملكة العربية السعودية
   • مدة التوصيل 3-7 أيام عمل
   • رسوم الشحن حسب المدينة

3. الإرجاع والاستبدال:
   • خلال 14 يوماً من الاستلام
   • المنتج بحالته الأصلية
   • المكملات الغذائية غير قابلة للإرجاع بعد الفتح
''',
                delay: 800,
              ),

              _buildSection(
                title: 'تحديد المسؤولية',
                content: '''
في حدود ما يسمح به القانون:

• نقدم التطبيق "كما هو" دون ضمانات
• لا نضمن عمل التطبيق بدون انقطاع
• لسنا مسؤولين عن الأضرار غير المباشرة
• مسؤوليتنا محدودة بقيمة اشتراكك

نبذل جهدنا لتقديم أفضل خدمة ممكنة.
''',
                delay: 900,
              ),

              _buildSection(
                title: 'إنهاء الخدمة',
                content: '''
يمكنك إنهاء استخدام التطبيق في أي وقت بحذف حسابك.

يحق لنا إنهاء أو تعليق حسابك في حالة:
• انتهاك هذه الشروط
• الاشتباه في نشاط احتيالي
• عدم الدفع
• طلبك حذف الحساب

عند الإنهاء:
• تفقد الوصول إلى الخدمات
• لا يحق لك استرداد المبالغ المدفوعة
• قد نحتفظ ببعض البيانات حسب القانون
''',
                delay: 1000,
              ),

              _buildSection(
                title: 'التعديلات على الشروط',
                content: '''
نحتفظ بالحق في تعديل هذه الشروط في أي وقت.

سنخطرك بالتغييرات عبر:
• إشعار في التطبيق
• بريد إلكتروني

استمرارك في استخدام التطبيق بعد التعديل يعني موافقتك على الشروط الجديدة.
''',
                delay: 1100,
              ),

              _buildSection(
                title: 'القانون الحاكم',
                content: '''
تخضع هذه الشروط لقوانين المملكة العربية السعودية.

أي نزاع ينشأ يتم حله:
• أولاً: بالتفاوض الودي
• ثانياً: عبر الوساطة
• ثالثاً: المحاكم المختصة في المملكة العربية السعودية
''',
                delay: 1200,
              ),

              _buildSection(
                title: 'تواصل معنا',
                content: '''
لأي استفسارات حول الشروط والأحكام:

البريد الإلكتروني: legal@vitafit.online
الهاتف: +966 50 000 0000
العنوان: المملكة العربية السعودية

شكراً لاستخدامك VitaFit!
''',
                delay: 1300,
              ),

              const SizedBox(height: AppTheme.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.lg),
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: AppTheme.fontLg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          Text(
            content.trim(),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.fontMd,
              height: 1.7,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }
}
