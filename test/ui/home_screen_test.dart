import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_training/src/services/focus_training_service.dart';
import 'package:focus_training/src/ui/screens/home_screen.dart';

Widget _buildApp({required FocusTrainingService service}) {
  return MaterialApp(home: HomeScreen(service: service));
}

void main() {
  group('HomeScreen', () {
    group('empty state', () {
      late FocusTrainingService service;

      setUp(() {
        service = FocusTrainingService();
      });

      testWidgets('shows empty state message when no sessions exist',
          (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('Start your first focus session'), findsOneWidget);
        expect(find.byIcon(Icons.self_improvement), findsOneWidget);
      });

      testWidgets('does not show Recent Sessions heading', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('Recent Sessions'), findsNothing);
      });

      testWidgets('shows level 1 with 0 XP', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('Level 1'), findsOneWidget);
        expect(find.text('0 XP total'), findsOneWidget);
      });

      testWidgets('shows 0 stats', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('0 days'), findsOneWidget); // streak
        expect(find.text('0'), findsOneWidget); // sessions count
        expect(find.text('0m'), findsOneWidget); // focus time
        expect(find.text('-'), findsOneWidget); // avg score (no data)
      });
    });

    group('with completed sessions', () {
      late FocusTrainingService service;

      setUp(() {
        service = FocusTrainingService();
        final session = service.startSession(
          plannedDuration: const Duration(minutes: 25),
        );
        service.completeSession(session: session, focusScore: 85);
      });

      testWidgets('shows updated session count', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('1'), findsWidgets); // total sessions and level 1
      });

      testWidgets('shows streak of 1 day', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('1 days'), findsOneWidget);
      });

      testWidgets('shows Recent Sessions heading', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('Recent Sessions'), findsOneWidget);
      });

      testWidgets('hides empty state message', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('Start your first focus session'), findsNothing);
      });

      testWidgets('shows Recent Achievements section', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('Recent Achievements'), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('tapping FAB does not crash', (tester) async {
        final service = FocusTrainingService();
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.text('Start Session'));
        await tester.pumpAndSettle();

        expect(find.text('New Session'), findsOneWidget);
      });

      testWidgets('achievements button exists in app bar', (tester) async {
        final service = FocusTrainingService();
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.byIcon(Icons.emoji_events), findsOneWidget);
        expect(find.byTooltip('Achievements'), findsOneWidget);
      });

      testWidgets('tapping achievements button navigates', (tester) async {
        final service = FocusTrainingService();
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.byIcon(Icons.emoji_events));
        await tester.pumpAndSettle();

        expect(find.text('Achievements'), findsOneWidget);
      });
    });
  });
}
