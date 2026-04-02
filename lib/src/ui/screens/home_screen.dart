import 'package:flutter/material.dart';
import 'package:rummel_blue_theme/rummel_blue_theme.dart';

import '../../models/achievement.dart';
import '../../services/focus_training_service.dart';
import 'session_screen.dart';
import 'achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  final FocusTrainingService service;

  const HomeScreen({super.key, required this.service});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FocusTrainingService get _service => widget.service;

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final progress = _service.progress;
    final levelPct = _service.getLevelProgress();
    final recentAchievements = _service.getRecentAchievements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Training'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'Achievements',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AchievementsScreen(service: _service),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(RummelBlueSpacing.base),
        children: [
          _LevelCard(
            level: progress.level,
            totalXP: progress.totalXP,
            levelProgress: levelPct,
            xpForNext: progress.xpForNextLevel(),
          ),
          const SizedBox(height: RummelBlueSpacing.base),
          _StatsRow(
            streak: progress.currentStreak,
            longestStreak: progress.longestStreak,
            totalSessions: progress.totalSessions,
            totalMinutes: progress.totalFocusTime.inMinutes,
            avgScore: progress.averageFocusScore,
          ),
          const SizedBox(height: RummelBlueSpacing.base),
          if (recentAchievements.isNotEmpty) ...[
            Text(
              'Recent Achievements',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: RummelBlueSpacing.gapNormal),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recentAchievements.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: RummelBlueSpacing.gapNormal),
                itemBuilder: (context, i) {
                  final a = recentAchievements[i];
                  return _AchievementChip(achievement: a);
                },
              ),
            ),
            const SizedBox(height: RummelBlueSpacing.base),
          ],
          if (progress.recentSessions.isNotEmpty) ...[
            Text(
              'Recent Sessions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: RummelBlueSpacing.gapNormal),
            ...progress.recentSessions.take(10).map((session) {
              final duration =
                  session.actualDuration ?? session.plannedDuration;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _scoreColor(session.focusScore),
                    child: Text(
                      '${session.focusScore}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  title: Text('${duration.inMinutes} min session'),
                  subtitle: Text(
                    '+${session.calculateXP()} XP${session.notes != null ? '  •  ${session.notes}' : ''}',
                  ),
                  trailing: Text(
                    _formatDate(session.startTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            }),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(RummelBlueSpacing.xl),
                child: Column(
                  children: [
                    Icon(Icons.self_improvement,
                        size: 64, color: RummelBlueColors.neutral400),
                    const SizedBox(height: RummelBlueSpacing.base),
                    Text(
                      'Start your first focus session',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: RummelBlueColors.neutral600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionScreen(service: _service),
            ),
          );
          _refresh();
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Session'),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 90) return RummelBlueColors.success500;
    if (score >= 75) return RummelBlueColors.primary600;
    if (score >= 60) return RummelBlueColors.warning500;
    return RummelBlueColors.error500;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final int totalXP;
  final double levelProgress;
  final int xpForNext;

  const _LevelCard({
    required this.level,
    required this.totalXP,
    required this.levelProgress,
    required this.xpForNext,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RummelBlueSpacing.cardPaddingDefault),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: RummelBlueColors.primary100,
                  child: Text(
                    '$level',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: RummelBlueColors.primary700,
                        ),
                  ),
                ),
                const SizedBox(width: RummelBlueSpacing.base),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level $level',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$totalXP XP total',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: RummelBlueColors.neutral600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: RummelBlueSpacing.base),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: levelProgress / 100,
                minHeight: 10,
                backgroundColor: RummelBlueColors.neutral200,
              ),
            ),
            const SizedBox(height: RummelBlueSpacing.gapTight),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${levelProgress.toStringAsFixed(0)}% to Level ${level + 1}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int streak;
  final int longestStreak;
  final int totalSessions;
  final int totalMinutes;
  final double avgScore;

  const _StatsRow({
    required this.streak,
    required this.longestStreak,
    required this.totalSessions,
    required this.totalMinutes,
    required this.avgScore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(icon: Icons.local_fire_department, label: 'Streak', value: '$streak days'),
        const SizedBox(width: RummelBlueSpacing.gapNormal),
        _StatTile(icon: Icons.timer, label: 'Sessions', value: '$totalSessions'),
        const SizedBox(width: RummelBlueSpacing.gapNormal),
        _StatTile(icon: Icons.schedule, label: 'Focus Time', value: '${totalMinutes}m'),
        const SizedBox(width: RummelBlueSpacing.gapNormal),
        _StatTile(icon: Icons.speed, label: 'Avg Score', value: avgScore > 0 ? avgScore.toStringAsFixed(0) : '-'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: RummelBlueSpacing.base,
            horizontal: RummelBlueSpacing.gapNormal,
          ),
          child: Column(
            children: [
              Icon(icon, color: RummelBlueColors.primary600),
              const SizedBox(height: RummelBlueSpacing.gapTight),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: RummelBlueColors.neutral600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementChip extends StatelessWidget {
  final Achievement achievement;

  const _AchievementChip({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RummelBlueSpacing.gapNormal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              achievement.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
