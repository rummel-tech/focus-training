/// Represents different types of achievements
enum AchievementType {
  firstSession,
  streak7Days,
  streak30Days,
  totalSessions10,
  totalSessions50,
  totalSessions100,
  perfectScore,
  earlyBird,
  nightOwl,
  marathonSession,
}

/// Represents an achievement/badge in the gamification system
class Achievement {
  final AchievementType type;
  final String name;
  final String description;
  final String icon;
  final int xpReward;
  final DateTime? unlockedAt;
  final bool unlocked;

  const Achievement({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    this.xpReward = 0,
    this.unlockedAt,
    this.unlocked = false,
  });

  Achievement copyWith({
    AchievementType? type,
    String? name,
    String? description,
    String? icon,
    int? xpReward,
    DateTime? unlockedAt,
    bool? unlocked,
  }) {
    return Achievement(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      xpReward: xpReward ?? this.xpReward,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlocked: unlocked ?? this.unlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'name': name,
      'description': description,
      'icon': icon,
      'xpReward': xpReward,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'unlocked': unlocked,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      xpReward: json['xpReward'] as int? ?? 0,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'] as String) 
          : null,
      unlocked: json['unlocked'] as bool? ?? false,
    );
  }

  /// Factory method to create predefined achievements
  static Achievement create(AchievementType type) {
    switch (type) {
      case AchievementType.firstSession:
        return Achievement(
          type: type,
          name: 'First Steps',
          description: 'Complete your first focus session',
          icon: '🎯',
          xpReward: 50,
        );
      case AchievementType.streak7Days:
        return Achievement(
          type: type,
          name: 'Week Warrior',
          description: 'Maintain a 7-day focus streak',
          icon: '🔥',
          xpReward: 200,
        );
      case AchievementType.streak30Days:
        return Achievement(
          type: type,
          name: 'Monthly Master',
          description: 'Maintain a 30-day focus streak',
          icon: '⭐',
          xpReward: 1000,
        );
      case AchievementType.totalSessions10:
        return Achievement(
          type: type,
          name: 'Getting Started',
          description: 'Complete 10 focus sessions',
          icon: '📚',
          xpReward: 100,
        );
      case AchievementType.totalSessions50:
        return Achievement(
          type: type,
          name: 'Focused Mind',
          description: 'Complete 50 focus sessions',
          icon: '🧠',
          xpReward: 500,
        );
      case AchievementType.totalSessions100:
        return Achievement(
          type: type,
          name: 'Focus Master',
          description: 'Complete 100 focus sessions',
          icon: '👑',
          xpReward: 1500,
        );
      case AchievementType.perfectScore:
        return Achievement(
          type: type,
          name: 'Perfect Focus',
          description: 'Achieve a perfect 100 focus score',
          icon: '💯',
          xpReward: 300,
        );
      case AchievementType.earlyBird:
        return Achievement(
          type: type,
          name: 'Early Bird',
          description: 'Complete a session before 6 AM',
          icon: '🌅',
          xpReward: 150,
        );
      case AchievementType.nightOwl:
        return Achievement(
          type: type,
          name: 'Night Owl',
          description: 'Complete a session after 10 PM',
          icon: '🦉',
          xpReward: 150,
        );
      case AchievementType.marathonSession:
        return Achievement(
          type: type,
          name: 'Marathon Focus',
          description: 'Complete a session longer than 2 hours',
          icon: '🏃',
          xpReward: 250,
        );
    }
  }
}
