class InstallmentModel {
  final int id;
  final int userId;
  final String name;
  final double totalAmount;
  final int totalInstallments;
  final double installmentValue;
  final int dueDayOfMonth;
  final DateTime startDate;
  final String? description;
  final String paymentMethod;
  final String? merchantName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InstallmentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.totalAmount,
    required this.totalInstallments,
    required this.installmentValue,
    required this.dueDayOfMonth,
    required this.startDate,
    this.description,
    required this.paymentMethod,
    this.merchantName,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  int get paidInstallments {
    final today = DateTime.now();
    final monthsDiff = (today.year - startDate.year) * 12 + (today.month - startDate.month);
    return (monthsDiff + 1).clamp(0, totalInstallments);
  }

  int getPaidInstallmentsForDate(DateTime referenceDate) {
    final monthsDiff = (referenceDate.year - startDate.year) * 12 + (referenceDate.month - startDate.month);
    return (monthsDiff + 1).clamp(0, totalInstallments);
  }

  int get remainingInstallments => totalInstallments - paidInstallments;

  bool get isCompleted => paidInstallments >= totalInstallments;

  factory InstallmentModel.fromJson(Map<String, dynamic> json) {
    return InstallmentModel(
      id: json['id'] as int,
      userId: int.tryParse((json['user_id'] ?? 0).toString()) ?? 0,
      name: json['name'] as String? ?? '',
      totalAmount: double.parse((json['total_amount'] ?? 0).toString()),
      totalInstallments: json['total_installments'] as int? ?? 0,
      installmentValue: double.parse((json['installment_value'] ?? 0).toString()),
      dueDayOfMonth: json['due_day_of_month'] as int? ?? 1,
      startDate: json['start_date'] is String
          ? DateTime.parse(json['start_date'] as String)
          : json['start_date'] as DateTime? ?? DateTime.now(),
      description: json['description'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'credit_card',
      merchantName: json['merchant_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : json['created_at'] as DateTime? ?? DateTime.now(),
      updatedAt: json['updated_at'] is String ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'total_amount': totalAmount,
    'total_installments': totalInstallments,
    'installment_value': installmentValue,
    'due_day_of_month': dueDayOfMonth,
    'start_date': startDate.toIso8601String(),
    'description': description,
    'payment_method': paymentMethod,
    'merchant_name': merchantName,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
  };

  InstallmentModel copyWith({
    int? id,
    int? userId,
    String? name,
    double? totalAmount,
    int? totalInstallments,
    double? installmentValue,
    int? dueDayOfMonth,
    DateTime? startDate,
    String? description,
    String? paymentMethod,
    String? merchantName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      InstallmentModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        totalAmount: totalAmount ?? this.totalAmount,
        totalInstallments: totalInstallments ?? this.totalInstallments,
        installmentValue: installmentValue ?? this.installmentValue,
        dueDayOfMonth: dueDayOfMonth ?? this.dueDayOfMonth,
        startDate: startDate ?? this.startDate,
        description: description ?? this.description,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        merchantName: merchantName ?? this.merchantName,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'InstallmentModel(id: $id, name: $name, totalAmount: $totalAmount, paidInstallments: $paidInstallments/$totalInstallments)';
}
