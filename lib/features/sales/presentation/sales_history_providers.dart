import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/sale.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/sale_repository.dart';

final salesSearchQueryProvider = StateProvider<String>((ref) => '');

final salesDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final salesProvider = StreamProvider<List<Sale>>((ref) {
  return ref.watch(saleRepositoryProvider).watchSales();
});

final filteredSalesProvider = Provider<AsyncValue<List<Sale>>>((ref) {
  final sales = ref.watch(salesProvider);
  final query = ref.watch(salesSearchQueryProvider).trim().toLowerCase();
  final range = ref.watch(salesDateRangeProvider);
  final user = ref.watch(authControllerProvider).currentUser;

  return sales.whenData((items) {
    return items.where((sale) {
      final matchesUser =
          user == null || !user.isCashier || sale.cashierId == user.id;
      final matchesReceipt =
          query.isEmpty || sale.receiptNumber.toLowerCase().contains(query);
      final matchesDate =
          range == null || _isWithinRange(sale.createdAt, range);
      return matchesUser && matchesReceipt && matchesDate;
    }).toList();
  });
});

final selectedPeriodSalesTotalProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(filteredSalesProvider).whenData((sales) {
    return sales.fold(0, (total, sale) => total + sale.grandTotal);
  });
});

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
