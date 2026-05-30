import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/database/database_provider.dart';
import '../../../shared/models/shop.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(ref.watch(appDatabaseProvider));
});

class ShopRepository {
  const ShopRepository(this._database);

  final db.AppDatabase _database;

  Stream<Shop?> watchShop(String id) {
    return (_database.select(_database.shops)
          ..where((table) => table.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _fromRow(row));
  }

  Future<Shop?> getShopById(String id) async {
    final row = await (_database.select(
      _database.shops,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<void> upsertShop(Shop shop) async {
    final errors = shop.validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }

    await _database
        .into(_database.shops)
        .insertOnConflictUpdate(_toCompanion(shop));
  }

  Future<void> ensureDefaultShop() async {
    final existing = await getShopById(Shop.defaultShopId);
    if (existing != null) {
      return;
    }

    await upsertShop(Shop.defaultShop());
  }

  Shop _fromRow(db.Shop row) {
    return Shop(
      id: row.id,
      shopName: row.shopName,
      phone: row.phone,
      address: row.address,
      email: row.email,
      branchName: row.branchName,
      currencyCode: row.currencyCode,
      currencySymbol: row.currencySymbol,
      receiptFooter: row.receiptFooter,
      taxEnabled: row.taxEnabled,
      taxRate: row.taxRate,
      lowStockThreshold: row.lowStockThreshold,
      createdByUserId: row.createdByUserId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  db.ShopsCompanion _toCompanion(Shop shop) {
    return db.ShopsCompanion(
      id: Value(shop.id),
      shopName: Value(shop.shopName),
      phone: Value(shop.phone),
      address: Value(shop.address),
      email: Value(shop.email),
      branchName: Value(shop.branchName),
      currencyCode: Value(shop.currencyCode),
      currencySymbol: Value(shop.currencySymbol),
      receiptFooter: Value(shop.receiptFooter),
      taxEnabled: Value(shop.taxEnabled),
      taxRate: Value(shop.taxRate),
      lowStockThreshold: Value(shop.lowStockThreshold),
      createdByUserId: Value(shop.createdByUserId),
      createdAt: Value(shop.createdAt),
      updatedAt: Value(shop.updatedAt),
    );
  }
}
