class FixedCostModel {
  final int id;
  final int userId;
  final String name;
  final double amount;
  final int dueDayOfMonth;
  final String category;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FixedCostModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.dueDayOfMonth,
    required this.category,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory FixedCostModel.fromJson(Map<String, dynamic> json) {
    return FixedCostModel(
      id: json['id'] as int,
      userId: int.tryParse((json['user_id'] ?? 0).toString()) ?? 0,
      name: json['name'] as String? ?? '',
      amount: double.parse((json['amount'] ?? 0).toString()),
      dueDayOfMonth: json['due_day_of_month'] as int? ?? 1,
      category: json['category'] as String? ?? 'other',
      description: json['description'] as String?,
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
    'amount': amount,
    'due_day_of_month': dueDayOfMonth,
    'category': category,
    'description': description,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
  };

  FixedCostModel copyWith({
    int? id,
    int? userId,
    String? name,
    double? amount,
    int? dueDayOfMonth,
    String? category,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      FixedCostModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        dueDayOfMonth: dueDayOfMonth ?? this.dueDayOfMonth,
        category: category ?? this.category,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'FixedCostModel(id: $id, name: $name, amount: $amount, category: $category)';
}
