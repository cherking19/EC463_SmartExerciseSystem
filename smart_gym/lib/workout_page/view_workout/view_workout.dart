import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../workout.dart';

class ViewWorkoutRoute extends StatelessWidget {
  const ViewWorkoutRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Workouts'),
      ),
      body: const ViewWorkout(),
    );
  }
}

class ViewWorkout extends StatefulWidget {
  const ViewWorkout({super.key});

  @override
  ViewWorkoutState createState() {
    return ViewWorkoutState();
  }
}

class ViewWorkoutState extends State<ViewWorkout> {
  void loadWorkouts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String p = prefs.getString('workout') ?? "";
    Map<String, dynamic> userMap = jsonDecode(p);
    WorkoutRoutine workout = WorkoutRoutine.fromJson(userMap);
    print(workout);
  }

  @override
  Widget build(BuildContext context) {
    loadWorkouts();
    return Column();
  }
}
