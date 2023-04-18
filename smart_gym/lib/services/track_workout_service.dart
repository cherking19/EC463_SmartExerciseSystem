import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_gym/main.dart';
import 'package:smart_gym/pages/workout_page/track_workout/track_widgets/track_set.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/services/sensor_service.dart';

class TrackWorkoutService extends ChangeNotifier {
  late DateTime start, repstart, repend;
  late int repdiff, state, /*holdup,*/ reps;
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
    repstart = start;
    repend = start;
    repdiff = 0;
    // List<double> yaws = [];
    // List<double> pitches = [];
    // List<double> rolls = [];
    state = 0;
    // holdup = 0;
    reps = 0;

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
    orientationSubscription.cancel();
    isListening = false;
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
      // data_temp[0][0] = map[rightShoulderSuffix]!.yaw!;
      data_temp[0][1] = map[rightShoulderSuffix]!.pitch!;
      // data_temp[0][2] = map[rightShoulderSuffix]!.roll!;
      //copy previous
      // data_prev[0][0] = data_per[0][0];
      data_prev[0][1] = data_per[0][1];
      // data_prev[0][2] = data_per[0][2];
      //copy temp -> data
      // data_per[0][0] = data_temp[0][0];
      data_per[0][1] = data_temp[0][1];
      // data_per[0][2] = data_temp[0][2];
    }
    if (map[rightForearmSuffix] != null &&
        map[rightForearmSuffix]?.pitch != null) {
      // data_temp[1][0] = map[rightForearmSuffix]!.yaw!;
      data_temp[1][1] = map[rightForearmSuffix]!.pitch!;
      // data_temp[1][2] = map[rightForearmSuffix]!.roll!;
      //copy previous
      // data_prev[1][0] = data_per[1][0];
      data_prev[1][1] = data_per[1][1];
      // data_prev[1][2] = data_per[1][2];
      //copy temp -> data
      // data_per[1][0] = data_temp[1][0];
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

    switch (state) {
      case 0:
        //Add Calibration
        //go to down state
        state = 1;
        break;

      case 1: //Down State

        //hold time?
        //check boundary for up state
        if (dp > 70) {
          state = 2;
          // holdup = 0;
          repstart = DateTime.now();
          print('curl up');
          // Here add thing ben
        sendData(SensorService.of(navigatorKey.currentState!.context).hapticCharacteristics['RightShoulder']!);
        sendData(SensorService.of(navigatorKey.currentState!.context).hapticCharacteristics['RightForearm']!);
        }
        //recalibrate if necessary
        break;

      case 2: //up state
        // holdup++;
        if (dp < 20) {
          state = 3;
          repend = DateTime.now();
          repdiff = (repend.difference(repstart)).inSeconds;
        }
        break;

      case 3: //finish state
        reps++;
        //output number of curls
        //output time curl held
        //any additional feedback
        state = 1;
        print('CURL $reps DONE, HELD FOR $repdiff SECONDS ---------------');
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

  void analyzePressWorkout(
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
      // data_temp[0][0] = map[rightShoulderSuffix]!.yaw!;
      data_temp[0][1] = map[rightShoulderSuffix]!.pitch!;
      // data_temp[0][2] = map[rightShoulderSuffix]!.roll!;
      //copy previous
      // data_prev[0][0] = data_per[0][0];
      data_prev[0][1] = data_per[0][1];
      // data_prev[0][2] = data_per[0][2];
      //copy temp -> data
      // data_per[0][0] = data_temp[0][0];
      data_per[0][1] = data_temp[0][1];
      // data_per[0][2] = data_temp[0][2];
    }
    if (map[rightForearmSuffix] != null &&
        map[rightForearmSuffix]?.pitch != null) {
      // data_temp[1][0] = map[rightForearmSuffix]!.yaw!;
      data_temp[1][1] = map[rightForearmSuffix]!.pitch!;
      // data_temp[1][2] = map[rightForearmSuffix]!.roll!;
      //copy previous
      // data_prev[1][0] = data_per[1][0];
      data_prev[1][1] = data_per[1][1];
      // data_prev[1][2] = data_per[1][2];
      //copy temp -> data
      // data_per[1][0] = data_temp[1][0];
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

    switch (state) {
      case 0:
        //Add Calibration
        //go to down state
        if(data_per[1][1]< -75.0 && dp>90.0)//vertical forearm and nonvertical bicep
        {
          state = 1;
        }
        break;

      case 1: //Down State

        //hold time?
        //check boundary for up state
        if (dp < 15) {
          state = 2;
          // holdup = 0;
          repstart = DateTime.now();
          print('press up');
          // Here add thing ben
        sendData(SensorService.of(navigatorKey.currentState!.context).hapticCharacteristics['RightShoulder']!);
        sendData(SensorService.of(navigatorKey.currentState!.context).hapticCharacteristics['RightForearm']!);
        }
        else if(dp>90.0 && data_per[1][1]>= -75.0){
          print('press reset');
          state=0;
        }
        //recalibrate if necessary
        break;

      case 2: //up state
        // holdup++;
        if (dp > 10) {
          state = 0;
          repend = DateTime.now();
          repdiff = (repend.difference(repstart)).inSeconds;
          reps++;
          print('PRESS $reps DONE, HELD FOR $repdiff SECONDS ---------------');
          sendData(SensorService.of(navigatorKey.currentState!.context).hapticCharacteristics['RightShoulder']!);
          sendData(SensorService.of(navigatorKey.currentState!.context).hapticCharacteristics['RightForearm']!);
          if (setController?.context?.mounted ?? false) {
            setController?.repCount!();
          }
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
