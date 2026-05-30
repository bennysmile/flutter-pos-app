import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../reports_providers.dart';
import 'report_section_card.dart';

class CashierPerformanceReportCard extends StatelessWidget {
  const CashierPerformanceReportCard({super.key, required this.cashiers});

  final List<CashierPerformanceSummary> cashiers;

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      title: 'Cashier Performance',
      icon: Icons.badge_outlined,
      child: cashiers.isEmpty
          ? const Text('No cashier activity in this period.')
          : Column(
              children: [
                for (final cashier in cashiers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cashier.cashierName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${cashier.transactionCount} transactions',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          AppCurrency.format(cashier.totalSales),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
