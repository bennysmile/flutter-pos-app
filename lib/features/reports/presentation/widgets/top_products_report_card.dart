import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../reports_providers.dart';
import 'report_section_card.dart';

class TopProductsReportCard extends StatelessWidget {
  const TopProductsReportCard({super.key, required this.products});

  final List<ProductSalesSummary> products;

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      title: 'Top-Selling Products',
      icon: Icons.local_fire_department_outlined,
      child: products.isEmpty
          ? const Text('No product sales in this period.')
          : Column(
              children: [
                for (final product in products)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.productName,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text('${product.quantitySold} sold'),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 92,
                          child: Text(
                            AppCurrency.format(product.revenue),
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
