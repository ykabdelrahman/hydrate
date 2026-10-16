import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hydrate/core/services/notification_service.dart';

class FakeNotifications extends Fake
    implements FlutterLocalNotificationsPlugin {
  final requests = <PendingNotificationRequest>[];
  Duration? lastInterval;
  AndroidScheduleMode? lastMode;
  bool failSchedule = false;
  int scheduleCalls = 0;

  @override
  Future<bool?> initialize(
    InitializationSettings settings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async => true;

  @override
  Future<List<PendingNotificationRequest>>
  pendingNotificationRequests() async => List.of(requests);

  @override
  Future<void> periodicallyShowWithDuration(
    int id,
    String? title,
    String? body,
    Duration interval,
    NotificationDetails details, {
    AndroidScheduleMode androidScheduleMode = AndroidScheduleMode.exact,
    String? payload,
  }) async {
    if (failSchedule) throw StateError('schedule failed');
    scheduleCalls++;
    lastInterval = interval;
    lastMode = androidScheduleMode;
    requests.removeWhere((request) => request.id == id);
    requests.add(PendingNotificationRequest(id, title, body, payload));
  }

  @override
  Future<void> cancel(int id, {String? tag}) async {
    requests.removeWhere((request) => request.id == id);
  }
}

class PermittedNotificationService extends NotificationService {
  PermittedNotificationService(super.plugin);

  @override
  Future<bool> areNotificationsEnabled() async => true;
}

void main() {
  test(
    'repeated calls repair the same reminder without duplicate requests',
    () async {
      final plugin = FakeNotifications();
      final service = PermittedNotificationService(plugin);

      await service.scheduleIntervalReminders(15);
      expect(plugin.requests, hasLength(1));
      expect(plugin.lastInterval, const Duration(minutes: 15));
      expect(plugin.lastMode, AndroidScheduleMode.inexactAllowWhileIdle);

      await service.scheduleIntervalReminders(15);
      expect(plugin.requests, hasLength(1));
      expect(plugin.scheduleCalls, 2);

      await service.scheduleIntervalReminders(30);
      expect(plugin.requests, hasLength(1));
      expect(plugin.lastInterval, const Duration(minutes: 30));
      expect(
        plugin.requests.single.payload,
        'water-reminder:30:inexactAllowWhileIdle',
      );

      await service.scheduleIntervalReminders(0);
      expect(plugin.requests, isEmpty);
    },
  );

  test('a failed replacement leaves the previous reminder intact', () async {
    final plugin = FakeNotifications();
    final service = PermittedNotificationService(plugin);
    await service.scheduleIntervalReminders(60);
    plugin.failSchedule = true;

    await expectLater(service.scheduleIntervalReminders(90), throwsStateError);
    expect(
      plugin.requests.single.payload,
      'water-reminder:60:inexactAllowWhileIdle',
    );
  });
}
