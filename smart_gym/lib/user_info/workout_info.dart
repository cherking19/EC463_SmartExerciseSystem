import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_gym/main.dart';
import 'package:smart_gym/services/exercise_service.dart';
import 'package:uuid/uuid.dart';
import '../pages/workout_page/workout.dart';

const String routinesKey = 'routines';
const String finishedWorkoutsKey = 'finishedWorkouts';
const String exercisesKey = 'exercises';

Future<Map<String, CustomExerciseChoice>> loadCustomExercises(
  BuildContext context,
  // {
  // required bool appendDefault,
// }
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String exercisesJson = prefs.getString(exercisesKey) ?? "";
  Map<String, CustomExerciseChoice> customExercises = HashMap();

  if (exercisesJson.isNotEmpty) {
    customExercises = (jsonDecode(exercisesJson) as Map).map(
      (key, value) => MapEntry<String, CustomExerciseChoice>(
        key,
        CustomExerciseChoice.fromJson(value),
      ),
    );
  }

  Provider.of<ExerciseService>(
    navigatorKey.currentContext!,
    listen: false,
  ).customExercises = customExercises;

  // if (appendDefault) {
  //   customExercises.addEntries(Provider.of<ExerciseService>(
  //     navigatorKey.currentContext!,
  //     listen: false,
  //   ).defaultExercises.entries);
  // }

  return customExercises;
}

Future<bool> saveCustomExercise(
  BuildContext context, {
  required String newExercise,
}) async {
  Map<String, CustomExerciseChoice> exercises = await loadCustomExercises(
    // appendDefault: false,
    context,
  );

  String defaultKey = const Uuid()
      .v5(ExerciseService.exerciseNamespace, newExercise.toLowerCase());

  if (ExerciseService.defaultExercises.containsKey(defaultKey) ||
      exercises.entries
          .map((exerciseEntry) => exerciseEntry.value.name)
          .toList()
          .contains(newExercise)) {
    return false;
  } else {
    exercises.addAll({
      uuid.v4(): CustomExerciseChoice(
        name: newExercise,
        exercisesUuid: [],
      ),
    });
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String exercisesJson = jsonEncode(exercises);

  if (await prefs.setString(exercisesKey, exercisesJson)) {
    Provider.of<ExerciseService>(
      navigatorKey.currentContext!,
      listen: false,
    ).customExercises = exercises;

    return true;
  }

  return false;
}

Future<bool> deleteCustomExercise(
  BuildContext context, {
  required String uuid,
}) async {
  Map<String, CustomExerciseChoice> exercises = await loadCustomExercises(
    // appendDefault: false,
    context,
  );

  if (exercises.remove(uuid) != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String exercisesJson = jsonEncode(exercises);

    if (await prefs.setString(exercisesKey, exercisesJson)) {
      Provider.of<ExerciseService>(navigatorKey.currentContext!, listen: false)
          .customExercises = exercises;
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Future<bool> renameCustomExercise(
  BuildContext context, {
  required String uuid,
  required String newName,
}) async {
  if (ExerciseService.defaultExercises.containsKey(
      const Uuid().v5(ExerciseService.exerciseNamespace, newName))) {
    return false;
  }

  Map<String, CustomExerciseChoice> customExercises = await loadCustomExercises(
    context,
    // appendDefault: false,
  );
  Map<String, CustomExerciseChoice> otherCustomExercises =
      HashMap.from(customExercises);
  CustomExerciseChoice original = otherCustomExercises.remove(uuid)!;

  if (otherCustomExercises.entries
      .map((otherCustomExerciseEntry) => otherCustomExerciseEntry.value.name)
      .toList()
      .contains(newName)) {
    return false;
  }

  CustomExerciseChoice renamed = CustomExerciseChoice(
    name: newName,
    exercisesUuid: original.exercisesUuid,
  );

  customExercises.update(uuid, (value) => renamed);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String exercisesJson = jsonEncode(customExercises);

  if (await prefs.setString(exercisesKey, exercisesJson)) {
    Provider.of<ExerciseService>(navigatorKey.currentContext!, listen: false)
        .customExercises = customExercises;
    return true;
  } else {
    return false;
  }
}

Future<bool> clearCustomExercises() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String exercisesJson = jsonEncode(HashMap());

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
  for (Exercise exercise in routine.exercises) {
    if (ExerciseService.isCustomExercise(exercise.exerciseUuid)) {}
  }

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
