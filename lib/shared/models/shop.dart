class Shop {
  const Shop({
    required this.id,
    required this.shopName,
    required this.phone,
    required this.address,
    required this.email,
    required this.branchName,
    required this.currencyCode,
    required this.currencySymbol,
    required this.receiptFooter,
    required this.taxEnabled,
    required this.taxRate,
    required this.lowStockThreshold,
    required this.createdByUserId,
    required this.createdAt,
    this.updatedAt,
  });

  static const defaultShopId = 'default-shop';

  final String id;
  final String shopName;
  final String phone;
  final String address;
  final String email;
  final String branchName;
  final String currencyCode;
  final String currencySymbol;
  final String receiptFooter;
  final bool taxEnabled;
  final double taxRate;
  final int lowStockThreshold;
  final String createdByUserId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory Shop.defaultShop() {
    final now = DateTime.now();
    return Shop(
      id: defaultShopId,
      shopName: 'My Store',
      phone: '0000000000',
      address: '',
      email: '',
      branchName: '',
      currencyCode: 'GHS',
      currencySymbol: 'GHS',
      receiptFooter: 'Thank you for shopping with us.',
      taxEnabled: false,
      taxRate: 0,
      lowStockThreshold: 5,
      createdByUserId: 'system',
      createdAt: now,
    );
  }

  Shop copyWith({
    String? id,
    String? shopName,
    String? phone,
    String? address,
    String? email,
    String? branchName,
    String? currencyCode,
    String? currencySymbol,
    String? receiptFooter,
    bool? taxEnabled,
    double? taxRate,
    int? lowStockThreshold,
    String? createdByUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shop(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      branchName: branchName ?? this.branchName,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      taxEnabled: taxEnabled ?? this.taxEnabled,
      taxRate: taxRate ?? this.taxRate,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isValid => validate().isEmpty;

  List<String> validate() {
    final errors = <String>[];

    if (id.trim().isEmpty) {
      errors.add('Shop id is required.');
    }
    if (shopName.trim().isEmpty) {
      errors.add('Shop name is required.');
    }
    if (phone.trim().isEmpty) {
      errors.add('Shop phone is required.');
    }
    if (address.trim().isEmpty && id != defaultShopId) {
      errors.add('Shop address is required.');
    }
    if (email.trim().isNotEmpty && !_emailPattern.hasMatch(email.trim())) {
      errors.add('Shop email is invalid.');
    }
    if (currencyCode != 'GHS') {
      errors.add('Currency must remain GHS.');
    }
    if (taxRate < 0) {
      errors.add('Tax rate must be 0 or greater.');
    }
    if (lowStockThreshold < 0) {
      errors.add('Low stock threshold must be 0 or greater.');
    }
    if (createdByUserId.trim().isEmpty) {
      errors.add('Shop creator is required.');
    }

    return errors;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopName': shopName,
      'phone': phone,
      'address': address,
      'email': email,
      'branchName': branchName,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'receiptFooter': receiptFooter,
      'taxEnabled': taxEnabled ? 1 : 0,
      'taxRate': taxRate,
      'lowStockThreshold': lowStockThreshold,
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'] as String? ?? defaultShopId,
      shopName: map['shopName'] as String? ?? 'My Store',
      phone: map['phone'] as String? ?? '0000000000',
      address: map['address'] as String? ?? '',
      email: map['email'] as String? ?? '',
      branchName: map['branchName'] as String? ?? '',
      currencyCode: map['currencyCode'] as String? ?? 'GHS',
      currencySymbol: map['currencySymbol'] as String? ?? 'GHS',
      receiptFooter:
          map['receiptFooter'] as String? ?? 'Thank you for shopping with us.',
      taxEnabled: _boolFromDatabase(map['taxEnabled']),
      taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0,
      lowStockThreshold: (map['lowStockThreshold'] as num?)?.toInt() ?? 5,
      createdByUserId: map['createdByUserId'] as String? ?? 'system',
      createdAt: _dateTimeOrNow(map['createdAt']),
      updatedAt: _dateTimeOrNull(map['updatedAt']),
    );
  }

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
}

bool _boolFromDatabase(Object? value, {bool defaultValue = false}) {
  if (value == null) {
    return defaultValue;
  }
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    return value == '1' || value.toLowerCase() == 'true';
  }
  return defaultValue;
}

DateTime _dateTimeOrNow(Object? value) {
  return _dateTimeOrNull(value) ?? DateTime.now();
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
