enum CompanyType {
  supplier,
  consumer,
}

class CompanyModel {
  final String id;
  final String name;
  final CompanyType type;
  final String userId; // Owner/Admin user
  final String address;
  final String phoneNumber;
  final String? taxId;
  final double balanceMoney; // For supplier: money earned, For consumer: credit available
  final double balanceLiters; // For supplier: fuel inventory, For consumer: liters consumed
  final DateTime createdAt;
  final List<String> driverIds; // For consumer companies

  CompanyModel({
    required this.id,
    required this.name,
    required this.type,
    required this.userId,
    required this.address,
    required this.phoneNumber,
    this.taxId,
    this.balanceMoney = 0.0,
    this.balanceLiters = 0.0,
    required this.createdAt,
    this.driverIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'userId': userId,
      'address': address,
      'phoneNumber': phoneNumber,
      'taxId': taxId,
      'balanceMoney': balanceMoney,
      'balanceLiters': balanceLiters,
      'createdAt': createdAt.toIso8601String(),
      'driverIds': driverIds,
    };
  }

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'],
      name: json['name'],
      type: CompanyType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      userId: json['userId'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      taxId: json['taxId'],
      balanceMoney: (json['balanceMoney'] ?? 0.0).toDouble(),
      balanceLiters: (json['balanceLiters'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      driverIds: List<String>.from(json['driverIds'] ?? []),
    );
  }

  CompanyModel copyWith({
    String? id,
    String? name,
    CompanyType? type,
    String? userId,
    String? address,
    String? phoneNumber,
    String? taxId,
    double? balanceMoney,
    double? balanceLiters,
    DateTime? createdAt,
    List<String>? driverIds,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      taxId: taxId ?? this.taxId,
      balanceMoney: balanceMoney ?? this.balanceMoney,
      balanceLiters: balanceLiters ?? this.balanceLiters,
      createdAt: createdAt ?? this.createdAt,
      driverIds: driverIds ?? this.driverIds,
    );
  }
}
