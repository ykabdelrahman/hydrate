import 'package:workmanager/workmanager.dart';

/// Registers the old callback solely so pending WorkManager jobs can be
/// cancelled when an existing installation upgrades to local alarms.
class BackgroundNotificationService {
  static Future<void> initialize() =>
      Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((_, __) async => true);
}
