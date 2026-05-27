import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../customers/models/customer_model.dart';
import '../../customers/services/veresiye_service.dart';
import '../models/debt_transaction_model.dart';
import '../../../core/ads/ad_service.dart';

class AddDebtTransactionScreen extends StatefulWidget {
  final CustomerModel customer;
  final DebtTransactionModel? transaction;
  final String? initialType;

  const AddDebtTransactionScreen({
    super.key,
    required this.customer,
    this.transaction,
    this.initialType,
  });

  @override
  State<AddDebtTransactionScreen> createState() =>
      _AddDebtTransactionScreenState();
}

class _AddDebtTransactionScreenState extends State<AddDebtTransactionScreen> {
  final VeresiyeService service = VeresiyeService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedType = AppConstants.debtType;
  DateTime selectedDate = DateTime.now();
  bool isSaving = false;

  bool get isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    final item = widget.transaction;

    if (item != null) {
      amountController.text = item.amount.toStringAsFixed(2);
      descriptionController.text = item.description;
      selectedType = item.type;
      selectedDate = item.date;
    } else {
      selectedType = widget.initialType ?? AppConstants.debtType;
    }
  }

  Future<void> pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('tr', 'TR'),
    );

    if (!mounted || result == null) return;

    setState(() => selectedDate = result);
  }

  Future<void> save() async {
    FocusScope.of(context).unfocus();

    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isSaving) return;

    setState(() => isSaving = true);

    try {
      final amountText = amountController.text.trim().replaceAll(',', '.');
      final amount = double.parse(amountText);
      final description = descriptionController.text.trim();

      if (isEdit) {
        final updated = widget.transaction!.copyWith(
          amount: amount,
          type: selectedType,
          description: description,
          date: selectedDate,
        );

        await service.updateTransaction(updated);
      } else {
        await service.addTransaction(
          customerId: widget.customer.id,
          amount: amount,
          type: selectedType,
          description: description,
          date: selectedDate,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'İşlem güncellendi.' : 'İşlem kaydedildi.'),
        ),
      );

      await AdService.registerActionAndMaybeShowAd();

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem sırasında bir hata oluştu.')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDebt = selectedType == AppConstants.debtType;
    final activeColor = isDebt ? AppTheme.debt : AppTheme.payment;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'İşlemi Düzenle' : 'Borç / Ödeme Ekle'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      title: 'Borç Ekle',
                      icon: Icons.add_card_outlined,
                      color: AppTheme.debt,
                      selected: selectedType == AppConstants.debtType,
                      onTap: () {
                        setState(() => selectedType = AppConstants.debtType);
                      },
                    ),
                  ),
                  Expanded(
                    child: _TypeButton(
                      title: 'Ödeme Al',
                      icon: Icons.payments_outlined,
                      color: AppTheme.payment,
                      selected: selectedType == AppConstants.paymentType,
                      onTap: () {
                        setState(() => selectedType = AppConstants.paymentType);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final amount = double.tryParse(
                        (value ?? '').trim().replaceAll(',', '.'),
                      );

                      if (amount == null || amount <= 0) {
                        return 'Geçerli bir tutar girin.';
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Tutar',
                      hintText: 'Örn: 500',
                      prefixIcon: Icon(Icons.currency_lira, color: activeColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DatePickerTile(
                    date: selectedDate,
                    color: activeColor,
                    onTap: pickDate,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      hintText: 'Örn: Ürün satışı, kısmi ödeme, eski borç...',
                      prefixIcon: Icon(Icons.description_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InfoBox(
              isDebt: isDebt,
              color: activeColor,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: isEdit ? 'Değişiklikleri Kaydet' : 'İşlemi Kaydet',
              icon: Icons.save_outlined,
              onPressed: save,
              isLoading: isSaving,
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime date;
  final Color color;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.date,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dateText,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final bool isDebt;
  final Color color;

  const _InfoBox({
    required this.isDebt,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDebt ? Icons.info_outline : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isDebt
                  ? 'Borç eklediğinizde müşterinin kalan bakiyesi artar.'
                  : 'Ödeme aldığınızda müşterinin kalan bakiyesi azalır.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}