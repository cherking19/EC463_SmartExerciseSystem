import 'dart:async';
import 'package:flutter/material.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  // duration in seconds
  int _duration = 0;

  int _elapsedMilli = 0;
  int _deltaMilli = 50;
  // int _elapsed = 0;

  int get duration => _duration;
  int get elapsedMilli => _elapsedMilli;

  bool get isRunning => _timer != null;

  TimerService();

  void restart(int duration) {
    stop();
    _duration = duration;
    // _elapsedMilli = duration * 1000;
    _elapsedMilli = 0;
    _timer = Timer.periodic(
        Duration(
          // seconds: 1,
          milliseconds: _deltaMilli,
        ), (timer) {
      countUp();
    });

    notifyListeners();
  }

  void countUp() {
    _elapsedMilli += _deltaMilli;
    // print(_elapsedMilli);

    if (elapsedMilli == _duration * 1000) {
      // stop();
    }

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
