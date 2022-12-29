import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/services/TimerService.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import 'package:smart_gym/pages/workout_page/track_workout/track_workout.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import '../../utils/widget_utils.dart';
import 'create_workout/create_workout.dart';
import 'view_workout/view_workouts.dart';

class WorkoutPage extends StatefulWidget {
  Workout? currentWorkout;
  TrackedWorkout? trackedWorkout;

  WorkoutPage({
    Key? key,
    required this.currentWorkout,
    required this.trackedWorkout,
  }) : super(key: key);

  @override
  State<WorkoutPage> createState() {
    return WorkoutPageState();
  }
}

class WorkoutPageState extends State<WorkoutPage>
    with AutomaticKeepAliveClientMixin {
  void startTracking(Workout workout) {
    if (widget.currentWorkout != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        workoutInProgressSnackBar(context),
      );
    } else {
      widget.currentWorkout = workout;
      widget.trackedWorkout = workout.getTrackedWorkout();
      setState(() {});
      openTracking();
    }
  }

  void openTracking() {
    Future result = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackWorkoutRoute(
          workout: widget.currentWorkout!,
          trackedWorkout: widget.trackedWorkout!,
        ),
      ),
    );

    result.then((value) {
      if (value != null) {
        NavigatorResponse response = value as NavigatorResponse;

        if (response.success) {
          if (response.action == finishAction) {
            finishTracking();
          } else if (response.action == cancelAction) {
            cancelTracking();
          }
        }
      }
    });
  }

  void finishTracking() {
    // print(widget.trackedWorkout);
    saveTrackedWorkout(widget.trackedWorkout!);
    setState(() {
      widget.currentWorkout = null;
    });
  }

  void cancelTracking() {
    setState(() {
      widget.currentWorkout = null;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // const Align(
              //   alignment: Alignment.centerLeft,
              //   child: Padding(
              //     padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
              //     child: Text(
              //       'Workout',
              //       style: TextStyle(fontSize: 18.0),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(10),
                    padding: const EdgeInsets.all(24.0),
                    // backgroundColor: Colors.lightBlue,
                  ),
                  child: const Text('Create Workout'),
                  onPressed: () {
                    Future result = Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateWorkoutRoute(),
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
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(10),
                  padding: const EdgeInsets.all(24.0),
                ),
                child: const Text('View Workouts'),
                onPressed: () {
                  Future result = Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewWorkoutsRoute(),
                    ),
                  );

                  result.then((value) {
                    if (value != null) {
                      NavigatorResponse response = value as NavigatorResponse;

                      if (response.action == trackAction) {
                        startTracking(response.data as Workout);
                      }
                    }
                  });
                },
              ),
              if (widget.currentWorkout != null)
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: WorkoutInProgressBar(
                      workout: widget.currentWorkout!,
                      trackedWorkout: widget.trackedWorkout!,
                      openTracking: openTracking,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutInProgressBar extends StatefulWidget {
  Workout? workout;
  final TrackedWorkout trackedWorkout;
  final Function openTracking;

  WorkoutInProgressBar({
    Key? key,
    required this.workout,
    required this.trackedWorkout,
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
    return AnimatedBuilder(
      animation: TimerService.ofSet(context),
      builder: (context, child) {
        // updateRestProgress();
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
                                    Duration(
                                        seconds: TimerService.ofSet(context)
                                                .elapsedMilli ~/
                                            1000),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  getFormattedDuration(
                                    Duration(
                                        seconds: TimerService.ofSet(context)
                                            .duration!),
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
                        end: TimerService.ofSet(context).elapsedMilli /
                            (TimerService.ofSet(context).duration! * 1000),
                      ),
                      duration: globalAnimationSpeed,
                      builder: ((context, value, child) {
                        // print(value);
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
