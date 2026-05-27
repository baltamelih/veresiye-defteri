import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../transactions/models/debt_transaction_model.dart';
import '../../transactions/screens/add_debt_transaction_screen.dart';
import '../../transactions/widgets/debt_transaction_tile.dart';
import '../models/customer_model.dart';
import '../services/veresiye_service.dart';
import 'add_customer_screen.dart';
import '../../../core/services/share_service.dart';
import '../../../core/ads/banner_ad_widget.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final VeresiyeService service = VeresiyeService();

  Future<void> refresh() async {
    setState(() {});
  }

  Future<void> editCustomer(CustomerModel customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomerScreen(customer: customer),
      ),
    );

    refresh();
  }

  Future<void> openAddTransaction(
      CustomerModel customer, {
        required String type,
      }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDebtTransactionScreen(
          customer: customer,
          initialType: type,
        ),
      ),
    );

    refresh();
  }

  Future<void> editTransaction(
      CustomerModel customer,
      DebtTransactionModel transaction,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDebtTransactionScreen(
          customer: customer,
          transaction: transaction,
        ),
      ),
    );

    refresh();
  }

  Future<void> shareBalance(CustomerModel customer, double balance) async {
    await ShareService.shareCustomerBalance(
      customerName: customer.name,
      balance: balance,
    );
  }

  Future<void> deleteTransaction(DebtTransactionModel transaction) async {
    await service.deleteTransaction(transaction.id);
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final customer = service.getCustomerById(widget.customerId);

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Müşteri Detayı')),
        body: const Center(
          child: Text('Müşteri bulunamadı.'),
        ),
      );
    }

    final balance = service.getCustomerBalance(customer.id);
    final transactions = service.getTransactionsByCustomer(customer.id);

    final totalDebt = transactions
        .where((e) => e.type == AppConstants.debtType)
        .fold(0.0, (sum, item) => sum + item.amount);

    final totalPayment = transactions
        .where((e) => e.type == AppConstants.paymentType)
        .fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            tooltip: 'Bakiye Paylaş',
            onPressed: () => shareBalance(customer, balance),
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: 'Müşteriyi Düzenle',
            onPressed: () => editCustomer(customer),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _BalanceCard(balance: balance),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    title: 'Toplam Borç',
                    value: CurrencyFormatter.format(totalDebt),
                    color: AppTheme.debt,
                    icon: Icons.add_card_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    title: 'Toplam Ödeme',
                    value: CurrencyFormatter.format(totalPayment),
                    color: AppTheme.payment,
                    icon: Icons.payments_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'Borç Ekle',
                    subtitle: 'Satış veya yeni borç',
                    icon: Icons.add_card_outlined,
                    color: AppTheme.debt,
                    onTap: () => openAddTransaction(
                      customer,
                      type: AppConstants.debtType,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    title: 'Ödeme Al',
                    subtitle: 'Tahsilat kaydı',
                    icon: Icons.payments_outlined,
                    color: AppTheme.payment,
                    onTap: () => openAddTransaction(
                      customer,
                      type: AppConstants.paymentType,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppCard(
              onTap: () => shareBalance(customer, balance),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.share_outlined,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bakiye Bilgisini Paylaş',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'WhatsApp, SMS veya diğer uygulamalarla gönder',
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (customer.phone.isNotEmpty || customer.note.isNotEmpty)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (customer.phone.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              customer.phone,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (customer.phone.isNotEmpty && customer.note.isNotEmpty)
                      const Divider(height: 24),
                    if (customer.note.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.note_alt_outlined,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              customer.note,
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'İşlem Geçmişi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${transactions.length} kayıt',
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              const SizedBox(
                height: 260,
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Henüz işlem yok',
                  description:
                  'Bu müşteriye borç veya ödeme ekleyerek geçmiş oluşturmaya başlayabilirsin.',
                ),
              )
            else
              ...transactions.map(
                    (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DebtTransactionTile(
                    transaction: transaction,
                    onTap: () => editTransaction(customer, transaction),
                    onDelete: () => deleteTransaction(transaction),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const BannerAdWidget(),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final color = balance > 0
        ? AppTheme.debt
        : balance == 0
        ? AppTheme.payment
        : AppTheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.23),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Güncel Bakiye',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(balance.abs()),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 34,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            balance > 0
                ? 'Bu müşteriden alacağınız bulunuyor.'
                : balance == 0
                ? 'Bu müşteri için açık bakiye yok.'
                : 'Bu müşteriye avans/fazla ödeme kaydı var.',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}