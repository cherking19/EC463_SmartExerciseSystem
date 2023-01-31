// import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
// import 'dart:convert';

part 'workout.g.dart';

const List<String> defaultExercises = <String>[
  'Squat',
  'Bench Press',
  'Deadlift',
  'Overhead Press',
  'Barbell Row'
];

// @JsonSerializable(explicitToJson: true)
// class CustomExercises {
//   List<String> _exercises = [];

//   CustomExercises({
//     required exercises,
//   });

//   factory CustomExercises.fromJson(Map<String, dynamic> json) =>
//       _$CustomExercisesFromJson(json);

//   Map<String, dynamic> toJson() => _$CustomExercisesToJson(this);

//   List<String> get exercises {
//     return _exercises;
//   }

//   set exercises(List<String> value) {
//     _exercises = value;
//   }

//   // void addExercise()
// }

// @JsonSerializable(explicitToJson: true)
// class Routines {
//   List<Workout> _workouts = [];

//   Routines(List<Workout> workouts) {
//     _workouts = workouts;
//   }

//   factory Routines.fromJson(Map<String, dynamic> json) =>
//       _$RoutinesFromJson(json);

//   Map<String, dynamic> toJson() => _$RoutinesToJson(this);

//   List<Workout> get workouts {
//     return _workouts;
//   }

//   void addWorkout(Workout workout) {
//     workouts.add(workout);
//   }

//   void replaceWorkout(Workout workout, int index) {
//     workouts[index] = workout;
//   }

//   void deleteWorkout(int index) {
//     workouts.removeAt(index);
//   }
// }

const defaultRestDuration = Duration(seconds: 0);

@JsonSerializable(explicitToJson: true)
class Workout {
  String _name = '';
  List<Exercise> _exercises = [];

  String? _uuid;
  Duration? _duration;
  DateTime? _dateStarted;

  Workout(String name, List<Exercise> exercises) {
    _name = name;
    _exercises = exercises;
  }

  @override
  String toString() {
    return ('$_name: $_exercises,');
  }

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutToJson(this);

  Workout copy() {
    String json = jsonEncode(toJson());
    return Workout.fromJson(jsonDecode(json));
  }

  bool validateRoutine() {
    if (_name.isEmpty) {
      return false;
    }

    for (int i = 0; i < _exercises.length; i++) {
      if (!_exercises[i].validateExercise()) {
        return false;
      }
    }

    return true;
  }

  String get name {
    return _name;
  }

  set name(String name) {
    _name = name;
  }

  List<Exercise> get exercises {
    return _exercises;
  }

  set exercises(List<Exercise> exercises) {
    _exercises = exercises;
  }

  int addExercise() {
    exercises.add(
      Exercise(
        defaultExercises.first,
        [
          Set(
            0,
            0,
            defaultRestDuration,
            null,
          )
        ],
        false,
        false,
        false,
      ),
    );

    return exercises.length - 1;
  }

  void deleteExercise(int index) {
    exercises.removeAt(index);
  }

  String? get uuid {
    return _uuid;
  }

  set uuid(String? value) {
    _uuid = value;
  }

  void generateRandomUuid() {
    uuid = const Uuid().v4();
  }

  Duration? get duration {
    return _duration;
  }

  set duration(Duration? value) {
    _duration = value;
  }

  DateTime? get dateStarted {
    return _dateStarted;
  }

  set dateStarted(DateTime? date) {
    _dateStarted = date;
  }

  bool isWorkoutStarted() {
    for (Exercise exercise in exercises) {
      if (exercise.isExerciseStarted()) {
        return true;
      }
    }

    return false;
  }

  bool isWorkoutDone() {
    for (Exercise exercise in exercises) {
      if (!exercise.isExerciseDone()) {
        return false;
      }
    }

    return true;
  }

  // TrackedWorkout getTrackedWorkout() {
  //   List<TrackedExercise> trackedExercises = [];

  //   for (Exercise exercise in exercises) {
  //     trackedExercises.add(exercise.getTrackedExercise());
  //   }

  //   return TrackedWorkout(name, trackedExercises);
  // }
}

@JsonSerializable(explicitToJson: true)
class Exercise {
  String _name = '';
  List<Set> _sets = [];
  bool _sameWeight = false;
  bool _sameReps = false;
  bool _sameRest = false;

