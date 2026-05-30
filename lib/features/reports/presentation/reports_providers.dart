import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/app_user.dart';
import '../../../shared/models/product.dart';
import '../../../shared/models/sale.dart';
import '../../auth/data/app_user_repository.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../products/presentation/product_providers.dart';
import '../../sales/presentation/sales_history_providers.dart';
import '../../settings/data/store_settings_providers.dart';

final reportsDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return DateTimeRange(start: today, end: today);
});

final appUsersProvider = StreamProvider<List<AppUser>>((ref) {
  final shopId = ref.watch(
    authControllerProvider.select((state) => state.currentUser?.shopId),
  );

  if (shopId == null) {
    return Stream.value(const []);
  }

  return ref.watch(appUserRepositoryProvider).watchUsers(shopId: shopId);
});

final reportSalesProvider = Provider<AsyncValue<List<Sale>>>((ref) {
  final sales = ref.watch(salesProvider);
  final range = ref.watch(reportsDateRangeProvider);

  return sales.whenData((items) {
    return items
        .where((sale) => _isWithinRange(sale.createdAt, range))
        .toList();
  });
});

final reportsSummaryProvider = Provider<AsyncValue<ReportsSummary>>((ref) {
  final sales = ref.watch(reportSalesProvider);
  final products = ref.watch(productsProvider);
  final users = ref.watch(appUsersProvider);
  final settings = ref.watch(storeSettingsProvider);

  return sales.when(
    data: (saleItems) {
      return products.when(
        data: (productItems) {
          return users.when(
            data: (userItems) {
              return settings.when(
                data: (storeSettings) {
                  return AsyncData(
                    ReportsSummary.fromData(
                      sales: saleItems,
                      products: productItems,
                      users: userItems,
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
    },
    loading: () => const AsyncLoading(),
    error: (error, stackTrace) => AsyncError(error, stackTrace),
  );
});

class ReportsSummary {
  const ReportsSummary({
    required this.totalSalesAmount,
    required this.transactionCount,
    required this.salesByPaymentMethod,
    required this.topProducts,
    required this.lowStockProducts,
    required this.cashierPerformance,
  });

  final double totalSalesAmount;
  final int transactionCount;
  final List<PaymentMethodSummary> salesByPaymentMethod;
  final List<ProductSalesSummary> topProducts;
  final List<Product> lowStockProducts;
  final List<CashierPerformanceSummary> cashierPerformance;

  factory ReportsSummary.fromData({
    required List<Sale> sales,
    required List<Product> products,
    required List<AppUser> users,
    required int lowStockThreshold,
  }) {
    final paymentTotals = {
      for (final method in PaymentMethod.values) method: _PaymentAccumulator(),
    };
    final productTotals = <String, _ProductAccumulator>{};
    final cashierTotals = <String, _CashierAccumulator>{};
    final userNames = {for (final user in users) user.id: user.name};

    var totalSalesAmount = 0.0;
    for (final sale in sales) {
      totalSalesAmount += sale.grandTotal;
      paymentTotals[sale.paymentMethod]!.add(sale.grandTotal);
      cashierTotals
          .putIfAbsent(sale.cashierId, _CashierAccumulator.new)
          .add(sale.grandTotal);

      for (final item in sale.items) {
        productTotals
            .putIfAbsent(
              item.productId,
              () => _ProductAccumulator(name: item.productName),
            )
            .add(quantity: item.quantity, revenue: item.lineTotal);
      }
    }

    final topProducts =
        productTotals.entries
            .map(
              (entry) => ProductSalesSummary(
                productId: entry.key,
                productName: entry.value.name,
                quantitySold: entry.value.quantity,
                revenue: entry.value.revenue,
              ),
            )
            .toList()
          ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    final lowStockProducts =
        products
            .where(
              (product) =>
                  product.isActive && _isLowStock(product, lowStockThreshold),
            )
            .toList()
          ..sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));

    final cashierPerformance =
        cashierTotals.entries
            .map(
              (entry) => CashierPerformanceSummary(
                cashierId: entry.key,
                cashierName: userNames[entry.key] ?? entry.key,
                transactionCount: entry.value.transactionCount,
                totalSales: entry.value.totalSales,
              ),
            )
            .toList()
          ..sort((a, b) => b.totalSales.compareTo(a.totalSales));

    return ReportsSummary(
      totalSalesAmount: totalSalesAmount,
      transactionCount: sales.length,
      salesByPaymentMethod: [
        for (final entry in paymentTotals.entries)
          PaymentMethodSummary(
            paymentMethod: entry.key,
            transactionCount: entry.value.transactionCount,
            totalSales: entry.value.totalSales,
          ),
      ],
      topProducts: topProducts.take(5).toList(),
      lowStockProducts: lowStockProducts.take(8).toList(),
      cashierPerformance: cashierPerformance,
    );
  }

  static bool _isLowStock(Product product, int lowStockThreshold) {
    final threshold = product.reorderLevel > 0
        ? product.reorderLevel
        : lowStockThreshold;
    return product.stockQuantity < threshold;
  }
}

class PaymentMethodSummary {
  const PaymentMethodSummary({
    required this.paymentMethod,
    required this.transactionCount,
    required this.totalSales,
  });

  final PaymentMethod paymentMethod;
  final int transactionCount;
  final double totalSales;
}

class ProductSalesSummary {
  const ProductSalesSummary({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });

  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;
}

class CashierPerformanceSummary {
  const CashierPerformanceSummary({
    required this.cashierId,
    required this.cashierName,
    required this.transactionCount,
    required this.totalSales,
  });

  final String cashierId;
  final String cashierName;
  final int transactionCount;
  final double totalSales;
}

class _PaymentAccumulator {
  var transactionCount = 0;
  var totalSales = 0.0;

  void add(double amount) {
    transactionCount++;
    totalSales += amount;
  }
}

class _ProductAccumulator {
  _ProductAccumulator({required this.name});

  final String name;
  var quantity = 0;
  var revenue = 0.0;

  void add({required int quantity, required double revenue}) {
    this.quantity += quantity;
    this.revenue += revenue;
  }
}

class _CashierAccumulator {
  var transactionCount = 0;
  var totalSales = 0.0;

  void add(double amount) {
    transactionCount++;
    totalSales += amount;
  }
}

bool _isWithinRange(DateTime date, DateTimeRange range) {
  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final end = DateTime(
    range.end.year,
    range.end.month,
    range.end.day,
    23,
    59,
    59,
    999,
  );

  return !date.isBefore(start) && !date.isAfter(end);
}
