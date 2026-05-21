class IncomeModel {
  final int id;
  final int userId;
  final int? accountId;
  final double amount;
  final String description;
  final String type;
  final DateTime incomeDate;
  final bool isRecurring;
  final String? recurrenceType;
  final DateTime createdAt;

  IncomeModel({
    required this.id,
    required this.userId,
    this.accountId,
    required this.amount,
    required this.description,
    required this.type,
    required this.incomeDate,
    required this.isRecurring,
    this.recurrenceType,
    required this.createdAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      accountId: json['account_id'] as int?,
      amount: double.parse((json['amount'] ?? 0).toString()),
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'salary',
      incomeDate: DateTime.parse(json['income_date'] as String? ?? '2000-01-01'),
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrenceType: json['recurrence_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? '2000-01-01'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'amount': amount,
      'description': description,
      'type': type,
      'income_date': incomeDate.toIso8601String(),
      'is_recurring': isRecurring,
      'recurrence_type': recurrenceType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  IncomeModel copyWith({
    int? id,
    int? userId,
    int? accountId,
    double? amount,
    String? description,
    String? type,
    DateTime? incomeDate,
    bool? isRecurring,
    String? recurrenceType,
    DateTime? createdAt,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      incomeDate: incomeDate ?? this.incomeDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'IncomeModel(id: $id, description: $description, amount: $amount)';
}
