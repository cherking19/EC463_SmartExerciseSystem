import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/workout_page/workout.dart';

const String routinesJsonKey = 'routines';
const String finishedWorkoutsKey = 'finishedWorkouts';

Future<Routines> loadRoutines() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = prefs.getString(routinesJsonKey) ?? "";
  Routines routines = Routines([]);
  if (routinesJson.isNotEmpty) {
    routines = Routines.fromJson(jsonDecode(routinesJson));
  }

  return routines;
}

Future<bool> saveRoutines(Routines routines) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = jsonEncode(routines.toJson());

  return await prefs.setString(routinesJsonKey, routinesJson);
}

Future<List<Workout>> loadFinishedWorkouts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String finishedWorkoutsJson = prefs.getString(finishedWorkoutsKey) ?? "";
  List<Workout> finishedWorouts = [];

  if (finishedWorkoutsJson.isNotEmpty) {
    finishedWorouts = (jsonDecode(finishedWorkoutsJson) as List)
        .map((i) => Workout.fromJson(i))
        .toList();
  }

  return finishedWorouts;
}

Future<bool> saveTrackedWorkout(Workout workout) async {
  List<Workout> finishedWorkouts = await loadFinishedWorkouts();
  workout.generateRandomUuid();
  finishedWorkouts.add(workout);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String finishedWorkoutsJson = jsonEncode(finishedWorkouts);

  return await prefs.setString(finishedWorkoutsKey, finishedWorkoutsJson);
}

Future<bool> deleteTrackedWorkout(String uuid) async {
  List<Workout> finishedWorkouts = await loadFinishedWorkouts();
  finishedWorkouts.removeAt(
    finishedWorkouts.indexWhere(
      (workout) => workout.uuid == uuid,
    ),
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String finishedWorkoutsJson = jsonEncode(finishedWorkouts);

  return await prefs.setString(finishedWorkoutsKey, finishedWorkoutsJson);
}

Future<bool> clearFinishedWorkouts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String finishedWorkoutsJson = jsonEncode([]);

  return await prefs.setString(finishedWorkoutsKey, finishedWorkoutsJson);
}
