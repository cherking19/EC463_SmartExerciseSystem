import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'workout_page/workout.dart';

FirebaseFunctions functions = FirebaseFunctions.instance;

Future<List<Workout>> getWorkouts() async {
  HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('getWorkouts');
  final results = await callable();
  //String workoutsJson = json.decode(results.data);
  Map<String, dynamic> data =
      new Map<String, dynamic>.from(json.decode(results.data));

  // print("result: ${workoutsJson}");
  print(data['name']);
  // var workoutsJsonList = jsonDecode(workoutsJson)['workouts'];
  // // List<Workout> workouts =
  // List<Workout>? workouts =
  //     workoutsJsonList != null ? List.from(workoutsJsonList) : null;
  // // Routines routines;
  // // if (routinesJson.isEmpty) {
  // //   routines = Routines([]);
  // // } else {
  // //   routines = Routines.fromJson(jsonDecode(routinesJson));
  // // }

  //return workouts ?? [];
  return [];
}

Future<void> addWorkout(Workout workout) async {
  String workoutJson = jsonEncode(workout);
  HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('addWorkout');
  final resp = await callable.call(<String, dynamic>{
    'workout': workoutJson,
  });
  print("result: ${resp.data}");
}
