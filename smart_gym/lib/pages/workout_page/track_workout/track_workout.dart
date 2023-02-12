import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
import 'package:smart_gym/reusable_widgets/workout_widgets/workout_widgets.dart';
import 'package:smart_gym/services/TimerService.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:statistics/statistics.dart';

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

void analyzeCurlWorkout(){
  // Add  timer Carlton ask richard
  //List<List<double>> = [[[],[],[]],[[],[],[]]];
  double yav=0;
  double pav=0;
  double rav=0;
  double yaw=0;
  double pitch=0;
  double roll=0;
  List<double> yaws = [];
  List<double> pitches = [];
  List<double> rolls = [];
  int state = 0;

  // add wat ever is in debug 20-23
 while (1==1) {

  //add the reading from whatever this is where the serial port went in
    yaws.add(yaw);
    pitches.add(pitch);
    rolls.add(roll);
    //add timer
    if("addd stuff for time differnece"==""){
      // add timer
        double pyav=yav;
        double ppav=pav;
        double prav=rav;
        yav = yaws.statistics.mean;
        pav = pitches.statistics.mean;
        rav = rolls.statistics.mean;
    }
    switch (state) {
    case 0:
    
      break;
    
    case 1:
      
      break;

    case 2:
      
      break;

    case 3:
      
      break;
    default:
  }
   
 }





}
