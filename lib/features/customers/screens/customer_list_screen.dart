import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../models/customer_model.dart';
import '../services/veresiye_service.dart';
import '../widgets/customer_tile.dart';
import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';
import '../../../core/ads/banner_ad_widget.dart';

enum CustomerFilter {
  all,
  debtors,
  clear,
  advance,
}

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final VeresiyeService service = VeresiyeService();
  final TextEditingController searchController = TextEditingController();

  String query = '';
  CustomerFilter selectedFilter = CustomerFilter.all;

  List<CustomerModel> get filteredCustomers {
    var customers = service.getCustomers();

    customers = customers.where((customer) {
      final balance = service.getCustomerBalance(customer.id);

      switch (selectedFilter) {
        case CustomerFilter.all:
          return true;
        case CustomerFilter.debtors:
          return balance > 0;
        case CustomerFilter.clear:
          return balance == 0;
        case CustomerFilter.advance:
          return balance < 0;
      }
    }).toList();

    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isNotEmpty) {
      customers = customers.where((customer) {
        return customer.name.toLowerCase().contains(normalizedQuery) ||
            customer.phone.toLowerCase().contains(normalizedQuery) ||
            customer.note.toLowerCase().contains(normalizedQuery);
      }).toList();
    }

    customers.sort((a, b) {
      final balanceA = service.getCustomerBalance(a.id);
      final balanceB = service.getCustomerBalance(b.id);

      if (balanceA == balanceB) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }

      return balanceB.compareTo(balanceA);
    });

    return customers;
  }

  Future<void> refresh() async {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> openAddCustomer() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
    );

    await refresh();
  }

  Future<void> openDetail(CustomerModel customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailScreen(customerId: customer.id),
      ),
    );

    await refresh();
  }

  Future<void> deleteCustomer(CustomerModel customer) async {
    await service.deleteCustomer(customer.id);
    await refresh();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${customer.name} silindi.'),
      ),
    );
  }

  void clearSearch() {
    searchController.clear();
    setState(() {
      query = '';
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = filteredCustomers;
    final totalCustomers = service.getCustomers().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteriler'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddCustomer,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Müşteri Ekle',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (value) => setState(() => query = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Müşteri adı, telefon veya not ara...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                      onPressed: clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _FilterBar(
                  selectedFilter: selectedFilter,
                  onChanged: (filter) {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _ListSummary(
              visibleCount: customers.length,
              totalCount: totalCustomers,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: refresh,
              child: customers.isEmpty
                  ? EmptyState(
                icon: Icons.groups_outlined,
                title: totalCustomers == 0
                    ? 'Henüz müşteri yok'
                    : 'Müşteri bulunamadı',
                description: totalCustomers == 0
                    ? 'İlk müşterini ekleyerek veresiye takibine başlayabilirsin.'
                    : 'Arama veya filtreye uygun müşteri bulunmuyor.',
                actionText: totalCustomers == 0 ? 'Müşteri Ekle' : null,
                onActionPressed:
                totalCustomers == 0 ? openAddCustomer : null,
              )
                  : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 108),
                itemCount: customers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final customer = customers[index];

                  return CustomerTile(
                    customer: customer,
                    balance: service.getCustomerBalance(customer.id),
                    lastTransaction:
                    service.getLastTransactionForCustomer(
                      customer.id,
                    ),
                    onTap: () => openDetail(customer),
                    onDelete: () => deleteCustomer(customer),
                  );
                },
              ),
            ),
          ),
          const BannerAdWidget(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final CustomerFilter selectedFilter;
  final ValueChanged<CustomerFilter> onChanged;

  const _FilterBar({
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<CustomerFilter>(
        selected: {selectedFilter},
        showSelectedIcon: false,
        onSelectionChanged: (value) => onChanged(value.first),
        segments: const [
          ButtonSegment(
            value: CustomerFilter.all,
            label: Text('Tümü'),
            icon: Icon(Icons.list_rounded),
          ),
          ButtonSegment(
            value: CustomerFilter.debtors,
            label: Text('Alacak'),
            icon: Icon(Icons.trending_up_rounded),
          ),
          ButtonSegment(
            value: CustomerFilter.clear,
            label: Text('Temiz'),
            icon: Icon(Icons.check_circle_outline_rounded),
          ),
          ButtonSegment(
            value: CustomerFilter.advance,
            label: Text('Avans'),
            icon: Icon(Icons.south_west_rounded),
          ),
        ],
      ),
    );
  }
}

class _ListSummary extends StatelessWidget {
  final int visibleCount;
  final int totalCount;

  const _ListSummary({
    required this.visibleCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final text = totalCount == visibleCount
        ? '$visibleCount müşteri listeleniyor'
        : '$visibleCount / $totalCount müşteri listeleniyor';

    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}