import 'package:test/test.dart';
import 'package:focus_training/focus_training.dart';

void main() {
  group('FocusSession', () {
    test('should calculate XP correctly for completed session', () {
      final session = FocusSession(
        id: '1',
        startTime: DateTime.now(),
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 25),
        focusScore: 80,
        completed: true,
      );

      final xp = session.calculateXP();
      // Base (10) + Duration (25) + Focus bonus (40) = 75
      expect(xp, equals(75));
    });

    test('should return 0 XP for incomplete session', () {
      final session = FocusSession(
        id: '1',
        startTime: DateTime.now(),
        plannedDuration: const Duration(minutes: 25),
        completed: false,
      );

      expect(session.calculateXP(), equals(0));
    });

    test('should serialize to/from JSON', () {
      final session = FocusSession(
        id: '1',
        startTime: DateTime(2026, 1, 17, 10, 0),
        endTime: DateTime(2026, 1, 17, 10, 25),
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 25),
        focusScore: 85,
        completed: true,
        notes: 'Test session',
      );

      final json = session.toJson();
      final restored = FocusSession.fromJson(json);

      expect(restored.id, equals(session.id));
      expect(restored.focusScore, equals(session.focusScore));
      expect(restored.completed, equals(session.completed));
      expect(restored.notes, equals(session.notes));
    });
  });

  group('Achievement', () {
    test('should create predefined achievements correctly', () {
      final achievement = Achievement.create(AchievementType.firstSession);

      expect(achievement.name, equals('First Steps'));
      expect(achievement.xpReward, equals(50));
      expect(achievement.unlocked, isFalse);
    });

    test('should serialize to/from JSON', () {
      final achievement = Achievement.create(AchievementType.streak7Days)
          .copyWith(unlocked: true, unlockedAt: DateTime(2026, 1, 17));

      final json = achievement.toJson();
      final restored = Achievement.fromJson(json);

      expect(restored.type, equals(achievement.type));
      expect(restored.name, equals(achievement.name));
      expect(restored.unlocked, isTrue);
    });
  });

  group('UserProgress', () {
    test('should calculate level from XP correctly', () {
      expect(UserProgress.calculateLevel(0), equals(1));
      expect(UserProgress.calculateLevel(99), equals(1));
      expect(UserProgress.calculateLevel(200), equals(2));
      expect(UserProgress.calculateLevel(600), equals(3));
    });

    test('should calculate average focus score', () {
      final sessions = [
        FocusSession(
          id: '1',
          startTime: DateTime.now(),
          plannedDuration: const Duration(minutes: 25),
          focusScore: 80,
          completed: true,
        ),
        FocusSession(
          id: '2',
          startTime: DateTime.now(),
          plannedDuration: const Duration(minutes: 25),
          focusScore: 90,
          completed: true,
        ),
      ];

      final progress = UserProgress(recentSessions: sessions);
      expect(progress.averageFocusScore, equals(85.0));
    });

    test('should serialize to/from JSON', () {
      final progress = UserProgress(
        totalXP: 500,
        level: 3,
        currentStreak: 7,
        totalSessions: 20,
      );

      final json = progress.toJson();
      final restored = UserProgress.fromJson(json);

      expect(restored.totalXP, equals(progress.totalXP));
      expect(restored.level, equals(progress.level));
      expect(restored.currentStreak, equals(progress.currentStreak));
      expect(restored.totalSessions, equals(progress.totalSessions));
    });
  });

  group('FocusTrainingService', () {
    late FocusTrainingService service;

    setUp(() {
      service = FocusTrainingService();
    });

    test('should start a new session', () {
      final session = service.startSession(
        plannedDuration: const Duration(minutes: 25),
        notes: 'Test session',
      );

      expect(session.plannedDuration, equals(const Duration(minutes: 25)));
      expect(session.notes, equals('Test session'));
      expect(session.completed, isFalse);
    });

    test('should complete session and update progress', () {
      var session = service.startSession(
        plannedDuration: const Duration(minutes: 25),
      );

      session = service.completeSession(
        session: session,
        focusScore: 85,
      );

      expect(session.completed, isTrue);
      expect(session.focusScore, equals(85));
      expect(service.progress.totalSessions, equals(1));
      expect(service.progress.totalXP, greaterThan(0));
    });

    test('should unlock first session achievement', () {
      var session = service.startSession(
        plannedDuration: const Duration(minutes: 25),
      );

      service.completeSession(session: session, focusScore: 80);

      final achievements = service.progress.achievements;
      expect(achievements.length, greaterThan(0));
      expect(
        achievements.any((a) => a.type == AchievementType.firstSession),
        isTrue,
      );
    });

    test('should track streak correctly', () {
      // First session
      var session = service.startSession(
        plannedDuration: const Duration(minutes: 25),
      );
      service.completeSession(session: session, focusScore: 80);

      expect(service.progress.currentStreak, equals(1));

      // Second session (same day - streak stays 1)
      session = service.startSession(
        plannedDuration: const Duration(minutes: 25),
      );
      service.completeSession(session: session, focusScore: 80);

      expect(service.progress.currentStreak, equals(1));
    });

    test('should provide motivational feedback', () {
      var session = service.startSession(
        plannedDuration: const Duration(minutes: 25),
      );
      session = service.completeSession(session: session, focusScore: 95);

      final feedback = service.getFeedback(session);
      expect(feedback, contains('Outstanding'));
      expect(feedback, contains('XP'));
    });

    test('should calculate level progress percentage', () {
      var session = service.startSession(
        plannedDuration: const Duration(minutes: 25),
      );
      service.completeSession(session: session, focusScore: 80);

      final progress = service.getLevelProgress();
      expect(progress, greaterThanOrEqualTo(0));
      expect(progress, lessThanOrEqualTo(100));
    });

    test('should save and load progress', () {
      var session = service.startSession(
        plannedDuration: const Duration(minutes: 25),
      );
      service.completeSession(session: session, focusScore: 80);

      final savedData = service.saveProgress();
      final newService = FocusTrainingService();
      newService.loadProgress(savedData);

      expect(newService.progress.totalSessions, equals(1));
      expect(newService.progress.totalXP, equals(service.progress.totalXP));
    });

    test('should reset progress', () {
      var session = service.startSession(
        plannedDuration: const Duration(minutes: 25),
      );
      service.completeSession(session: session, focusScore: 80);

      service.resetProgress();

      expect(service.progress.totalSessions, equals(0));
      expect(service.progress.totalXP, equals(0));
      expect(service.progress.achievements, isEmpty);
    });

    test('should unlock perfect score achievement', () {
      var session = service.startSession(
        plannedDuration: const Duration(minutes: 25),
      );
      service.completeSession(session: session, focusScore: 100);

      final hasAchievement = service.progress.achievements.any(
        (a) => a.type == AchievementType.perfectScore && a.unlocked,
      );
      expect(hasAchievement, isTrue);
    });
  });
}
