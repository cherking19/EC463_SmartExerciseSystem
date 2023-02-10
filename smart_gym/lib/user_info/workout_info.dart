import 'dart:collection';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_gym/services/exercise_service.dart';
import '../pages/workout_page/workout.dart';

const String routinesKey = 'routines';
const String finishedWorkoutsKey = 'finishedWorkouts';
const String exercisesKey = 'exercises';

Future<List<String>> loadCustomExercises(bool appendDefault) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String exercisesJson = prefs.getString(exercisesKey) ?? "";
  // CustomExercises? customExercises;
  List<String> exercises = [];

  if (exercisesJson.isNotEmpty) {
    // customExercises = CustomExercises.fromJson(jsonDecode(exercisesJson));
    exercises = (jsonDecode(exercisesJson) as List)
        .map((exercise) => exercise as String)
        .toList();
  }

  // List<String> exercises =
  //     customExercises != null ? customExercises.exercises : [];

  if (appendDefault) {
    exercises = ExerciseService.defaultExerciseNames + exercises;
  }

  return exercises;
}

Future<bool> saveCustomExercise(String newExercise) async {
  List<String> exercises = await loadCustomExercises(false);

  if (ExerciseService.defaultExerciseNames.indexWhere((defaultExercise) =>
              defaultExercise.toLowerCase() == newExercise.toLowerCase()) !=
          -1 ||
      exercises.indexWhere((exercise) =>
              exercise.toLowerCase() == newExercise.toLowerCase()) !=
          -1) {
    return false;
  } else {
    exercises.add(newExercise);
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String exercisesJson = jsonEncode(exercises);

  return await prefs.setString(exercisesKey, exercisesJson);
}

Future<bool> deleteCustomExercise(String exercise) async {
  List<String> exercises = await loadCustomExercises(false);

  if (exercises.remove(exercise)) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String exercisesJson = jsonEncode(exercises);

    return await prefs.setString(exercisesKey, exercisesJson);
  } else {
    return false;
  }
}

Future<bool> clearCustomExercises() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String exercisesJson = jsonEncode([]);

  return await prefs.setString(exercisesKey, exercisesJson);
}

Future<Map<String, Workout>> loadRoutines() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = prefs.getString(routinesKey) ?? "";
  Map<String, Workout> routines = HashMap();

  if (routinesJson.isNotEmpty) {
    routines = (jsonDecode(routinesJson) as Map).map(
      (key, value) => MapEntry(
        key,
        Workout.fromJson(value),
      ),
    );
  }

  return routines;
}

Future<bool> saveRoutine(Workout routine) async {
  Map<String, Workout> routines = await loadRoutines();
  routine.generateRandomUuid();
  routines.addAll({routine.uuid!: routine});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = jsonEncode(routines);

  return await prefs.setString(routinesKey, routinesJson);
}

Future<bool> updateRoutine(Workout routine) async {
  Map<String, Workout> routines = await loadRoutines();
  routines.update(routine.uuid!, (v) => routine);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = jsonEncode(routines);

  return await prefs.setString(routinesKey, routinesJson);
}

Future<bool> deleteRoutine(String uuid) async {
  Map<String, Workout> routines = await loadRoutines();
  routines.remove(uuid);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = jsonEncode(routines);

  return prefs.setString(routinesKey, routinesJson);
}

Future<bool> clearRoutines() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = jsonEncode([]);

  return await prefs.setString(routinesKey, routinesJson);
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
