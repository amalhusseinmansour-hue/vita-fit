/// نموذج بيانات المدرب - Trainer Model
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
  final String? email;
  final String? phone;

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
    this.email,
    this.phone,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      specialty: json['specialty'] as String? ?? json['specialization'] as String? ?? '',
      image: json['image'] as String? ?? json['avatar'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      experience: json['experience'] as int? ?? 0,
      clients: json['clients'] as int? ?? json['clientsCount'] as int? ?? 0,
      description: json['description'] as String? ?? json['bio'] as String? ?? '',
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'] as List)
          : const [],
      isAvailable: json['isAvailable'] as bool? ?? json['available'] as bool? ?? true,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'image': image,
      'rating': rating,
      'experience': experience,
      'clients': clients,
      'description': description,
      'certifications': certifications,
      'isAvailable': isAvailable,
      'email': email,
      'phone': phone,
    };
  }

  /// نسخ مع تعديل
  Trainer copyWith({
    String? id,
    String? name,
    String? specialty,
    String? image,
    double? rating,
    int? experience,
    int? clients,
    String? description,
    List<String>? certifications,
    bool? isAvailable,
    String? email,
    String? phone,
  }) {
    return Trainer(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      experience: experience ?? this.experience,
      clients: clients ?? this.clients,
      description: description ?? this.description,
      certifications: certifications ?? this.certifications,
      isAvailable: isAvailable ?? this.isAvailable,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
