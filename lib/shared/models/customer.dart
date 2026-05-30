class Customer {
  const Customer({
    required this.id,
    required this.shopId,
    required this.name,
    required this.createdAt,
    this.phone,
    this.email,
    this.address,
    this.updatedAt,
  });

  final String id;
  final String shopId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isValid => validate().isEmpty;

  List<String> validate() {
    final errors = <String>[];

    if (id.trim().isEmpty) {
      errors.add('Customer id is required.');
    }
    if (shopId.trim().isEmpty) {
      errors.add('Customer shop id is required.');
    }
    if (name.trim().isEmpty) {
      errors.add('Customer name is required.');
    }
    if (email != null && email!.trim().isNotEmpty) {
      final isEmailValid = RegExp(
        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
      ).hasMatch(email!.trim());
      if (!isEmailValid) {
        errors.add('Customer email is invalid.');
      }
    }

    return errors;
  }

  Customer copyWith({
    String? id,
    String? shopId,
    String? name,
    String? phone,
    String? email,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      shopId: map['shopId'] as String? ?? 'default-shop',
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: _dateTimeOrNull(map['updatedAt']),
    );
  }
}

DateTime? _dateTimeOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value.toString());
}
