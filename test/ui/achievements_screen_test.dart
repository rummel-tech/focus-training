import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_training/src/models/achievement.dart';
import 'package:focus_training/src/services/focus_training_service.dart';
import 'package:focus_training/src/ui/screens/achievements_screen.dart';

Widget _buildApp({required FocusTrainingService service}) {
  return MaterialApp(home: AchievementsScreen(service: service));
}

void main() {
  group('AchievementsScreen', () {
    group('with no unlocked achievements', () {
      late FocusTrainingService service;

      setUp(() {
        service = FocusTrainingService();
      });

      testWidgets('shows all achievements as locked', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        final lockedCount = AchievementType.values.length;
        expect(find.text('Locked ($lockedCount)'), findsOneWidget);
      });

      testWidgets('does not show Unlocked section', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.textContaining('Unlocked'), findsNothing);
      });

      testWidgets('shows lock icons for visible achievements', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('🔒'), findsWidgets);

        // Scroll to bottom to verify more lock icons appear
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pump();
        expect(find.text('🔒'), findsWidgets);
      });

      testWidgets('shows achievement names', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('First Steps'), findsOneWidget);
        expect(find.text('Perfect Focus'), findsOneWidget);
        expect(find.text('Week Warrior'), findsOneWidget);
      });

      testWidgets('shows XP rewards', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('+50 XP'), findsOneWidget); // First Steps
        expect(find.text('+300 XP'), findsOneWidget); // Perfect Focus
      });

      testWidgets('displays Achievements title in app bar', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('Achievements'), findsOneWidget);
      });
    });

    group('with some unlocked achievements', () {
      late FocusTrainingService service;

      setUp(() {
        service = FocusTrainingService();
        final session = service.startSession(
          plannedDuration: const Duration(minutes: 25),
        );
        service.completeSession(session: session, focusScore: 85);
      });

      testWidgets('shows Unlocked section with count', (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        expect(find.text('Unlocked (1)'), findsOneWidget);
      });

      testWidgets('shows Locked section with remaining count',
          (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        final remaining = AchievementType.values.length - 1;
        expect(find.text('Locked ($remaining)'), findsOneWidget);
      });

      testWidgets('unlocked achievement shows its icon instead of lock',
          (tester) async {
        await tester.pumpWidget(_buildApp(service: service));

        // First Steps achievement icon is 🎯
        expect(find.text('🎯'), findsOneWidget);
      });

      testWidgets('multiple unlocked achievements shown correctly',
          (tester) async {
        // Complete a session with perfect score to unlock two achievements
        final svc = FocusTrainingService();
        final session = svc.startSession(
          plannedDuration: const Duration(minutes: 25),
        );
        svc.completeSession(session: session, focusScore: 100);

        await tester.pumpWidget(_buildApp(service: svc));

        // firstSession + perfectScore = 2 unlocked
        expect(find.text('Unlocked (2)'), findsOneWidget);
        expect(find.text('🎯'), findsOneWidget); // First Steps
        expect(find.text('💯'), findsOneWidget); // Perfect Focus
      });
    });
  });
}
