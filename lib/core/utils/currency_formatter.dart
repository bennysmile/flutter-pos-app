import 'package:intl/intl.dart';

class AppCurrency {
  const AppCurrency._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_GH',
    name: 'GHS',
    symbol: 'GHS ',
    decimalDigits: 2,
  );

  static String format(num value) {
    return _formatter.format(value);
  }
}
