import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/models/debt_transaction_model.dart';
import '../models/customer_model.dart';

class CustomerTile extends StatelessWidget {
  final CustomerModel customer;
  final double balance;
  final DebtTransactionModel? lastTransaction;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CustomerTile({
    super.key,
    required this.customer,
    required this.balance,
    required this.lastTransaction,
    required this.onTap,
    this.onDelete,
  });

  bool get _hasDebt => balance > 0;
  bool get _isClear => balance == 0;
  bool get _isAdvance => balance < 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor;
    final statusLabel = _statusLabel;
    final subtitle = _subtitle;

    return Dismissible(
      key: ValueKey(customer.id),
      direction: onDelete == null
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: _DeleteBackground(),
      confirmDismiss: (_) => _confirmDelete(context),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _Avatar(
                  name: customer.name,
                  color: statusColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CustomerInfo(
                    name: customer.name,
                    subtitle: subtitle,
                    phone: customer.phone,
                  ),
                ),
                const SizedBox(width: 10),
                _BalanceInfo(
                  amount: balance.abs(),
                  color: statusColor,
                  label: statusLabel,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _statusColor {
    if (_hasDebt) return AppTheme.debt;
    if (_isClear) return AppTheme.payment;
    return AppTheme.warning;
  }

  String get _statusLabel {
    if (_hasDebt) return 'Alacak';
    if (_isClear) return 'Temiz';
    return 'Avans';
  }

  String get _subtitle {
    if (lastTransaction == null) return 'Henüz işlem yok';

    final typeText = lastTransaction!.isDebt ? 'Borç eklendi' : 'Ödeme alındı';
    final dateText = DateFormat('dd.MM.yyyy').format(lastTransaction!.date);

    return '$typeText • $dateText';
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    if (onDelete == null) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Müşteri silinsin mi?'),
          content: Text(
            '${customer.name} ve bu müşteriye ait tüm borç/ödeme kayıtları kalıcı olarak silinecek.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.debt,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      onDelete?.call();
      return true;
    }

    return false;
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final Color color;

  const _Avatar({
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim().characters.first.toUpperCase() : '?';

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 19,
          ),
        ),
      ),
    );
  }
}

class _CustomerInfo extends StatelessWidget {
  final String name;
  final String subtitle;
  final String phone;

  const _CustomerInfo({
    required this.name,
    required this.subtitle,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhone = phone.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.trim().isEmpty ? 'İsimsiz Müşteri' : name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (hasPhone) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 13,
                color: AppTheme.textLight,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BalanceInfo extends StatelessWidget {
  final double amount;
  final Color color;
  final String label;
  final ThemeData theme;

  const _BalanceInfo({
    required this.amount,
    required this.color,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 86, maxWidth: 112),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            CurrencyFormatter.format(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      decoration: BoxDecoration(
        color: AppTheme.debt,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: Colors.white,
      ),
    );
  }
}