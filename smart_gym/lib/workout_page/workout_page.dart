import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/services/TimerService.dart';
import 'package:smart_gym/workout_page/track_workout/track_workout.dart';
import 'package:smart_gym/workout_page/workout.dart';
import '../utils/widget_utils.dart';
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

class WorkoutPageState extends State<WorkoutPage> {
  // int rest = 0;
  // Timer? timer;

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
          // rest: rest,
        ),
      ),
    );

    result.then((value) {
      if (value != null) {
        NavigatorResponse response = value as NavigatorResponse;

        if (response.success) {
          if (response.action == finishAction) {
            finishTracking();
          }
        }
      }
    });
  }

  void finishTracking() {
    setState(() {
      widget.currentWorkout = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Workout',
                style: TextStyle(fontSize: 18.0),
              ),
              TextButton(
                child: const Text('Create Workout'),
                onPressed: () {
                  Future result = Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateWorkoutRoute(),
                    ),
                  );

                  result.then((value) {
                    if (value) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(createSuccessSnackBar(context));
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(createFailedSnackBar(context));
                    }
                  });
                },
              ),
              TextButton(
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

                      if (response.action == 'Track') {
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
  void openTracking() {
    widget.openTracking();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TimerService.of(context),
      builder: (context, child) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(10),
            padding: const EdgeInsets.all(12.0),
          ),
          onPressed: openTracking,
          child: Padding(
            padding: const EdgeInsets.all(
              0.0,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 40,
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
                  if (TimerService.of(context).isRunning)
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
                                    seconds: TimerService.of(context).elapsed),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              getFormattedDuration(
                                Duration(
                                    seconds: TimerService.of(context).duration),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
