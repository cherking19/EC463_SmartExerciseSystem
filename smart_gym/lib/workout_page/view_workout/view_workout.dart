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
  List<Workout> workouts = [];

  void loadWorkouts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String routinesJson = prefs.getString(routinesJsonKey) ?? "";
    // Map<String, dynamic> routines = jsonDecode(routinesJson);
    workouts = Routines.fromJson(jsonDecode(routinesJson)).workouts;
    // print(workout);

    setState(() {});
  }

  void openWorkout() {}

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
                      onPressed: openWorkout,
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
