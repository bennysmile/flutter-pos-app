import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/database/database_provider.dart';
import '../../../shared/models/product.dart';
import '../../../shared/models/shop.dart';
import '../../auth/presentation/auth_controller.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final shopId =
      ref.watch(
        authControllerProvider.select((state) => state.currentUser?.shopId),
      ) ??
      Shop.defaultShopId;
  return ProductRepository(ref.watch(appDatabaseProvider), shopId: shopId);
});

class ProductRepository {
  const ProductRepository(this._database, {required this.shopId});

  final db.AppDatabase _database;
  final String shopId;

  Stream<List<Product>> watchProducts() {
    return (_database.select(_database.products)
          ..where((table) => table.shopId.equals(shopId))
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  Future<List<Product>> getProducts() async {
    final rows =
        await (_database.select(_database.products)
              ..where((table) => table.shopId.equals(shopId))
              ..orderBy([(table) => OrderingTerm.asc(table.name)]))
            .get();
    return rows.map(_fromRow).toList();
  }

  Future<Product?> getProductById(String id) async {
    final row =
        await (_database.select(_database.products)..where(
              (table) => table.id.equals(id) & table.shopId.equals(shopId),
            ))
            .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<void> createProduct(Product product) async {
    final scopedProduct = product.copyWith(shopId: shopId);
    _ensureValid(scopedProduct);
    await _database
        .into(_database.products)
        .insert(_toCompanion(scopedProduct), mode: InsertMode.insert);
  }

  Future<void> upsertProduct(Product product) async {
    final scopedProduct = product.copyWith(shopId: shopId);
    _ensureValid(scopedProduct);
    await _database
        .into(_database.products)
        .insertOnConflictUpdate(_toCompanion(scopedProduct));
  }

  Future<int> updateProduct(Product product) async {
    final scopedProduct = product.copyWith(shopId: shopId);
    _ensureValid(scopedProduct);
    return (_database.update(_database.products)..where(
          (table) => table.id.equals(product.id) & table.shopId.equals(shopId),
        ))
        .write(_toCompanion(scopedProduct));
  }

  Future<int> deleteProduct(String id) {
    return (_database.delete(_database.products)
          ..where((table) => table.id.equals(id) & table.shopId.equals(shopId)))
        .go();
  }

  Product _fromRow(db.Product row) {
    return Product(
      id: row.id,
      shopId: row.shopId,
      name: row.name,
      sku: row.sku,
      barcode: row.barcode,
      description: row.description,
      imagePath: row.imagePath,
      price: row.price,
      stockQuantity: row.stockQuantity,
      reorderLevel: row.reorderLevel,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  db.ProductsCompanion _toCompanion(Product product) {
    return db.ProductsCompanion(
      id: Value(product.id),
      shopId: Value(product.shopId),
      name: Value(product.name),
      sku: Value(product.sku),
      barcode: Value(product.barcode),
      description: Value(product.description),
      imagePath: Value(product.imagePath),
      price: Value(product.price),
      stockQuantity: Value(product.stockQuantity),
      reorderLevel: Value(product.reorderLevel),
      isActive: Value(product.isActive),
      createdAt: Value(product.createdAt),
      updatedAt: Value(product.updatedAt),
    );
  }

  void _ensureValid(Product product) {
    final errors = product.validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }
  }
}
