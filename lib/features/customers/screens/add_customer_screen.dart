import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../models/customer_model.dart';
import '../services/veresiye_service.dart';

class AddCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;

  const AddCustomerScreen({
    super.key,
    this.customer,
  });

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final VeresiyeService service = VeresiyeService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool isSaving = false;

  bool get isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();

    final customer = widget.customer;

    if (customer != null) {
      nameController.text = customer.name;
      phoneController.text = customer.phone;
      noteController.text = customer.note;
    }
  }

  Future<void> save() async {
    FocusScope.of(context).unfocus();

    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isSaving) return;

    setState(() => isSaving = true);

    try {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final note = noteController.text.trim();

      if (isEdit) {
        final updated = widget.customer!.copyWith(
          name: name,
          phone: phone,
          note: note,
        );

        await service.updateCustomer(updated);
      } else {
        await service.addCustomer(
          name: name,
          phone: phone,
          note: note,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Müşteri güncellendi.' : 'Müşteri kaydedildi.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşlem sırasında bir hata oluştu.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? 'Müşteri Düzenle' : 'Yeni Müşteri';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Müşteri Bilgileri' : 'Müşteri Oluştur',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Müşteri adı zorunludur. Telefon ve not alanları isteğe bağlıdır.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Müşteri adı zorunludur.';
                      }

                      if (value.trim().length < 2) {
                        return 'Müşteri adı en az 2 karakter olmalıdır.';
                      }

                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Müşteri Adı',
                      hintText: 'Örn: Ahmet Market',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      hintText: 'İsteğe bağlı',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteController,
                    minLines: 4,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Not',
                      hintText: 'İsteğe bağlı müşteri notu',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: isEdit ? 'Değişiklikleri Kaydet' : 'Müşteri Kaydet',
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