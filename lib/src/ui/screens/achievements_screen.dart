import 'package:flutter/material.dart';
import 'package:rummel_blue_theme/rummel_blue_theme.dart';

import '../../models/achievement.dart';
import '../../services/focus_training_service.dart';

class AchievementsScreen extends StatelessWidget {
  final FocusTrainingService service;

  const AchievementsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final unlocked = service.progress.achievements
        .where((a) => a.unlocked)
        .toList();

    final allTypes = AchievementType.values;
    final unlockedTypes = unlocked.map((a) => a.type).toSet();
    final locked = allTypes
        .where((t) => !unlockedTypes.contains(t))
        .map((t) => Achievement.create(t))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(RummelBlueSpacing.base),
        children: [
          if (unlocked.isNotEmpty) ...[
            Text(
              'Unlocked (${unlocked.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: RummelBlueSpacing.gapNormal),
            ...unlocked.map((a) => _AchievementTile(achievement: a, isLocked: false)),
            const SizedBox(height: RummelBlueSpacing.lg),
          ],
          Text(
            'Locked (${locked.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: RummelBlueColors.neutral600,
                ),
          ),
          const SizedBox(height: RummelBlueSpacing.gapNormal),
          ...locked.map((a) => _AchievementTile(achievement: a, isLocked: true)),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool isLocked;

  const _AchievementTile({required this.achievement, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isLocked ? RummelBlueColors.neutral100 : null,
      child: ListTile(
        leading: Text(
          isLocked ? '🔒' : achievement.icon,
          style: TextStyle(fontSize: 28, color: isLocked ? Colors.grey : null),
        ),
        title: Text(
          achievement.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isLocked ? RummelBlueColors.neutral500 : null,
          ),
        ),
        subtitle: Text(
          achievement.description,
          style: TextStyle(
            color: isLocked ? RummelBlueColors.neutral400 : null,
          ),
        ),
        trailing: Text(
          '+${achievement.xpReward} XP',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isLocked
                    ? RummelBlueColors.neutral400
                    : RummelBlueColors.primary600,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
