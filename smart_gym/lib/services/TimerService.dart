import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  // duration in seconds
  Duration? endDuration = const Duration(seconds: 0);

  Duration elapsed = defaultRestDuration;
  static const Duration _delta = Duration(milliseconds: 50);
  // int _elapsed = 0;

  // Duration? get duration => _duration;
  // Duration get elapsedMilli => elapsed;

  bool get isRunning => _timer != null;

  TimerService();

  void restart(
    Duration? duration,
  ) {
    stop();
    endDuration = duration;
    // _elapsedMilli = duration * 1000;
    elapsed = const Duration(seconds: 0);
    // _deltaMilli = 50;
    _timer = Timer.periodic(_delta, (timer) {
      countUp();
    });

    notifyListeners();
  }

  void countUp() {
    elapsed += _delta;

    // if (elapsedMilli == _duration * 1000) {
    //   // stop();
    // }

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;

    notifyListeners();
  }

  static TimerService ofSet(BuildContext context) {
    var provider =
        context.dependOnInheritedWidgetOfExactType<TimerServiceProvider>();
    return provider!.setService;
  }

  static TimerService ofWorkout(BuildContext context) {
    var provider =
        context.dependOnInheritedWidgetOfExactType<TimerServiceProvider>();
    return provider!.workoutService;
  }
}

class TimerServiceProvider extends InheritedWidget {
  final TimerService setService;
  final TimerService workoutService;

  const TimerServiceProvider({
    Key? key,
    required this.setService,
    required this.workoutService,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(TimerServiceProvider oldWidget) =>
      setService != oldWidget.setService ||
      workoutService != oldWidget.workoutService;
}
