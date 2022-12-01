// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_gym/workout_page/widgets/workout_widgets.dart';
import '../workout.dart';

class ViewWorkoutRoute extends StatefulWidget {
  // const ViewWorkoutRoute({super.key});

  final Workout workout;

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('View Workouts'),
  //     ),
  //     body: const ViewWorkout(),
  //   );
  // }

  const ViewWorkoutRoute({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  State<ViewWorkoutRoute> createState() => _ViewWorkoutRouteState();
}

class _ViewWorkoutRouteState extends State<ViewWorkoutRoute> {
  final bool editable = false;

  @override
  Widget build(BuildContext context) {
    // print(widget.workout);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewing Workout'),
      ),
      body: Column(
        children: [
          Expanded(
            child: WorkoutForm(
              editable: editable,
              workout: widget.workout,
            ),
          )
        ],
      ),
    );
  }
}
