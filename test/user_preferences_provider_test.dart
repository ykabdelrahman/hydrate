import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/core/providers/user_preferences_provider.dart';
import 'package:hydrate/core/domain/models/user_preferences.dart';
import 'package:hydrate/core/domain/repositories/user_preferences_repository.dart';
import 'package:hydrate/core/services/notification_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_preferences_provider_test.mocks.dart';
import 'test_helper.dart';

class RecordingNotificationService extends NotificationService {
  final scheduledIntervals = <int>[];

  @override
  Future<void> scheduleIntervalReminders(int intervalMinutes) async {
    scheduledIntervals.add(intervalMinutes);
  }
}

@GenerateMocks([IUserPreferencesRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UserPreferencesNotifier userPreferencesNotifier;
  late MockIUserPreferencesRepository mockUserPreferencesRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initHive();
    mockUserPreferencesRepository = MockIUserPreferencesRepository();
    userPreferencesNotifier = UserPreferencesNotifier(
      mockUserPreferencesRepository,
    );
  });

  test('initial state is correct', () {
    expect(
      userPreferencesNotifier.state,
      UserPreferences(
        dailyGoalMl: 2000,
        unit: 'ml',
        notificationIntervalMinutes: 60,
        darkModeEnabled: false,
        weightKg: 70,
      ),
    );
  });

  test('loadUserPreferences should update the state', () async {
    final preferences = UserPreferences(
      dailyGoalMl: 2500,
      unit: 'oz',
      notificationIntervalMinutes: 180,
      darkModeEnabled: true,
      weightKg: 80,
    );
    when(
      mockUserPreferencesRepository.loadUserPreferences(),
    ).thenAnswer((_) async => preferences);

    await userPreferencesNotifier.loadUserPreferences();

    expect(userPreferencesNotifier.state, preferences);
  });

  test('updateGoal should update the state and save the preferences', () async {
    const newGoal = 3000.0;
    when(
      mockUserPreferencesRepository.saveUserPreferences(any),
    ).thenAnswer((_) async => {});

    await userPreferencesNotifier.updateGoal(newGoal);

    expect(userPreferencesNotifier.state.dailyGoalMl, newGoal);
    verify(mockUserPreferencesRepository.saveUserPreferences(any)).called(1);
  });

  test('failed preference save restores the previous reminder', () async {
    final notifications = RecordingNotificationService();
    final notifier = UserPreferencesNotifier(
      mockUserPreferencesRepository,
      notifications,
    );
    when(
      mockUserPreferencesRepository.saveUserPreferences(any),
    ).thenThrow(StateError('save failed'));

    await expectLater(
      notifier.updateNotificationInterval(30),
      throwsStateError,
    );
    expect(notifications.scheduledIntervals, [30, 60]);
    expect(notifier.state.notificationIntervalMinutes, 60);
  });
}
