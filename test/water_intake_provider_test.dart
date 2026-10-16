import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/providers/water_intake_provider.dart';
import 'package:hydrate/core/providers/repository_providers.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helper.dart';
import 'water_intake_provider_test.mocks.dart';

@GenerateMocks([IWaterRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WaterIntakeNotifier waterIntakeNotifier;
  late MockIWaterRepository mockWaterRepository;
  late ProviderContainer container;

  setUp(() async {
    await initHive();
    SharedPreferences.setMockInitialValues({});
    mockWaterRepository = MockIWaterRepository();
    when(
      mockWaterRepository.getWaterLogsForDate(any),
    ).thenAnswer((_) async => []);
    when(mockWaterRepository.addDailySummary(any)).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [
        waterRepositoryProvider.overrideWithValue(mockWaterRepository),
      ],
    );
    waterIntakeNotifier = container.read(waterIntakeNotifierProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('initial state is correct', () {
    expect(waterIntakeNotifier.state.currentIntake, 0);
    expect(waterIntakeNotifier.state.dailyGoal, 2000);
    expect(waterIntakeNotifier.state.unit, 'ml');
  });

  test(
    'addWater should update the current intake and call the repository',
    () async {
      const amount = 250.0;
      when(mockWaterRepository.addWaterLog(any)).thenAnswer((_) async => {});

      await waterIntakeNotifier.addWater(amount);

      expect(waterIntakeNotifier.state.currentIntake, amount);
      verify(mockWaterRepository.addWaterLog(any)).called(1);
    },
  );
}
