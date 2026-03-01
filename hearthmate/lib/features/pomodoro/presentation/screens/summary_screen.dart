import 'package:flutter/material.dart';

import '../../domain/timer_snapshot.dart';

class PomodoroSummaryScreen extends StatelessWidget {
  const PomodoroSummaryScreen({super.key, required this.snapshot});

  final TimerSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final int remainingMinutes = snapshot.remaining.inMinutes;
    final int remainingSeconds = snapshot.remaining.inSeconds % 60;
    final String remainingText =
        '${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Session Summary')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            title: const Text('Current mode'),
            trailing: Text(snapshot.isBreak ? 'Break' : 'Focus'),
          ),
          ListTile(
            title: const Text('Timer running'),
            trailing: Text(snapshot.isRunning ? 'Yes' : 'No'),
          ),
          ListTile(
            title: const Text('Remaining time'),
            trailing: Text(remainingText),
          ),
          ListTile(
            title: const Text('Completed focus sessions'),
            trailing: Text('${snapshot.completedFocusSessions}'),
          ),
        ],
      ),
    );
  }
}
