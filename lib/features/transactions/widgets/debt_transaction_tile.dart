import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/debt_transaction_model.dart';

class DebtTransactionTile extends StatelessWidget {
  final DebtTransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DebtTransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDebt = transaction.type == AppConstants.debtType;
    final color = isDebt ? AppTheme.debt : AppTheme.payment;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction:
      onDelete == null ? DismissDirection.none : DismissDirection.endToStart,
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
            ),
            child: Row(
              children: [
                _TransactionIcon(
                  isDebt: isDebt,
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TransactionInfo(
                    isDebt: isDebt,
                    description: transaction.description,
                    date: transaction.date,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${isDebt ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    if (onDelete == null) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('İşlem silinsin mi?'),
          content: const Text(
            'Bu borç/ödeme kaydı silinecek. İşlem geri alınamaz.',
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

class _TransactionIcon extends StatelessWidget {
  final bool isDebt;
  final Color color;

  const _TransactionIcon({
    required this.isDebt,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isDebt ? Icons.add_card_outlined : Icons.payments_outlined,
        color: color,
      ),
    );
  }
}

class _TransactionInfo extends StatelessWidget {
  final bool isDebt;
  final String description;
  final DateTime date;

  const _TransactionInfo({
    required this.isDebt,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd.MM.yyyy').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isDebt ? 'Borç Eklendi' : 'Ödeme Alındı',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description.trim().isEmpty ? dateText : '${description.trim()} • $dateText',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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