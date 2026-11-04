import 'dart:async';
import 'dart:math';

class StockPreviewSchedule {
  StockPreviewSchedule(
    this._poll, {
    required Duration interval,
    this.freshFor = const Duration(seconds: 5),
    Random? random,
    DateTime Function()? clock,
  }) : _interval = _clamp(interval),
       _random = random ?? Random(),
       _clock = clock ?? DateTime.now;

  static const minInterval = Duration(seconds: 5);
  static const maxInterval = Duration(minutes: 5);

  final Future<void> Function() _poll;
  final Duration freshFor;
  final Random _random;
  final DateTime Function() _clock;
  Duration _interval;
  Timer? _timer;
  DateTime? _last;
  bool _running = false;
  bool _polling = false;
  bool _disposed = false;

  Duration get interval => _interval;

  bool get running => _running;

  set serverInterval(Duration? value) {
    if (value != null) _interval = _clamp(value);
  }

  static Duration _clamp(Duration value) => value < minInterval
      ? minInterval
      : value > maxInterval
      ? maxInterval
      : value;

  void resume() {
    if (_disposed || _running) return;
    _running = true;
    _stale ? unawaited(_fire()) : _schedule();
  }

  void pause() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  void nudge() {
    if (_running && !_disposed && _stale) unawaited(_fire());
  }

  bool get _stale {
    final last = _last;
    return last == null || _clock().difference(last) >= freshFor;
  }

  void _schedule() {
    _timer?.cancel();
    if (!_running || _disposed) return;
    _timer = Timer(_interval * (0.75 + _random.nextDouble() * 0.5), () => unawaited(_fire()));
  }

  Future<void> _fire() async {
    if (_polling || _disposed) return;
    _timer?.cancel();
    _polling = true;
    _last = _clock();
    try {
      await _poll();
    } finally {
      _polling = false;
      _schedule();
    }
  }

  void dispose() {
    _disposed = true;
    pause();
  }
}
