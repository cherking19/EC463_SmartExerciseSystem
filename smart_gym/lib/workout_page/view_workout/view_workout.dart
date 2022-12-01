// import 'dart:io';

import 'package:flutter/material.dart';
import '../workout.dart';

class ViewWorkoutRoute extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
      ),
      body: const ViewWorkout(),
    );
  }

  // State<ViewWorkoutRoute> createState() => _ViewWorkoutRouteState();
}

class ViewWorkout extends StatelessWidget {
  const ViewWorkout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [],
    );
  }
}

// class _ViewWorkoutRouteState extends State<ViewWorkoutRoute> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.workoutName),
//       ),
//       body: Column(
//         children: const [],
//       ),
//     );
//   }
// }

// class _ViewWorkout