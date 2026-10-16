import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hydrate/core/data/hive_service.dart';
import 'package:hydrate/core/data/repositories/dummy_user_preferences_repository.dart';
import 'package:hydrate/core/data/repositories/dummy_water_repository.dart';
import 'package:hydrate/core/data/repositories/user_preferences_repository_impl.dart';
import 'package:hydrate/core/data/repositories/water_repository_impl.dart';
import 'package:hydrate/core/domain/models/daily_summary.dart';
import 'package:hydrate/core/domain/models/user_preferences.dart';
import 'package:hydrate/core/domain/models/water_log.dart';
import 'package:hydrate/core/domain/repositories/user_preferences_repository.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

final waterLogBoxProvider = FutureProvider<Box<WaterLog>>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return await hiveService.openBox<WaterLog>('water_log');
});

final dailySummaryBoxProvider = FutureProvider<Box<DailySummary>>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return await hiveService.openBox<DailySummary>('daily_summary');
});

final userPreferencesBoxProvider = FutureProvider<Box<UserPreferences>>((
  ref,
) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return await hiveService.openBox<UserPreferences>('user_preferences');
});

final waterRepositoryProvider = Provider<IWaterRepository>((ref) {
  final waterLogBox = ref.watch(waterLogBoxProvider);
  final dailySummaryBox = ref.watch(dailySummaryBoxProvider);

  return waterLogBox.when(
    data: (waterLogBoxData) => dailySummaryBox.when(
      data: (dailySummaryBoxData) =>
          WaterRepositoryImpl(waterLogBoxData, dailySummaryBoxData),
      loading: () => DummyWaterRepository(),
      error: (error, stackTrace) => DummyWaterRepository(),
    ),
    loading: () => DummyWaterRepository(),
    error: (error, stackTrace) => DummyWaterRepository(),
  );
});

final userPreferencesRepositoryProvider = Provider<IUserPreferencesRepository>((
  ref,
) {
  // AppInitializer opens this box before runApp. Use it immediately so a
  // reminder change made on the first screen is saved to the real repository.
  if (Hive.isBoxOpen('user_preferences')) {
    return UserPreferencesRepositoryImpl(
      Hive.box<UserPreferences>('user_preferences'),
    );
  }
  final userPreferencesBox = ref.watch(userPreferencesBoxProvider);

  return userPreferencesBox.when(
    data: (userPreferencesBoxData) =>
        UserPreferencesRepositoryImpl(userPreferencesBoxData),
    loading: () => DummyUserPreferencesRepository(),
    error: (error, stackTrace) => DummyUserPreferencesRepository(),
  );
});
