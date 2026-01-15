/// نموذج بيانات الحصة المباشرة - Live Class Model
class LiveClass {
  final String id;
  final String title;
  final String instructor;
  final String time;
  final int duration; // بالدقائق
  final String level; // مبتدئ، متوسط، متقدم
  final int participants; // عدد المشاركين
  final String category; // yoga, cardio, strength, dance
  final bool isLive; // هل الحصة مباشرة الآن

  const LiveClass({
    required this.id,
    required this.title,
    required this.instructor,
    required this.time,
    required this.duration,
    required this.level,
    required this.participants,
    this.category = 'yoga',
    this.isLive = false,
  });

  // تحويل من JSON
  factory LiveClass.fromJson(Map<String, dynamic> json) {
    return LiveClass(
      id: json['id'] as String,
      title: json['title'] as String,
      instructor: json['instructor'] as String,
      time: json['time'] as String,
      duration: json['duration'] as int,
      level: json['level'] as String,
      participants: json['participants'] as int,
      category: json['category'] as String? ?? 'yoga',
      isLive: json['isLive'] as bool? ?? false,
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'time': time,
      'duration': duration,
      'level': level,
      'participants': participants,
      'category': category,
      'isLive': isLive,
    };
  }
}

/// نموذج بيانات الفئة - Category Model
class Category {
  final String id;
  final String title;
  final String icon;

  const Category({
    required this.id,
    required this.title,
    required this.icon,
  });
}
