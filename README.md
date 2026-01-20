# Focus Training 🎯

A gamified focus training module for Artemis that manages focus training activities and provides feedback on progress.

## Features

### 🎮 Gamification Elements

- **XP System**: Earn experience points for completing focus sessions
  - Base XP for completion
  - Bonus XP for session duration
  - Bonus XP for high focus scores
  
- **Level Progression**: Level up as you accumulate XP
  - Dynamic XP requirements per level
  - Track progress towards next level
  
- **Achievements**: Unlock 10 different achievements
  - 🎯 First Steps - Complete your first session
  - 🔥 Week Warrior - 7-day streak
  - ⭐ Monthly Master - 30-day streak
  - 📚 Getting Started - 10 sessions
  - 🧠 Focused Mind - 50 sessions
  - 👑 Focus Master - 100 sessions
  - 💯 Perfect Focus - Achieve 100 focus score
  - 🌅 Early Bird - Session before 6 AM
  - 🦉 Night Owl - Session after 10 PM
  - 🏃 Marathon Focus - 2+ hour session

- **Streak Tracking**: Build and maintain daily focus streaks

- **Performance Metrics**: Track comprehensive statistics
  - Total sessions completed
  - Total focus time
  - Average focus score
  - Current and longest streaks

### 📊 Progress Tracking

- Real-time progress monitoring
- Session history (last 30 sessions)
- Detailed statistics and analytics
- Motivational feedback system

### 💾 Persistence

- Save/load progress as JSON
- Easy integration with any storage backend

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  focus_training: ^1.0.0
```

## Usage

### Basic Example

```dart
import 'package:focus_training/focus_training.dart';

void main() {
  // Initialize the service
  final service = FocusTrainingService();

  // Start a focus session
  var session = service.startSession(
    plannedDuration: const Duration(minutes: 25),
    notes: 'Deep work on project',
  );

  // Complete the session with a focus score
  session = service.completeSession(
    session: session,
    focusScore: 85,
  );

  // Get feedback
  print(service.getFeedback(session));
  // Output: "Great work! 👏 You earned 60 XP. Keep up the excellent focus!"

  // Check progress
  final progress = service.progress;
  print('Level: ${progress.level}');
  print('Total XP: ${progress.totalXP}');
  print('Current Streak: ${progress.currentStreak} days');
  
  // Check achievements
  for (final achievement in progress.achievements) {
    print('${achievement.icon} ${achievement.name}');
  }
}
```

### Save and Load Progress

```dart
// Save progress
final savedData = service.saveProgress();
// Store savedData in your preferred storage (file, database, etc.)

// Load progress
final newService = FocusTrainingService();
newService.loadProgress(savedData);
```

### Check Level Progress

```dart
final progressPercentage = service.getLevelProgress();
print('Level progress: ${progressPercentage.toStringAsFixed(1)}%');
```

### Get Recent Achievements

```dart
final recentAchievements = service.getRecentAchievements();
for (final achievement in recentAchievements) {
  print('${achievement.icon} ${achievement.name}');
  print('Unlocked: ${achievement.unlockedAt}');
}
```

## API Reference

### FocusTrainingService

Main service class for managing focus training.

**Methods:**
- `startSession({required Duration plannedDuration, String? notes, Map<String, dynamic>? metadata})` - Start a new focus session
- `completeSession({required FocusSession session, required int focusScore, String? notes})` - Complete a session and update progress
- `getFeedback(FocusSession session)` - Get motivational feedback for a session
- `getLevelProgress()` - Get progress towards next level (0-100%)
- `getRecentAchievements()` - Get last 5 unlocked achievements
- `saveProgress()` - Serialize progress to JSON
- `loadProgress(Map<String, dynamic> json)` - Load progress from JSON
- `resetProgress()` - Reset all progress

**Properties:**
- `progress` - Get current UserProgress

### FocusSession

Represents a single focus training session.

**Properties:**
- `id` - Unique identifier
- `startTime` - When the session started
- `endTime` - When the session ended
- `plannedDuration` - Intended session length
- `actualDuration` - Actual session length
- `focusScore` - Performance score (0-100)
- `completed` - Whether session is complete
- `notes` - Optional session notes

**Methods:**
- `calculateXP()` - Calculate XP earned from session

### UserProgress

Tracks overall user progress and statistics.

**Properties:**
- `totalXP` - Total experience points
- `level` - Current level
- `currentStreak` - Current consecutive day streak
- `longestStreak` - Longest streak achieved
- `totalSessions` - Total sessions completed
- `totalFocusTime` - Total time spent focusing
- `achievements` - List of all achievements
- `recentSessions` - Last 30 sessions
- `averageFocusScore` - Average score across sessions

### Achievement

Represents an unlockable achievement.

**Properties:**
- `type` - Achievement type
- `name` - Achievement name
- `description` - Achievement description
- `icon` - Icon/emoji
- `xpReward` - XP awarded on unlock
- `unlocked` - Whether unlocked
- `unlockedAt` - When it was unlocked

## Running the Example

```bash
dart run example/main.dart
```

## Running Tests

```bash
dart test
```

## Documentation

- [Objectives](./OBJECTIVES.md) - Goals, requirements, and success criteria
- [Architecture](docs/ARCHITECTURE.md) - System design
- [Deployment](docs/DEPLOYMENT.md) - Deployment guide
- [Changelog](./CHANGELOG.md) - Version history

## License

MIT License - see LICENSE file for details

---

[Platform Documentation](../../../docs/) | [Product Overview](../../../docs/products/focus-training.md)