import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
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
  void startTracking(Workout workout) {
    widget.currentWorkout = workout;
    widget.trackedWorkout = workout.getTrackedWorkout();
    setState(() {});
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
                WorkoutInProgressBar(
                  workout: widget.currentWorkout!,
                  trackedWorkout: widget.trackedWorkout!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutInProgressBar extends StatefulWidget {
  final Workout workout;
  final TrackedWorkout trackedWorkout;

  const WorkoutInProgressBar({
    Key? key,
    required this.workout,
    required this.trackedWorkout,
  }) : super(key: key);

  @override
  State<WorkoutInProgressBar> createState() {
    return WorkoutInProgressBarState();
  }
}

class WorkoutInProgressBarState extends State<WorkoutInProgressBar> {
  void openTracking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackWorkoutRoute(
          workout: widget.workout,
          trackedWorkout: widget.trackedWorkout,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: openTracking,
      child: Column(
        children: [
          const Text('Workout In Progress'),
          Text(widget.workout.name),
        ],
      ),
    );
  }
}
