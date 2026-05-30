import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../app/routes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/sale.dart';
import '../../../shared/models/sale_item.dart';
import '../../../shared/models/store_settings.dart';
import '../../auth/data/app_user_repository.dart';
import '../../settings/data/store_settings_repository.dart';
import '../data/sale_repository.dart';
import 'receipt_pdf_builder.dart';

class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key, required this.saleId});

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: FutureBuilder<_ReceiptDetails?>(
        future: _loadReceipt(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final details = snapshot.data;
          if (details == null) {
            return const Center(child: Text('Receipt not found'));
          }

          return _ReceiptContent(details: details);
        },
      ),
    );
  }

  Future<_ReceiptDetails?> _loadReceipt(WidgetRef ref) async {
    final sale = await ref.read(saleRepositoryProvider).getSaleById(saleId);
    if (sale == null) {
      return null;
    }

    final cashier = await ref
        .read(appUserRepositoryProvider)
        .getUserById(sale.cashierId);
    final settings = await ref
        .read(storeSettingsRepositoryProvider)
        .getSettings(sale.shopId);

    return _ReceiptDetails(
      sale: sale,
      cashierName: cashier?.name ?? sale.cashierId,
      settings: settings,
    );
  }
}

class _ReceiptContent extends StatelessWidget {
  const _ReceiptContent({required this.details});

  final _ReceiptDetails details;

  @override
  Widget build(BuildContext context) {
    final sale = details.sale;
    final settings = details.settings;
    final date = DateFormat.yMMMd().add_jm().format(sale.createdAt);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          settings.storeName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if (settings.branchName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            settings.branchName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                        if (settings.address.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(settings.address, textAlign: TextAlign.center),
                        ],
                        if (settings.phone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(settings.phone, textAlign: TextAlign.center),
                        ],
                        if (settings.email.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(settings.email, textAlign: TextAlign.center),
                        ],
                        if (settings.taxId.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Tax ID: ${settings.taxId}',
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Receipt ${sale.receiptNumber}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 8),
                        Text(date, textAlign: TextAlign.center),
                        const Divider(height: 32),
                        _ReceiptRow(
                          label: 'Cashier',
                          value: details.cashierName,
                        ),
                        _ReceiptRow(
                          label: 'Payment method',
                          value: sale.paymentMethod.label,
                        ),
                        const Divider(height: 32),
                        for (final item in sale.items)
                          _ReceiptItemRow(item: item),
                        const Divider(height: 32),
                        _ReceiptRow(
                          label: 'Subtotal',
                          value: AppCurrency.format(sale.subtotal),
                        ),
                        _ReceiptRow(
                          label: 'Discount',
                          value: AppCurrency.format(sale.discountTotal),
                        ),
                        const SizedBox(height: 10),
                        _ReceiptRow(
                          label: 'Total',
                          value: AppCurrency.format(sale.grandTotal),
                          isTotal: true,
                        ),
                        _ReceiptRow(
                          label: sale.paymentMethod == PaymentMethod.cash
                              ? 'Cash Received'
                              : 'Amount Received',
                          value: AppCurrency.format(sale.amountReceived),
                        ),
                        _ReceiptRow(
                          label: 'Change',
                          value: AppCurrency.format(sale.changeAmount),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          settings.receiptFooter,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _ReceiptActions(details: details),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReceiptActions extends StatelessWidget {
  const _ReceiptActions({required this.details});

  final _ReceiptDetails details;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => _printReceipt(details),
          icon: const Icon(Icons.print_outlined),
          label: const Text('Print'),
        ),
        OutlinedButton.icon(
          onPressed: () => _sharePdf(details),
          icon: const Icon(Icons.ios_share_outlined),
          label: const Text('Share PDF'),
        ),
        ElevatedButton.icon(
          onPressed: () => context.go(AppRoutes.pos),
          icon: const Icon(Icons.point_of_sale_outlined),
          label: const Text('New Sale'),
        ),
      ],
    );
  }

  Future<void> _printReceipt(_ReceiptDetails details) async {
    await Printing.layoutPdf(
      name: 'receipt-${details.sale.receiptNumber}.pdf',
      onLayout: (_) => _buildPdf(details),
    );
  }

  Future<void> _sharePdf(_ReceiptDetails details) async {
    final bytes = await _buildPdf(details);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'receipt-${details.sale.receiptNumber}.pdf',
    );
  }

  Future<Uint8List> _buildPdf(_ReceiptDetails details) {
    return ReceiptPdfBuilder.build(
      sale: details.sale,
      cashierName: details.cashierName,
      settings: details.settings,
    );
  }
}

class _ReceiptItemRow extends StatelessWidget {
  const _ReceiptItemRow({required this.item});

  final SaleItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} x ${AppCurrency.format(item.unitPrice)}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Text(
            AppCurrency.format(item.lineTotal),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Flexible(
            child: Text(value, textAlign: TextAlign.end, style: style),
          ),
        ],
      ),
    );
  }
}

class _ReceiptDetails {
  const _ReceiptDetails({
    required this.sale,
    required this.cashierName,
    required this.settings,
  });

  final Sale sale;
  final String cashierName;
  final StoreSettings settings;
}
