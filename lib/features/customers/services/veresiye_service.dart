import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../transactions/models/debt_transaction_model.dart';
import '../models/customer_model.dart';

class VeresiyeService {
  static const Uuid _uuid = Uuid();

  List<CustomerModel> getCustomers() {
    final items = LocalStorageService.customerBox.values
        .map((item) {
      try {
        return CustomerModel.fromMap(Map<String, dynamic>.from(item));
      } catch (_) {
        return null;
      }
    })
        .whereType<CustomerModel>()
        .toList();

    items.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return items;
  }

  CustomerModel? getCustomerById(String id) {
    for (final customer in getCustomers()) {
      if (customer.id == id) return customer;
    }

    return null;
  }

  Future<CustomerModel> addCustomer({
    required String name,
    required String phone,
    required String note,
  }) async {
    final now = DateTime.now();
    final customer = CustomerModel(
      id: _uuid.v4(),
      name: name.trim(),
      phone: phone.trim(),
      note: note.trim(),
      createdAt: now,
    );

    await LocalStorageService.customerBox.put(customer.id, customer.toMap());

    return customer;
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await LocalStorageService.customerBox.put(
      customer.id,
      customer.toMap(),
    );
  }

  Future<void> deleteCustomer(String customerId) async {
    final transactions = getTransactionsByCustomer(customerId);

    for (final transaction in transactions) {
      await LocalStorageService.transactionBox.delete(transaction.id);
    }

    await LocalStorageService.customerBox.delete(customerId);
  }

  List<DebtTransactionModel> getAllTransactions() {
    final items = LocalStorageService.transactionBox.values
        .map((item) {
      try {
        return DebtTransactionModel.fromMap(
          Map<String, dynamic>.from(item),
        );
      } catch (_) {
        return null;
      }
    })
        .whereType<DebtTransactionModel>()
        .toList();

    items.sort(_sortTransactionDesc);

    return items;
  }

  List<DebtTransactionModel> getTransactionsByCustomer(String customerId) {
    final items = getAllTransactions()
        .where((item) => item.customerId == customerId)
        .toList();

    items.sort(_sortTransactionDesc);

    return items;
  }

  Future<DebtTransactionModel> addTransaction({
    required String customerId,
    required double amount,
    required String type,
    required String description,
    required DateTime date,
  }) async {
    final now = DateTime.now();

    final transaction = DebtTransactionModel(
      id: _uuid.v4(),
      customerId: customerId,
      amount: amount,
      type: type,
      description: description.trim(),
      date: date,
      createdAt: now,
    );

    await LocalStorageService.transactionBox.put(
      transaction.id,
      transaction.toMap(),
    );

    return transaction;
  }

  Future<void> updateTransaction(DebtTransactionModel transaction) async {
    await LocalStorageService.transactionBox.put(
      transaction.id,
      transaction.toMap(),
    );
  }

  Future<void> deleteTransaction(String id) async {
    await LocalStorageService.transactionBox.delete(id);
  }

  Future<void> clearAllData() async {
    await LocalStorageService.transactionBox.clear();
    await LocalStorageService.customerBox.clear();
  }

  double getCustomerBalance(String customerId) {
    final transactions = getTransactionsByCustomer(customerId);

    return transactions.fold<double>(0, (sum, item) {
      if (item.type == AppConstants.debtType) {
        return sum + item.amount;
      }

      if (item.type == AppConstants.paymentType) {
        return sum - item.amount;
      }

      return sum;
    });
  }

  double getTotalDebt() {
    return getAllTransactions()
        .where((item) => item.type == AppConstants.debtType)
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  double getTotalPayments() {
    return getAllTransactions()
        .where((item) => item.type == AppConstants.paymentType)
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  double getTotalReceivable() {
    return getCustomers().fold<double>(0, (sum, customer) {
      final balance = getCustomerBalance(customer.id);
      return balance > 0 ? sum + balance : sum;
    });
  }

  double getTotalAdvance() {
    return getCustomers().fold<double>(0, (sum, customer) {
      final balance = getCustomerBalance(customer.id);
      return balance < 0 ? sum + balance.abs() : sum;
    });
  }

  double getTodayPayments() {
    final now = DateTime.now();

    return getAllTransactions()
        .where(
          (item) =>
      item.type == AppConstants.paymentType &&
          _isSameDay(item.date, now),
    )
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  int getDebtorCustomerCount() {
    return getCustomers()
        .where((customer) => getCustomerBalance(customer.id) > 0)
        .length;
  }

  int getClearCustomerCount() {
    return getCustomers()
        .where((customer) => getCustomerBalance(customer.id) == 0)
        .length;
  }

  int getAdvanceCustomerCount() {
    return getCustomers()
        .where((customer) => getCustomerBalance(customer.id) < 0)
        .length;
  }

  DebtTransactionModel? getLastTransactionForCustomer(String customerId) {
    final items = getTransactionsByCustomer(customerId);

    if (items.isEmpty) return null;

    items.sort(_sortTransactionDesc);
    return items.first;
  }

  int _sortTransactionDesc(
      DebtTransactionModel a,
      DebtTransactionModel b,
      ) {
    final dateCompare = b.date.compareTo(a.date);

    if (dateCompare != 0) return dateCompare;

    return b.createdAt.compareTo(a.createdAt);
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}