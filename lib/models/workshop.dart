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
  });

  bool get isFull => enrolled >= capacity;
  int get availableSeats => capacity - enrolled;
  double get fillPercentage => (enrolled / capacity) * 100;
}
