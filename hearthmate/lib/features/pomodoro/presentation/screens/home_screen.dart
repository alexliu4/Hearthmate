import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:hearthmate/game/game.dart';
import '../../domain/pomodoro_timer_logic.dart';
import '../../domain/timer_snapshot.dart';
import '../widgets/pomodoro_panel.dart';
import 'summary_screen.dart';

class PomodoroHomeScreen extends StatefulWidget {
  const PomodoroHomeScreen({super.key});

  @override
  State<PomodoroHomeScreen> createState() => _PomodoroHomeScreenState();
}

class _PomodoroHomeScreenState extends State<PomodoroHomeScreen> {
  late final HearthGame _game;
  late final PomodoroTimerLogic _timer;
  late TimerSnapshot _snapshot;

  @override
  void initState() {
    super.initState();
    _game = HearthGame();
    _timer = PomodoroTimerLogic();
    _snapshot = _timer.snapshot;
  }

  @override
  void dispose() {
    _timer.dispose();
    _game.pauseEngine();
    super.dispose();
  }

  void _handleTick(TimerSnapshot next) {
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshot = next;
    });
  }

  void _toggle() {
    if (_snapshot.isRunning) {
      _timer.pause(_handleTick);
      return;
    }
    _timer.start(_handleTick);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.52),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: PomodoroPanel(
                  snapshot: _snapshot,
                  onToggle: _toggle,
                  onReset: () => _timer.resetCurrent(_handleTick),
                  onSkip: () => _timer.skip(_handleTick),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PomodoroSummaryScreen(snapshot: _snapshot),
            ),
          );
        },
        icon: const Icon(Icons.analytics_outlined),
        label: const Text('Summary'),
      ),
    );
  }
}

