/// نموذج بيانات الورشة - Workshop Model
class Workshop {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String image;
  final DateTime date;
  final String time;
  final int duration; // بالدقائق
  final int capacity;
  final int enrolled;
  final double price;
  final String level; // مبتدئ، متوسط، متقدم
  final List<String> requirements;
  final String location;
  final String? category;

  const Workshop({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.image,
    required this.date,
    required this.time,
    required this.duration,
    required this.capacity,
    required this.enrolled,
    required this.price,
    required this.level,
    this.requirements = const [],
    required this.location,
    this.category,
  });

  bool get isFull => enrolled >= capacity;
  int get availableSeats => capacity - enrolled;
  double get fillPercentage => capacity > 0 ? (enrolled / capacity) * 100 : 0;

  factory Workshop.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return Workshop(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      instructor: json['instructor'] as String? ?? json['instructorName'] as String? ?? '',
      image: json['image'] as String? ?? json['imageUrl'] as String? ?? '',
      date: parseDate(json['date']),
      time: json['time'] as String? ?? '',
      duration: json['duration'] as int? ?? 60,
      capacity: json['capacity'] as int? ?? json['maxParticipants'] as int? ?? 0,
      enrolled: json['enrolled'] as int? ?? json['participantsCount'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      level: json['level'] as String? ?? 'مبتدئ',
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'] as List)
          : const [],
      location: json['location'] as String? ?? 'أونلاين',
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'image': image,
      'date': date.toIso8601String(),
      'time': time,
      'duration': duration,
      'capacity': capacity,
      'enrolled': enrolled,
      'price': price,
      'level': level,
      'requirements': requirements,
      'location': location,
      'category': category,
    };
  }

  /// نسخ مع تعديل
  Workshop copyWith({
    String? id,
    String? title,
    String? description,
    String? instructor,
    String? image,
    DateTime? date,
    String? time,
    int? duration,
    int? capacity,
    int? enrolled,
    double? price,
    String? level,
    List<String>? requirements,
    String? location,
    String? category,
  }) {
    return Workshop(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructor: instructor ?? this.instructor,
      image: image ?? this.image,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      capacity: capacity ?? this.capacity,
      enrolled: enrolled ?? this.enrolled,
      price: price ?? this.price,
      level: level ?? this.level,
      requirements: requirements ?? this.requirements,
      location: location ?? this.location,
      category: category ?? this.category,
    );
  }
}
