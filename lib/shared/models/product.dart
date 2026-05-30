class Product {
  const Product({
    required this.id,
    required this.shopId,
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.reorderLevel,
    required this.isActive,
    required this.createdAt,
    this.sku,
    this.barcode,
    this.description,
    this.imagePath,
    this.updatedAt,
  });

  final String id;
  final String shopId;
  final String name;
  final String? sku;
  final String? barcode;
  final String? description;
  final String? imagePath;
  final double price;
  final int stockQuantity;
  final int reorderLevel;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isInStock => stockQuantity > 0;
  bool get isLowStock => stockQuantity < reorderLevel;
  bool get isValid => validate().isEmpty;

  List<String> validate() {
    final errors = <String>[];

    if (id.trim().isEmpty) {
      errors.add('Product id is required.');
    }
    if (shopId.trim().isEmpty) {
      errors.add('Product shop id is required.');
    }
    if (name.trim().isEmpty) {
      errors.add('Product name is required.');
    }
    if (price < 0) {
      errors.add('Product price cannot be negative.');
    }
    if (stockQuantity < 0) {
      errors.add('Product stock cannot be negative.');
    }
    if (reorderLevel < 0) {
      errors.add('Product reorder level cannot be negative.');
    }

    return errors;
  }

  Product copyWith({
    String? id,
    String? shopId,
    String? name,
    String? sku,
    String? barcode,
    String? description,
    String? imagePath,
    double? price,
    int? stockQuantity,
    int? reorderLevel,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'description': description,
      'imagePath': imagePath,
      'price': price,
      'stockQuantity': stockQuantity,
      'reorderLevel': reorderLevel,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      shopId: map['shopId'] as String? ?? 'default-shop',
      name: map['name'] as String,
      sku: map['sku'] as String?,
      barcode: map['barcode'] as String?,
      description: map['description'] as String?,
      imagePath: map['imagePath'] as String?,
      price: (map['price'] as num).toDouble(),
      stockQuantity: (map['stockQuantity'] as num).toInt(),
      reorderLevel: (map['reorderLevel'] as num?)?.toInt() ?? 0,
      isActive: _boolFromDatabase(map['isActive']),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: _dateTimeOrNull(map['updatedAt']),
    );
  }
}

bool _boolFromDatabase(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    return value == '1' || value.toLowerCase() == 'true';
  }
  return false;
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
