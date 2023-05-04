import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_gym/main.dart';
import 'package:smart_gym/pages/workout_page/track_workout/track_widgets/track_set.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/services/sensor_service.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

class TrackWorkoutService extends ChangeNotifier {
  late DateTime start, curlstart, curlend;
  late int curldiff, state, holdup, curls;
  late List<List<double>> data_per, data_prev, data_temp;
  late double dy, dp, dr;

  bool isListening = false;
  late StreamSubscription<Map<String, SensorOrientation>>
      orientationSubscription;

  Workout? trackedWorkout;
  TrackSetController? setController;

  TrackWorkoutService() {
    initializeAnalysis();
  }
  void sendData(BluetoothCharacteristic characteristic) {
    String exampleCode = "01";
    characteristic
        .write(utf8
        .encode(exampleCode));
  }

  void initializeAnalysis() {
    start = DateTime.now();
    curlstart = start;
    curlend = start;
    curldiff = 0;
    // List<double> yaws = [];
    // List<double> pitches = [];
    // List<double> rolls = [];
    state = 0;
    holdup = 0;
    curls = 0;

    // List<List<List<double>>> data;
    data_per = List.generate(2, (i) => [0, 0, 0], growable: false);
    data_prev = List.generate(2, (i) => [0, 0, 0], growable: false);
    data_temp = List.generate(2, (i) => [0, 0, 0], growable: false);
  }

  void beginListening(
    BuildContext context, {
    required TrackSetController controller,
  }) {
    if (isListening) {
      stopListening(context);
    }
    setController = controller;
    Stream<Map<String, SensorOrientation>> orientationsStream =
        SensorService.of(context).orientationsStreamController.stream;
    orientationSubscription =
        orientationsStream.asBroadcastStream().listen((newMap) {
      analyzeCurlWorkout(
        map: newMap,
      );
    });

    isListening = true;
  }

  void updateSetController({
    required TrackSetController controller,
  }) {
    setController = controller;
  }

  void stopListening(BuildContext context) {
    try {
    orientationSubscription.cancel();

    } finally {
    isListening = false;

    }
  }

  void analyzeCurlWorkout(
      // BuildContext context,
      {
    required Map<String, SensorOrientation> map,
  }) {
    // Map<String, SensorOrientation> map = SensorService.of(context).orientations;

    // while (1 == 1) {
    //Get data
    // map = SensorService.of(context).orientations;
    if (map[rightShoulderSuffix] != null &&
        map[rightShoulderSuffix]?.pitch != null) {
      data_temp[0][0] = map[rightShoulderSuffix]!.yaw!;
      data_temp[0][1] = map[rightShoulderSuffix]!.pitch!;
      // data_temp[0][2] = map[rightShoulderSuffix]!.roll!;
      //copy previous
      data_prev[0][0] = data_per[0][0];
      data_prev[0][1] = data_per[0][1];
      // data_prev[0][2] = data_per[0][2];
      //copy temp -> data
      data_per[0][0] = data_temp[0][0];
      data_per[0][1] = data_temp[0][1];
      // data_per[0][2] = data_temp[0][2];
    }
    if (map[rightForearmSuffix] != null &&
        map[rightForearmSuffix]?.pitch != null) {
      data_temp[1][0] = map[rightForearmSuffix]!.yaw!;
      data_temp[1][1] = map[rightForearmSuffix]!.pitch!;
      // data_temp[1][2] = map[rightForearmSuffix]!.roll!;
      //copy previous
      data_prev[1][0] = data_per[1][0];
      data_prev[1][1] = data_per[1][1];
      // data_prev[1][2] = data_per[1][2];
      //copy temp -> data
      data_per[1][0] = data_temp[1][0];
      data_per[1][1] = data_temp[1][1];
      // data_per[1][2] = data_temp[1][2];
    }

    // //add timer
    // if("addd stuff for time differnece"==""){
    //   // add timer

    //calculate difference between 2 sensors
    // dy = (data_per[0][0] - data_per[1][0]).abs();
    dp = (data_per[0][1] - data_per[1][1]).abs();
    // dr = (data_per[0][2] - data_per[1][2]).abs();

    // print('DP: $dp ');
    //Benjamin Math
    double yawForCartesianVector1 = data_per[0][0];
    double yawForCartesianVector2 = data_per[1][0];
    double pitchForCartesianVector1 = data_per[0][1];
    double pitchForCartesianVector2 = data_per[1][1];
    Vector3 vector1 = new Vector3(sin(yawForCartesianVector1)*cos(pitchForCartesianVector1), cos(yawForCartesianVector1)*cos(pitchForCartesianVector1), sin(pitchForCartesianVector1));
    Vector3 vector2 = new Vector3(sin(yawForCartesianVector2)*cos(pitchForCartesianVector2), cos(yawForCartesianVector2)*cos(pitchForCartesianVector2), sin(pitchForCartesianVector2));
    double angle;
    double magnitude1 = sqrt(pow(vector1.x,2)+pow(vector1.y,2)+pow(vector1.z,2));
    double magnitude2 = sqrt(pow(vector2.x,2)+pow(vector2.y,2)+pow(vector2.z,2));
    angle = degrees(acos(dot3(vector1,vector2)/(magnitude1*magnitude2)));
    //print(angle);

    switch (state) {
      case 0:
        //Add Calibration
        //go to down state
        state = 1;
        break;

      case 1: //Down State

        //hold time?
        //check boundary for up state
        if (dp > 68) {
          state = 2;
          holdup = 0;
          curlstart = DateTime.now();
          print('curl up');
          // Here add thing ben
        sendData(SensorService.of(navigatorKey.currentState!.context).hapticCharacteristics['RightShoulder']!);
        sendData(SensorService.of(navigatorKey.currentState!.context).hapticCharacteristics['RightForearm']!);
        }
        //recalibrate if necessary
        break;

      case 2: //up state
        holdup++;
        if (dp < 30) {
          state = 3;
          curlend = DateTime.now();
          curldiff = (curlend.difference(curlstart)).inSeconds;
          
        }
        break;

      case 3: //finish state
        curls++;
        //output number of curls
        //output time curl held
        //any additional feedback
        state = 1;
        print('CURL $curls DONE, HELD FOR $curldiff SECONDS ---------------');
        sendData(SensorService.of(navigatorKey.currentState!.context).hapticCharacteristics['RightShoulder']!);
        sendData(SensorService.of(navigatorKey.currentState!.context).hapticCharacteristics['RightForearm']!);
        if (setController?.context?.mounted ?? false) {
          setController?.repCount!();
        }
        break;
      default:
    }
    // }
  }

  loadWorkout(Workout workout) {
    trackedWorkout = workout;
  }

  static TrackWorkoutService of(BuildContext context) {
    var provider = context
        .dependOnInheritedWidgetOfExactType<TrackWorkoutServiceProvider>();
    return provider!.service;
  }
}

class TrackWorkoutServiceProvider extends InheritedWidget {
  final TrackWorkoutService service;

  const TrackWorkoutServiceProvider({
    Key? key,
    required this.service,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(TrackWorkoutServiceProvider oldWidget) =>
      service != oldWidget.service;
}
