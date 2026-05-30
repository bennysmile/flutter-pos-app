import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../pos_cart_controller.dart';

class PosCartPanel extends StatelessWidget {
  const PosCartPanel({
    super.key,
    required this.cart,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final PosCartState cart;
  final ValueChanged<String> onIncrease;
  final ValueChanged<String> onDecrease;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (cart.items.isEmpty) {
      return const Center(child: Text('Cart is empty'));
    }

    return ListView.separated(
      itemCount: cart.items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return _CartItemTile(
          item: item,
          onIncrease: () => onIncrease(item.product.id),
          onDecrease: () => onDecrease(item.product.id),
          onRemove: () => onRemove(item.product.id),
        );
      },
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final PosCartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppCurrency.format(item.product.price)} each',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Decrease quantity',
            onPressed: onDecrease,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 32,
            child: Text(
              item.quantity.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'Increase quantity',
            onPressed: item.canIncrease ? onIncrease : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
          SizedBox(
            width: 82,
            child: Text(
              AppCurrency.format(item.lineTotal),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'Remove item',
            onPressed: onRemove,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
