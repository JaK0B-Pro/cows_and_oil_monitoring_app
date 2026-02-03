enum TransactionStatus {
  pending,
  approved,
  rejected,
}

class TransactionModel {
  final String id;
  final String initiatorId; // User who initiated (driver or supplier)
  final String initiatorName;
  final String receiverId; // User who receives request (driver or supplier)
  final String receiverName;
  final String? supplierCompanyId;
  final String? supplierCompanyName;
  final String? consumerCompanyId;
  final String? consumerCompanyName;
  final double amountLiters;
  final double pricePerLiter;
  final double totalPrice;
  final double amountDZD; // Direct DZD amount input
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  TransactionModel({
    required this.id,
    required this.initiatorId,
    required this.initiatorName,
    required this.receiverId,
    required this.receiverName,
    this.supplierCompanyId,
    this.supplierCompanyName,
    this.consumerCompanyId,
    this.consumerCompanyName,
    required this.amountLiters,
    required this.pricePerLiter,
    required this.totalPrice,
    required this.amountDZD,
    this.status = TransactionStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'initiatorId': initiatorId,
      'initiatorName': initiatorName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'supplierCompanyId': supplierCompanyId,
      'supplierCompanyName': supplierCompanyName,
      'consumerCompanyId': consumerCompanyId,
      'consumerCompanyName': consumerCompanyName,
      'amountLiters': amountLiters,
      'pricePerLiter': pricePerLiter,
      'totalPrice': totalPrice,
      'amountDZD': amountDZD,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      initiatorId: json['initiatorId'],
      initiatorName: json['initiatorName'],
      receiverId: json['receiverId'],
      receiverName: json['receiverName'],
      supplierCompanyId: json['supplierCompanyId'],
      supplierCompanyName: json['supplierCompanyName'],
      consumerCompanyId: json['consumerCompanyId'],
      consumerCompanyName: json['consumerCompanyName'],
      amountLiters: (json['amountLiters'] ?? 0.0).toDouble(),
      pricePerLiter: (json['pricePerLiter'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      amountDZD: (json['amountDZD'] ?? json['totalPrice'] ?? 0.0).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
    );
  }

  TransactionModel copyWith({
    String? id,
    String? initiatorId,
    String? initiatorName,
    String? receiverId,
    String? receiverName,
    String? supplierCompanyId,
    String? supplierCompanyName,
    String? consumerCompanyId,
    String? consumerCompanyName,
    double? amountLiters,
    double? pricePerLiter,
    double? totalPrice,
    double? amountDZD,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      initiatorId: initiatorId ?? this.initiatorId,
      initiatorName: initiatorName ?? this.initiatorName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      supplierCompanyId: supplierCompanyId ?? this.supplierCompanyId,
      supplierCompanyName: supplierCompanyName ?? this.supplierCompanyName,
      consumerCompanyId: consumerCompanyId ?? this.consumerCompanyId,
      consumerCompanyName: consumerCompanyName ?? this.consumerCompanyName,
      amountLiters: amountLiters ?? this.amountLiters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalPrice: totalPrice ?? this.totalPrice,
      amountDZD: amountDZD ?? this.amountDZD,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }
}
