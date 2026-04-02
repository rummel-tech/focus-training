import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_training/src/services/focus_training_service.dart';
import 'package:focus_training/src/ui/screens/session_screen.dart';

Widget _buildApp({required FocusTrainingService service}) {
  return MaterialApp(home: SessionScreen(service: service));
}

void main() {
  group('SessionScreen', () {
    late FocusTrainingService service;

    setUp(() {
      service = FocusTrainingService();
    });

    group('setup view', () {
      testWidgets('shows duration choice chips', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        for (final minutes in [15, 25, 45, 60, 90, 120]) {
          expect(find.text('$minutes min'), findsOneWidget);
        }
      });

      testWidgets('25 min chip is selected by default', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        final chip = tester.widget<ChoiceChip>(
          find.ancestor(
            of: find.text('25 min'),
            matching: find.byType(ChoiceChip),
          ),
        );
        expect(chip.selected, isTrue);
      });

      testWidgets('notes field is present', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Session notes (optional)'), findsOneWidget);
        expect(find.text('What will you focus on?'), findsOneWidget);
      });

      testWidgets('shows Start Focus Session button', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('Start Focus Session'), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('shows New Session title', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('New Session'), findsOneWidget);
      });

      testWidgets('tapping a different chip selects it', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.text('45 min'));
        await tester.pump();

        final chip = tester.widget<ChoiceChip>(
          find.ancestor(
            of: find.text('45 min'),
            matching: find.byType(ChoiceChip),
          ),
        );
        expect(chip.selected, isTrue);
      });
    });

    group('active view', () {
      testWidgets('tapping Start transitions to active view', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.text('Start Focus Session'));
        // pump once — pumpAndSettle won't work due to periodic timer
        await tester.pump();

        expect(find.text('Focusing...'), findsOneWidget);
        expect(find.text('Start Focus Session'), findsNothing);
      });

      testWidgets('active view has circular progress indicator',
          (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.text('Start Focus Session'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('active view has focus score slider', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.text('Start Focus Session'));
        await tester.pump();

        expect(find.byType(Slider), findsOneWidget);
        expect(find.text('How focused are you?'), findsOneWidget);
      });

      testWidgets('active view has Complete Session button', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.text('Start Focus Session'));
        await tester.pump();

        expect(find.text('Complete Session'), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('active view shows remaining label', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.text('Start Focus Session'));
        await tester.pump();

        expect(find.text('remaining'), findsOneWidget);
      });
    });

    group('completion view', () {
      testWidgets('completing session shows feedback', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.text('Start Focus Session'));
        await tester.pump();

        await tester.tap(find.text('Complete Session'));
        await tester.pumpAndSettle();

        expect(find.text('Session Complete'), findsOneWidget);
        expect(find.byIcon(Icons.celebration), findsOneWidget);
      });

      testWidgets('completion shows summary stats', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.text('Start Focus Session'));
        await tester.pump();

        await tester.tap(find.text('Complete Session'));
        await tester.pumpAndSettle();

        expect(find.text('Level'), findsOneWidget);
        expect(find.text('Total XP'), findsOneWidget);
        expect(find.text('Streak'), findsOneWidget);
        expect(find.text('Sessions'), findsOneWidget);
      });

      testWidgets('completion shows Done button', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.text('Start Focus Session'));
        await tester.pump();

        await tester.tap(find.text('Complete Session'));
        await tester.pumpAndSettle();

        expect(find.text('Done'), findsOneWidget);
      });

      testWidgets('feedback text contains XP info', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        await tester.tap(find.text('Start Focus Session'));
        await tester.pump();

        await tester.tap(find.text('Complete Session'));
        await tester.pumpAndSettle();

        // Default focus score is 80 -> "Great work!" feedback
        expect(find.textContaining('XP'), findsWidgets);
      });
    });
  });
}
