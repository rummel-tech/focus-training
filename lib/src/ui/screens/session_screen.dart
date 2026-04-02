import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rummel_blue_theme/rummel_blue_theme.dart';

import '../../models/focus_session.dart';
import '../../services/focus_training_service.dart';

class SessionScreen extends StatefulWidget {
  final FocusTrainingService service;

  const SessionScreen({super.key, required this.service});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  static const _durations = [15, 25, 45, 60, 90, 120];
  int _selectedMinutes = 25;
  FocusSession? _activeSession;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _completed = false;
  int _focusScore = 80;
  String? _feedback;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _startSession() {
    final session = widget.service.startSession(
      plannedDuration: Duration(minutes: _selectedMinutes),
    );
    setState(() {
      _activeSession = session;
      _elapsed = Duration.zero;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(session.startTime);
      });
    });
  }

  void _completeSession() {
    _timer?.cancel();
    final completed = widget.service.completeSession(
      session: _activeSession!,
      focusScore: _focusScore,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    setState(() {
      _completed = true;
      _feedback = widget.service.getFeedback(completed);
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$m:$s';
    }
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return _buildCompletedView(context);
    }
    if (_activeSession != null) {
      return _buildActiveView(context);
    }
    return _buildSetupView(context);
  }

  Widget _buildSetupView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Session')),
      body: Padding(
        padding: const EdgeInsets.all(RummelBlueSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: RummelBlueSpacing.xl),
            Text(
              'How long do you want to focus?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RummelBlueSpacing.lg),
            Wrap(
              spacing: RummelBlueSpacing.gapNormal,
              runSpacing: RummelBlueSpacing.gapNormal,
              alignment: WrapAlignment.center,
              children: _durations.map((m) {
                final selected = m == _selectedMinutes;
                return ChoiceChip(
                  label: Text('$m min'),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedMinutes = m),
                );
              }).toList(),
            ),
            const SizedBox(height: RummelBlueSpacing.lg),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Session notes (optional)',
                border: OutlineInputBorder(),
                hintText: 'What will you focus on?',
              ),
              maxLines: 2,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Focus Session'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: RummelBlueSpacing.base),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveView(BuildContext context) {
    final planned = Duration(minutes: _selectedMinutes);
    final progress = _elapsed.inSeconds / planned.inSeconds;
    final remaining = planned - _elapsed;
    final isOvertime = remaining.isNegative;

    return Scaffold(
      appBar: AppBar(title: const Text('Focusing...')),
      body: Padding(
        padding: const EdgeInsets.all(RummelBlueSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 12,
                    backgroundColor: RummelBlueColors.neutral200,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatDuration(isOvertime ? _elapsed - planned : remaining),
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isOvertime ? 'overtime' : 'remaining',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RummelBlueSpacing.xl),
            Text(
              'Elapsed: ${_formatDuration(_elapsed)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: RummelBlueSpacing.lg),
            Text('How focused are you?',
                style: Theme.of(context).textTheme.bodyMedium),
            Slider(
              value: _focusScore.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '$_focusScore',
              onChanged: (v) => setState(() => _focusScore = v.round()),
            ),
            Text('Focus Score: $_focusScore',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: RummelBlueSpacing.lg),
            ElevatedButton.icon(
              onPressed: _completeSession,
              icon: const Icon(Icons.check),
              label: const Text('Complete Session'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedView(BuildContext context) {
    final progress = widget.service.progress;

    return Scaffold(
      appBar: AppBar(title: const Text('Session Complete')),
      body: Padding(
        padding: const EdgeInsets.all(RummelBlueSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 72, color: RummelBlueColors.primary600),
            const SizedBox(height: RummelBlueSpacing.base),
            Text(
              _feedback ?? 'Great work!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RummelBlueSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(RummelBlueSpacing.cardPaddingDefault),
                child: Column(
                  children: [
                    _summaryRow(context, 'Level', '${progress.level}'),
                    _summaryRow(context, 'Total XP', '${progress.totalXP}'),
                    _summaryRow(context, 'Streak', '${progress.currentStreak} days'),
                    _summaryRow(context, 'Sessions', '${progress.totalSessions}'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text('Done'),
            ),
            const SizedBox(height: RummelBlueSpacing.base),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
