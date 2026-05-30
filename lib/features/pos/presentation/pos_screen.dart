import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../shared/models/product.dart';
import '../../../shared/models/sale.dart';
import '../../../shared/models/sale_item.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../sales/data/sale_repository.dart';
import 'pos_cart_controller.dart';
import 'widgets/checkout_summary.dart';
import 'widgets/pos_cart_panel.dart';
import 'widgets/pos_product_search.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _discountController = TextEditingController(text: '0');
  final _cashReceivedController = TextEditingController();
  var _isCompleting = false;

  @override
  void dispose() {
    _discountController.dispose();
    _cashReceivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(posCartProvider);
    final controller = ref.read(posCartProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('POS Checkout')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final productSearch = PosProductSearch(
              onProductSelected: _addProduct,
            );
            final checkout = _CheckoutColumn(
              cart: cart,
              discountController: _discountController,
              cashReceivedController: _cashReceivedController,
              isCompleting: _isCompleting,
              onIncrease: _increaseQuantity,
              onDecrease: controller.decreaseQuantity,
              onRemove: controller.removeItem,
              onDiscountChanged: controller.setDiscount,
              onCashReceivedChanged: controller.setCashReceived,
              onPaymentChanged: (method) {
                controller.setPaymentMethod(method);
                if (method != PaymentMethod.cash) {
                  _cashReceivedController.clear();
                }
              },
              onCompleteSale: _completeSale,
            );

            if (wide) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: productSearch),
                    const SizedBox(width: 24),
                    SizedBox(width: 460, child: checkout),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(child: productSearch),
                  const SizedBox(height: 16),
                  SizedBox(height: 470, child: checkout),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _addProduct(Product product) {
    final added = ref.read(posCartProvider.notifier).addProduct(product);
    if (!added) {
      _showMessage('No stock available for ${product.name}.');
    }
  }

  void _increaseQuantity(String productId) {
    final increased = ref
        .read(posCartProvider.notifier)
        .increaseQuantity(productId);
    if (!increased) {
      _showMessage('Cannot sell more than available stock.');
    }
  }

  Future<void> _completeSale() async {
    final cart = ref.read(posCartProvider);
    final user = ref.read(authControllerProvider).currentUser;
    if (!cart.canCheckout || _isCompleting) {
      if (cart.paymentMethod == PaymentMethod.cash) {
        _showMessage(
          cart.cashReceived == null
              ? 'Cash received is required.'
              : 'Cash received cannot be less than total amount.',
        );
      }
      return;
    }
    if (user == null) {
      _showMessage('Please sign in before completing a sale.');
      return;
    }

    setState(() => _isCompleting = true);

    final now = DateTime.now();
    final saleId = 'sale-${now.microsecondsSinceEpoch}';
    final shopId = user.shopId;
    final sale = Sale(
      id: saleId,
      shopId: shopId,
      receiptNumber: _receiptNumber(now),
      cashierId: user.id,
      status: SaleStatus.completed,
      paymentMethod: cart.paymentMethod,
      subtotal: cart.subtotal,
      discountTotal: cart.discountAmount,
      taxTotal: 0,
      grandTotal: cart.total,
      amountReceived: cart.amountReceived,
      changeAmount: cart.changeAmount,
      createdAt: now,
      items: [
        for (var index = 0; index < cart.items.length; index++)
          SaleItem(
            id: '$saleId-item-$index',
            shopId: shopId,
            saleId: saleId,
            productId: cart.items[index].product.id,
            productName: cart.items[index].product.name,
            quantity: cart.items[index].quantity,
            unitPrice: cart.items[index].product.price,
          ),
      ],
    );

    try {
      await ref.read(saleRepositoryProvider).completeSale(sale);
      ref.read(posCartProvider.notifier).clear();
      _discountController.text = '0';
      _cashReceivedController.clear();

      if (mounted) {
        context.go(AppRoutes.receiptPath(saleId));
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  String _receiptNumber(DateTime dateTime) {
    final timestamp = dateTime.millisecondsSinceEpoch.toString();
    return 'R-${timestamp.substring(timestamp.length - 8)}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CheckoutColumn extends StatelessWidget {
  const _CheckoutColumn({
    required this.cart,
    required this.discountController,
    required this.cashReceivedController,
    required this.isCompleting,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.onDiscountChanged,
    required this.onCashReceivedChanged,
    required this.onPaymentChanged,
    required this.onCompleteSale,
  });

  final PosCartState cart;
  final TextEditingController discountController;
  final TextEditingController cashReceivedController;
  final bool isCompleting;
  final ValueChanged<String> onIncrease;
  final ValueChanged<String> onDecrease;
  final ValueChanged<String> onRemove;
  final ValueChanged<double> onDiscountChanged;
  final ValueChanged<double?> onCashReceivedChanged;
  final ValueChanged<PaymentMethod> onPaymentChanged;
  final VoidCallback onCompleteSale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Cart',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PosCartPanel(
                cart: cart,
                onIncrease: onIncrease,
                onDecrease: onDecrease,
                onRemove: onRemove,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AbsorbPointer(
          absorbing: isCompleting,
          child: CheckoutSummary(
            cart: cart,
            discountController: discountController,
            cashReceivedController: cashReceivedController,
            onDiscountChanged: onDiscountChanged,
            onCashReceivedChanged: onCashReceivedChanged,
            onPaymentChanged: onPaymentChanged,
            onCompleteSale: onCompleteSale,
          ),
        ),
      ],
    );
  }
}
