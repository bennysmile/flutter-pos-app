import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/sale.dart';

class SalesHistoryList extends StatelessWidget {
  const SalesHistoryList({
    super.key,
    required this.sales,
    required this.onOpenDetails,
  });

  final List<Sale> sales;
  final ValueChanged<Sale> onOpenDetails;

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return const _EmptySales();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: sales.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sale = sales[index];
        return _SaleTile(sale: sale, onOpenDetails: () => onOpenDetails(sale));
      },
    );
  }
}

class _SaleTile extends StatelessWidget {
  const _SaleTile({required this.sale, required this.onOpenDetails});

  final Sale sale;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().add_jm().format(sale.createdAt);

    return Card(
      child: ListTile(
        onTap: onOpenDetails,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          sale.receiptNumber,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('$date\n${sale.paymentMethod.label}'),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppCurrency.format(sale.grandTotal),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _EmptySales extends StatelessWidget {
  const _EmptySales();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No sales found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Complete a sale or adjust your filters.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
