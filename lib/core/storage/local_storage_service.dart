import 'package:hive/hive.dart';

import '../constants/app_constants.dart';

class LocalStorageService {
  LocalStorageService._();

  static Future<void> init() async {
    await _openBoxIfNeeded(AppConstants.customerBox);
    await _openBoxIfNeeded(AppConstants.transactionBox);
    await _openBoxIfNeeded(AppConstants.settingsBox);
  }

  static Box get customerBox => Hive.box(AppConstants.customerBox);

  static Box get transactionBox => Hive.box(AppConstants.transactionBox);

  static Box get settingsBox => Hive.box(AppConstants.settingsBox);

  static Future<void> _openBoxIfNeeded(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }
}