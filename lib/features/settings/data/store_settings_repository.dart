import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/database/database_provider.dart';
import '../../../shared/models/shop.dart';
import '../../../shared/models/store_settings.dart';

final storeSettingsRepositoryProvider = Provider<StoreSettingsRepository>((
  ref,
) {
  return StoreSettingsRepository(ref.watch(appDatabaseProvider));
});

class StoreSettingsRepository {
  const StoreSettingsRepository(this._database);

  final db.AppDatabase _database;

  Stream<StoreSettings> watchSettings(String shopId) {
    final query = _database.select(_database.storeSettingsTable)
      ..where((table) => table.shopId.equals(shopId))
      ..limit(1);

    return query.watch().map(
      (rows) => rows.isEmpty
          ? StoreSettings.defaultSettings(shopId: shopId)
          : _fromRow(rows.first),
    );
  }

  Future<StoreSettings> getSettings([
    String shopId = Shop.defaultShopId,
  ]) async {
    final rows =
        await (_database.select(_database.storeSettingsTable)
              ..where((table) => table.shopId.equals(shopId))
              ..limit(1))
            .get();
    return rows.isEmpty
        ? StoreSettings.defaultSettings(shopId: shopId)
        : _fromRow(rows.first);
  }

  Future<void> saveSettings(StoreSettings settings) async {
    final normalized = settings.copyWith(
      id: settings.id.trim().isEmpty
          ? StoreSettings.idForShop(settings.shopId)
          : settings.id,
      currencyCode: 'GHS',
      currencySymbol: 'GHS',
      updatedAt: DateTime.now(),
    );
    final errors = normalized.validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }

    await _database
        .into(_database.storeSettingsTable)
        .insertOnConflictUpdate(_toCompanion(normalized));
    await (_database.update(
      _database.shops,
    )..where((table) => table.id.equals(normalized.shopId))).write(
      db.ShopsCompanion(
        shopName: Value(normalized.storeName),
        phone: Value(normalized.phone),
        address: Value(normalized.address),
        email: Value(normalized.email),
        branchName: Value(normalized.branchName),
        currencyCode: const Value('GHS'),
        currencySymbol: const Value('GHS'),
        receiptFooter: Value(normalized.receiptFooter),
        taxEnabled: Value(normalized.taxEnabled),
        taxRate: Value(normalized.taxRate),
        lowStockThreshold: Value(normalized.lowStockThreshold),
        updatedAt: Value(normalized.updatedAt),
      ),
    );
  }

  StoreSettings _fromRow(db.StoreSettingsTableData row) {
    return StoreSettings(
      id: row.id,
      shopId: row.shopId,
      storeName: row.storeName,
      address: row.address,
      phone: row.phone,
      email: row.email,
      taxId: row.taxId,
      receiptFooter: row.receiptFooter,
      currencyCode: row.currencyCode,
      currencySymbol: row.currencySymbol,
      taxEnabled: row.taxEnabled,
      taxRate: row.taxRate,
      lowStockThreshold: row.lowStockThreshold,
      branchName: row.branchName,
      logoPath: row.logoPath,
      cashEnabled: row.cashEnabled,
      mobileMoneyEnabled: row.mobileMoneyEnabled,
      bankTransferEnabled: row.bankTransferEnabled,
      cardEnabled: row.cardEnabled,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  db.StoreSettingsTableCompanion _toCompanion(StoreSettings settings) {
    return db.StoreSettingsTableCompanion(
      id: Value(settings.id),
      shopId: Value(settings.shopId),
      storeName: Value(settings.storeName),
      address: Value(settings.address),
      phone: Value(settings.phone),
      email: Value(settings.email),
      taxId: Value(settings.taxId),
      receiptFooter: Value(settings.receiptFooter),
      currencyCode: Value(settings.currencyCode),
      currencySymbol: Value(settings.currencySymbol),
      taxEnabled: Value(settings.taxEnabled),
      taxRate: Value(settings.taxRate),
      lowStockThreshold: Value(settings.lowStockThreshold),
      branchName: Value(settings.branchName),
      logoPath: Value(settings.logoPath),
      cashEnabled: Value(settings.cashEnabled),
      mobileMoneyEnabled: Value(settings.mobileMoneyEnabled),
      bankTransferEnabled: Value(settings.bankTransferEnabled),
      cardEnabled: Value(settings.cardEnabled),
      createdAt: Value(settings.createdAt),
      updatedAt: Value(settings.updatedAt),
    );
  }
}
