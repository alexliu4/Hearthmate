import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:hearthmate/core/voyage_timer_logic.dart';
import 'package:hearthmate/features/pomodoro/presentation/widgets/character_select_dialog.dart';
import 'package:hearthmate/features/pomodoro/presentation/widgets/collection_overlay_dialog.dart';
import 'package:hearthmate/features/pomodoro/presentation/widgets/home_action_panel.dart';
import 'package:hearthmate/game/game.dart';

class PomodoroHomeScreen extends StatefulWidget {
  const PomodoroHomeScreen({super.key});

  @override
  State<PomodoroHomeScreen> createState() => _PomodoroHomeScreenState();
}

class _PomodoroHomeScreenState extends State<PomodoroHomeScreen> {
  late final HearthGame _game;
  late final VoyageTimerLogic _timer;
  Duration _elapsed = Duration.zero;
  String? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    _game = HearthGame();
    _timer = VoyageTimerLogic();
  }

  @override
  void dispose() {
    _timer.dispose();
    _game.pauseEngine();
    super.dispose();
  }

  void _handleTick(Duration next) {
    if (!mounted) {
      return;
    }
    setState(() {
      _elapsed = next;
    });
  }

  void _toggleVoyage() {
    if (_timer.isRunning) {
      _timer.pause(_handleTick);
      return;
    }
    _timer.start(_handleTick);
  }

  Future<void> _openCharacterSelect() async {
    final String? picked = await showCharacterSelectDialog(
      context,
      selectedCharacter: _selectedCharacter,
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      _selectedCharacter = picked;
    });
  }

  Future<void> _openCollectionLog() async {
    final Size screen = MediaQuery.sizeOf(context);
    final double horizontalInset = (screen.width * 0.05).clamp(12, 24);
    final double verticalInset = (screen.height * 0.08).clamp(14, 30);

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (BuildContext context) {
        return CollectionOverlayDialog(
          horizontalInset: horizontalInset,
          verticalInset: verticalInset,
        );
      },
    );
  }

  String _formatClock(Duration value) {
    final int hours = value.inHours;
    final int minutes = value.inMinutes.remainder(60);
    final int seconds = value.inSeconds.remainder(60);
    return
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _phoneScale(BuildContext context) {
    final double shortestSide = MediaQuery.sizeOf(context).shortestSide;
    return (shortestSide / 390).clamp(0.82, 1.25);
  }

  @override
  Widget build(BuildContext context) {
    final String voyageLabel = _timer.isRunning
        ? _formatClock(_elapsed)
        : _elapsed == Duration.zero
            ? 'START NEW VOYAGE'
            : 'RESUME ${_formatClock(_elapsed)}';

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
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double scale = _phoneScale(context);
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    16 * scale,
                    12 * scale,
                    16 * scale,
                    18 * scale,
                  ),
                  child: Column(
                    children: [
                      const Spacer(),
                      HomeActionPanel(
                        maxWidth: constraints.maxWidth,
                        scale: scale,
                        voyageLabel: voyageLabel,
                        selectedCharacter: _selectedCharacter,
                        onCharacterTap: _openCharacterSelect,
                        onVoyageTap: _toggleVoyage,
                        onVoyageLongPress: () => _timer.reset(_handleTick),
                        onCollectionTap: _openCollectionLog,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
