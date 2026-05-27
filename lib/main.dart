import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/ads/ad_service.dart';
import 'core/storage/local_storage_service.dart';
import 'core/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await LocalStorageService.init();

  await AdService.initialize();

  await NotificationService.initialize();

  runApp(const VeresiyeDefteriApp());
}