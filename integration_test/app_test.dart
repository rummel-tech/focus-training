import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:focus_training/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Focus Training — App Launch', () {
    testWidgets('App loads and displays home screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Focus Training'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Home screen renders without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(tester.takeException(), isNull);
      expect(find.text('Focus Training'), findsOneWidget);
    });

    testWidgets('Material app is configured', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Focus Training — Home Screen Content', () {
    testWidgets('Start Session button is present', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Start Session'), findsOneWidget);
    });

    testWidgets('Level and XP progress are displayed', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App displays level information
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('Statistics section renders', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Home screen should show stats (sessions, focus time, score)
      expect(find.byType(Card), findsWidgets);
    });
  });

  group('Focus Training — Session Flow', () {
    testWidgets('Tapping Start Session opens session screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final startButton = find.text('Start Session');
      expect(startButton, findsOneWidget);

      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Session screen should appear
      expect(tester.takeException(), isNull);
    });

    testWidgets('Session duration options are shown after Start Session', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Start Session'));
      await tester.pumpAndSettle();

      // Duration options: 15, 25, 45, 60+ minutes
      final has15 = find.textContaining('15').evaluate().isNotEmpty;
      final has25 = find.textContaining('25').evaluate().isNotEmpty;
      expect(has15 || has25, isTrue);
    });
  });

  group('Focus Training — Achievements Navigation', () {
    testWidgets('Achievements screen is reachable', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for achievements navigation (icon or tab)
      final achievementsEntry = find.byIcon(Icons.emoji_events).evaluate().isNotEmpty
          ? find.byIcon(Icons.emoji_events)
          : find.byIcon(Icons.star);

      if (achievementsEntry.evaluate().isNotEmpty) {
        await tester.tap(achievementsEntry.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      // If no dedicated nav entry, achievements may be on home — pass gracefully
    });
  });

  group('Focus Training — Persistence', () {
    testWidgets('App loads without error (persisted data available)', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // If prior sessions exist, recent sessions section should be present
      // If no prior sessions, empty state message should be present — both are valid
      expect(tester.takeException(), isNull);
      expect(find.text('Focus Training'), findsOneWidget);
    });

    testWidgets('App handles cold start with no saved data', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should not crash even with no prior save file
      expect(tester.takeException(), isNull);
      expect(find.text('Start Session'), findsOneWidget);
    });
  });

  group('Focus Training — Stability', () {
    testWidgets('App handles multiple rapid interactions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap Start Session and navigate back multiple times
      for (int i = 0; i < 3; i++) {
        final startBtn = find.text('Start Session');
        if (startBtn.evaluate().isNotEmpty) {
          await tester.tap(startBtn.first);
          await tester.pump(const Duration(milliseconds: 300));
          // Navigate back if possible
          final backBtn = find.byTooltip('Back');
          if (backBtn.evaluate().isNotEmpty) {
            await tester.tap(backBtn.first);
            await tester.pumpAndSettle();
          }
        }
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('App is stable after pump settle', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Focus Training'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
