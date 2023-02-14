import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/exercises/exercises.dart';
import 'package:smart_gym/pages/workout_page/track_workout/sensor_interface.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/snackbars.dart';
import 'package:smart_gym/services/TimerService.dart';
import 'package:smart_gym/pages/workout_page/track_workout/track_workout.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import '../../utils/widget_utils.dart';
import 'create_routine/create_routine.dart';
import 'view_workout/view_workouts.dart';

class WorkoutPage extends StatefulWidget {
  Workout? workout;

  WorkoutPage({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  State<WorkoutPage> createState() {
    return WorkoutPageState();
  }
}

class WorkoutPageState extends State<WorkoutPage>
    with AutomaticKeepAliveClientMixin {
  void startWorkoutTimer() {
    TimerService.ofWorkout(context).restart(null);
    widget.workout!.dateStarted = DateTime.now();
  }

  void startTracking(Workout workout) {
    if (widget.workout != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        workoutInProgressSnackBar(context),
      );
    } else {
      widget.workout = workout;
      startWorkoutTimer();
      setState(() {});
      openTracking();
    }
  }

  void openTracking() {
    Future result = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackWorkoutRoute(
          workout: widget.workout!,
        ),
      ),
    );

    result.then(
      (value) {
        if (value != null) {
          NavigatorResponse response = value as NavigatorResponse;

          if (response.success) {
            if (response.action == NavigatorAction.finish) {
              finishTracking();
            } else if (response.action == NavigatorAction.cancel) {
              cancelTracking();
            }
          }
        }
      },
    );
  }

  void saveCurrentDuration() {
    widget.workout!.duration = TimerService.ofWorkout(context).elapsed;
  }

  void stopTimers() {
    TimerService.ofSet(context).stop();
    TimerService.ofWorkout(context).stop();
  }

  void finishTracking() {
    saveCurrentDuration();
    stopTimers();
    saveTrackedWorkout(widget.workout!);
    setState(() {
      widget.workout = null;
    });
  }

  void cancelTracking() {
    saveCurrentDuration();
    stopTimers();
    setState(() {
      widget.workout = null;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    void clickCreate() {
      Future result = Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateRoutineRoute(),
        ),
      );

      result.then((value) {
        if (value != null) {
          if (value) {
            ScaffoldMessenger.of(context)
                .showSnackBar(createSuccessSnackBar(context));
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(createFailedSnackBar(context));
          }
        }
      });
    }

    void clickViewWorkouts() {
      Future result = Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ViewWorkoutsRoute(),
        ),
      );

      result.then((value) {
        if (value != null) {
          NavigatorResponse response = value as NavigatorResponse;

          if (response.action == NavigatorAction.track) {
            startTracking(response.data as Workout);
          }
        }
      });
    }

    void clickExercises() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ViewExercisesRoute(),
        ),
      );
    }

    Widget workoutPageButton({
      required String text,
      required onPressed,
    }) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(10),
            padding: const EdgeInsets.all(24.0),
          ),
          onPressed: onPressed,
          child: Text(text),
        ),
      );
    }

    super.build(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              workoutPageButton(
                text: 'Create Workout',
                onPressed: clickCreate,
              ),
              workoutPageButton(
                text: 'View Workouts',
                onPressed: clickViewWorkouts,
              ),
              workoutPageButton(
                text: 'Exercises',
                onPressed: clickExercises,
              ),
              if (widget.workout != null)
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: WorkoutInProgressBar(
                      workout: widget.workout!,
                      openTracking: openTracking,
                    ),
                  ),
                ),
              // ProviderWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutInProgressBar extends StatefulWidget {
  Workout? workout;
  final Function openTracking;

  WorkoutInProgressBar({
    Key? key,
    required this.workout,
    required this.openTracking,
  }) : super(key: key);

  @override
  State<WorkoutInProgressBar> createState() {
    return WorkoutInProgressBarState();
  }
}

class WorkoutInProgressBarState extends State<WorkoutInProgressBar> {
  double restProgress = 0.0;

  void openTracking() {
    widget.openTracking();
  }

  @override
  Widget build(BuildContext context) {
    DurationFormat restTimerFormat = DurationFormat(
      TimeFormat.digital,
      DigitalTimeFormat(
        hours: false,
        minutes: true,
        seconds: true,
        twoDigit: false,
      ),
    );

    return AnimatedBuilder(
      animation: TimerService.ofSet(context),
      builder: (context, child) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(10),
            padding: const EdgeInsets.all(0.0),
          ),
          onPressed: openTracking,
          child: SizedBox(
            width: double.infinity,
            height: TimerService.ofSet(context).isRunning ? 75 : 65,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.workout!.name,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const Text(
                            'In Progress',
                          ),
                        ],
                      ),
                      if (TimerService.ofSet(context).isRunning)
                        Flexible(
                          fit: FlexFit.loose,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  getFormattedDuration(
                                    TimerService.ofSet(context).elapsed,
                                    restTimerFormat,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  getFormattedDuration(
                                    TimerService.ofSet(context).endDuration!,
                                    restTimerFormat,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (TimerService.ofSet(context).isRunning)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 6.0),
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(
                        begin: 0,
                        end:
                            TimerService.ofSet(context).elapsed.inMilliseconds /
                                TimerService.ofSet(context)
                                    .endDuration!
                                    .inMilliseconds,
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
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
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
