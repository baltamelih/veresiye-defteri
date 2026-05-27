import 'package:share_plus/share_plus.dart';

import '../utils/currency_formatter.dart';

class ShareService {
  ShareService._();

  static Future<void> shareCustomerBalance({
    required String customerName,
    required double balance,
  }) async {
    final message = '''
Merhaba $customerName,

Güncel veresiye bakiyeniz:
${CurrencyFormatter.format(balance.abs())}

${_balanceStatusText(balance)}

İyi günler dileriz.
''';

    await Share.share(
      message.trim(),
      subject: 'Güncel Veresiye Bakiyesi',
    );
  }

  static Future<void> shareCustomerStatement({
    required String customerName,
    required double balance,
    required int transactionCount,
  }) async {
    final message = '''
Merhaba $customerName,

Veresiye hesabınızda toplam $transactionCount işlem bulunmaktadır.

Güncel bakiye:
${CurrencyFormatter.format(balance.abs())}

${_balanceStatusText(balance)}

İyi günler dileriz.
''';

    await Share.share(
      message.trim(),
      subject: 'Veresiye Hesap Özeti',
    );
  }

  static String _balanceStatusText(double balance) {
    if (balance > 0) {
      return 'Kayıtlarımıza göre ödenmemiş bakiyeniz bulunmaktadır.';
    }

    if (balance < 0) {
      return 'Kayıtlarımıza göre fazla ödeme / avans bakiyeniz bulunmaktadır.';
    }

    return 'Kayıtlarımıza göre açık bakiyeniz bulunmamaktadır.';
  }
}