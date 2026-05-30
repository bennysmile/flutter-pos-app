import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/product.dart';
import '../data/product_repository.dart';

final productSearchQueryProvider = StateProvider<String>((ref) => '');

final productsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchProducts();
});

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productsProvider);
  final query = ref.watch(productSearchQueryProvider).trim().toLowerCase();

  return products.whenData((items) {
    if (query.isEmpty) {
      return items;
    }

    return items.where((product) {
      final sku = product.sku?.toLowerCase() ?? '';
      return product.name.toLowerCase().contains(query) || sku.contains(query);
    }).toList();
  });
});
