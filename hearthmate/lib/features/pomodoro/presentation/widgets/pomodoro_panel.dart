import 'package:flutter/material.dart';

import '../../domain/timer_snapshot.dart';

class PomodoroPanel extends StatelessWidget {
  const PomodoroPanel({
    super.key,
    required this.snapshot,
    required this.onToggle,
    required this.onReset,
    required this.onSkip,
  });

  final TimerSnapshot snapshot;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String label = snapshot.isBreak ? 'Break' : 'Focus';
    final int minutes = snapshot.remaining.inMinutes;
    final int seconds = snapshot.remaining.inSeconds % 60;
    final String timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(20),
      color: Colors.white.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pomodoro', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('$label session', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: 210,
              height: 210,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: snapshot.progress,
                    strokeWidth: 12,
                    backgroundColor: const Color(0xFFFFE0B2),
                  ),
                  Text(
                    timeText,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onToggle,
                  icon: Icon(snapshot.isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(snapshot.isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.replay),
                  label: const Text('Reset'),
                ),
                const SizedBox(width: 10),
                TextButton(onPressed: onSkip, child: const Text('Skip')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Completed focus sessions: ${snapshot.completedFocusSessions}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
