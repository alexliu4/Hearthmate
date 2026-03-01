import '../features/pomodoro/presentation/widgets/pomodoro_panel.dart';
import '../features/pomodoro/domain/timer_snapshot.dart';
import 'package:flutter/material.dart';

class PomodoroWidget extends StatelessWidget {
  const PomodoroWidget({
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
    return PomodoroPanel(
      snapshot: snapshot,
      onToggle: onToggle,
      onReset: onReset,
      onSkip: onSkip,
    );
  }
}
