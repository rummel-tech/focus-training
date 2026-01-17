import 'achievement.dart';
import 'focus_session.dart';

/// Represents the user's overall progress and stats
class UserProgress {
  final int totalXP;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final Duration totalFocusTime;
  final List<Achievement> achievements;
  final List<FocusSession> recentSessions;
  final DateTime? lastSessionDate;
  final Map<String, dynamic> stats;

  const UserProgress({
    this.totalXP = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.totalFocusTime = Duration.zero,
    this.achievements = const [],
    this.recentSessions = const [],
    this.lastSessionDate,
    this.stats = const {},
  });

  /// Calculate level based on XP (100 XP per level with increasing requirements)
  static int calculateLevel(int xp) {
    if (xp < 100) return 1;
    // Each level requires 100 more XP than the previous
    // Level 2: 100, Level 3: 300, Level 4: 600, etc.
    int level = 1;
    int xpRequired = 0;
    while (xpRequired <= xp) {
      level++;
      xpRequired += level * 100;
    }
    return level - 1;
  }

  /// Calculate XP required for next level
  int xpForNextLevel() {
    return (level + 1) * 100;
  }

  /// Calculate XP progress in current level
  int xpInCurrentLevel() {
    int xpForCurrentLevel = 0;
    for (int i = 1; i < level; i++) {
      xpForCurrentLevel += (i + 1) * 100;
    }
    return totalXP - xpForCurrentLevel;
  }

  /// Get average focus score
  double get averageFocusScore {
    if (recentSessions.isEmpty) return 0.0;
    final completedSessions = recentSessions.where((s) => s.completed);
    if (completedSessions.isEmpty) return 0.0;
    return completedSessions.map((s) => s.focusScore).reduce((a, b) => a + b) /
        completedSessions.length;
  }

  UserProgress copyWith({
    int? totalXP,
    int? level,
    int? currentStreak,
    int? longestStreak,
    int? totalSessions,
    Duration? totalFocusTime,
    List<Achievement>? achievements,
    List<FocusSession>? recentSessions,
    DateTime? lastSessionDate,
    Map<String, dynamic>? stats,
  }) {
    return UserProgress(
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      totalFocusTime: totalFocusTime ?? this.totalFocusTime,
      achievements: achievements ?? this.achievements,
      recentSessions: recentSessions ?? this.recentSessions,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      stats: stats ?? this.stats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXP': totalXP,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalSessions': totalSessions,
      // Note: Microseconds are lost in serialization, precision limited to seconds
      'totalFocusTime': totalFocusTime.inSeconds,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'recentSessions': recentSessions.map((s) => s.toJson()).toList(),
      'lastSessionDate': lastSessionDate?.toIso8601String(),
      'stats': stats,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalXP: json['totalXP'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalSessions: json['totalSessions'] as int? ?? 0,
      totalFocusTime: Duration(seconds: json['totalFocusTime'] as int? ?? 0),
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((a) => Achievement.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      recentSessions: (json['recentSessions'] as List<dynamic>?)
              ?.map((s) => FocusSession.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      lastSessionDate: json['lastSessionDate'] != null
          ? DateTime.parse(json['lastSessionDate'] as String)
          : null,
      stats: json['stats'] as Map<String, dynamic>? ?? {},
    );
  }
}
