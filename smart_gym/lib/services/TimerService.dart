import 'dart:async';
import 'package:flutter/material.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  int _duration = 0;
  int _elapsed = 0;

  int get elapsed => _elapsed;

  bool get isRunning => _timer != null;

  TimerService();

  void restart(int duration) {
    stop();
    _duration = duration;
    _elapsed = 0;
    _timer = Timer.periodic(
        const Duration(
          seconds: 1,
        ), (timer) {
      countUp();
    });

    notifyListeners();
  }

  void countUp() {
    _elapsed++;

    if (_elapsed == _duration) {}

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;

    notifyListeners();
  }

  static TimerService of(BuildContext context) {
    var provider =
        context.dependOnInheritedWidgetOfExactType<TimerServiceProvider>();
    return provider!.service;
  }
}

class TimerServiceProvider extends InheritedWidget {
  final TimerService service;

  const TimerServiceProvider({
    Key? key,
    required this.service,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(TimerServiceProvider oldWidget) =>
      service != oldWidget.service;
}
