import 'dart:async';

class VoyageTimerLogic {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  Duration get elapsed => _elapsed;
  bool get isRunning => _isRunning;

  void start(void Function(Duration elapsed) onTick) {
    if (_isRunning) {
      return;
    }

    _isRunning = true;
    onTick(_elapsed);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = Duration(seconds: _elapsed.inSeconds + 1);
      onTick(_elapsed);
    });
  }

  void pause(void Function(Duration elapsed) onTick) {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;
    onTick(_elapsed);
  }

  void reset(void Function(Duration elapsed) onTick) {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;
    _elapsed = Duration.zero;
    onTick(_elapsed);
  }

  void dispose() {
    _ticker?.cancel();
  }
}
