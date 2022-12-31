import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/workout_widgets/workout_widgets.dart';
import 'package:smart_gym/services/TimerService.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';

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
            NavigatorResponse(true, cancelAction, null),
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
              NavigatorResponse(true, finishAction, null),
            );
          }
        },
      );
    } else {
      Navigator.of(context).pop(
        NavigatorResponse(true, finishAction, null),
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
            NavigatorResponse(true, cancelAction, null),
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
                      Duration(
                        seconds:
                            TimerService.ofSet(context).elapsedMilli ~/ 1000,
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
                      end: TimerService.ofSet(context).elapsedMilli /
                          (TimerService.ofSet(context).duration! * 1000),
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
