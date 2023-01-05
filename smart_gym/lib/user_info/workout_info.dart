import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/workout_page/workout.dart';

const String routinesJsonKey = 'routines';
const String finishedWorkoutsKey = 'finishedWorkouts';

Future<List<Workout>> loadRoutines() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = prefs.getString(routinesJsonKey) ?? "";
  List<Workout> routines = [];

  if (routinesJson.isNotEmpty) {
    routines = (jsonDecode(routinesJson) as List)
        .map((i) => Workout.fromJson(i))
        .toList();
  }

  return routines;
}

Future<bool> saveRoutine(Workout routine) async {
  List<Workout> routines = await loadRoutines();
  routine.generateRandomUuid();
  routines.add(routine);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = jsonEncode(routines);

  return await prefs.setString(routinesJsonKey, routinesJson);
}

Future<bool> updateRoutine(Workout workout) async {
  List<Workout> routines = await loadRoutines();
  routines[routines.indexWhere(
    (routine) => routine.uuid == workout.uuid,
  )] = workout;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = jsonEncode(routines);

  return await prefs.setString(routinesJsonKey, routinesJson);
}

Future<bool> deleteRoutine(String uuid) async {
  List<Workout> routines = await loadRoutines();
  routines.removeAt(
    routines.indexWhere(
      (routine) => routine.uuid == uuid,
    ),
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = jsonEncode(routines);

  return prefs.setString(routinesJsonKey, routinesJson);
}

Future<bool> clearRoutines() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = jsonEncode([]);

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

Future<bool> updateTrackedWorkout(Workout workout) async {
  List<Workout> finishedWorkouts = await loadFinishedWorkouts();
  finishedWorkouts[finishedWorkouts.indexWhere(
    (finishedWorkout) => finishedWorkout.uuid == workout.uuid,
  )] = workout;
  String finishedWorkoutsJson = jsonEncode(finishedWorkouts);
  SharedPreferences prefs = await SharedPreferences.getInstance();

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

Future<bool> clearSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.clear();
}
