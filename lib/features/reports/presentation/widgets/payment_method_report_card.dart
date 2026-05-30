import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../reports_providers.dart';
import 'report_section_card.dart';

class PaymentMethodReportCard extends StatelessWidget {
  const PaymentMethodReportCard({super.key, required this.items});

  final List<PaymentMethodSummary> items;

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      title: 'Sales by Payment Method',
      icon: Icons.credit_card_outlined,
      child: Column(
        children: [
          for (final item in items)
            _ReportRow(
              label: item.paymentMethod.label,
              detail: '${item.transactionCount} transactions',
              value: AppCurrency.format(item.totalSales),
            ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.label,
    required this.detail,
    required this.value,
  });

  final String label;
  final String detail;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(detail, style: const TextStyle(color: Color(0xFF64748B))),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
