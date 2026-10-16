import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';

/// Owns the single OS-managed repeating reminder. The operating system, rather
/// than a running Dart isolate or a periodic background job, delivers it.
class NotificationService {
  static const int reminderId = 1001;
  static const int testId = 9999;
  static const _exactAlarmChannel = MethodChannel('hydrate/exact_alarms');

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialization;

  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<void> init() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings);
  }

  Future<bool> requestPermissions() async {
    await init();
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  Future<bool> areNotificationsEnabled() async {
    await init();
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final permissions = await ios?.checkPermissions();
      return permissions?.isEnabled ?? false;
    }
    return false;
  }

  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _exactAlarmChannel.invokeMethod<bool>(
            'canScheduleExactAlarms',
          ) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return false;
    await init();
    if (await canScheduleExactAlarms()) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestExactAlarmsPermission();
    return canScheduleExactAlarms();
  }

  /// Replaces the previous reminder. The plugin's cached pending request can
  /// outlive the actual Android alarm, so every call repairs the OS schedule.
  Future<void> scheduleIntervalReminders(int intervalMinutes) async {
    await init();
    if (intervalMinutes < 0) {
      throw ArgumentError.value(intervalMinutes, 'intervalMinutes');
    }
    if (intervalMinutes == 0) {
      await _plugin.cancel(reminderId);
      return;
    }
    if (!await areNotificationsEnabled()) {
      throw StateError('Notification permission is disabled');
    }

    final exact = await canScheduleExactAlarms();
    var mode = exact
        ? AndroidScheduleMode.alarmClock
        : AndroidScheduleMode.inexactAllowWhileIdle;
    var payload = 'water-reminder:$intervalMinutes:${mode.name}';
    try {
      await _scheduleRepeating(intervalMinutes, mode, payload);
    } on PlatformException catch (error) {
      if (mode != AndroidScheduleMode.alarmClock ||
          error.code != 'exact_alarms_not_permitted') {
        rethrow;
      }
      // Access can be revoked between checking and scheduling.
      mode = AndroidScheduleMode.inexactAllowWhileIdle;
      payload = 'water-reminder:$intervalMinutes:${mode.name}';
      await _scheduleRepeating(intervalMinutes, mode, payload);
    }
  }

  Future<void> _scheduleRepeating(
    int intervalMinutes,
    AndroidScheduleMode mode,
    String payload,
  ) => _plugin.periodicallyShowWithDuration(
    reminderId,
    '💧 Time to hydrate',
    'Take a moment to drink some water.',
    Duration(minutes: intervalMinutes),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'hydrate_reminders_v2',
        'Water reminders',
        channelDescription: 'Reminders to drink water',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      ),
    ),
    androidScheduleMode: mode,
    payload: payload,
  );

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    await init();
    return _plugin.pendingNotificationRequests();
  }

  Future<void> showImmediateTestNotification() async {
    await init();
    await _plugin.show(
      testId,
      '💧 Test water reminder',
      'Notifications are working on this device.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hydrate_reminders_v2',
          'Water reminders',
          channelDescription: 'Reminders to drink water',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentList: true,
          presentSound: true,
        ),
      ),
    );
  }
}
