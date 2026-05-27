import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static String format(double value) {
    return _formatter.format(value);
  }

  static String compact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} Mn ₺';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} Bin ₺';
    }

    return format(value);
  }

  static String withoutSymbol(double value) {
    final formatter = NumberFormat.decimalPattern('tr_TR');
    return formatter.format(value);
  }
}