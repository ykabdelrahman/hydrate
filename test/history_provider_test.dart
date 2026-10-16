import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/providers/history_provider.dart';
import 'package:hydrate/core/providers/repository_providers.dart';
import 'package:hydrate/core/domain/models/daily_summary.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'history_provider_test.mocks.dart';
import 'test_helper.dart';

@GenerateMocks([IWaterRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HistoryNotifier historyNotifier;
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
    when(
      mockWaterRepository.getWaterIntakeHistory(),
    ).thenAnswer((_) async => []);
    container = ProviderContainer(
      overrides: [
        waterRepositoryProvider.overrideWithValue(mockWaterRepository),
      ],
    );
    historyNotifier = container.read(historyProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('initial state is an empty list', () {
    expect(historyNotifier.state.history, []);
  });

  test('loadHistory should update the state with the history', () async {
    final history = [DailySummary(date: DateTime.now(), totalIntakeMl: 1500)];
    when(
      mockWaterRepository.getWaterIntakeHistory(),
    ).thenAnswer((_) async => history);

    await historyNotifier.loadHistory();

    expect(historyNotifier.state.history, history);
  });
}
