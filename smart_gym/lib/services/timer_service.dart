import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_gym/main.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/services/notifications_service.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  // duration in seconds
  Duration? endDuration = const Duration(seconds: 0);

  Duration elapsed = defaultRestDuration;
  static const Duration _delta = Duration(milliseconds: 50);

  bool get isRunning => _timer != null;

  TimerService();

  void restart(
    Duration? duration,
  ) {
    stop();
    endDuration = duration;
    elapsed = const Duration(seconds: 0);
    _timer = Timer.periodic(_delta, (timer) {
      countUp();
    });

    notifyListeners();
  }

  void countUp() async {
    elapsed += _delta;

    if (elapsed == endDuration) {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      if (NotificationsService.of(
              NavigationService.navigatorKey.currentContext!)
          .initialized) {
        print('showing notif');
        NotificationsService.of(NavigationService.navigatorKey.currentContext!)
            .notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()!
            .requestPermission();
        await NotificationsService.of(
                NavigationService.navigatorKey.currentContext!)
            .notificationsPlugin
            .show(
              0,
              'Rest time up!',
              'Time to start the next set.',
              notificationDetails,
              payload: timeUpPayloadNotif,
            );
      }
    }

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
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(TimerServiceProvider oldWidget) =>
      setService != oldWidget.setService ||
      workoutService != oldWidget.workoutService;
}
