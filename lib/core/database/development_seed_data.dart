import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'app_database.dart';

class DevelopmentSeedData {
  const DevelopmentSeedData._();

  static Future<void> seedIfNeeded(AppDatabase database) async {
    if (!kDebugMode) {
      return;
    }

    final existingProducts = await database.select(database.products).get();
    if (existingProducts.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    await database
        .into(database.shops)
        .insertOnConflictUpdate(
          ShopsCompanion(
            id: const Value('default-shop'),
            shopName: const Value('My Store'),
            phone: const Value('0000000000'),
            address: const Value(''),
            email: const Value(''),
            branchName: const Value(''),
            currencyCode: const Value('GHS'),
            currencySymbol: const Value('GHS'),
            receiptFooter: const Value('Thank you for shopping with us.'),
            taxEnabled: const Value(false),
            taxRate: const Value(0),
            lowStockThreshold: const Value(5),
            createdByUserId: const Value('system'),
            createdAt: Value(now),
          ),
        );
    await database.batch((batch) {
      batch.insertAll(database.products, _products(now));
    });
  }

  static List<ProductsCompanion> _products(DateTime now) {
    return [
      _product(
        id: 'seed-kuura-shampoo',
        name: 'Kuura Shampoo',
        sku: 'KUR-SHAM-300',
        price: 24.99,
        stockQuantity: 42,
        reorderLevel: 10,
        now: now,
      ),
      _product(
        id: 'seed-kuura-conditioner',
        name: 'Kuura Conditioner',
        sku: 'KUR-COND-300',
        price: 25.99,
        stockQuantity: 38,
        reorderLevel: 10,
        now: now,
      ),
      _product(
        id: 'seed-kuura-leave-in-conditioner',
        name: 'Kuura Leave-In Conditioner',
        sku: 'KUR-LVIN-200',
        price: 29.99,
        stockQuantity: 24,
        reorderLevel: 8,
        now: now,
      ),
      _product(
        id: 'seed-kuura-no-breakage-treatment',
        name: 'Kuura No Breakage Treatment',
        sku: 'KUR-NBRK-150',
        price: 34.99,
        stockQuantity: 18,
        reorderLevel: 6,
        now: now,
      ),
      _product(
        id: 'seed-kuura-styling-mousse',
        name: 'Kuura Styling Mousse',
        sku: 'KUR-MOUS-220',
        price: 21.99,
        stockQuantity: 31,
        reorderLevel: 8,
        now: now,
      ),
      _product(
        id: 'seed-bbl-straightener',
        name: 'BBL Straightener',
        sku: 'BBL-STR-001',
        price: 129.99,
        stockQuantity: 9,
        reorderLevel: 3,
        now: now,
      ),
      _product(
        id: 'seed-bbl-hot-comb',
        name: 'BBL Hot Comb',
        sku: 'BBL-HCOMB-001',
        price: 79.99,
        stockQuantity: 12,
        reorderLevel: 4,
        now: now,
      ),
      _product(
        id: 'seed-bbl-curler',
        name: 'BBL Curler',
        sku: 'BBL-CURL-125',
        price: 89.99,
        stockQuantity: 14,
        reorderLevel: 4,
        now: now,
      ),
      _product(
        id: 'seed-bbl-heat-protectant',
        name: 'BBL Heat Protectant',
        sku: 'BBL-HPRO-180',
        price: 19.99,
        stockQuantity: 36,
        reorderLevel: 12,
        now: now,
      ),
      _product(
        id: 'seed-bbl-wax-stick',
        name: 'BBL Wax Stick',
        sku: 'BBL-WAX-075',
        price: 14.99,
        stockQuantity: 28,
        reorderLevel: 10,
        now: now,
      ),
    ];
  }

  static ProductsCompanion _product({
    required String id,
    required String name,
    required String sku,
    required double price,
    required int stockQuantity,
    required int reorderLevel,
    required DateTime now,
  }) {
    return ProductsCompanion(
      id: Value(id),
      shopId: const Value('default-shop'),
      name: Value(name),
      sku: Value(sku),
      price: Value(price),
      stockQuantity: Value(stockQuantity),
      reorderLevel: Value(reorderLevel),
      isActive: const Value(true),
      createdAt: Value(now),
    );
  }
}
