class Trainer {
  final String id;
  final String name;
  final String specialty;
  final String image;
  final double rating;
  final int experience; // بالسنوات
  final int clients; // عدد العملاء
  final String description;
  final List<String> certifications;
  final bool isAvailable;

  const Trainer({
    required this.id,
    required this.name,
    required this.specialty,
    required this.image,
    required this.rating,
    required this.experience,
    required this.clients,
    required this.description,
    this.certifications = const [],
    this.isAvailable = true,
  });
}