  Exercise(String name, List<Set> sets, bool sameWeight, bool sameReps,
      bool sameRest) {
    _name = name;
    _sets = sets;
    _sameWeight = sameWeight;
    _sameReps = sameReps;
    _sameRest = sameRest;
  }

  @override
  String toString() {
    return '$_name: $_sets ';
  }

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  bool validateExercise() {
    if (_name.isEmpty) {
      return false;
    }

    for (int i = 0; i < _sets.length; i++) {
      if (!_sets[i].validateSet()) {
        return false;
      }
    }

    return true;
  }

  String get name {
    return _name;
  }

  set name(String name) {
    _name = name;
  }

  List<Set> get sets {
    return _sets;
  }

  // adds a set to the exercise. Does not initialize the set to any useful properties
  void addSet() {
    Set newSet = Set(
      0,
      0,
      defaultRestDuration,
      null,
    );

    if (sameWeight) {
      newSet.weight = sets[0].weight;
    }

    if (sameReps) {
      newSet.reps = sets[0].reps;
    }

    if (sameRest) {
      newSet.rest = sets[0].rest;
    }

    sets.add(newSet);
  }

  void deleteSet(int index) {
    _sets.removeAt(index);
  }

  bool get sameWeight {
    // print('weight $_sameWeight');
    return _sameWeight;
  }

  bool get sameReps {
    // print('reps $_sameReps');
    return _sameReps;
  }

  bool get sameRest {
    // print('rest $_sameRest');
    return _sameRest;
  }

  set sameWeight(bool value) {
    _sameWeight = value;

    if (sameWeight) {
      for (Set set in sets) {
        set.weight = sets[0].weight;
      }
    }
  }

  set sameReps(bool value) {
    _sameReps = value;

    if (sameReps) {
      for (Set set in sets) {
        set.reps = sets[0].reps;
      }
    }
  }

  set sameRest(bool value) {
    _sameRest = value;

    if (sameRest) {
      for (Set set in sets) {
        set.rest = sets[0].rest;
      }
    }
  }

  void setWeight(int index, int weight) {
    if (sameWeight) {
      // print('same weight');
      for (Set set in sets) {
        set.weight = weight;
      }
    } else {
      sets[index].weight = weight;
    }
  }

  void setReps(int index, int reps) {
    if (sameReps) {
      for (Set set in sets) {
        set.reps = reps;
      }
    } else {
      sets[index].reps = reps;
    }
  }

  void setRest(int index, Duration rest) {
    if (sameRest) {
      for (Set set in sets) {
        set.rest = rest;
      }
    } else {
      _sets[index].rest = rest;
    }
  }

  bool isExerciseStarted() {
    return sets[0].repsDone != null;
  }

  bool isExerciseDone() {
    for (Set set in sets) {
      if (set.repsDone == null) {
        return false;
      }
    }

    return true;
  }

  // TrackedExercise getTrackedExercise() {
  //   List<TrackedSet> trackedSets = [];

  //   for (Set set in sets) {
  //     trackedSets.add(set.getTrackedSet());
  //   }

  //   return TrackedExercise(name, trackedSets);
  // }
}

@JsonSerializable()
class Set {
  int _weight = 0;

  // the number of reps. In practice should be greater than 0
  int _reps = 0;

  // the rest time in seconds. Should be greater than 0
  Duration _rest = const Duration(seconds: 0);

  int? _repsDone;

  Set(
    int weight,
    int reps,
    Duration rest,
    int? repsDone,
  ) {
    _reps = reps;
    _rest = rest;
    _weight = weight;
    _repsDone = repsDone;
  }

  @override
  String toString() {
    return 'weight: $weight, reps: $reps, rest: $rest, reps done: $repsDone';
  }

  factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);

  Map<String, dynamic> toJson() => _$SetToJson(this);

  set reps(int value) {
    _reps = value;
  }

  int get reps {
    return _reps;
  }

  // set the rest of this set in seconds. Should be non-negative
  set rest(Duration value) {
    assert(rest.inSeconds >= 0, 'The passed rest is not non-negative');
    _rest = value;
  }

  Duration get rest {
    return _rest;
  }

  set weight(int value) {
    _weight = value;
  }

  int get weight {
    return _weight;
  }

  set repsDone(int? value) {
    _repsDone = value;
  }

  int? get repsDone {
    return _repsDone;
  }

  bool validateSet() {
    return reps > 0 && rest.inSeconds > 0 && weight > 0;
  }

  // TrackedSet getTrackedSet() {
  //   return TrackedSet(
  //     null,
  //     reps,
  //     weight,
  //   );
  // }
}

