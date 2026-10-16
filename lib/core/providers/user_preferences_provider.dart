import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/domain/models/user_preferences.dart';
import 'package:hydrate/core/domain/repositories/user_preferences_repository.dart';
import 'package:hydrate/core/providers/repository_providers.dart';
import 'package:hydrate/core/providers/notification_provider.dart';
import 'package:hydrate/core/services/notification_service.dart';
import 'package:hydrate/core/utils/app_initializer.dart';
import 'package:hydrate/core/domain/use_cases/calculate_recommended_intake.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
      final repository = ref.watch(userPreferencesRepositoryProvider);
      final notificationService = ref.watch(notificationServiceProvider);
      return UserPreferencesNotifier(repository, notificationService);
    });

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final IUserPreferencesRepository _userPreferencesRepository;
  final NotificationService _notificationService;
  final CalculateRecommendedIntake _calculateRecommendedIntake =
      CalculateRecommendedIntake();

  UserPreferencesNotifier(
    this._userPreferencesRepository, [
    NotificationService? notificationService,
  ]) : _notificationService = notificationService ?? NotificationService(),
       super(AppInitializer.getInitialPreferences());

  Future<void> loadUserPreferences() async {
    final preferences = await _userPreferencesRepository.loadUserPreferences();
    if (preferences != null) {
      state = preferences;
    }
  }

  Future<void> updateGoal(double newGoal) async {
    state = state.copyWith(dailyGoalMl: newGoal);
    await _userPreferencesRepository.saveUserPreferences(state);
  }

  Future<void> updateUnit(String newUnit) async {
    state = state.copyWith(unit: newUnit);
    await _userPreferencesRepository.saveUserPreferences(state);
  }

  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(darkModeEnabled: value);
    await _userPreferencesRepository.saveUserPreferences(state);

    // Also save to SharedPreferences for background notification access
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode_enabled', value);
      print('Dark mode preference saved: $value');
    } catch (e) {
      print('Failed to save dark mode preference: $e');
    }
  }

  Future<void> updateNotificationInterval(int intervalMinutes) async {
    final previousInterval = state.notificationIntervalMinutes;
    await _notificationService.scheduleIntervalReminders(intervalMinutes);
    final updated = state.copyWith(
      notificationIntervalMinutes: intervalMinutes,
    );
    try {
      await _userPreferencesRepository.saveUserPreferences(updated);
    } catch (_) {
      await _notificationService.scheduleIntervalReminders(previousInterval);
      rethrow;
    }
    state = updated;
  }

  Future<void> updateWeight(double newWeight) async {
    // Calculate new recommended intake based on weight
    final recommendedIntake = _calculateRecommendedIntake(newWeight);

    state = state.copyWith(weightKg: newWeight, dailyGoalMl: recommendedIntake);
    await _userPreferencesRepository.saveUserPreferences(state);
  }

  double getRecommendedIntakeForCurrentWeight() {
    return _calculateRecommendedIntake(state.weightKg);
  }

  bool isUsingRecommendedGoal() {
    final recommended = getRecommendedIntakeForCurrentWeight();
    return (state.dailyGoalMl - recommended).abs() <
        50; // Within 50ml tolerance
  }

  Future<void> updateDailyGoal(double newGoalMl) async {
    state = state.copyWith(dailyGoalMl: newGoalMl);
    await _userPreferencesRepository.saveUserPreferences(state);
  }
}
