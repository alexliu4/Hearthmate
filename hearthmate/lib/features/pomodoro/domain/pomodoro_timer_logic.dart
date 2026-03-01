import 'dart:async';

import 'pomodoro_constants.dart';
import 'timer_snapshot.dart';

class PomodoroTimerLogic {
  PomodoroTimerLogic() {
    _setSession(isBreak: false, minutes: PomodoroConstants.focusMinutes);
  }

  Timer? _ticker;
  late Duration _remaining;
  late Duration _total;
  bool _isBreak = false;
  bool _isRunning = false;
  int _completedFocusSessions = 0;

  TimerSnapshot get snapshot => TimerSnapshot(
        remaining: _remaining,
        total: _total,
        isRunning: _isRunning,
        isBreak: _isBreak,
        completedFocusSessions: _completedFocusSessions,
      );

  void start(void Function(TimerSnapshot) onTick) {
    if (_isRunning) {
      return;
    }

    _isRunning = true;
    onTick(snapshot);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 1) {
        _advanceSession();
        onTick(snapshot);
        return;
      }

      _remaining = Duration(seconds: _remaining.inSeconds - 1);
      onTick(snapshot);
    });
  }

  void pause(void Function(TimerSnapshot) onTick) {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;
    onTick(snapshot);
  }

  void resetCurrent(void Function(TimerSnapshot) onTick) {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;

    final int minutes = _isBreak
        ? _currentBreakMinutes()
        : PomodoroConstants.focusMinutes;
    _setSession(isBreak: _isBreak, minutes: minutes);
    onTick(snapshot);
  }

  void skip(void Function(TimerSnapshot) onTick) {
    _advanceSession();
    onTick(snapshot);
  }

  void dispose() {
    _ticker?.cancel();
  }

  void _advanceSession() {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;

    if (_isBreak) {
      _setSession(isBreak: false, minutes: PomodoroConstants.focusMinutes);
      return;
    }

    _completedFocusSessions += 1;
    _setSession(isBreak: true, minutes: _currentBreakMinutes());
  }

  int _currentBreakMinutes() {
    final bool useLongBreak =
        _completedFocusSessions > 0 &&
        _completedFocusSessions % PomodoroConstants.sessionsBeforeLongBreak == 0;
    return useLongBreak
        ? PomodoroConstants.longBreakMinutes
        : PomodoroConstants.shortBreakMinutes;
  }

  void _setSession({required bool isBreak, required int minutes}) {
    _isBreak = isBreak;
    _total = Duration(minutes: minutes);
    _remaining = _total;
  }
}
