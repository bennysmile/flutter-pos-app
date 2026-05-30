class StoreSettings {
  const StoreSettings({
    required this.id,
    required this.shopId,
    required this.storeName,
    required this.address,
    required this.phone,
    required this.email,
    required this.taxId,
    required this.receiptFooter,
    required this.currencyCode,
    required this.currencySymbol,
    required this.taxEnabled,
    required this.taxRate,
    required this.lowStockThreshold,
    required this.branchName,
    required this.logoPath,
    required this.cashEnabled,
    required this.mobileMoneyEnabled,
    required this.bankTransferEnabled,
    required this.cardEnabled,
    required this.createdAt,
    this.updatedAt,
  });

  static const defaultId = 'store-settings';

  static String idForShop(String shopId) => 'settings-$shopId';

  final String id;
  final String shopId;
  final String storeName;
  final String address;
  final String phone;
  final String email;
  final String taxId;
  final String receiptFooter;
  final String currencyCode;
  final String currencySymbol;
  final bool taxEnabled;
  final double taxRate;
  final int lowStockThreshold;
  final String branchName;
  final String? logoPath;
  final bool cashEnabled;
  final bool mobileMoneyEnabled;
  final bool bankTransferEnabled;
  final bool cardEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory StoreSettings.defaultSettings({String shopId = 'default-shop'}) {
    final now = DateTime.now();
    return StoreSettings(
      id: idForShop(shopId),
      shopId: shopId,
      storeName: 'My Store',
      address: '',
      phone: shopId == 'default-shop' ? '0000000000' : '',
      email: '',
      taxId: '',
      receiptFooter: 'Thank you for shopping with us.',
      currencyCode: 'GHS',
      currencySymbol: 'GHS',
      taxEnabled: false,
      taxRate: 0,
      lowStockThreshold: 5,
      branchName: '',
      logoPath: null,
      cashEnabled: true,
      mobileMoneyEnabled: true,
      bankTransferEnabled: true,
      cardEnabled: true,
      createdAt: now,
    );
  }

  bool get isValid => validate().isEmpty;

  List<String> validate() {
    final errors = <String>[];

    if (storeName.trim().isEmpty) {
      errors.add('Store name is required.');
    }
    if (shopId.trim().isEmpty) {
      errors.add('Store shop id is required.');
    }
    if (phone.trim().isEmpty) {
      errors.add('Phone number is required.');
    }
    if (email.trim().isNotEmpty && !_emailPattern.hasMatch(email.trim())) {
      errors.add('Email is invalid.');
    }
    if (taxRate < 0) {
      errors.add('Tax rate must be 0 or greater.');
    }
    if (lowStockThreshold < 0) {
      errors.add('Low stock threshold must be 0 or greater.');
    }
    if (currencyCode != 'GHS') {
      errors.add('Currency must remain GHS.');
    }

    return errors;
  }

  StoreSettings copyWith({
    String? id,
    String? shopId,
    String? storeName,
    String? address,
    String? phone,
    String? email,
    String? taxId,
    String? receiptFooter,
    String? currencyCode,
    String? currencySymbol,
    bool? taxEnabled,
    double? taxRate,
    int? lowStockThreshold,
    String? branchName,
    String? logoPath,
    bool? cashEnabled,
    bool? mobileMoneyEnabled,
    bool? bankTransferEnabled,
    bool? cardEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreSettings(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      taxId: taxId ?? this.taxId,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      taxEnabled: taxEnabled ?? this.taxEnabled,
      taxRate: taxRate ?? this.taxRate,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      branchName: branchName ?? this.branchName,
      logoPath: logoPath ?? this.logoPath,
      cashEnabled: cashEnabled ?? this.cashEnabled,
      mobileMoneyEnabled: mobileMoneyEnabled ?? this.mobileMoneyEnabled,
      bankTransferEnabled: bankTransferEnabled ?? this.bankTransferEnabled,
      cardEnabled: cardEnabled ?? this.cardEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'storeName': storeName,
      'address': address,
      'phone': phone,
      'email': email,
      'taxId': taxId,
      'receiptFooter': receiptFooter,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'taxEnabled': taxEnabled ? 1 : 0,
      'taxRate': taxRate,
      'lowStockThreshold': lowStockThreshold,
      'branchName': branchName,
      'logoPath': logoPath,
      'cashEnabled': cashEnabled ? 1 : 0,
      'mobileMoneyEnabled': mobileMoneyEnabled ? 1 : 0,
      'bankTransferEnabled': bankTransferEnabled ? 1 : 0,
      'cardEnabled': cardEnabled ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory StoreSettings.fromMap(Map<String, dynamic> map) {
    return StoreSettings(
      id: map['id'] as String? ?? defaultId,
      shopId: map['shopId'] as String? ?? 'default-shop',
      storeName: map['storeName'] as String? ?? 'My Store',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      taxId: map['taxId'] as String? ?? '',
      receiptFooter:
          map['receiptFooter'] as String? ?? 'Thank you for shopping with us.',
      currencyCode: map['currencyCode'] as String? ?? 'GHS',
      currencySymbol: map['currencySymbol'] as String? ?? 'GHS',
      taxEnabled: _boolFromDatabase(map['taxEnabled']),
      taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0,
      lowStockThreshold: (map['lowStockThreshold'] as num?)?.toInt() ?? 5,
      branchName: map['branchName'] as String? ?? '',
      logoPath: map['logoPath'] as String?,
      cashEnabled: _boolFromDatabase(map['cashEnabled'], defaultValue: true),
      mobileMoneyEnabled: _boolFromDatabase(
        map['mobileMoneyEnabled'],
        defaultValue: true,
      ),
      bankTransferEnabled: _boolFromDatabase(
        map['bankTransferEnabled'],
        defaultValue: true,
      ),
      cardEnabled: _boolFromDatabase(map['cardEnabled'], defaultValue: true),
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
