import 'package:flutter/material.dart';

import '../../../core/ads/banner_ad_widget.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/import_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../customers/services/veresiye_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final VeresiyeService service = VeresiyeService();

  bool isExporting = false;
  bool isImporting = false;
  bool isDeleting = false;

  Future<void> exportCsv() async {
    if (isExporting) return;

    final customers = service.getCustomers();
    final transactions = service.getAllTransactions();

    if (customers.isEmpty) {
      _showMessage('Dışa aktarılacak müşteri kaydı bulunamadı.');
      return;
    }

    setState(() => isExporting = true);

    try {
      await ExportService.exportAllDataToCsv(
        customers: customers,
        transactions: transactions,
        getBalance: service.getCustomerBalance,
      );
    } catch (_) {
      _showMessage('CSV dışa aktarılırken bir hata oluştu.');
    } finally {
      if (mounted) setState(() => isExporting = false);
    }
  }

  Future<void> importCsv() async {
    if (isImporting) return;

    setState(() => isImporting = true);

    try {
      final count = await ImportService.importCustomersFromCsv();

      if (!mounted) return;

      _showMessage(
        count == 0
            ? 'İçe aktarılacak yeni müşteri bulunamadı.'
            : '$count müşteri başarıyla içe aktarıldı.',
      );

      setState(() {});
    } catch (_) {
      _showMessage('CSV içe aktarılırken bir hata oluştu.');
    } finally {
      if (mounted) setState(() => isImporting = false);
    }
  }

  Future<void> clearAllData() async {
    if (isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tüm veriler silinsin mi?'),
          content: const Text(
            'Bu işlem geri alınamaz. Tüm müşteri, borç ve ödeme kayıtları kalıcı olarak silinir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.debt),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => isDeleting = true);

    try {
      await service.clearAllData();

      if (!mounted) return;

      _showMessage('Tüm veriler silindi.');
      setState(() {});
    } catch (_) {
      _showMessage('Veriler silinirken bir hata oluştu.');
    } finally {
      if (mounted) setState(() => isDeleting = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerCount = service.getCustomers().length;
    final transactionCount = service.getAllTransactions().length;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const _AppInfoCard(),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.groups_outlined,
                  title: 'Toplam Müşteri',
                  value: '$customerCount kayıt',
                ),
                const Divider(),
                _InfoRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Toplam İşlem',
                  value: '$transactionCount kayıt',
                ),
                const Divider(),
                const _InfoRow(
                  icon: Icons.storage_outlined,
                  title: 'Kayıt Türü',
                  value: 'Cihaz içi',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Veri Yönetimi', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Verilerin cihazda saklanır. CSV ile yedek alabilir veya daha önce dışa aktardığın müşteri listesini geri yükleyebilirsin.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: isExporting ? null : exportCsv,
                    icon: isExporting
                        ? const _ButtonLoader(color: Colors.white)
                        : const Icon(Icons.ios_share_outlined),
                    label: Text(
                      isExporting ? 'Dışa Aktarılıyor...' : 'CSV Olarak Dışa Aktar',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: isImporting ? null : importCsv,
                    icon: isImporting
                        ? const _ButtonLoader()
                        : const Icon(Icons.file_upload_outlined),
                    label: Text(
                      isImporting ? 'İçe Aktarılıyor...' : 'CSV’den İçe Aktar',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: isDeleting ? null : clearAllData,
                    icon: isDeleting
                        ? const _ButtonLoader()
                        : const Icon(Icons.delete_outline_rounded),
                    label: Text(
                      isDeleting ? 'Siliniyor...' : 'Tüm Verileri Sil',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Text(
              'v1.0.0\nİlk profesyonel sürüm',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textLight,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const BannerAdWidget(),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _ButtonLoader extends StatelessWidget {
  final Color? color;

  const _ButtonLoader({this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        color: color,
      ),
    );
  }
}

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.book_rounded, color: AppTheme.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Veresiye Defteri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Müşteri borç ve ödeme takip uygulaması',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}