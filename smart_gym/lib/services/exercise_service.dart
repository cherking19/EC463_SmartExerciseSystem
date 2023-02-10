import 'dart:collection';
import 'package:flutter/material.dart';
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

  Map<String, String> defaultExercises = HashMap();

  ExerciseService() {
    for (int i = 0; i < defaultExerciseNames.length; i++) {
      defaultExercises.addAll({
        uuid.v5(exerciseNamespace, defaultExerciseNames[i]):
            defaultExerciseNames[i]
      });
    }
  }

  // static ExerciseService of(BuildContext context) {
  //   var provider =
  //       context.dependOnInheritedWidgetOfExactType<ExerciseServiceProvider>();
  //   return provider!.exerciseService;
  // }
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
