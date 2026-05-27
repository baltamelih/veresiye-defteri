import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../customers/services/veresiye_service.dart';
import '../../../core/ads/banner_ad_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final VeresiyeService service = VeresiyeService();

  Future<void> refresh() async {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final customers = service.getCustomers();
    final transactions = service.getAllTransactions();

    final totalDebt = service.getTotalDebt();
    final totalPayment = service.getTotalPayments();
    final activeBalance = totalDebt - totalPayment;
    final totalReceivable = service.getTotalReceivable();
    final totalAdvance = service.getTotalAdvance();

    final sortedCustomers = [...customers]..sort((a, b) {
      final balanceA = service.getCustomerBalance(a.id);
      final balanceB = service.getCustomerBalance(b.id);
      return balanceB.compareTo(balanceA);
    });

    final topCustomers = sortedCustomers
        .where((customer) => service.getCustomerBalance(customer.id) > 0)
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryCard(
              activeBalance: activeBalance,
              totalDebt: totalDebt,
              totalPayment: totalPayment,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SmallReportCard(
                    title: 'Müşteri',
                    value: '${customers.length}',
                    icon: Icons.groups_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SmallReportCard(
                    title: 'İşlem',
                    value: '${transactions.length}',
                    icon: Icons.receipt_long_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SmallReportCard(
                    title: 'Alacaklı',
                    value: '${service.getDebtorCustomerCount()}',
                    icon: Icons.trending_up_rounded,
                    color: AppTheme.debt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SmallReportCard(
                    title: 'Temiz',
                    value: '${service.getClearCustomerCount()}',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppTheme.payment,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _BreakdownCard(
              totalReceivable: totalReceivable,
              totalAdvance: totalAdvance,
              todayPayments: service.getTodayPayments(),
            ),
            const SizedBox(height: 16),
            _TopCustomersCard(
              customers: topCustomers,
              getBalance: service.getCustomerBalance,
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

class _SummaryCard extends StatelessWidget {
  final double activeBalance;
  final double totalDebt;
  final double totalPayment;

  const _SummaryCard({
    required this.activeBalance,
    required this.totalDebt,
    required this.totalPayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary,
              AppTheme.primaryDark.withValues(alpha: 0.92),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genel Finans Özeti',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.78),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              CurrencyFormatter.format(activeBalance),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              activeBalance >= 0
                  ? 'Toplam açık bakiye ve tahsilat durumun.'
                  : 'Ödeme toplamı borçlardan yüksek görünüyor.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.76),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _WhiteMiniStat(
                    title: 'Borç',
                    value: CurrencyFormatter.format(totalDebt),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _WhiteMiniStat(
                    title: 'Tahsilat',
                    value: CurrencyFormatter.format(totalPayment),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteMiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _WhiteMiniStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallReportCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final double totalReceivable;
  final double totalAdvance;
  final double todayPayments;

  const _BreakdownCard({
    required this.totalReceivable,
    required this.totalAdvance,
    required this.todayPayments,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detaylı Durum',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          _ReportAmountRow(
            title: 'Tahsil Edilecek Alacak',
            value: CurrencyFormatter.format(totalReceivable),
            icon: Icons.account_balance_wallet_rounded,
            color: AppTheme.debt,
          ),
          const Divider(),
          _ReportAmountRow(
            title: 'Avans / Fazla Ödeme',
            value: CurrencyFormatter.format(totalAdvance),
            icon: Icons.south_west_rounded,
            color: AppTheme.warning,
          ),
          const Divider(),
          _ReportAmountRow(
            title: 'Bugünkü Tahsilat',
            value: CurrencyFormatter.format(todayPayments),
            icon: Icons.today_rounded,
            color: AppTheme.payment,
          ),
        ],
      ),
    );
  }
}

class _ReportAmountRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportAmountRow({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TopCustomersCard extends StatelessWidget {
  final List<dynamic> customers;
  final double Function(String customerId) getBalance;

  const _TopCustomersCard({
    required this.customers,
    required this.getBalance,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'En Yüksek Bakiyeli Müşteriler',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          if (customers.isEmpty)
            Text(
              'Henüz alacak bakiyesi olan müşteri bulunmuyor.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textLight,
              ),
            )
          else
            ...customers.map((customer) {
              final balance = getBalance(customer.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CustomerBalanceRow(
                  name: customer.name,
                  balance: balance,
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _CustomerBalanceRow extends StatelessWidget {
  final String name;
  final double balance;

  const _CustomerBalanceRow({
    required this.name,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.debt.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: AppTheme.debt,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          CurrencyFormatter.format(balance),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppTheme.debt,
          ),
        ),
      ],
    );
  }
}