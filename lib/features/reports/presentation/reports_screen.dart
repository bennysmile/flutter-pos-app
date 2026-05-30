import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/store_settings.dart';
import '../../settings/data/store_settings_providers.dart';
import 'reports_providers.dart';
import 'widgets/cashier_performance_report_card.dart';
import 'widgets/low_stock_report_card.dart';
import 'widgets/payment_method_report_card.dart';
import 'widgets/report_date_filter.dart';
import 'widgets/report_metric_grid.dart';
import 'widgets/top_products_report_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(reportsSummaryProvider);
    final settings = ref
        .watch(storeSettingsProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: StoreSettings.defaultSettings,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SafeArea(
        child: summary.when(
          data: (data) => _ReportsDashboard(summary: data, settings: settings),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ReportsError(message: error.toString()),
        ),
      ),
    );
  }
}

class _ReportsDashboard extends StatelessWidget {
  const _ReportsDashboard({required this.summary, required this.settings});

  final ReportsSummary summary;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          settings.storeName,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        if (settings.branchName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            settings.branchName,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ],
        const SizedBox(height: 16),
        const ReportDateFilter(),
        const SizedBox(height: 16),
        ReportMetricGrid(summary: summary),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final leftColumn = Column(
              children: [
                PaymentMethodReportCard(items: summary.salesByPaymentMethod),
                const SizedBox(height: 16),
                TopProductsReportCard(products: summary.topProducts),
              ],
            );
            final rightColumn = Column(
              children: [
                LowStockReportCard(products: summary.lowStockProducts),
                const SizedBox(height: 16),
                CashierPerformanceReportCard(
                  cashiers: summary.cashierPerformance,
                ),
              ],
            );

            if (!wide) {
              return Column(
                children: [leftColumn, const SizedBox(height: 16), rightColumn],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: leftColumn),
                const SizedBox(width: 16),
                Expanded(child: rightColumn),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ReportsError extends StatelessWidget {
  const _ReportsError({required this.message});

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
