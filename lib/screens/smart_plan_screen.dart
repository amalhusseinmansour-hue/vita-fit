import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../services/hive_storage_service.dart';

class SmartPlanScreen extends StatefulWidget {
  const SmartPlanScreen({super.key});

  @override
  State<SmartPlanScreen> createState() => _SmartPlanScreenState();
}

class _SmartPlanScreenState extends State<SmartPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for personal info
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  // Health info controllers
  final _healthConditionController = TextEditingController();
  final _previousInjuriesController = TextEditingController();
  final _surgeriesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();

  // Measurements controllers
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _chestController = TextEditingController();
  final _armController = TextEditingController();
  final _thighController = TextEditingController();

  // Calculated values
  double? _bmiResult;
  String _bmiCategory = '';
  String _bmiMessage = '';
  Color _bmiColor = AppTheme.primary;

  double? _bmrResult;
  double? _tdeeResult;

  // Activity level
  String? _selectedActivityLevel;
  double _activityMultiplier = 1.2;

  // Training type
  String? _selectedTrainingType;

  // Subscription type
  String? _selectedSubscriptionType;

  // Selected trainer
  String? _selectedTrainer;
  bool _trainerLocked = false; // Lock trainer selection after first choice
  String? _trainerRequestStatus; // pending, approved, rejected

  final List<Map<String, dynamic>> _activityLevels = [
    {
      'id': 'sedentary',
      'title': 'قليلة النشاط',
      'description': 'شغل مكتبي، حركة بسيطة جدًا، بدون تمارين منتظمة',
      'multiplier': 1.2,
      'color': const Color(0xFFFFD700),
    },
    {
      'id': 'light',
      'title': 'خفيفة النشاط',
      'description': 'تمارين خفيفة 1–3 مرات بالأسبوع أو شغل بيت مع حركة خفيفة',
      'multiplier': 1.375,
      'color': const Color(0xFF4CAF50),
    },
    {
      'id': 'moderate',
      'title': 'متوسطة النشاط',
      'description': 'تمارين 3–5 مرات بالأسبوع سواء في البيت أو الجيم، مشي 3 ساعات',
      'multiplier': 1.55,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 'active',
      'title': 'عالية النشاط',
      'description': 'تمارين 6 مرات بالأسبوع سواء في البيت أو الجيم',
      'multiplier': 1.725,
      'color': const Color(0xFFF44336),
    },
    {
      'id': 'very_active',
      'title': 'عالية النشاط جدًا',
      'description': 'تمارين مرتين باليوم سواء في البيت أو الجيم، أو شغل يحتاج مجهود بدني عالي',
      'multiplier': 1.9,
      'color': const Color(0xFF4CAF50),
    },
  ];

  final List<Map<String, dynamic>> _trainingTypes = [
    {'id': 'online', 'title': 'أون لاين', 'icon': Icons.wifi},
    {'id': 'gym', 'title': 'جيم', 'icon': Icons.fitness_center},
    {'id': 'home', 'title': 'بيت', 'icon': Icons.home},
  ];

  final List<Map<String, dynamic>> _subscriptionTypes = [
    {'id': 'training', 'title': 'جدول تدريبي', 'price': '299', 'duration': 'شهري'},
    {'id': 'nutrition', 'title': 'جدول غذائي', 'price': '249', 'duration': 'شهري'},
    {'id': 'training_nutrition', 'title': 'تدريبي + غذائي', 'price': '449', 'duration': 'شهري'},
    {'id': 'full', 'title': 'تدريبي + غذائي + متابعة', 'price': '599', 'duration': 'شهري'},
    {'id': 'private', 'title': 'تدريب خاص', 'price': '799', 'duration': 'شهري'},
    {'id': 'group', 'title': 'تدريب جماعي', 'price': '199', 'duration': 'شهري'},
  ];

  List<Map<String, dynamic>> _trainers = [];
  bool _isLoadingTrainers = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      // Load from local storage first
      setState(() {
        final name = HiveStorageService.getString('smartplan_name');
        if (name != null && name.isNotEmpty) _nameController.text = name;

        final age = HiveStorageService.getString('smartplan_age');
        if (age != null && age.isNotEmpty) _ageController.text = age;

        final height = HiveStorageService.getString('smartplan_height');
        if (height != null && height.isNotEmpty) _heightController.text = height;

        final currentWeight = HiveStorageService.getString('smartplan_current_weight');
        if (currentWeight != null && currentWeight.isNotEmpty) _currentWeightController.text = currentWeight;

        final targetWeight = HiveStorageService.getString('smartplan_target_weight');
        if (targetWeight != null && targetWeight.isNotEmpty) _targetWeightController.text = targetWeight;

        final healthCondition = HiveStorageService.getString('smartplan_health_condition');
        if (healthCondition != null) _healthConditionController.text = healthCondition;

        final previousInjuries = HiveStorageService.getString('smartplan_previous_injuries');
        if (previousInjuries != null) _previousInjuriesController.text = previousInjuries;

        final surgeries = HiveStorageService.getString('smartplan_surgeries');
        if (surgeries != null) _surgeriesController.text = surgeries;

        final medications = HiveStorageService.getString('smartplan_medications');
        if (medications != null) _medicationsController.text = medications;

        final allergies = HiveStorageService.getString('smartplan_allergies');
        if (allergies != null) _allergiesController.text = allergies;

        final waist = HiveStorageService.getString('smartplan_waist');
        if (waist != null && waist.isNotEmpty) _waistController.text = waist;

        final hips = HiveStorageService.getString('smartplan_hips');
        if (hips != null && hips.isNotEmpty) _hipsController.text = hips;

        final chest = HiveStorageService.getString('smartplan_chest');
        if (chest != null && chest.isNotEmpty) _chestController.text = chest;

        final arm = HiveStorageService.getString('smartplan_arm');
        if (arm != null && arm.isNotEmpty) _armController.text = arm;

        final thigh = HiveStorageService.getString('smartplan_thigh');
        if (thigh != null && thigh.isNotEmpty) _thighController.text = thigh;

        final activityLevel = HiveStorageService.getString('smartplan_activity_level');
        if (activityLevel != null) {
          _selectedActivityLevel = activityLevel;
          final level = _activityLevels.firstWhere(
            (l) => l['id'] == activityLevel,
            orElse: () => {'multiplier': 1.2},
          );
          _activityMultiplier = level['multiplier'] as double;
        }

        final trainingType = HiveStorageService.getString('smartplan_training_type');
        debugPrint('Loaded training type: $trainingType');
        if (trainingType != null && trainingType.isNotEmpty) _selectedTrainingType = trainingType;

        final subscriptionType = HiveStorageService.getString('smartplan_subscription_type');
        debugPrint('Loaded subscription type: $subscriptionType');
        if (subscriptionType != null && subscriptionType.isNotEmpty) _selectedSubscriptionType = subscriptionType;

        final trainerId = HiveStorageService.getString('smartplan_trainer_id');
        debugPrint('Loaded trainer id: $trainerId');
        if (trainerId != null && trainerId.isNotEmpty) _selectedTrainer = trainerId;

        // Load trainer lock status
        _trainerLocked = HiveStorageService.getBool('smartplan_trainer_locked') ?? false;
        _trainerRequestStatus = HiveStorageService.getString('smartplan_trainer_request_status');
        debugPrint('Trainer locked: $_trainerLocked, Request status: $_trainerRequestStatus');

        _calculateBMI();
        _calculateBMR();
      });

      // Also try to load from API if available
      final result = await ApiService.getSmartPlanData();
      if (result['success'] == true && result['data'] != null && mounted) {
        final data = result['data'];
        final user = data['user'];
        final measurements = data['measurements'];
        final healthData = data['healthData'];

        setState(() {
          if (user != null) {
            if (user['name'] != null && _nameController.text.isEmpty) {
              _nameController.text = user['name'];
            }
            if (user['height'] != null && _heightController.text.isEmpty) {
              _heightController.text = user['height'].toString();
            }
            if (user['weight'] != null && _currentWeightController.text.isEmpty) {
              _currentWeightController.text = user['weight'].toString();
            }
            if (user['activity_level'] != null && _selectedActivityLevel == null) {
              _selectedActivityLevel = user['activity_level'];
              final level = _activityLevels.firstWhere(
                (l) => l['id'] == user['activity_level'],
                orElse: () => {'multiplier': 1.2},
              );
              _activityMultiplier = level['multiplier'] as double;
            }
          }

          if (measurements != null) {
            if (measurements['waist'] != null && _waistController.text.isEmpty) {
              _waistController.text = measurements['waist'].toString();
            }
            if (measurements['hips'] != null && _hipsController.text.isEmpty) {
              _hipsController.text = measurements['hips'].toString();
            }
            if (measurements['chest'] != null && _chestController.text.isEmpty) {
              _chestController.text = measurements['chest'].toString();
            }
            if (measurements['arms'] != null && _armController.text.isEmpty) {
              _armController.text = measurements['arms'].toString();
            }
            if (measurements['thighs'] != null && _thighController.text.isEmpty) {
              _thighController.text = measurements['thighs'].toString();
            }
          }

          if (healthData != null) {
            if (healthData['age'] != null && _ageController.text.isEmpty) {
              _ageController.text = healthData['age'].toString();
            }
            if (healthData['target_weight'] != null && _targetWeightController.text.isEmpty) {
              _targetWeightController.text = healthData['target_weight'].toString();
            }
            if (healthData['health_condition'] != null && _healthConditionController.text.isEmpty) {
              _healthConditionController.text = healthData['health_condition'];
            }
            if (healthData['previous_injuries'] != null && _previousInjuriesController.text.isEmpty) {
              _previousInjuriesController.text = healthData['previous_injuries'];
            }
            if (healthData['surgeries'] != null && _surgeriesController.text.isEmpty) {
              _surgeriesController.text = healthData['surgeries'];
            }
            if (healthData['medications'] != null && _medicationsController.text.isEmpty) {
              _medicationsController.text = healthData['medications'];
            }
            if (healthData['allergies'] != null && _allergiesController.text.isEmpty) {
              _allergiesController.text = healthData['allergies'];
            }
            if (healthData['training_type'] != null && _selectedTrainingType == null) {
              _selectedTrainingType = healthData['training_type'];
            }
            if (healthData['subscription_type'] != null && _selectedSubscriptionType == null) {
              _selectedSubscriptionType = healthData['subscription_type'];
            }
          }

          if (data['trainer'] != null && _selectedTrainer == null) {
            _selectedTrainer = data['trainer']['id']?.toString();
          }

          _calculateBMI();
          _calculateBMR();
        });
      }
    } catch (e) {
      debugPrint('Error loading existing data: $e');
    }
  }

  Future<void> _saveSmartPlan() async {
    setState(() => _isSaving = true);

    try {
      // Save locally first
      // Using HiveStorageService
      await HiveStorageService.setString('smartplan_name', _nameController.text);
      await HiveStorageService.setString('smartplan_age', _ageController.text);
      await HiveStorageService.setString('smartplan_height', _heightController.text);
      await HiveStorageService.setString('smartplan_current_weight', _currentWeightController.text);
      await HiveStorageService.setString('smartplan_target_weight', _targetWeightController.text);
      await HiveStorageService.setString('smartplan_health_condition', _healthConditionController.text);
      await HiveStorageService.setString('smartplan_previous_injuries', _previousInjuriesController.text);
      await HiveStorageService.setString('smartplan_surgeries', _surgeriesController.text);
      await HiveStorageService.setString('smartplan_medications', _medicationsController.text);
      await HiveStorageService.setString('smartplan_allergies', _allergiesController.text);
      await HiveStorageService.setString('smartplan_waist', _waistController.text);
      await HiveStorageService.setString('smartplan_hips', _hipsController.text);
      await HiveStorageService.setString('smartplan_chest', _chestController.text);
      await HiveStorageService.setString('smartplan_arm', _armController.text);
      await HiveStorageService.setString('smartplan_thigh', _thighController.text);
      if (_selectedActivityLevel != null) {
        await HiveStorageService.setString('smartplan_activity_level', _selectedActivityLevel!);
      }
      if (_selectedTrainingType != null) {
        await HiveStorageService.setString('smartplan_training_type', _selectedTrainingType!);
        debugPrint('Saved training type: $_selectedTrainingType');
      }
      if (_selectedSubscriptionType != null) {
        await HiveStorageService.setString('smartplan_subscription_type', _selectedSubscriptionType!);
        debugPrint('Saved subscription type: $_selectedSubscriptionType');
      }
      if (_selectedTrainer != null) {
        await HiveStorageService.setString('smartplan_trainer_id', _selectedTrainer!);
        debugPrint('Saved trainer id: $_selectedTrainer');

        // Lock trainer selection after first save
        if (!_trainerLocked) {
          await HiveStorageService.setBool('smartplan_trainer_locked', true);
          _trainerLocked = true;
          debugPrint('Trainer selection locked');
        }
      }

      // Then try to save to server
      final result = await ApiService.saveSmartPlan(
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        age: int.tryParse(_ageController.text),
        height: double.tryParse(_heightController.text),
        currentWeight: double.tryParse(_currentWeightController.text),
        targetWeight: double.tryParse(_targetWeightController.text),
        healthCondition: _healthConditionController.text.isNotEmpty ? _healthConditionController.text : null,
        previousInjuries: _previousInjuriesController.text.isNotEmpty ? _previousInjuriesController.text : null,
        surgeries: _surgeriesController.text.isNotEmpty ? _surgeriesController.text : null,
        medications: _medicationsController.text.isNotEmpty ? _medicationsController.text : null,
        allergies: _allergiesController.text.isNotEmpty ? _allergiesController.text : null,
        activityLevel: _selectedActivityLevel,
        bmr: _bmrResult,
        tdee: _tdeeResult,
        waist: double.tryParse(_waistController.text),
        hips: double.tryParse(_hipsController.text),
        chest: double.tryParse(_chestController.text),
        arm: double.tryParse(_armController.text),
        thigh: double.tryParse(_thighController.text),
        trainingType: _selectedTrainingType,
        subscriptionType: _selectedSubscriptionType,
        trainerId: _selectedTrainer != null ? int.tryParse(_selectedTrainer!) : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? (result['success'] == true ? 'تم حفظ البيانات بنجاح' : 'تم حفظ البيانات محليا')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ البيانات محليا'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _loadTrainers() async {
    try {
      final trainers = await ApiService.getTrainers();
      if (mounted) {
        setState(() {
          _trainers = trainers.map((t) => {
            'id': t['_id']?.toString() ?? '',
            'name': t['name'] ?? '',
            'specialty': t['specialty'] ?? '',
            'location': t['location'] ?? 'أون لاين',
            'price': t['price']?.toString() ?? '0',
            'rating': t['rating'] ?? 0.0,
          }).toList();
          _isLoadingTrainers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTrainers = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _healthConditionController.dispose();
    _previousInjuriesController.dispose();
    _surgeriesController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _chestController.dispose();
    _armController.dispose();
    _thighController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    final weight = double.tryParse(_currentWeightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight != null && height != null && height > 0) {
      final heightInMeters = height / 100;
      final bmi = weight / (heightInMeters * heightInMeters);

      setState(() {
        _bmiResult = bmi;
        if (bmi < 18.5) {
          _bmiCategory = 'نقص في الوزن';
          _bmiMessage = 'وزنك أقل من الطبيعي… بنساعدك توصلين للوزن الصحي بطريقة آمنة.';
          _bmiColor = const Color(0xFFFFD700);
        } else if (bmi < 25) {
          _bmiCategory = 'وزن طبيعي';
          _bmiMessage = 'وزنك ضمن النطاق الصحي… استمري على روتينك الجميل!';
          _bmiColor = const Color(0xFF4CAF50);
        } else if (bmi < 30) {
          _bmiCategory = 'زيادة في الوزن';
          _bmiMessage = 'أنتِ قريبة من الوزن الصحي… خطوات بسيطة ونوصل لهدفك.';
          _bmiColor = const Color(0xFFFF9800);
        } else {
          _bmiCategory = 'سمنة';
          _bmiMessage = 'بداية قوية تنتظرك… بنمشي معك خطوة بخطوة نحو وزن صحي.';
          _bmiColor = const Color(0xFFF44336);
        }
      });
    }
  }

  void _calculateBMR() {
    final weight = double.tryParse(_currentWeightController.text);
    final height = double.tryParse(_heightController.text);
    final age = double.tryParse(_ageController.text);

    if (weight != null && height != null && age != null) {
      // BMR formula for women: 665.1 + (9.6 * weight) + (1.8 * height) - (4.7 * age)
      final bmr = 665.1 + (9.6 * weight) + (1.8 * height) - (4.7 * age);

      setState(() {
        _bmrResult = bmr;
      });
    }
  }

  void _calculateTDEE() {
    if (_bmrResult != null) {
      setState(() {
        _tdeeResult = _bmrResult! * _activityMultiplier;
      });
    }
  }

  String _getSelectedTrainerName() {
    if (_selectedTrainer == null) return 'المدربة';
    final trainer = _trainers.firstWhere(
      (t) => t['id'] == _selectedTrainer,
      orElse: () => {'name': 'المدربة'},
    );
    return trainer['name'] ?? 'المدربة';
  }

  void _showTDEEResult() {
    _calculateBMR();
    _calculateTDEE();

    if (_tdeeResult != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'خطة السعرات اليومية',
            style: TextStyle(color: AppTheme.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_tdeeResult!.round()}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    const Text(
                      'سعرة / اليوم',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'هذه هي السعرات الحرارية التي تحافظ على وزنك الحالي.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'شاركي … وقوتك بتكبر كل يوم',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'حسناً',
                style: TextStyle(color: AppTheme.primary),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showTrainerConfirmationDialog(Map<String, dynamic> trainer) async {
    if (_trainerLocked) {
      // Show locked message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'المدربة مقفلة',
            style: TextStyle(color: AppTheme.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, color: Color(0xFFFF69B4), size: 48),
              const SizedBox(height: 16),
              Text(
                'لقد اخترتِ ${_getSelectedTrainerName()} مسبقاً.\n\nللتغيير، يرجى التواصل مع الإدارة.',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'حسناً',
                style: TextStyle(color: AppTheme.primary),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Show confirmation dialog for first-time selection
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'تأكيد اختيار المدربة',
          style: TextStyle(color: AppTheme.white, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFFF69B4).withOpacity(0.2),
              child: const Icon(Icons.person, color: Color(0xFFFF69B4), size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              trainer['name'] ?? 'المدربة',
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trainer['specialty'] ?? '',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تنبيه: لن تتمكني من تغيير المدربة بعد هذا الاختيار إلا بالتواصل مع الإدارة',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF69B4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تأكيد الاختيار',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _selectedTrainer = trainer['id'];
      });
      // Send trainer request to API
      await _sendTrainerRequest(trainer['id']);
    }
  }

  Future<void> _sendTrainerRequest(String trainerId) async {
    try {
      // Using HiveStorageService
      await HiveStorageService.setString('smartplan_trainer_request_status', 'pending');
      _trainerRequestStatus = 'pending';

      // Send request to server
      final result = await ApiService.sendTrainerRequest(trainerId);

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال طلب الإضافة للمدربة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending trainer request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF69B4).withOpacity(0.05),
                const Color(0xFFFFF0F5),
                const Color(0xFFFFE4E1).withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 24),
                    _buildBMIResult(),
                    const SizedBox(height: 24),
                    _buildHealthInfoSection(),
                    const SizedBox(height: 24),
                    _buildBMRSection(),
                    const SizedBox(height: 24),
                    _buildActivityLevelSection(),
                    const SizedBox(height: 24),
                    _buildTDEEButton(),
                    const SizedBox(height: 24),
                    _buildMeasurementsSection(),
                    const SizedBox(height: 24),
                    _buildTrainingTypeSection(),
                    const SizedBox(height: 24),
                    _buildSubscriptionSection(),
                    const SizedBox(height: 24),
                    _buildTrainerSection(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppTheme.gradientPrimary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF69B4).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveSmartPlan,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'حفظ البيانات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 1000.ms);
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF69B4).withOpacity(0.95),
                  const Color(0xFFFF1493).withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF69B4).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'خطتي الذكية',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'رحلتي مع ${_getSelectedTrainerName()}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF69B4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('معلوماتي الشخصية', Icons.person),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF69B4).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTextField(_nameController, 'اسمي', Icons.badge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_ageController, 'عمري', Icons.cake, isNumber: true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(_heightController, 'طولي (سم)', Icons.height, isNumber: true, onChanged: (_) => _calculateBMI()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_currentWeightController, 'وزني الحالي (كجم)', Icons.monitor_weight, isNumber: true, onChanged: (_) => _calculateBMI()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(_targetWeightController, 'وزني المستهدف', Icons.flag, isNumber: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF69B4).withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFFFF69B4),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: const Color(0xFFFF69B4).withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFFFF69B4), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildBMIResult() {
    if (_bmiResult == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _bmiColor.withOpacity(0.1),
              _bmiColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _bmiColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'مؤشر كتلة الجسم BMI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF69B4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _bmiResult!.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _bmiColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _bmiColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _bmiCategory,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _bmiMessage,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildHealthInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('صحتي العامة', Icons.favorite),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF69B4).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTextField(_healthConditionController, 'الحالة الصحية', Icons.health_and_safety),
                const SizedBox(height: 16),
                _buildTextField(_previousInjuriesController, 'إصابات سابقة', Icons.healing),
                const SizedBox(height: 16),
                _buildTextField(_surgeriesController, 'عمليات / ولادة', Icons.medical_services),
                const SizedBox(height: 16),
                _buildTextField(_medicationsController, 'أدوية تستخدمها', Icons.medication),
                const SizedBox(height: 16),
                _buildTextField(_allergiesController, 'حساسية من أطعمة معينة', Icons.no_food),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildBMRSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('معدل الأيض الأساسي BMR', Icons.local_fire_department),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: _calculateBMR,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.gradientPrimary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF69B4).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'اضغطي لحساب معدل الأيض',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  if (_bmrResult != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${_bmrResult!.round()} سعرة/اليوم',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'هذه هي السعرات التي يحرقها جسمك في حالة الراحة التامة',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }

  Widget _buildActivityLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('مستوى نشاطي اليومي', Icons.directions_run),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _activityLevels.length,
            itemBuilder: (context, index) {
              final level = _activityLevels[index];
              final isSelected = _selectedActivityLevel == level['id'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedActivityLevel = level['id'];
                    _activityMultiplier = level['multiplier'];
                  });
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? level['color'] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: level['color'],
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (level['color'] as Color).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : level['color'],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          level['description'],
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white.withOpacity(0.9) : const Color(0xFF666666),
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  Widget _buildTDEEButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _showTDEEResult,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF69B4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 8,
            shadowColor: const Color(0xFFFF69B4).withOpacity(0.5),
          ),
          child: const Text(
            'سعراتي الحرارية اليومية TDEE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 500.ms);
  }

  Widget _buildMeasurementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('القياسات', Icons.straighten),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF69B4).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTextField(_waistController, 'محيط الخصر', Icons.accessibility, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_hipsController, 'محيط الأرداف', Icons.accessibility, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_chestController, 'محيط الصدر', Icons.accessibility, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_armController, 'محيط الذراع', Icons.accessibility, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_thighController, 'محيط الفخذ', Icons.accessibility, isNumber: true),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms);
  }

  Widget _buildTrainingTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('نظام التدريب', Icons.fitness_center),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _trainingTypes.map((type) {
              final isSelected = _selectedTrainingType == type['id'];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTrainingType = type['id'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.gradientPrimary : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF69B4),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          type['icon'],
                          color: isSelected ? Colors.white : const Color(0xFFFF69B4),
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          type['title'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFFFF69B4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 700.ms);
  }

  Widget _buildSubscriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('نوع الاشتراك', Icons.card_membership),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _subscriptionTypes.length,
            itemBuilder: (context, index) {
              final sub = _subscriptionTypes[index];
              final isSelected = _selectedSubscriptionType == sub['id'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSubscriptionType = sub['id'];
                  });
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.gradientPrimary : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF69B4),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF69B4).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub['title'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFFFF69B4),
                        ),
                        maxLines: 2,
                      ),
                      const Spacer(),
                      Text(
                        '${sub['price']} ريال',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFFFF69B4),
                        ),
                      ),
                      Text(
                        sub['duration'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 800.ms);
  }

  Widget _buildTrainerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSectionTitle('اختاري المدربة', Icons.person_pin)),
            if (_trainerLocked)
              Container(
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, color: Colors.orange, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'مقفل',
                      style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (_trainerLocked) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'للتغيير، يرجى التواصل مع الإدارة',
              style: TextStyle(color: Colors.orange.withOpacity(0.8), fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: _isLoadingTrainers
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF69B4)))
              : _trainers.isEmpty
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFF69B4).withOpacity(0.3)),
                        ),
                        child: const Text(
                          'لا يوجد مدربات متاحات حالياً',
                          style: TextStyle(color: Color(0xFFFF69B4)),
                        ),
                      ),
                    )
                  : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _trainers.length,
            itemBuilder: (context, index) {
              final trainer = _trainers[index];
              final isSelected = _selectedTrainer == trainer['id'];

              return GestureDetector(
                onTap: () => _showTrainerConfirmationDialog(trainer),
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.gradientPrimary : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF69B4),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF69B4).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isSelected ? Colors.white.withOpacity(0.3) : const Color(0xFFFF69B4).withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: isSelected ? Colors.white : const Color(0xFFFF69B4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trainer['name'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : const Color(0xFFFF69B4),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 12,
                                      color: isSelected ? Colors.amber : Colors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${trainer['rating']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected ? Colors.white : const Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        trainer['specialty'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white.withOpacity(0.9) : const Color(0xFF666666),
                        ),
                      ),
                      Text(
                        trainer['location'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF999999),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${trainer['price']} ريال/شهر',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFFFF69B4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 900.ms);
  }
}
