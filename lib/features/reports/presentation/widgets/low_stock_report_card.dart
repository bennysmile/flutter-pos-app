import 'package:flutter/material.dart';

import '../../../../shared/models/product.dart';
import 'report_section_card.dart';

class LowStockReportCard extends StatelessWidget {
  const LowStockReportCard({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      title: 'Low-Stock Products',
      icon: Icons.warning_amber_outlined,
      child: products.isEmpty
          ? const Text('No low-stock products.')
          : Column(
              children: [
                for (final product in products)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          '${product.stockQuantity} left',
                          style: const TextStyle(color: Color(0xFFC2410C)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
