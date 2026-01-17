import 'package:uuid/uuid.dart';

import '../models/achievement.dart';
import '../models/focus_session.dart';
import '../models/user_progress.dart';

const _uuid = Uuid();

/// Result of checking achievements
class _AchievementCheckResult {
  final List<Achievement> achievements;
  final int xpEarned;

  const _AchievementCheckResult({
    required this.achievements,
    required this.xpEarned,
  });
}

/// Service for managing focus training sessions and gamification
class FocusTrainingService {
  UserProgress _progress;

  FocusTrainingService({UserProgress? initialProgress})
      : _progress = initialProgress ?? const UserProgress();

  /// Get current user progress
  UserProgress get progress => _progress;

  /// Start a new focus session
  FocusSession startSession({
    required Duration plannedDuration,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    final session = FocusSession(
      id: _uuid.v4(),
      startTime: DateTime.now(),
      plannedDuration: plannedDuration,
      notes: notes,
      metadata: metadata ?? {},
    );
    return session;
  }

  /// Complete a focus session and update progress
  FocusSession completeSession({
    required FocusSession session,
    required int focusScore,
    String? notes,
  }) {
    final completedSession = session.copyWith(
      endTime: DateTime.now(),
      actualDuration: DateTime.now().difference(session.startTime),
      focusScore: focusScore,
      completed: true,
      notes: notes ?? session.notes,
    );

    // Update progress
    _updateProgress(completedSession);

    return completedSession;
  }

  /// Update user progress after completing a session
  void _updateProgress(FocusSession completedSession) {
    // Calculate XP earned from session
    final sessionXP = completedSession.calculateXP();

    // Update streak
    final now = DateTime.now();
    final lastDate = _progress.lastSessionDate;
    int newStreak = _progress.currentStreak;

    if (lastDate == null) {
      newStreak = 1;
    } else {
      final daysSinceLastSession = now.difference(lastDate).inDays;
      if (daysSinceLastSession == 0) {
        // Same day, maintain streak
        newStreak = _progress.currentStreak;
      } else if (daysSinceLastSession == 1) {
        // Consecutive day, increment streak
        newStreak = _progress.currentStreak + 1;
      } else {
        // Streak broken, reset to 1
        newStreak = 1;
      }
    }

    final newLongestStreak = newStreak > _progress.longestStreak
        ? newStreak
        : _progress.longestStreak;

    // Add to recent sessions (keep last 30)
    final updatedSessions = [completedSession, ..._progress.recentSessions];
    final recentSessions = updatedSessions.take(30).toList();

    // Update total stats
    final newTotalSessions = _progress.totalSessions + 1;
    final newTotalFocusTime = _progress.totalFocusTime +
        (completedSession.actualDuration ?? Duration.zero);

    // Check for new achievements and calculate achievement XP
    final achievementResult = _checkAchievements(
      completedSession,
      newTotalSessions,
      newStreak,
      recentSessions,
    );
    
    final newAchievements = achievementResult.achievements;
    final achievementXP = achievementResult.xpEarned;
    
    // Calculate total XP and level
    final newTotalXP = _progress.totalXP + sessionXP + achievementXP;
    final newLevel = UserProgress.calculateLevel(newTotalXP);

    _progress = _progress.copyWith(
      totalXP: newTotalXP,
      level: newLevel,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      totalSessions: newTotalSessions,
      totalFocusTime: newTotalFocusTime,
      achievements: newAchievements,
      recentSessions: recentSessions,
      lastSessionDate: now,
    );
  }

  /// Check and unlock achievements based on current progress
  _AchievementCheckResult _checkAchievements(
    FocusSession session,
    int totalSessions,
    int currentStreak,
    List<FocusSession> sessions,
  ) {
    final achievements = List<Achievement>.from(_progress.achievements);
    final now = DateTime.now();
    int totalXPEarned = 0;

    // Helper to unlock achievement if not already unlocked
    void unlockIfNew(AchievementType type) {
      if (!achievements.any((a) => a.type == type && a.unlocked)) {
        final achievement = Achievement.create(type).copyWith(
          unlocked: true,
          unlockedAt: now,
        );
        achievements.add(achievement);
        totalXPEarned += achievement.xpReward;
      }
    }

    // First session
    if (totalSessions == 1) {
      unlockIfNew(AchievementType.firstSession);
    }

    // Total sessions milestones
    if (totalSessions >= 10) unlockIfNew(AchievementType.totalSessions10);
    if (totalSessions >= 50) unlockIfNew(AchievementType.totalSessions50);
    if (totalSessions >= 100) unlockIfNew(AchievementType.totalSessions100);

    // Streak achievements
    if (currentStreak >= 7) unlockIfNew(AchievementType.streak7Days);
    if (currentStreak >= 30) unlockIfNew(AchievementType.streak30Days);

    // Perfect score
    if (session.focusScore == 100) {
      unlockIfNew(AchievementType.perfectScore);
    }

    // Time-based achievements
    final hour = session.startTime.hour;
    if (hour < 6) unlockIfNew(AchievementType.earlyBird);
    if (hour >= 22) unlockIfNew(AchievementType.nightOwl);

    // Marathon session (2+ hours)
    if ((session.actualDuration?.inMinutes ?? 0) >= 120) {
      unlockIfNew(AchievementType.marathonSession);
    }

    return _AchievementCheckResult(
      achievements: achievements,
      xpEarned: totalXPEarned,
    );
  }

  /// Get motivational feedback based on session performance
  String getFeedback(FocusSession session) {
    if (!session.completed) {
      return 'Keep going! Stay focused on your goal.';
    }

    final score = session.focusScore;
    final xp = session.calculateXP();

    if (score >= 90) {
      return 'Outstanding! 🌟 You earned $xp XP. Your focus is incredible!';
    } else if (score >= 75) {
      return 'Great work! 👏 You earned $xp XP. Keep up the excellent focus!';
    } else if (score >= 60) {
      return 'Good job! 👍 You earned $xp XP. You\'re making progress!';
    } else if (score >= 40) {
      return 'Nice effort! 💪 You earned $xp XP. Every session makes you stronger!';
    } else {
      return 'You completed the session! 🎯 You earned $xp XP. Tomorrow will be even better!';
    }
  }

  /// Get current level progress as a percentage (0-100)
  double getLevelProgress() {
    final currentLevelXP = _progress.xpInCurrentLevel();
    final xpForNext = _progress.xpForNextLevel();
    return (currentLevelXP / xpForNext * 100).clamp(0, 100);
  }

  /// Get recently unlocked achievements (last 5)
  List<Achievement> getRecentAchievements() {
    final unlocked = _progress.achievements
        .where((a) => a.unlocked)
        .toList()
      ..sort((a, b) => (b.unlockedAt ?? DateTime(0))
          .compareTo(a.unlockedAt ?? DateTime(0)));
    return unlocked.take(5).toList();
  }

  /// Reset progress (for testing or user request)
  void resetProgress() {
    _progress = const UserProgress();
  }

  /// Load progress from JSON
  void loadProgress(Map<String, dynamic> json) {
    _progress = UserProgress.fromJson(json);
  }

  /// Save progress to JSON
  Map<String, dynamic> saveProgress() {
    return _progress.toJson();
  }
}
