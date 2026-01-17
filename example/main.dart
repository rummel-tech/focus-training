import 'package:focus_training/focus_training.dart';

void main() {
  // Initialize the focus training service
  final service = FocusTrainingService();

  print('=== Focus Training Gamification Demo ===\n');
  
  // Simulate first session
  print('📚 Starting first focus session (25 minutes)...');
  var session = service.startSession(
    plannedDuration: const Duration(minutes: 25),
    notes: 'Deep work on Artemis module',
  );

  // Simulate completing the session
  session = service.completeSession(
    session: session,
    focusScore: 85,
    notes: 'Good session, minimal distractions',
  );

  print('✅ Session completed!');
  print('   Focus Score: ${session.focusScore}/100');
  print('   XP Earned: ${session.calculateXP()}');
  print('   ${service.getFeedback(session)}\n');

  // Check progress
  var progress = service.progress;
  print('📊 Current Progress:');
  print('   Level: ${progress.level}');
  print('   Total XP: ${progress.totalXP}');
  print('   Current Streak: ${progress.currentStreak} days');
  print('   Total Sessions: ${progress.totalSessions}');
  print('   Level Progress: ${service.getLevelProgress().toStringAsFixed(1)}%\n');

  // Check achievements
  if (progress.achievements.isNotEmpty) {
    print('🏆 Achievements Unlocked:');
    for (final achievement in progress.achievements) {
      print('   ${achievement.icon} ${achievement.name} - ${achievement.description}');
      print('      +${achievement.xpReward} XP');
    }
    print('');
  }

  // Simulate more sessions to demonstrate progression
  print('🔄 Simulating more sessions...\n');
  
  for (int i = 0; i < 5; i++) {
    session = service.startSession(
      plannedDuration: Duration(minutes: 20 + (i * 5)),
    );
    
    // Vary the focus scores
    final scores = [75, 90, 100, 65, 88];
    session = service.completeSession(
      session: session,
      focusScore: scores[i],
    );
    
    print('Session ${i + 2}: Score ${scores[i]}/100 → +${session.calculateXP()} XP');
  }

  // Final progress
  progress = service.progress;
  print('\n📊 Final Progress:');
  print('   Level: ${progress.level}');
  print('   Total XP: ${progress.totalXP}');
  print('   Current Streak: ${progress.currentStreak} days');
  print('   Total Sessions: ${progress.totalSessions}');
  print('   Average Focus Score: ${progress.averageFocusScore.toStringAsFixed(1)}');
  print('   Total Focus Time: ${progress.totalFocusTime.inMinutes} minutes');
  print('   Level Progress: ${service.getLevelProgress().toStringAsFixed(1)}%\n');

  // Show all achievements
  print('🏆 All Achievements (${progress.achievements.length} unlocked):');
  for (final achievement in progress.achievements) {
    print('   ${achievement.icon} ${achievement.name}');
    print('      ${achievement.description}');
    print('      Unlocked: ${achievement.unlockedAt?.toString().split('.')[0]}');
    print('');
  }

  // Demonstrate persistence
  print('💾 Saving progress...');
  final savedData = service.saveProgress();
  print('   Progress saved to JSON (${savedData.keys.length} fields)\n');

  // Load progress into new service instance
  print('📥 Loading progress into new service instance...');
  final newService = FocusTrainingService();
  newService.loadProgress(savedData);
  print('   Progress restored successfully!');
  print('   Level: ${newService.progress.level}');
  print('   Total XP: ${newService.progress.totalXP}');
  print('   Total Sessions: ${newService.progress.totalSessions}\n');

  print('=== Demo Complete ===');
}
