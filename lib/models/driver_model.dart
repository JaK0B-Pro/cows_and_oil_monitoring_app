class DriverModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? phoneNumber;
  final String consumerCompanyId;
  final String consumerCompanyName;
  final String licenseNumber;
  final String? vehicleNumber;
  final String? truckModel;
  final String? licensePlate;
  final double totalLitersConsumed;
  final double balanceDZD;
  final double monthlyLimit; // Liters
  final bool isActive;
  final DateTime createdAt;

  DriverModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.consumerCompanyId,
    required this.consumerCompanyName,
    required this.licenseNumber,
    this.vehicleNumber,
    this.truckModel,
    this.licensePlate,
    this.totalLitersConsumed = 0.0,
    this.balanceDZD = 0.0,
    this.monthlyLimit = 1000.0,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'consumerCompanyId': consumerCompanyId,
      'consumerCompanyName': consumerCompanyName,
      'licenseNumber': licenseNumber,
      'vehicleNumber': vehicleNumber,
      'truckModel': truckModel,
      'licensePlate': licensePlate,
      'totalLitersConsumed': totalLitersConsumed,
      'balanceDZD': balanceDZD,
      'monthlyLimit': monthlyLimit,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      consumerCompanyId: json['consumerCompanyId'],
      consumerCompanyName: json['consumerCompanyName'],
      licenseNumber: json['licenseNumber'],
      vehicleNumber: json['vehicleNumber'],
      truckModel: json['truckModel'],
      licensePlate: json['licensePlate'],
      totalLitersConsumed: (json['totalLitersConsumed'] ?? 0.0).toDouble(),
      balanceDZD: (json['balanceDZD'] ?? 0.0).toDouble(),
      monthlyLimit: (json['monthlyLimit'] ?? 1000.0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  DriverModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? consumerCompanyId,
    String? consumerCompanyName,
    String? licenseNumber,
    String? vehicleNumber,
    double? totalLitersConsumed,
    double? monthlyLimit,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      consumerCompanyId: consumerCompanyId ?? this.consumerCompanyId,
      consumerCompanyName: consumerCompanyName ?? this.consumerCompanyName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      totalLitersConsumed: totalLitersConsumed ?? this.totalLitersConsumed,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
