import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/sale.dart';
import '../../../shared/models/store_settings.dart';

class ReceiptPdfBuilder {
  const ReceiptPdfBuilder._();

  static Future<Uint8List> build({
    required Sale sale,
    required String cashierName,
    required StoreSettings settings,
  }) async {
    final document = pw.Document();
    final date = DateFormat.yMMMd().add_jm().format(sale.createdAt);

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(18),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                settings.storeName,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (settings.branchName.isNotEmpty)
                pw.Text(settings.branchName, textAlign: pw.TextAlign.center),
              if (settings.address.isNotEmpty)
                pw.Text(settings.address, textAlign: pw.TextAlign.center),
              if (settings.phone.isNotEmpty)
                pw.Text(settings.phone, textAlign: pw.TextAlign.center),
              if (settings.email.isNotEmpty)
                pw.Text(settings.email, textAlign: pw.TextAlign.center),
              if (settings.taxId.isNotEmpty)
                pw.Text(
                  'Tax ID: ${settings.taxId}',
                  textAlign: pw.TextAlign.center,
                ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Receipt ${sale.receiptNumber}',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                date,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 10),
              _infoRow('Cashier', cashierName),
              _infoRow('Payment', sale.paymentMethod.label),
              pw.Divider(),
              ...sale.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Text(
                        item.productName,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${item.quantity} x ${AppCurrency.format(item.unitPrice)}',
                          ),
                          pw.Text(AppCurrency.format(item.lineTotal)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              pw.Divider(),
              _totalRow('Subtotal', AppCurrency.format(sale.subtotal)),
              _totalRow('Discount', AppCurrency.format(sale.discountTotal)),
              pw.SizedBox(height: 4),
              _totalRow(
                'Total',
                AppCurrency.format(sale.grandTotal),
                isTotal: true,
              ),
              _totalRow(
                sale.paymentMethod == PaymentMethod.cash
                    ? 'Cash Received'
                    : 'Amount Received',
                AppCurrency.format(sale.amountReceived),
              ),
              _totalRow('Change', AppCurrency.format(sale.changeAmount)),
              pw.SizedBox(height: 14),
              pw.Text(
                settings.receiptFooter,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    return document.save();
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, textAlign: pw.TextAlign.right),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final style = isTotal
        ? pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)
        : const pw.TextStyle(fontSize: 11);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }
}
