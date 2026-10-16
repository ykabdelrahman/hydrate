import 'dart:io' show Platform;

import 'package:hive/hive.dart';
import 'package:hydrate/core/domain/models/user_preferences.dart';
import 'package:hydrate/core/services/background_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class AppInitializer {
  static UserPreferences? _cachedPreferences;

  static Future<void> initialize() async {
    // One-time migration from the old WorkManager reminder implementation.
    // Its one-off tasks had unique names, so cancelByUniqueName was insufficient.
    try {
      final prefs = await SharedPreferences.getInstance();
      if (Platform.isAndroid &&
          !(prefs.getBool('water_reminders_workmanager_migrated') ?? false)) {
        await BackgroundNotificationService.initialize();
        await Workmanager().cancelAll();
        await prefs.setBool('notifications_enabled', false);
        await prefs.setBool('water_reminders_workmanager_migrated', true);
      }
    } catch (e) {
      // Retry the migration on the next launch.
      print('Failed to migrate old reminder tasks: $e');
    }

    // Load preferences synchronously during app startup
    try {
      final box = await Hive.openBox<UserPreferences>('user_preferences');
      _cachedPreferences = box.get('user_preferences');
    } catch (e) {
      // If there's an error, use default preferences
      _cachedPreferences = null;
    }
  }

  static UserPreferences getInitialPreferences() {
    final preferences =
        _cachedPreferences ??
        UserPreferences(
          dailyGoalMl: 2000,
          unit: 'ml',
          notificationIntervalMinutes: 60, // Default: every 1 hour
          darkModeEnabled: false,
          weightKg: 70,
        );

    // Sync dark mode preference to SharedPreferences for background access
    _syncDarkModePreference(preferences.darkModeEnabled);

    return preferences;
  }

  /// Sync dark mode preference to SharedPreferences for background notifications
  static void _syncDarkModePreference(bool darkModeEnabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode_enabled', darkModeEnabled);
    } catch (e) {
      print('Failed to sync dark mode preference: $e');
    }
  }

  static bool get hasLoadedPreferences => _cachedPreferences != null;
}
