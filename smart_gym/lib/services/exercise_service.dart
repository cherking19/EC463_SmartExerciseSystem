import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class ExerciseService extends ChangeNotifier {
  static const String exerciseNamespace =
      '703af2f7-5bbc-4fc5-9ee3-8ead62789c05';
  static const List<String> defaultExerciseNames = <String>[
    'Squat',
    'Bench Press',
    'Deadlift',
    'Overhead Press',
    'Barbell Row'
  ];

  static Map<String, String> defaultExercises = HashMap();
  Map<String, CustomExerciseChoice> customExercises = HashMap();

  ExerciseService(BuildContext context) {
    for (int i = 0; i < defaultExerciseNames.length; i++) {
      String key =
          uuid.v5(exerciseNamespace, defaultExerciseNames[i].toLowerCase());
      defaultExercises.addAll(
        {
          key: defaultExerciseNames[i],
        },
      );
    }

    loadCustomExercises(
      context,
      // appendDefault: false,
    );
  }

  Map<String, String> get exercises {
    Map<String, String> allExercises = defaultExercises;
    allExercises.addEntries(customExercises.entries.map(
      (customExerciseEntry) => MapEntry(
        customExerciseEntry.key,
        customExerciseEntry.value.name,
      ),
    ));

    return allExercises;
  }

  static bool isCustomExercise(String uuid) {
    return !defaultExercises.containsKey(uuid);
  }
}

class ExerciseServiceProvider extends InheritedWidget {
  final ExerciseService exerciseService;

  const ExerciseServiceProvider({
    Key? key,
    required this.exerciseService,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(ExerciseServiceProvider oldWidget) =>
      exerciseService != oldWidget.exerciseService;
}
