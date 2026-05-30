import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../product_providers.dart';

class ProductSearchField extends ConsumerWidget {
  const ProductSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (value) {
        ref.read(productSearchQueryProvider.notifier).state = value;
      },
      decoration: const InputDecoration(
        hintText: 'Search by name or SKU',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
