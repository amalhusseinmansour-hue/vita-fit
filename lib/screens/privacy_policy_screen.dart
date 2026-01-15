import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
            'سياسة الخصوصية',
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
                        Icons.privacy_tip,
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
                            'سياسة الخصوصية',
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
                title: 'مقدمة',
                content: '''
نحن في VitaFit نقدر خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح سياسة الخصوصية هذه كيفية جمعنا واستخدامنا وحمايتنا لمعلوماتك عند استخدام تطبيقنا.

باستخدامك لتطبيق VitaFit، فإنك توافق على جمع واستخدام معلوماتك وفقاً لهذه السياسة.
''',
                delay: 100,
              ),

              _buildSection(
                title: 'المعلومات التي نجمعها',
                content: '''
1. معلومات الحساب:
   • الاسم الكامل
   • البريد الإلكتروني
   • رقم الهاتف
   • كلمة المرور (مشفرة)

2. معلومات الصحة واللياقة:
   • الطول والوزن
   • الأهداف الصحية
   • مستوى النشاط البدني
   • تاريخ التمارين والوجبات

3. معلومات الجهاز:
   • نوع الجهاز ونظام التشغيل
   • معرف الجهاز للإشعارات
   • عنوان IP

4. معلومات الدفع:
   • نحتفظ فقط بآخر 4 أرقام من البطاقة
   • لا نخزن معلومات البطاقة الكاملة
''',
                delay: 200,
              ),

              _buildSection(
                title: 'كيف نستخدم معلوماتك',
                content: '''
نستخدم المعلومات التي نجمعها للأغراض التالية:

• تقديم خدمات التطبيق وتحسينها
• تخصيص تجربتك وبرامج التدريب
• إرسال الإشعارات والتذكيرات
• معالجة المدفوعات والاشتراكات
• التواصل معك بشأن حسابك
• تحسين أمان التطبيق
• الامتثال للمتطلبات القانونية
''',
                delay: 300,
              ),

              _buildSection(
                title: 'مشاركة المعلومات',
                content: '''
لا نبيع أو نؤجر معلوماتك الشخصية لأطراف ثالثة. قد نشارك معلوماتك في الحالات التالية:

• مع المدربات المعينات لك (معلومات اللياقة فقط)
• مع مزودي خدمات الدفع لمعالجة المدفوعات
• عند الاقتضاء بموجب القانون
• لحماية حقوقنا وسلامة المستخدمين
''',
                delay: 400,
              ),

              _buildSection(
                title: 'حماية البيانات',
                content: '''
نتخذ إجراءات أمنية صارمة لحماية معلوماتك:

• تشفير البيانات أثناء النقل والتخزين
• استخدام بروتوكولات HTTPS آمنة
• تخزين كلمات المرور بتشفير قوي
• مراجعات أمنية دورية
• تقييد الوصول إلى البيانات للموظفين المصرح لهم
''',
                delay: 500,
              ),

              _buildSection(
                title: 'حقوقك',
                content: '''
لديك الحقوق التالية فيما يتعلق ببياناتك:

• الوصول إلى بياناتك الشخصية
• تصحيح البيانات غير الدقيقة
• حذف حسابك وبياناتك
• الاعتراض على معالجة بياناتك
• نقل بياناتك إلى خدمة أخرى
• سحب موافقتك في أي وقت

لممارسة أي من هذه الحقوق، يرجى التواصل معنا عبر التطبيق أو البريد الإلكتروني.
''',
                delay: 600,
              ),

              _buildSection(
                title: 'ملفات تعريف الارتباط',
                content: '''
قد نستخدم ملفات تعريف الارتباط وتقنيات مشابهة لتحسين تجربتك:

• تذكر تفضيلاتك وإعداداتك
• تحليل استخدام التطبيق
• تخصيص المحتوى والإعلانات

يمكنك التحكم في ملفات تعريف الارتباط من إعدادات جهازك.
''',
                delay: 700,
              ),

              _buildSection(
                title: 'الاحتفاظ بالبيانات',
                content: '''
نحتفظ ببياناتك طالما كان حسابك نشطاً أو حسب الحاجة لتقديم خدماتنا.

عند حذف حسابك:
• يتم حذف بياناتك الشخصية خلال 30 يوماً
• قد نحتفظ ببعض البيانات المجهولة للتحليلات
• نحتفظ بسجلات المعاملات المالية حسب القانون
''',
                delay: 800,
              ),

              _buildSection(
                title: 'التحديثات على السياسة',
                content: '''
قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنخطرك بأي تغييرات جوهرية عبر:

• إشعار داخل التطبيق
• بريد إلكتروني على عنوانك المسجل

ننصحك بمراجعة هذه السياسة بشكل دوري.
''',
                delay: 900,
              ),

              _buildSection(
                title: 'تواصل معنا',
                content: '''
إذا كان لديك أي أسئلة حول سياسة الخصوصية، يرجى التواصل معنا:

البريد الإلكتروني: privacy@vitafit.online
الهاتف: +966 50 000 0000
العنوان: المملكة العربية السعودية

نحن ملتزمون بالرد على استفساراتك خلال 48 ساعة.
''',
                delay: 1000,
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
