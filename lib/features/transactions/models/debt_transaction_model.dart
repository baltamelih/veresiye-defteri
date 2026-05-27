class DebtTransactionModel {
  final String id;
  final String customerId;
  final double amount;
  final String type; // debt / payment
  final String description;
  final DateTime date;
  final DateTime createdAt;

  const DebtTransactionModel({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  bool get isDebt => type == 'debt';
  bool get isPayment => type == 'payment';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DebtTransactionModel.fromMap(Map data) {
    return DebtTransactionModel(
      id: data['id']?.toString() ?? '',
      customerId: data['customerId']?.toString() ?? '',
      amount: _parseAmount(data['amount']),
      type: data['type']?.toString() ?? 'debt',
      description: data['description']?.toString() ?? '',
      date: _parseDate(data['date']),
      createdAt: _parseDate(data['createdAt']),
    );
  }

  DebtTransactionModel copyWith({
    String? id,
    String? customerId,
    double? amount,
    String? type,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return DebtTransactionModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }
}