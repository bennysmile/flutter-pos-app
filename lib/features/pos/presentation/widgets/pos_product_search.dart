import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/product.dart';
import '../../../products/presentation/product_providers.dart';
import '../../../products/presentation/widgets/product_image_thumbnail.dart';

class PosProductSearch extends ConsumerStatefulWidget {
  const PosProductSearch({super.key, required this.onProductSelected});

  final ValueChanged<Product> onProductSelected;

  @override
  ConsumerState<PosProductSearch> createState() => _PosProductSearchState();
}

class _PosProductSearchState extends ConsumerState<PosProductSearch> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: 'Search products by name or SKU',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: products.when(
            data: _buildProducts,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
          ),
        ),
      ],
    );
  }

  Widget _buildProducts(List<Product> products) {
    final filtered = products.where((product) {
      if (!product.isActive) {
        return false;
      }
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }
      final sku = product.sku?.toLowerCase() ?? '';
      return product.name.toLowerCase().contains(query) || sku.contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No matching products'));
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _ProductTile(
          product: filtered[index],
          onTap: () => widget.onProductSelected(filtered[index]),
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stockQuantity <= 0;

    return Card(
      child: ListTile(
        enabled: !outOfStock,
        onTap: outOfStock ? null : onTap,
        leading: ProductImageThumbnail(imagePath: product.imagePath),
        title: Text(product.name),
        subtitle: Text(
          '${product.sku ?? 'No SKU'} - ${product.stockQuantity} available',
        ),
        trailing: Text(
          AppCurrency.format(product.price),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
