class AccountModel {
  final int id;
  final int userId;
  final String name;
  final String type;
  final double balance;
  final String? bankName;
  final String? accountNumber;
  final bool isActive;
  final DateTime createdAt;

  AccountModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    this.bankName,
    this.accountNumber,
    required this.isActive,
    required this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'checking',
      balance: double.parse((json['balance'] ?? 0).toString()),
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String? ?? '2000-01-01'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'bank_name': bankName,
      'account_number': accountNumber,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AccountModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
    double? balance,
    String? bankName,
    String? accountNumber,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'AccountModel(id: $id, name: $name, balance: $balance)';
}
