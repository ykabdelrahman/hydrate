import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/providers/repository_providers.dart';
import 'package:hydrate/core/providers/user_preferences_provider.dart';
import 'package:hydrate/core/domain/models/water_log.dart';
import 'package:hydrate/core/domain/models/daily_summary.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';
import 'package:hydrate/core/data/repositories/dummy_water_repository.dart';

class WaterIntakeState {
  final double currentIntake;
  final double dailyGoal;
  final String unit;

  WaterIntakeState({
    required this.currentIntake,
    required this.dailyGoal,
    required this.unit,
  });

  WaterIntakeState copyWith({
    double? currentIntake,
    double? dailyGoal,
    String? unit,
  }) {
    return WaterIntakeState(
      currentIntake: currentIntake ?? this.currentIntake,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      unit: unit ?? this.unit,
    );
  }
}

class WaterIntakeNotifier extends StateNotifier<WaterIntakeState> {
  final IWaterRepository _waterRepository;
  final Ref _ref;
  late final Future<void> _initialLoad;

  WaterIntakeNotifier(this._waterRepository, this._ref)
    : super(WaterIntakeState(currentIntake: 0, dailyGoal: 2000, unit: 'ml')) {
    _syncWithUserPreferences();
    // Load today's intake if we have a real repository
    _initialLoad = _waterRepository is DummyWaterRepository
        ? Future.value()
        : _loadTodaysIntake();
  }

  Future<void> _loadTodaysIntake() async {
    final today = DateTime.now();
    final logs = await _waterRepository.getWaterLogsForDate(today);
    final totalIntake = logs.fold<double>(0, (sum, log) => sum + log.amountMl);

    state = state.copyWith(currentIntake: totalIntake);

    // Ensure we have a daily summary for today
    await _updateDailySummary();
  }

  void _syncWithUserPreferences() {
    // Get initial preferences
    final currentPrefs = _ref.read(userPreferencesProvider);
    state = state.copyWith(
      dailyGoal: currentPrefs.dailyGoalMl,
      unit: currentPrefs.unit,
    );

    // Listen for future changes
    _ref.listen(userPreferencesProvider, (previous, next) {
      state = state.copyWith(dailyGoal: next.dailyGoalMl, unit: next.unit);
    });
  }

  Future<void> addWater(double amount) async {
    await _initialLoad;
    // Convert to ml if needed
    final amountInMl = state.unit == 'oz' ? amount * 29.5735 : amount;

    state = state.copyWith(currentIntake: state.currentIntake + amountInMl);
    await _waterRepository.addWaterLog(
      WaterLog(timestamp: DateTime.now(), amountMl: amountInMl),
    );

    // Update daily summary for today
    await _updateDailySummary();
  }

  Future<void> setGoal(double goal) async {
    await _ref.read(userPreferencesProvider.notifier).updateGoal(goal);
  }

  Future<void> resetDailyIntake() async {
    await _initialLoad;
    // Clear today's water logs from storage
    final today = DateTime.now();
    await _waterRepository.clearWaterLogsForDate(today);

    // Reset the in-memory state
    state = state.copyWith(currentIntake: 0);

    // Update daily summary to reflect the reset
    await _updateDailySummary();
  }

  Future<void> _updateDailySummary() async {
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    // Get all logs for today and calculate total
    final logs = await _waterRepository.getWaterLogsForDate(today);
    final totalIntake = logs.fold<double>(0, (sum, log) => sum + log.amountMl);

    // Create or update daily summary
    final summary = DailySummary(
      date: normalizedDate,
      totalIntakeMl: totalIntake,
    );

    await _waterRepository.addDailySummary(summary);
  }

  double getCurrentIntakeInDisplayUnit() {
    return state.unit == 'oz'
        ? state.currentIntake / 29.5735
        : state.currentIntake;
  }

  double getDailyGoalInDisplayUnit() {
    return state.unit == 'oz' ? state.dailyGoal / 29.5735 : state.dailyGoal;
  }
}

final waterIntakeNotifierProvider =
    StateNotifierProvider<WaterIntakeNotifier, WaterIntakeState>((ref) {
      return WaterIntakeNotifier(ref.watch(waterRepositoryProvider), ref);
    });
