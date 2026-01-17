/// Represents a single focus training session
class FocusSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration plannedDuration;
  final Duration? actualDuration;
  final int focusScore; // 0-100 score based on performance
  final bool completed;
  final String? notes;
  final Map<String, dynamic> metadata;

  const FocusSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.plannedDuration,
    this.actualDuration,
    this.focusScore = 0,
    this.completed = false,
    this.notes,
    this.metadata = const {},
  });

  /// Calculate XP earned from this session
  int calculateXP() {
    if (!completed) return 0;
    
    // Base XP for completion
    int baseXP = 10;
    
    // Bonus for duration (1 XP per minute)
    int durationBonus = (actualDuration?.inMinutes ?? plannedDuration.inMinutes);
    
    // Bonus for focus score (up to 50 bonus XP)
    int focusBonus = (focusScore * 0.5).round();
    
    return baseXP + durationBonus + focusBonus;
  }

  FocusSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    Duration? plannedDuration,
    Duration? actualDuration,
    int? focusScore,
    bool? completed,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return FocusSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      focusScore: focusScore ?? this.focusScore,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'plannedDuration': plannedDuration.inSeconds,
      'actualDuration': actualDuration?.inSeconds,
      'focusScore': focusScore,
      'completed': completed,
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      plannedDuration: Duration(seconds: json['plannedDuration'] as int),
      actualDuration: json['actualDuration'] != null 
          ? Duration(seconds: json['actualDuration'] as int) 
          : null,
      focusScore: json['focusScore'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}
