import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/product.dart';
import '../data/product_repository.dart';
import 'product_providers.dart';
import 'widgets/product_form_sheet.dart';
import 'widgets/product_list.dart';
import 'widgets/product_search_field.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            tooltip: 'Add product',
            onPressed: () => _openProductForm(context, ref),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProductForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Product'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: ProductSearchField(),
            ),
            Expanded(
              child: products.when(
                data: (items) {
                  return ProductList(
                    products: items,
                    onEdit: (product) =>
                        _openProductForm(context, ref, product: product),
                    onDelete: (product) =>
                        _confirmDelete(context, ref, product),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ProductsError(message: error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openProductForm(
    BuildContext context,
    WidgetRef ref, {
    Product? product,
  }) async {
    final repository = ref.read(productRepositoryProvider);
    final savedProduct = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ProductFormSheet(
        product: product,
        shopId: product?.shopId ?? repository.shopId,
      ),
    );

    if (savedProduct == null || !context.mounted) {
      return;
    }

    try {
      if (product == null) {
        await repository.createProduct(savedProduct);
      } else {
        await repository.updateProduct(savedProduct);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(product == null ? 'Product added' : 'Product saved'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete product?'),
          content: Text('This will remove ${product.name} from the catalog.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    await ref.read(productRepositoryProvider).deleteProduct(product.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product deleted')));
    }
  }
}

class _ProductsError extends StatelessWidget {
  const _ProductsError({required this.message});

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
