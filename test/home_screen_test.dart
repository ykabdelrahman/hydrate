import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate/core/providers/water_intake_provider.dart';
import 'package:hydrate/core/domain/repositories/water_repository.dart';
import 'package:hydrate/features/home/home_screen.dart';
import 'package:hydrate/features/home/widgets/current_intake_display.dart';
import 'package:hydrate/features/home/widgets/quick_add_buttons.dart';
import 'package:hydrate/features/home/widgets/water_progress_indicator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_screen_test.mocks.dart';
import 'test_helper.dart';

@GenerateMocks([IWaterRepository])
void main() {
  setUpAll(() async {
    await initHive();
  });
  group('HomeScreen', () {
    testWidgets(
      'displays WaterProgressIndicator, CurrentIntakeDisplay, and QuickAddButtons',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: HomeScreen())),
        );

        expect(find.byType(WaterProgressIndicator), findsOneWidget);
        expect(find.byType(CurrentIntakeDisplay), findsOneWidget);
        expect(find.byType(QuickAddButtons), findsOneWidget);
      },
    );

    testWidgets('quick add buttons add water', (tester) async {
      final mockWaterRepository = MockIWaterRepository();
      when(mockWaterRepository.addWaterLog(any)).thenAnswer((_) async => {});
      when(
        mockWaterRepository.getWaterLogsForDate(any),
      ).thenAnswer((_) async => []);
      when(mockWaterRepository.addDailySummary(any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            waterIntakeNotifierProvider.overrideWith(
              (ref) => WaterIntakeNotifier(mockWaterRepository, ref),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Initial state
      expect(
        find.descendant(
          of: find.byType(CurrentIntakeDisplay),
          matching: find.text('0'),
        ),
        findsOneWidget,
      );

      // Tap 250ml button
      final quickAddButton = find
          .descendant(
            of: find.byType(QuickAddButtons),
            matching: find.byType(ElevatedButton),
          )
          .first;
      await tester.ensureVisible(quickAddButton);
      await tester.tap(quickAddButton);
      await tester.pumpAndSettle();
      verify(mockWaterRepository.addWaterLog(any)).called(1);
    });
  });
}
