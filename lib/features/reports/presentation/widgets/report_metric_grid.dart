import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../reports_providers.dart';

class ReportMetricGrid extends StatelessWidget {
  const ReportMetricGrid({super.key, required this.summary});

  final ReportsSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricCard(
        title: 'Total Sales',
        value: AppCurrency.format(summary.totalSalesAmount),
        icon: Icons.payments_outlined,
      ),
      _MetricCard(
        title: 'Transactions',
        value: summary.transactionCount.toString(),
        icon: Icons.receipt_long_outlined,
      ),
      _MetricCard(
        title: 'Average Sale',
        value: AppCurrency.format(
          summary.transactionCount == 0
              ? 0
              : summary.totalSalesAmount / summary.transactionCount,
        ),
        icon: Icons.trending_up_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980 ? 3 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: columns == 1 ? 3.4 : 2.4,
          children: cards,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
