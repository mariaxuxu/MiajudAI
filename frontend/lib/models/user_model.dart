class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? gender;
  final String? birthDate;
  final String? birthCountry;
  final String? birthState;
  final String? birthCity;
  final String? nationality;
  final String? maritalStatus;
  final String? emergencyContact1Name;
  final String? emergencyContact1Phone;
  final String? emergencyContact2Name;
  final String? emergencyContact2Phone;
  final String? emergencyContact3Name;
  final String? emergencyContact3Phone;
  final DateTime createdAt;
  final DateTime? lastActivity;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.gender,
    this.birthDate,
    this.birthCountry,
    this.birthState,
    this.birthCity,
    this.nationality,
    this.maritalStatus,
    this.emergencyContact1Name,
    this.emergencyContact1Phone,
    this.emergencyContact2Name,
    this.emergencyContact2Phone,
    this.emergencyContact3Name,
    this.emergencyContact3Phone,
    required this.createdAt,
    this.lastActivity,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: json['email'] ?? '',
      fullName: json['full_name'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      gender: json['gender'],
      birthDate: json['birth_date'],
      birthCountry: json['birth_country'],
      birthState: json['birth_state'],
      birthCity: json['birth_city'],
      nationality: json['nationality'],
      maritalStatus: json['marital_status'],
      emergencyContact1Name: json['emergency_contact_1_name'],
      emergencyContact1Phone: json['emergency_contact_1_phone'],
      emergencyContact2Name: json['emergency_contact_2_name'],
      emergencyContact2Phone: json['emergency_contact_2_phone'],
      emergencyContact3Name: json['emergency_contact_3_name'],
      emergencyContact3Phone: json['emergency_contact_3_phone'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'gender': gender,
      'birth_date': birthDate,
      'birth_country': birthCountry,
      'birth_state': birthState,
      'birth_city': birthCity,
      'nationality': nationality,
      'marital_status': maritalStatus,
      'emergency_contact_1_name': emergencyContact1Name,
      'emergency_contact_1_phone': emergencyContact1Phone,
      'emergency_contact_2_name': emergencyContact2Name,
      'emergency_contact_2_phone': emergencyContact2Phone,
      'emergency_contact_3_name': emergencyContact3Name,
      'emergency_contact_3_phone': emergencyContact3Phone,
      'created_at': createdAt.toIso8601String(),
      'last_activity': lastActivity?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? gender,
    String? birthDate,
    String? birthCountry,
    String? birthState,
    String? birthCity,
    String? nationality,
    String? maritalStatus,
    String? emergencyContact1Name,
    String? emergencyContact1Phone,
    String? emergencyContact2Name,
    String? emergencyContact2Phone,
    String? emergencyContact3Name,
    String? emergencyContact3Phone,
    DateTime? createdAt,
    DateTime? lastActivity,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthCountry: birthCountry ?? this.birthCountry,
      birthState: birthState ?? this.birthState,
      birthCity: birthCity ?? this.birthCity,
      nationality: nationality ?? this.nationality,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      emergencyContact1Name: emergencyContact1Name ?? this.emergencyContact1Name,
      emergencyContact1Phone: emergencyContact1Phone ?? this.emergencyContact1Phone,
      emergencyContact2Name: emergencyContact2Name ?? this.emergencyContact2Name,
      emergencyContact2Phone: emergencyContact2Phone ?? this.emergencyContact2Phone,
      emergencyContact3Name: emergencyContact3Name ?? this.emergencyContact3Name,
      emergencyContact3Phone: emergencyContact3Phone ?? this.emergencyContact3Phone,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName)';
  }
}
