import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/app_core.dart';
import 'core/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  final snapshot = await LocalStore.load();
  runApp(ScheduleApp(initialSnapshot: snapshot));
}
