import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/product.dart';
import '../../../shared/models/sale.dart';
import '../../products/presentation/product_providers.dart';
import '../../sales/presentation/sales_history_providers.dart';
import '../../settings/data/store_settings_providers.dart';

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final sales = ref.watch(salesProvider);
  final products = ref.watch(productsProvider);
  final settings = ref.watch(storeSettingsProvider);

  return sales.when(
    data: (saleItems) {
      return products.when(
        data: (productItems) {
          return settings.when(
            data: (storeSettings) {
              return AsyncData(
                DashboardSummary.fromData(
                  sales: saleItems,
                  products: productItems,
                  now: DateTime.now(),
                  lowStockThreshold: storeSettings.lowStockThreshold,
                ),
              );
            },
            loading: () => const AsyncLoading(),
            error: (error, stackTrace) => AsyncError(error, stackTrace),
          );
        },
        loading: () => const AsyncLoading(),
        error: (error, stackTrace) => AsyncError(error, stackTrace),
      );
    },
    loading: () => const AsyncLoading(),
    error: (error, stackTrace) => AsyncError(error, stackTrace),
  );
});

class DashboardSummary {
  const DashboardSummary({
    required this.totalSalesToday,
    required this.transactionsToday,
    required this.totalStockValue,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.cashSalesToday,
    required this.mobileMoneySalesToday,
    required this.bankTransferSalesToday,
    required this.topProductsToday,
  });

  final double totalSalesToday;
  final int transactionsToday;
  final double totalStockValue;
  final int totalProducts;
  final int lowStockProducts;
  final double cashSalesToday;
  final double mobileMoneySalesToday;
  final double bankTransferSalesToday;
  final List<DashboardTopProduct> topProductsToday;

  factory DashboardSummary.fromData({
    required List<Sale> sales,
    required List<Product> products,
    required DateTime now,
    required int lowStockThreshold,
  }) {
    final todaySales = sales.where((sale) => _isSameDay(sale.createdAt, now));
    final productTotals = <String, _ProductAccumulator>{};

    var totalSalesToday = 0.0;
    var cashSalesToday = 0.0;
    var mobileMoneySalesToday = 0.0;
    var bankTransferSalesToday = 0.0;
    var transactionsToday = 0;

    for (final sale in todaySales) {
      transactionsToday++;
      totalSalesToday += sale.grandTotal;

      switch (sale.paymentMethod) {
        case PaymentMethod.cash:
          cashSalesToday += sale.grandTotal;
        case PaymentMethod.mobileMoney:
          mobileMoneySalesToday += sale.grandTotal;
        case PaymentMethod.bankTransfer:
          bankTransferSalesToday += sale.grandTotal;
        case PaymentMethod.card:
          break;
      }

      for (final item in sale.items) {
        productTotals
            .putIfAbsent(
              item.productId,
              () => _ProductAccumulator(name: item.productName),
            )
            .add(item.quantity, item.lineTotal);
      }
    }

    final activeProducts = products.where((product) => product.isActive);
    final topProducts =
        productTotals.entries
            .map(
              (entry) => DashboardTopProduct(
                name: entry.value.name,
                quantitySold: entry.value.quantity,
                revenue: entry.value.revenue,
              ),
            )
            .toList()
          ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    return DashboardSummary(
      totalSalesToday: totalSalesToday,
      transactionsToday: transactionsToday,
      totalStockValue: activeProducts.fold(
        0,
        (total, product) => total + (product.price * product.stockQuantity),
      ),
      totalProducts: activeProducts.length,
      lowStockProducts: activeProducts
          .where((product) => _isLowStock(product, lowStockThreshold))
          .length,
      cashSalesToday: cashSalesToday,
      mobileMoneySalesToday: mobileMoneySalesToday,
      bankTransferSalesToday: bankTransferSalesToday,
      topProductsToday: topProducts.take(5).toList(),
    );
  }

  static bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static bool _isLowStock(Product product, int lowStockThreshold) {
    final threshold = product.reorderLevel > 0
        ? product.reorderLevel
        : lowStockThreshold;
    return product.stockQuantity < threshold;
  }
}

class DashboardTopProduct {
  const DashboardTopProduct({
    required this.name,
    required this.quantitySold,
    required this.revenue,
  });

  final String name;
  final int quantitySold;
  final double revenue;
}

class _ProductAccumulator {
  _ProductAccumulator({required this.name});

  final String name;
  var quantity = 0;
  var revenue = 0.0;

  void add(int quantity, double revenue) {
    this.quantity += quantity;
    this.revenue += revenue;
  }
}
