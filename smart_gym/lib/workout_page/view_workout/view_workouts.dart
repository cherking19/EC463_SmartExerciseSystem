import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_gym/workout_page/view_workout/view_workout.dart';
import 'dart:convert';
import '../workout.dart';

class ViewWorkoutsRoute extends StatelessWidget {
  const ViewWorkoutsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Workouts'),
      ),
      body: const ViewWorkouts(),
    );
  }
}

class ViewWorkouts extends StatefulWidget {
  const ViewWorkouts({super.key});

  @override
  ViewWorkoutsState createState() {
    return ViewWorkoutsState();
  }
}

class ViewWorkoutsState extends State<ViewWorkouts> {
  List<Workout> workouts = [];

  void loadWorkouts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String routinesJson = prefs.getString(routinesJsonKey) ?? "";
    // Map<String, dynamic> routines = jsonDecode(routinesJson);
    if (routinesJson.isNotEmpty) {
      workouts = Routines.fromJson(jsonDecode(routinesJson)).workouts;
    }
    // print(workout);

    setState(() {});
  }

  void openWorkout(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewWorkoutRoute(workout: workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    loadWorkouts();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: workouts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TextButton(
                      onPressed: () => openWorkout(workouts[index]),
                      child: Text(workouts[index].name),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
