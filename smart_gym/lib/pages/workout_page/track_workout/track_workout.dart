import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
import 'package:smart_gym/reusable_widgets/workout_widgets/workout_widgets.dart';
import 'package:smart_gym/services/TimerService.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:statistics/statistics.dart';

import '../../../services/sensor_service.dart';

class TrackWorkoutRoute extends StatelessWidget {
  final Workout workout;

  const TrackWorkoutRoute({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout In Progress'),
      ),
      body: TrackWorkoutPage(
        workout: workout,
      ),
    );
  }
}

class TrackWorkoutPage extends StatefulWidget {
  final Workout workout;

  const TrackWorkoutPage({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  TrackWorkoutPageState createState() => TrackWorkoutPageState();
}

class TrackWorkoutPageState extends State<TrackWorkoutPage> {
  // void blah(BuildContext context) {
  //   Map<String, SensorOrientation> map = SensorService.of(context).orientations
  // }
  void analyzeCurlWorkout(BuildContext context){
    Map<String,SensorOrientation> map = SensorService.of(context).orientations;


    DateTime start = DateTime.now();
    DateTime curlstart = start, curlend = start;
    int curldiff = 0;
    // List<double> yaws = [];
    // List<double> pitches = [];
    // List<double> rolls = [];
    int state = 0;
    int holdup = 0;
    int curls = 0;

    // List<List<List<double>>> data;
    List<List<double>> data_per = List.generate(2, (i) => [0,0,0], growable: false);
    List<List<double>> data_prev = List.generate(2, (i) => [0,0,0], growable: false);
    List<List<double>> data_temp = List.generate(2, (i) => [0,0,0], growable: false);
    double dy, dp, dr;

    
  while (1==1) {
    //Get data
    map = SensorService.of(context).orientations;
    if(map[rightShoulderSuffix ] !=null && map[rightShoulderSuffix]?.yaw != null){
      data_temp[0][0] = map[rightShoulderSuffix]!.yaw!;
      data_temp[0][1] = map[rightShoulderSuffix]!.pitch!;
      data_temp[0][2] = map[rightShoulderSuffix]!.roll!;
      //copy previous
      data_prev[0][0] = data_per[0][0];
      data_prev[0][1] = data_per[0][1];
      data_prev[0][2] = data_per[0][2];
      //copy temp -> data
      data_per[0][0] = data_temp[0][0];
      data_per[0][1] = data_temp[0][1];
      data_per[0][2] = data_temp[0][2];
    }
    if(map[rightForearmSuffix ] !=null && map[rightForearmSuffix]?.yaw != null){
      data_temp[1][0] = map[rightForearmSuffix]!.yaw!;
      data_temp[1][1] = map[rightForearmSuffix]!.pitch!;
      data_temp[1][2] = map[rightForearmSuffix]!.roll!;
      //copy previous
      data_prev[1][0] = data_per[1][0];
      data_prev[1][1] = data_per[1][1];
      data_prev[1][2] = data_per[1][2];
      //copy temp -> data
      data_per[1][0] = data_temp[1][0];
      data_per[1][1] = data_temp[1][1];
      data_per[1][2] = data_temp[1][2];
    }
    
      // //add timer
      // if("addd stuff for time differnece"==""){
      //   // add timer
      
      //calculate difference between 2 sensors
      dy = (data_per[0][0]-data_per[1][0]).abs();
      dp = (data_per[0][1]-data_per[1][1]).abs();
      dr = (data_per[0][2]-data_per[1][2]).abs();
      switch (state) {
      case 0:
        //Add Calibration
        //go to down state
        state=1;
        break;
      
      case 1: //Down State
        
        //hold time?
        //check boundary for up state
        if(dp>60){
          state=2;
          holdup=0;
          curlstart = DateTime.now();
        }
        //recalibrate if necessary
        break;

      case 2://up state
        holdup++;
        if(dp<30){
          state=3;
          curlend = DateTime.now();
          curldiff = (curlend.difference(curlstart)).inSeconds;
        }
        break;
  
      case 3://finish state
        curls++;
        //output number of curls
        //output time curl held
        //any additional feedback
        state=1;
        //if(signal or done)
          //return
        break;
      default:
    }
    
  }

  }

  void stopWorkout(BuildContext context) {
    if (!widget.workout.isWorkoutStarted()) {
      Future result = showConfirmationDialog(
        context,
        confirmFinishDialogTitle,
        confirmNoStartDialogMessage,
      );

      result.then((value) {
        if (value) {
          Navigator.of(context).pop(
            NavigatorResponse(true, NavigatorAction.cancel, null),
          );
        }
      });
    } else if (!widget.workout.isWorkoutDone()) {
      Future result = showConfirmationDialog(
        context,
        confirmFinishDialogTitle,
        confirmFinishDialogMessage,
      );

      result.then(
        (value) {
          if (value) {
            Navigator.of(context).pop(
              NavigatorResponse(
                true,
                NavigatorAction.finish,
                null,
              ),
            );
          }
        },
      );
    } else {
      Navigator.of(context).pop(
        NavigatorResponse(
          true,
          NavigatorAction.finish,
          null,
        ),
      );
    }
  }

  void cancelWorkout(BuildContext context) {
    Future result = showConfirmationDialog(
      context,
      confirmCancelDialogTitle,
      confirmCancelWorkoutDialogMessage,
    );

    result.then(
      (value) {
        if (value) {
          Navigator.of(context).pop(
            NavigatorResponse(true, NavigatorAction.cancel, null),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TimerService.ofSet(context),
      builder: (context, child) {
        return Column(
          children: [
            WorkoutWidget(
              type: WidgetType.track,
              workout: widget.workout,
              editable: false,
            ),
            if (TimerService.ofSet(context).isRunning)
              const Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                child: SizedBox(
                  width: double.infinity,
                  child: RestTimer(),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    cancelWorkout(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    stopWorkout(context);
                  },
                  child: const Text('Finish'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class RestTimer extends StatefulWidget {
  const RestTimer({
    Key? key,
  }) : super(key: key);

  @override
  State<RestTimer> createState() => RestTimerState();
}

class RestTimerState extends State<RestTimer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TimerService.ofSet(context),
      builder: (context, child) {
        return Container(
          decoration: globalBoxDecoration,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    getFormattedDuration(
                      TimerService.ofSet(context).elapsed,
                      DurationFormat(
                        TimeFormat.digital,
                        DigitalTimeFormat(
                          hours: false,
                          minutes: true,
                          seconds: true,
                          twoDigit: false,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 6.0),
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(
                        begin: 0,
                        end:
                            TimerService.ofSet(context).elapsed.inMilliseconds /
                                180000
                        // TimerService.ofSet(context)
                        //     .endDuration!
                        //     .inMilliseconds,
                        ),
                    duration: globalAnimationSpeed,
                    builder: ((context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: const Color.fromARGB(
                          0,
                          0,
                          0,
                          0,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// class SensorOrientation {
//   double? yaw;
//   double? pitch;
//   double? roll;

//   SensorOrientation();

//   @override
//   String toString() {
//     return 'Yaw: $yaw \t Pitch: $pitch \t Roll: $roll';
//   }
// }


