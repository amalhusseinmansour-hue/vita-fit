import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class TrainerAddExerciseScreen extends StatefulWidget {
  final Map<String, dynamic>? trainee; // If null, select trainee first

  const TrainerAddExerciseScreen({super.key, this.trainee});

  @override
  State<TrainerAddExerciseScreen> createState() => _TrainerAddExerciseScreenState();
}

class _TrainerAddExerciseScreenState extends State<TrainerAddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '12');
  final _durationController = TextEditingController();
  final _restController = TextEditingController(text: '60');
  final _notesController = TextEditingController();

  List<dynamic> _trainees = [];
  Map<String, dynamic>? _selectedTrainee;
  String _selectedCategory = 'strength';
  String _selectedDifficulty = 'medium';
  bool _isLoading = false;
  bool _isLoadingTrainees = true;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'strength', 'name': 'تمارين القوة', 'icon': Icons.fitness_center},
    {'id': 'cardio', 'name': 'تمارين الكارديو', 'icon': Icons.directions_run},
    {'id': 'flexibility', 'name': 'تمارين المرونة', 'icon': Icons.self_improvement},
    {'id': 'balance', 'name': 'تمارين التوازن', 'icon': Icons.accessibility_new},
    {'id': 'hiit', 'name': 'تمارين HIIT', 'icon': Icons.flash_on},
    {'id': 'yoga', 'name': 'يوغا', 'icon': Icons.spa},
  ];

  final List<Map<String, dynamic>> _difficulties = [
    {'id': 'easy', 'name': 'سهل', 'color': Colors.green},
    {'id': 'medium', 'name': 'متوسط', 'color': Colors.orange},
    {'id': 'hard', 'name': 'صعب', 'color': Colors.red},
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
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _restController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
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
      final result = await ApiService.createExerciseForTrainee(
        traineeId: _selectedTrainee!['id'].toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
        sets: int.tryParse(_setsController.text) ?? 3,
        reps: int.tryParse(_repsController.text) ?? 12,
        duration: int.tryParse(_durationController.text),
        restSeconds: int.tryParse(_restController.text) ?? 60,
        notes: _notesController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة التمرين بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل إضافة التمرين'),
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
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: const Text('إضافة تمرين'),
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

                // Exercise Name
                _buildTextField(
                  controller: _nameController,
                  label: 'اسم التمرين',
                  hint: 'مثال: تمرين الضغط',
                  icon: Icons.fitness_center,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم التمرين';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Category
                const Text(
                  'نوع التمرين',
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
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat['id']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'],
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['name'],
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

                const SizedBox(height: 16),

                // Difficulty
                const Text(
                  'مستوى الصعوبة',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _difficulties.map((diff) {
                    final isSelected = _selectedDifficulty == diff['id'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDifficulty = diff['id']),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? diff['color']
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? diff['color']
                                  : AppTheme.border,
                            ),
                          ),
                          child: Text(
                            diff['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Sets and Reps
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _setsController,
                        label: 'عدد المجموعات',
                        hint: '3',
                        icon: Icons.repeat,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _repsController,
                        label: 'عدد التكرارات',
                        hint: '12',
                        icon: Icons.numbers,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Duration and Rest
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _durationController,
                        label: 'المدة (ثانية)',
                        hint: 'اختياري',
                        icon: Icons.timer,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _restController,
                        label: 'وقت الراحة (ثانية)',
                        hint: '60',
                        icon: Icons.hourglass_empty,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'وصف التمرين',
                  hint: 'اشرح كيفية أداء التمرين...',
                  icon: Icons.description,
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // Notes
                _buildTextField(
                  controller: _notesController,
                  label: 'ملاحظات للمتدربة',
                  hint: 'نصائح أو تعليمات إضافية...',
                  icon: Icons.note,
                  maxLines: 2,
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
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
                            'حفظ التمرين',
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppTheme.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            prefixIcon: Icon(icon, color: AppTheme.primary),
            filled: true,
            fillColor: AppTheme.surface,
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
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
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
