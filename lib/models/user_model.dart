enum UserRole {
  supplierCompany,
  consumerCompany,
  driver,
}

class UserModel {
  final String id;
  final String email;
  final String password;
  final UserRole role;
  final String name;
  final String? companyId; // For drivers, reference to their company
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.name,
    this.companyId,
    this.phoneNumber,
    this.dateOfBirth,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role.toString(),
      'name': name,
      'companyId': companyId,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == json['role'],
      ),
      name: json['name'],
      companyId: json['companyId'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? password,
    UserRole? role,
    String? name,
    String? companyId,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      name: name ?? this.name,
      companyId: companyId ?? this.companyId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