// @JsonSerializable()
// class TrackedWorkout {
//   String _name = '';
//   // in seconds
//   int? _totalTime;
//   DateTime? _dateStarted;
//   List<TrackedExercise> _exercises = [];

//   TrackedWorkout(
//     String name,
//     List<TrackedExercise> exercises,
//   ) {
//     _name = name;
//     _exercises = exercises;
//   }

//   @override
//   String toString() {
//     return '$name: time: $totalTime, date: $dateStarted $exercises ';
//   }

//   factory TrackedWorkout.fromJson(Map<String, dynamic> json) =>
//       _$TrackedWorkoutFromJson(json);

//   Map<String, dynamic> toJson() => _$TrackedWorkoutToJson(this);

//   String get name {
//     return _name;
//   }

//   set name(String name) {
//     _name = name;
//   }

//   int? get totalTime {
//     return _totalTime;
//   }

//   set totalTime(int? time) {
//     _totalTime = time;
//   }

//   DateTime? get dateStarted {
//     return _dateStarted;
//   }

//   set dateStarted(DateTime? date) {
//     _dateStarted = date;
//   }

//   List<TrackedExercise> get exercises {
//     return _exercises;
//   }

//   set exercises(List<TrackedExercise> exercises) {
//     _exercises = exercises;
//   }

//   bool isWorkoutStarted() {
//     for (TrackedExercise exercise in exercises) {
//       if (exercise.isExerciseStarted()) {
//         return true;
//       }
//     }

//     return false;
//   }

//   bool isWorkoutDone() {
//     for (TrackedExercise exercise in exercises) {
//       if (!exercise.isExerciseDone()) {
//         return false;
//       }
//     }

//     return true;
//   }
// }

// @JsonSerializable()
// class TrackedExercise {
//   String _name = '';
//   List<TrackedSet> _sets = [];

//   TrackedExercise(
//     String name,
//     List<TrackedSet> sets,
//   ) {
//     _name = name;
//     _sets = sets;
//   }

//   @override
//   String toString() {
//     return '$name: $sets ';
//   }

//   factory TrackedExercise.fromJson(Map<String, dynamic> json) =>
//       _$TrackedExerciseFromJson(json);

//   Map<String, dynamic> toJson() => _$TrackedExerciseToJson(this);

//   String get name {
//     return _name;
//   }

//   set name(String name) {
//     _name = name;
//   }

//   List<TrackedSet> get sets {
//     return _sets;
//   }

//   set sets(List<TrackedSet> sets) {
//     _sets = sets;
//   }

//   bool isExerciseStarted() {
//     return sets[0].repsDone != null;
//   }

//   bool isExerciseDone() {
//     for (TrackedSet set in sets) {
//       if (set.repsDone == null) {
//         return false;
//       }
//     }

//     return true;
//   }
// }

// @JsonSerializable()
// class TrackedSet {
//   int? _repsDone;
//   int _totalReps = 0;
//   int _weight = 0;

//   TrackedSet(
//     int? repsDone,
//     int totalReps,
//     int weight,
//   ) {
//     _repsDone = repsDone;
//     _totalReps = totalReps;
//     _weight = weight;
//   }

//   @override
//   String toString() {
//     return ('reps done: $repsDone, total reps: $totalReps, weight: $weight');
//   }

//   factory TrackedSet.fromJson(Map<String, dynamic> json) =>
//       _$TrackedSetFromJson(json);

//   Map<String, dynamic> toJson() => _$TrackedSetToJson(this);

//   int? get repsDone {
//     return _repsDone;
//   }

//   set repsDone(int? repsDone) {
//     _repsDone = repsDone;
//   }

//   int get totalReps {
//     return _totalReps;
//   }

//   set totalReps(int totalReps) {
//     _totalReps = totalReps;
//   }

//   int get weight {
//     return _weight;
//   }

//   set weight(int weight) {
//     _weight = weight;
//   }
// }
