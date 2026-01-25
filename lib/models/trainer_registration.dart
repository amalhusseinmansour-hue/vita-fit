class TrainerRegistration {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String specialty;
  final int experienceYears;
  final List<String> certifications;
  final String bio;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  TrainerRegistration({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.specialty,
    required this.experienceYears,
    required this.certifications,
    required this.bio,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TrainerRegistration.fromJson(Map<String, dynamic> json) {
    return TrainerRegistration(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: '', // Never store password from response
      specialty: json['specialty'] ?? json['specialization'] ?? '',
      experienceYears: json['experience_years'] ?? json['experienceYears'] ?? 0,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : [],
      bio: json['bio'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
      'specialty': specialty,
      'experience_years': experienceYears,
      'certifications': certifications,
      'bio': bio,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TrainerRegistration copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? specialty,
    int? experienceYears,
    List<String>? certifications,
    String? bio,
    String? status,
    DateTime? createdAt,
  }) {
    return TrainerRegistration(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      specialty: specialty ?? this.specialty,
      experienceYears: experienceYears ?? this.experienceYears,
      certifications: certifications ?? this.certifications,
      bio: bio ?? this.bio,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
