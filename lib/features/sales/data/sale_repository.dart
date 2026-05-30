import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/database/database_provider.dart';
import '../../../shared/models/sale.dart';
import '../../../shared/models/sale_item.dart';
import '../../../shared/models/shop.dart';
import '../../auth/presentation/auth_controller.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  final shopId =
      ref.watch(
        authControllerProvider.select((state) => state.currentUser?.shopId),
      ) ??
      Shop.defaultShopId;
  return SaleRepository(ref.watch(appDatabaseProvider), shopId: shopId);
});

class SaleRepository {
  const SaleRepository(this._database, {required this.shopId});

  final db.AppDatabase _database;
  final String shopId;

  Future<void> completeSale(Sale sale) async {
    final scopedSale = _scopeSale(sale);
    _ensureValid(scopedSale);

    await _database.transaction(() async {
      for (final item in scopedSale.items) {
        final product =
            await (_database.select(_database.products)..where(
                  (table) =>
                      table.id.equals(item.productId) &
                      table.shopId.equals(shopId),
                ))
                .getSingleOrNull();

        if (product == null) {
          throw StateError('Product ${item.productName} no longer exists.');
        }
        if (product.stockQuantity < item.quantity) {
          throw StateError(
            'Only ${product.stockQuantity} units of ${product.name} are available.',
          );
        }

        await (_database.update(_database.products)..where(
              (table) =>
                  table.id.equals(item.productId) & table.shopId.equals(shopId),
            ))
            .write(
              db.ProductsCompanion(
                stockQuantity: Value(product.stockQuantity - item.quantity),
                updatedAt: Value(DateTime.now()),
              ),
            );
      }

      await _insertSaleWithItems(scopedSale);
    });
  }

  Future<void> createSale(Sale sale) async {
    final scopedSale = _scopeSale(sale);
    _ensureValid(scopedSale);

    await _database.transaction(() async {
      await _insertSaleWithItems(scopedSale);
    });
  }

  Future<List<Sale>> getSales() async {
    final rows =
        await (_database.select(_database.sales)
              ..where((table) => table.shopId.equals(shopId))
              ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
            .get();

    final sales = <Sale>[];
    for (final row in rows) {
      sales.add(await _saleWithItems(row));
    }
    return sales;
  }

  Future<Sale?> getSaleById(String id) async {
    final row =
        await (_database.select(_database.sales)..where(
              (table) => table.id.equals(id) & table.shopId.equals(shopId),
            ))
            .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _saleWithItems(row);
  }

  Stream<List<Sale>> watchSales() {
    final query = _database.select(_database.sales)
      ..where((table) => table.shopId.equals(shopId))
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);

    return query.watch().asyncMap((rows) async {
      final sales = <Sale>[];
      for (final row in rows) {
        sales.add(await _saleWithItems(row));
      }
      return sales;
    });
  }

  Future<Sale> _saleWithItems(db.Sale row) async {
    final itemRows =
        await (_database.select(_database.saleItems)..where(
              (table) =>
                  table.saleId.equals(row.id) & table.shopId.equals(shopId),
            ))
            .get();

    return Sale(
      id: row.id,
      shopId: row.shopId,
      receiptNumber: row.receiptNumber,
      cashierId: row.cashierId,
      customerId: row.customerId,
      status: SaleStatus.fromValue(row.status),
      paymentMethod: PaymentMethod.fromValue(row.paymentMethod),
      subtotal: row.subtotal,
      discountTotal: row.discountTotal,
      taxTotal: row.taxTotal,
      grandTotal: row.grandTotal,
      amountReceived: row.amountReceived == 0
          ? row.grandTotal
          : row.amountReceived,
      changeAmount: row.changeAmount,
      items: itemRows.map(_itemFromRow).toList(),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  SaleItem _itemFromRow(db.SaleItem row) {
    return SaleItem(
      id: row.id,
      shopId: row.shopId,
      saleId: row.saleId,
      productId: row.productId,
      productName: row.productName,
      quantity: row.quantity,
      unitPrice: row.unitPrice,
      discountAmount: row.discountAmount,
      taxAmount: row.taxAmount,
    );
  }

  db.SalesCompanion _saleToCompanion(Sale sale) {
    return db.SalesCompanion(
      id: Value(sale.id),
      shopId: Value(sale.shopId),
      receiptNumber: Value(sale.receiptNumber),
      cashierId: Value(sale.cashierId),
      customerId: Value(sale.customerId),
      status: Value(sale.status.name),
      paymentMethod: Value(sale.paymentMethod.name),
      subtotal: Value(sale.subtotal),
      discountTotal: Value(sale.discountTotal),
      taxTotal: Value(sale.taxTotal),
      grandTotal: Value(sale.grandTotal),
      amountReceived: Value(sale.amountReceived),
      changeAmount: Value(sale.changeAmount),
      createdAt: Value(sale.createdAt),
      updatedAt: Value(sale.updatedAt),
    );
  }

  db.SaleItemsCompanion _itemToCompanion(SaleItem item) {
    return db.SaleItemsCompanion(
      id: Value(item.id),
      shopId: Value(item.shopId),
      saleId: Value(item.saleId),
      productId: Value(item.productId),
      productName: Value(item.productName),
      quantity: Value(item.quantity),
      unitPrice: Value(item.unitPrice),
      discountAmount: Value(item.discountAmount),
      taxAmount: Value(item.taxAmount),
      lineTotal: Value(item.lineTotal),
    );
  }

  void _ensureValid(Sale sale) {
    final errors = sale.validate();
    if (sale.items.isEmpty) {
      errors.add('Sale must include at least one item.');
    }
    for (final item in sale.items) {
      if (item.saleId != sale.id) {
        errors.add('Sale item ${item.id} does not match sale ${sale.id}.');
      }
    }
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }
  }

  Future<void> _insertSaleWithItems(Sale sale) async {
    await _database.into(_database.sales).insert(_saleToCompanion(sale));
    await _database.batch((batch) {
      batch.insertAll(
        _database.saleItems,
        sale.items.map(_itemToCompanion).toList(),
      );
    });
    await _database
        .into(_database.payments)
        .insert(
          db.PaymentsCompanion(
            id: Value('${sale.id}-payment'),
            shopId: Value(sale.shopId),
            saleId: Value(sale.id),
            paymentMethod: Value(sale.paymentMethod.name),
            amount: Value(sale.grandTotal),
            amountReceived: Value(sale.amountReceived),
            changeAmount: Value(sale.changeAmount),
            createdAt: Value(sale.createdAt),
          ),
        );
  }

  Sale _scopeSale(Sale sale) {
    return sale.copyWith(
      shopId: shopId,
      items: [for (final item in sale.items) item.copyWith(shopId: shopId)],
    );
  }
}
