class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String note;
  final DateTime createdAt;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromMap(Map data) {
    return CustomerModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      note: data['note'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? note,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}