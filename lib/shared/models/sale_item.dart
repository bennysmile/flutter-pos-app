class SaleItem {
  const SaleItem({
    required this.id,
    required this.shopId,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discountAmount = 0,
    this.taxAmount = 0,
  });

  final String id;
  final String shopId;
  final String saleId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double discountAmount;
  final double taxAmount;

  double get grossTotal => quantity * unitPrice;
  double get lineTotal => grossTotal - discountAmount + taxAmount;
  bool get isValid => validate().isEmpty;

  List<String> validate() {
    final errors = <String>[];

    if (id.trim().isEmpty) {
      errors.add('Sale item id is required.');
    }
    if (shopId.trim().isEmpty) {
      errors.add('Sale item shop id is required.');
    }
    if (saleId.trim().isEmpty) {
      errors.add('Sale id is required.');
    }
    if (productId.trim().isEmpty) {
      errors.add('Product id is required.');
    }
    if (productName.trim().isEmpty) {
      errors.add('Product name is required.');
    }
    if (quantity <= 0) {
      errors.add('Quantity must be greater than zero.');
    }
    if (unitPrice < 0) {
      errors.add('Unit price cannot be negative.');
    }
    if (discountAmount < 0) {
      errors.add('Discount cannot be negative.');
    }
    if (taxAmount < 0) {
      errors.add('Tax cannot be negative.');
    }
    if (discountAmount > grossTotal) {
      errors.add('Discount cannot exceed item gross total.');
    }

    return errors;
  }

  SaleItem copyWith({
    String? id,
    String? shopId,
    String? saleId,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? discountAmount,
    double? taxAmount,
  }) {
    return SaleItem(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'saleId': saleId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'lineTotal': lineTotal,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'] as String,
      shopId: map['shopId'] as String? ?? 'default-shop',
      saleId: map['saleId'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      quantity: (map['quantity'] as num).toInt(),
      unitPrice: (map['unitPrice'] as num).toDouble(),
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0,
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}
