import 'package:flutter/material.dart';
import 'package:smart_gym/workout_page/workout.dart';

class TrackWorkoutRoute extends StatelessWidget {
  final Workout workout;
  final TrackedWorkout trackedWorkout;

  const TrackWorkoutRoute({
    Key? key,
    required this.workout,
    required this.trackedWorkout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout In Progress'),
      ),
      body: TrackWorkout(
        workout: workout,
        trackedWorkout: trackedWorkout,
      ),
    );
  }
}

class TrackWorkout extends StatelessWidget {
  final Workout workout;
  final TrackedWorkout trackedWorkout;

  const TrackWorkout({
    Key? key,
    required this.workout,
    required this.trackedWorkout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(workout.name),
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: workout.exercises.length,
              itemBuilder: (BuildContext context, int index) {
                return TrackExercise(
                  exercise: workout.exercises[index],
                  trackedExercise: trackedWorkout.exercises[index],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class TrackExercise extends StatelessWidget {
  final Exercise exercise;
  final TrackedExercise trackedExercise;

  const TrackExercise({
    Key? key,
    required this.exercise,
    required this.trackedExercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(exercise.name);
  }
}
