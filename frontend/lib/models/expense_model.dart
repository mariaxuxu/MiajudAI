class ExpenseModel {
  final int id;
  final int userId;
  final int? accountId;
  final int categoryId;
  final double amount;
  final String description;
  final DateTime expenseDate;
  final bool isRecurring;
  final String? recurrenceType;
  final String paymentMethod;
  final String status;
  final String? tags;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    this.accountId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.expenseDate,
    required this.isRecurring,
    this.recurrenceType,
    required this.paymentMethod,
    required this.status,
    this.tags,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      accountId: json['account_id'] as int?,
      categoryId: json['category_id'] as int,
      amount: double.parse((json['amount'] ?? 0).toString()),
      description: json['description'] as String? ?? '',
      expenseDate: DateTime.parse(json['expense_date'] as String? ?? '2000-01-01'),
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrenceType: json['recurrence_type'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      status: json['status'] as String? ?? 'paid',
      tags: json['tags'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? '2000-01-01'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'expense_date': expenseDate.toIso8601String(),
      'is_recurring': isRecurring,
      'recurrence_type': recurrenceType,
      'payment_method': paymentMethod,
      'status': status,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ExpenseModel copyWith({
    int? id,
    int? userId,
    int? accountId,
    int? categoryId,
    double? amount,
    String? description,
    DateTime? expenseDate,
    bool? isRecurring,
    String? recurrenceType,
    String? paymentMethod,
    String? status,
    String? tags,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      expenseDate: expenseDate ?? this.expenseDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'ExpenseModel(id: $id, description: $description, amount: $amount)';
}
