import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_gym/main.dart';
import 'package:smart_gym/pages/workout_page/track_workout/track_workout.dart';

const String timeUpPayloadNotif = 'time_up';

class NotificationsService {
  late FlutterLocalNotificationsPlugin notificationsPlugin;
  bool initialized = false;

  NotificationsService() {
    notificationsPlugin = FlutterLocalNotificationsPlugin();
    initialize();
  }

  void initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    void onDidReceiveNotificationResponse(
        NotificationResponse notificationResponse) async {
      final String? payload = notificationResponse.payload;

      if (payload != null) {
        if (payload == timeUpPayloadNotif) {
          Navigator.push(
            NavigationService.navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => const TrackWorkoutRoute(
                  // workout: tracked.workout!,
                  ),
            ),
          );
        }
      }
    }

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    initialized = true;
  }

  static NotificationsService of(BuildContext context) {
    var provider = context
        .dependOnInheritedWidgetOfExactType<NotificationsServiceProvider>();
    return provider!.notifService;
  }
}

class NotificationsServiceProvider extends InheritedWidget {
  final NotificationsService notifService;

  const NotificationsServiceProvider({
    Key? key,
    required this.notifService,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(NotificationsServiceProvider oldWidget) =>
      notifService != oldWidget.notifService;
}
