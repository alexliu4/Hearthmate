class TimerSnapshot {
  const TimerSnapshot({
    required this.remaining,
    required this.total,
    required this.isRunning,
    required this.isBreak,
    required this.completedFocusSessions,
  });

  final Duration remaining;
  final Duration total;
  final bool isRunning;
  final bool isBreak;
  final int completedFocusSessions;

  double get progress {
    if (total.inSeconds == 0) {
      return 1;
    }
    return 1 - (remaining.inSeconds / total.inSeconds);
  }
}
