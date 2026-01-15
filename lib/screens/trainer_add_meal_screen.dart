import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class TrainerAddMealScreen extends StatefulWidget {
  final Map<String, dynamic>? trainee;

  const TrainerAddMealScreen({super.key, this.trainee});

  @override
  State<TrainerAddMealScreen> createState() => _TrainerAddMealScreenState();
}

class _TrainerAddMealScreenState extends State<TrainerAddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _notesController = TextEditingController();

  List<dynamic> _trainees = [];
  Map<String, dynamic>? _selectedTrainee;
  String _selectedMealType = 'lunch';
  bool _isLoading = false;
  bool _isLoadingTrainees = true;

  final List<Map<String, dynamic>> _mealTypes = [
    {'id': 'breakfast', 'name': 'فطور', 'icon': Icons.free_breakfast},
    {'id': 'lunch', 'name': 'غداء', 'icon': Icons.lunch_dining},
    {'id': 'dinner', 'name': 'عشاء', 'icon': Icons.dinner_dining},
    {'id': 'snack', 'name': 'وجبة خفيفة', 'icon': Icons.cookie},
    {'id': 'pre_workout', 'name': 'قبل التمرين', 'icon': Icons.sports},
    {'id': 'post_workout', 'name': 'بعد التمرين', 'icon': Icons.sports_score},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTrainee = widget.trainee;
    _loadTrainees();
  }

  Future<void> _loadTrainees() async {
    try {
      final trainees = await ApiService.getTrainerClients();
      setState(() {
        _trainees = trainees;
        _isLoadingTrainees = false;
      });
    } catch (e) {
      setState(() => _isLoadingTrainees = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTrainee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار المتدربة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.createMealForTrainee(
        traineeId: _selectedTrainee!['id'].toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        mealType: _selectedMealType,
        calories: int.tryParse(_caloriesController.text),
        protein: double.tryParse(_proteinController.text),
        carbs: double.tryParse(_carbsController.text),
        fat: double.tryParse(_fatController.text),
        ingredients: _ingredientsController.text.trim(),
        instructions: _instructionsController.text.trim(),
        notes: _notesController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الوجبة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل إضافة الوجبة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في الاتصال'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.secondary,
          foregroundColor: Colors.white,
          title: const Text('إضافة وجبة'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Select Trainee
                const Text(
                  'اختر المتدربة',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _isLoadingTrainees
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, dynamic>>(
                            isExpanded: true,
                            value: _selectedTrainee,
                            hint: const Text(
                              'اختر المتدربة',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            dropdownColor: AppTheme.surface,
                            items: _trainees.map((trainee) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: trainee,
                                child: Text(
                                  trainee['name'] ?? 'بدون اسم',
                                  style: const TextStyle(color: AppTheme.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedTrainee = value);
                            },
                          ),
                        ),
                      ),

                const SizedBox(height: 20),

                // Meal Name
                _buildTextField(
                  controller: _nameController,
                  label: 'اسم الوجبة',
                  hint: 'مثال: سلطة الدجاج المشوي',
                  icon: Icons.restaurant,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الوجبة';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Meal Type
                const Text(
                  'نوع الوجبة',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _mealTypes.map((type) {
                    final isSelected = _selectedMealType == type['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMealType = type['id']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.secondary
                              : AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.secondary
                                : AppTheme.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type['icon'],
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              type['name'],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Nutrition Info
                const Text(
                  'القيم الغذائية',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Calories
                _buildTextField(
                  controller: _caloriesController,
                  label: 'السعرات الحرارية',
                  hint: 'مثال: 350',
                  icon: Icons.local_fire_department,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 12),

                // Macros Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _proteinController,
                        label: 'البروتين (جم)',
                        hint: '25',
                        icon: Icons.egg,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: _carbsController,
                        label: 'الكربوهيدرات (جم)',
                        hint: '30',
                        icon: Icons.grain,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: _fatController,
                        label: 'الدهون (جم)',
                        hint: '10',
                        icon: Icons.opacity,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'وصف الوجبة',
                  hint: 'وصف مختصر للوجبة...',
                  icon: Icons.description,
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Ingredients
                _buildTextField(
                  controller: _ingredientsController,
                  label: 'المكونات',
                  hint: 'اكتب كل مكون في سطر جديد...',
                  icon: Icons.list,
                  maxLines: 4,
                ),

                const SizedBox(height: 16),

                // Instructions
                _buildTextField(
                  controller: _instructionsController,
                  label: 'طريقة التحضير',
                  hint: 'خطوات تحضير الوجبة...',
                  icon: Icons.format_list_numbered,
                  maxLines: 4,
                ),

                const SizedBox(height: 16),

                // Notes
                _buildTextField(
                  controller: _notesController,
                  label: 'ملاحظات للمتدربة',
                  hint: 'نصائح أو بدائل...',
                  icon: Icons.note,
                  maxLines: 2,
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'حفظ الوجبة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppTheme.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            prefixIcon: Icon(icon, color: AppTheme.secondary, size: 20),
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
