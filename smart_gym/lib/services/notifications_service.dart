import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_gym/main.dart';
import 'package:smart_gym/pages/workout_page/track_workout/track_workout.dart';

const String timeUpPayloadNotif = 'time_up';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

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

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    void onDidReceiveNotificationResponse(
        NotificationResponse notificationResponse) async {
      final String? payload = notificationResponse.payload;

      if (payload != null) {
        if (payload == timeUpPayloadNotif) {
          Navigator.of(NavigationService.navigatorKey.currentContext!)
              .popUntil((route) => route.isFirst);
          Navigator.push(
            NavigationService.navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => const TrackWorkoutRoute(),
            ),
          );
        }
      }
    }

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    initialized = true;
  }

  void requestPermissions() async {
    FlutterLocalNotificationsPlugin notifPlugin =
        NotificationsService.of(NavigationService.navigatorKey.currentContext!)
            .notificationsPlugin;

    if (Platform.isAndroid) {
      notifPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestPermission();
    } else if (Platform.isIOS) {
      notifPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
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
