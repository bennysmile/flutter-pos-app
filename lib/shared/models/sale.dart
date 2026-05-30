import 'sale_item.dart';

enum SaleStatus {
  completed,
  voided,
  refunded;

  static SaleStatus fromValue(String value) {
    return SaleStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => SaleStatus.completed,
    );
  }
}

enum PaymentMethod {
  cash,
  mobileMoney,
  bankTransfer,
  card;

  String get label {
    return switch (this) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.mobileMoney => 'Mobile Money',
      PaymentMethod.bankTransfer => 'Bank Transfer',
      PaymentMethod.card => 'Card',
    };
  }

  static PaymentMethod fromValue(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

class Sale {
  const Sale({
    required this.id,
    required this.shopId,
    required this.receiptNumber,
    required this.cashierId,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.grandTotal,
    required this.createdAt,
    this.amountReceived = 0,
    this.changeAmount = 0,
    this.customerId,
    this.items = const [],
    this.updatedAt,
  });

  final String id;
  final String shopId;
  final String receiptNumber;
  final String cashierId;
  final String? customerId;
  final SaleStatus status;
  final PaymentMethod paymentMethod;
  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;
  final double amountReceived;
  final double changeAmount;
  final List<SaleItem> items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isValid => validate().isEmpty;
  double get calculatedGrandTotal => subtotal - discountTotal + taxTotal;

  List<String> validate() {
    final errors = <String>[];

    if (id.trim().isEmpty) {
      errors.add('Sale id is required.');
    }
    if (shopId.trim().isEmpty) {
      errors.add('Sale shop id is required.');
    }
    if (receiptNumber.trim().isEmpty) {
      errors.add('Receipt number is required.');
    }
    if (cashierId.trim().isEmpty) {
      errors.add('Cashier id is required.');
    }
    if (subtotal < 0) {
      errors.add('Sale subtotal cannot be negative.');
    }
    if (discountTotal < 0) {
      errors.add('Sale discount cannot be negative.');
    }
    if (taxTotal < 0) {
      errors.add('Sale tax cannot be negative.');
    }
    if (grandTotal < 0) {
      errors.add('Sale total cannot be negative.');
    }
    if (amountReceived < 0) {
      errors.add('Amount received cannot be negative.');
    }
    if (changeAmount < 0) {
      errors.add('Change amount cannot be negative.');
    }
    if (paymentMethod == PaymentMethod.cash && amountReceived < grandTotal) {
      errors.add('Cash received cannot be less than total amount.');
    }
    if (discountTotal > subtotal) {
      errors.add('Sale discount cannot exceed subtotal.');
    }

    for (final item in items) {
      errors.addAll(item.validate());
    }

    return errors;
  }

  Sale copyWith({
    String? id,
    String? shopId,
    String? receiptNumber,
    String? cashierId,
    String? customerId,
    SaleStatus? status,
    PaymentMethod? paymentMethod,
    double? subtotal,
    double? discountTotal,
    double? taxTotal,
    double? grandTotal,
    double? amountReceived,
    double? changeAmount,
    List<SaleItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sale(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      cashierId: cashierId ?? this.cashierId,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      discountTotal: discountTotal ?? this.discountTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      amountReceived: amountReceived ?? this.amountReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'receiptNumber': receiptNumber,
      'cashierId': cashierId,
      'customerId': customerId,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'subtotal': subtotal,
      'discountTotal': discountTotal,
      'taxTotal': taxTotal,
      'grandTotal': grandTotal,
      'amountReceived': amountReceived,
      'changeAmount': changeAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as String,
      shopId: map['shopId'] as String? ?? 'default-shop',
      receiptNumber: map['receiptNumber'] as String,
      cashierId: map['cashierId'] as String,
      customerId: map['customerId'] as String?,
      status: SaleStatus.fromValue(
        map['status'] as String? ?? SaleStatus.completed.name,
      ),
      paymentMethod: PaymentMethod.fromValue(
        map['paymentMethod'] as String? ?? PaymentMethod.cash.name,
      ),
      subtotal: (map['subtotal'] as num).toDouble(),
      discountTotal: (map['discountTotal'] as num?)?.toDouble() ?? 0,
      taxTotal: (map['taxTotal'] as num?)?.toDouble() ?? 0,
      grandTotal: (map['grandTotal'] as num).toDouble(),
      amountReceived:
          (map['amountReceived'] as num?)?.toDouble() ??
          (map['grandTotal'] as num).toDouble(),
      changeAmount: (map['changeAmount'] as num?)?.toDouble() ?? 0,
      items: _itemsFromMap(map['items']),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: _dateTimeOrNull(map['updatedAt']),
    );
  }

  static List<SaleItem> _itemsFromMap(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) => SaleItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();
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
