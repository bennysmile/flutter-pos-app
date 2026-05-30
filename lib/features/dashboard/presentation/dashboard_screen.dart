import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_formatter.dart';
import 'dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: summary.when(
          data: (data) => _DashboardContent(summary: data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _DashboardError(message: error.toString()),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricCard(
        title: 'Today\'s sales',
        value: AppCurrency.format(summary.totalSalesToday),
        icon: Icons.payments_outlined,
      ),
      _MetricCard(
        title: 'Transactions today',
        value: summary.transactionsToday.toString(),
        icon: Icons.receipt_long_outlined,
      ),
      _MetricCard(
        title: 'Stock value',
        value: AppCurrency.format(summary.totalStockValue),
        icon: Icons.inventory_outlined,
      ),
      _MetricCard(
        title: 'Products',
        value: summary.totalProducts.toString(),
        icon: Icons.inventory_2_outlined,
      ),
      _MetricCard(
        title: 'Low stock',
        value: summary.lowStockProducts.toString(),
        icon: Icons.warning_amber_outlined,
      ),
      _MetricCard(
        title: 'Cash sales',
        value: AppCurrency.format(summary.cashSalesToday),
        icon: Icons.money_outlined,
      ),
      _MetricCard(
        title: 'Mobile money',
        value: AppCurrency.format(summary.mobileMoneySalesToday),
        icon: Icons.phone_android_outlined,
      ),
      _MetricCard(
        title: 'Bank transfer',
        value: AppCurrency.format(summary.bankTransferSalesToday),
        icon: Icons.account_balance_outlined,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Business overview',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Live summary from your local POS database.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1100
                ? 4
                : constraints.maxWidth >= 760
                ? 2
                : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 1 ? 3.6 : 2.2,
              children: metrics,
            );
          },
        ),
        const SizedBox(height: 24),
        _TopProductsPanel(products: summary.topProductsToday),
      ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
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

class _TopProductsPanel extends StatelessWidget {
  const _TopProductsPanel({required this.products});

  final List<DashboardTopProduct> products;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top-selling products today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            if (products.isEmpty)
              const Text('No product sales today.')
            else
              for (final product in products)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(child: Text(product.name)),
                      Text('${product.quantitySold} sold'),
                      const SizedBox(width: 16),
                      Text(
                        AppCurrency.format(product.revenue),
                        style: const TextStyle(fontWeight: FontWeight.w800),
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

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
