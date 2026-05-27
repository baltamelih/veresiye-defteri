import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import '../../features/customers/services/veresiye_service.dart';

class ImportService {
  ImportService._();

  static Future<int> importCustomersFromCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) {
      return 0;
    }

    final file = File(result.files.single.path!);
    final content = await file.readAsString();

    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(content.replaceFirst('\uFEFF', ''));

    if (rows.length <= 1) return 0;

    final service = VeresiyeService();
    int importedCount = 0;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      if (row.isEmpty) continue;

      final name = _readCell(row, 0);
      final phone = _readCell(row, 1);
      final note = _readCell(row, 2);

      if (name.trim().isEmpty) continue;

      final alreadyExists = service.getCustomers().any(
            (customer) =>
        customer.name.trim().toLowerCase() ==
            name.trim().toLowerCase() &&
            customer.phone.trim() == phone.trim(),
      );

      if (alreadyExists) continue;

      await service.addCustomer(
        name: name,
        phone: phone,
        note: note,
      );

      importedCount++;
    }

    return importedCount;
  }

  static String _readCell(List<dynamic> row, int index) {
    if (index >= row.length) return '';
    return row[index]?.toString().trim() ?? '';
  }
}