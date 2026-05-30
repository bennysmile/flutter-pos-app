import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/sale.dart';
import '../pos_cart_controller.dart';

class CheckoutSummary extends StatelessWidget {
  const CheckoutSummary({
    super.key,
    required this.cart,
    required this.discountController,
    required this.cashReceivedController,
    required this.onDiscountChanged,
    required this.onCashReceivedChanged,
    required this.onPaymentChanged,
    required this.onCompleteSale,
  });

  final PosCartState cart;
  final TextEditingController discountController;
  final TextEditingController cashReceivedController;
  final ValueChanged<double> onDiscountChanged;
  final ValueChanged<double?> onCashReceivedChanged;
  final ValueChanged<PaymentMethod> onPaymentChanged;
  final VoidCallback onCompleteSale;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _AmountRow(
              label: 'Subtotal',
              value: AppCurrency.format(cart.subtotal),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: discountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Discount',
                prefixIcon: Icon(Icons.discount_outlined),
              ),
              onChanged: (value) {
                onDiscountChanged(double.tryParse(value.trim()) ?? 0);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentMethod>(
              value: cart.paymentMethod,
              decoration: const InputDecoration(labelText: 'Payment method'),
              items: [
                for (final method in PaymentMethod.values)
                  DropdownMenuItem(value: method, child: Text(method.label)),
              ],
              onChanged: (method) {
                if (method != null) {
                  onPaymentChanged(method);
                }
              },
            ),
            if (cart.paymentMethod == PaymentMethod.cash) ...[
              const SizedBox(height: 12),
              TextField(
                controller: cashReceivedController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Cash Received',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  errorText: cart.cashReceivedError,
                ),
                onChanged: (value) {
                  onCashReceivedChanged(double.tryParse(value.trim()));
                },
              ),
              const SizedBox(height: 12),
              _AmountRow(
                label: 'Change',
                value: AppCurrency.format(cart.changeAmount),
              ),
            ],
            const SizedBox(height: 16),
            _AmountRow(
              label: 'Total',
              value: AppCurrency.format(cart.total),
              isTotal: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: cart.canCheckout ? onCompleteSale : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Complete sale'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
