import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/services/notification_service.dart';
import 'package:hydrate/core/providers/user_preferences_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationInitProvider = FutureProvider<void>((ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.init();
  if (await notificationService.requestPermissions()) {
    final interval = ref
        .read(userPreferencesProvider)
        .notificationIntervalMinutes;
    await notificationService.scheduleIntervalReminders(interval);
  }
});
