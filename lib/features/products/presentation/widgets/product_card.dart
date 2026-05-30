import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/product.dart';
import 'product_image_thumbnail.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ProductImageThumbnail(imagePath: product.imagePath),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (product.isLowStock) const _LowStockBadge(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.sku?.isNotEmpty == true
                        ? 'SKU: ${product.sku}'
                        : 'No SKU',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _ProductValue(
                        icon: Icons.sell_outlined,
                        label: AppCurrency.format(product.price),
                      ),
                      _ProductValue(
                        icon: Icons.inventory_outlined,
                        label: '${product.stockQuantity} in stock',
                      ),
                      _ProductValue(
                        icon: Icons.flag_outlined,
                        label: 'Reorder at ${product.reorderLevel}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Edit product',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete product',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductValue extends StatelessWidget {
  const _ProductValue({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _LowStockBadge extends StatelessWidget {
  const _LowStockBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Low stock',
        style: TextStyle(color: Color(0xFFC2410C), fontWeight: FontWeight.w700),
      ),
    );
  }
}
