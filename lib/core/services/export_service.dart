import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/customers/models/customer_model.dart';
import '../../features/transactions/models/debt_transaction_model.dart';
import '../utils/currency_formatter.dart';

class ExportService {
  ExportService._();

  static Future<void> exportAllDataToCsv({
    required List<CustomerModel> customers,
    required List<DebtTransactionModel> transactions,
    required double Function(String customerId) getBalance,
  }) async {
    final buffer = StringBuffer();

    buffer.writeln(
      [
        'Müşteri',
        'Telefon',
        'Not',
        'Güncel Bakiye',
        'İşlem Tarihi',
        'İşlem Tipi',
        'Tutar',
        'Açıklama',
      ].map(_escape).join(','),
    );

    for (final customer in customers) {
      final customerTransactions = transactions
          .where((item) => item.customerId == customer.id)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (customerTransactions.isEmpty) {
        buffer.writeln(
          [
            customer.name,
            customer.phone,
            customer.note,
            CurrencyFormatter.format(getBalance(customer.id)),
            '',
            '',
            '',
            '',
          ].map(_escape).join(','),
        );
        continue;
      }

      for (final transaction in customerTransactions) {
        buffer.writeln(
          [
            customer.name,
            customer.phone,
            customer.note,
            CurrencyFormatter.format(getBalance(customer.id)),
            _formatDate(transaction.date),
            transaction.isDebt ? 'Borç' : 'Ödeme',
            transaction.amount.toStringAsFixed(2),
            transaction.description,
          ].map(_escape).join(','),
        );
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'veresiye_defteri_${DateTime.now().millisecondsSinceEpoch}.csv';

    final file = File('${directory.path}/$fileName');

    await file.writeAsString(
      '\uFEFF${buffer.toString()}',
      flush: true,
    );

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Veresiye Defteri kayıtları',
      subject: 'Veresiye Defteri CSV Export',
    );
  }

  static String _escape(String value) {
    final sanitized = value.replaceAll('"', '""');
    return '"$sanitized"';
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }
}