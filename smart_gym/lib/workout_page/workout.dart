// import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
// import 'dart:convert';

part 'workout.g.dart';

const List<String> exerciseChoices = <String>[
  'Squat',
  'Bench Press',
  'Deadlift',
  'Overhead Press',
  'Barbell Row'
];

@JsonSerializable(explicitToJson: true)
class Routines {
  List<Workout> _workouts = [];

  Routines(List<Workout> workouts) {
    _workouts = workouts;
  }

  factory Routines.fromJson(Map<String, dynamic> json) =>
      _$RoutinesFromJson(json);

  Map<String, dynamic> toJson() => _$RoutinesToJson(this);

  List<Workout> get workouts {
    return _workouts;
  }

  void addWorkout(Workout workout) {
    workouts.add(workout);
  }

  void replaceWorkout(Workout workout, int index) {
    workouts[index] = workout;
  }

  void deleteWorkout(int index) {
    workouts.removeAt(index);
  }
}

@JsonSerializable(explicitToJson: true)
class Workout {
  String _name = '';
  List<Exercise> _exercises = [];

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

  // factory WorkoutRoutine.fromJson(Map<String, dynamic> parsedJson) {
  //   return WorkoutRoutine();
  // }

  // Map<String, dynamic> toJson() {
  //   return {"name": _name, "exercises": jsonEncode(_exercises)};
  // }

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
          exerciseChoices.first,
          [
            Set(
              0,
              0,
              0,
            )
          ],
          false,
          false,
          false),
    );

    return exercises.length - 1;
  }

  void deleteExercise(int index) {
    exercises.removeAt(index);
  }

  TrackedWorkout getTrackedWorkout() {
    List<TrackedExercise> trackedExercises = [];

    for (Exercise exercise in exercises) {
      trackedExercises.add(exercise.getTrackedExercise());
    }

    return TrackedWorkout(name, trackedExercises);
  }
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
    Set newSet = Set(0, 0, 0);

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

  void setRest(int index, int rest) {
    if (sameRest) {
      for (Set set in sets) {
        set.rest = rest;
      }
    } else {
      _sets[index].rest = rest;
    }
  }

  TrackedExercise getTrackedExercise() {
    List<TrackedSet> trackedSets = [];

    for (Set set in sets) {
      trackedSets.add(set.getTrackedSet());
    }

    return TrackedExercise(name, trackedSets);
  }
}

@JsonSerializable()
class Set {
  int _weight = 0;

  // the number of reps. In practice should be greater than 0
  int _reps = 0;

  // the rest time in seconds. Should be greater than 0
  int _rest = 0;

  Set(int weight, int reps, int rest) {
    _reps = reps;
    _rest = rest;
    _weight = weight;
  }

  @override
  String toString() {
    return 'weight: $_weight, reps: $_reps, rest: $_rest ';
  }

  factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);

  Map<String, dynamic> toJson() => _$SetToJson(this);

  bool validateSet() {
    return _reps > 0 && _rest > 0 && _weight > 0;
  }

  set reps(int value) {
    _reps = value;
  }

  int get reps {
    return _reps;
  }

  // set the rest of this set in seconds. Should be non-negative
  set rest(int value) {
    assert(rest >= 0, 'The passed rest is not non-negative');
    _rest = value;
  }

  int get rest {
    return _rest;
  }

  set weight(int value) {
    _weight = value;
  }

  int get weight {
    return _weight;
  }

  TrackedSet getTrackedSet() {
    return TrackedSet(
      null,
      reps,
      weight,
    );
  }
}

@JsonSerializable()
class TrackedWorkout {
  String _name = '';
  List<TrackedExercise> _exercises = [];

  TrackedWorkout(
    String name,
    List<TrackedExercise> exercises,
  ) {
    _name = name;
    _exercises = exercises;
  }

  @override
  String toString() {
    return '$name: $exercises ';
  }

  factory TrackedWorkout.fromJson(Map<String, dynamic> json) =>
      _$TrackedWorkoutFromJson(json);

  Map<String, dynamic> toJson() => _$TrackedWorkoutToJson(this);

  String get name {
    return _name;
  }

  set name(String name) {
    _name = name;
  }

  List<TrackedExercise> get exercises {
    return _exercises;
  }

  set exercises(List<TrackedExercise> exercises) {
    _exercises = exercises;
  }
}

@JsonSerializable()
class TrackedExercise {
  String _name = '';
  List<TrackedSet> _sets = [];

  TrackedExercise(
    String name,
    List<TrackedSet> sets,
  ) {
    _name = name;
    _sets = sets;
  }

  @override
  String toString() {
    return '$name: $sets ';
  }

  factory TrackedExercise.fromJson(Map<String, dynamic> json) =>
      _$TrackedExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$TrackedExerciseToJson(this);

  String get name {
    return _name;
  }

  set name(String name) {
    _name = name;
  }

  List<TrackedSet> get sets {
    return _sets;
  }

  set sets(List<TrackedSet> sets) {
    _sets = sets;
  }
}

@JsonSerializable()
class TrackedSet {
  int? _reps_done = null;
  int _total_reps = 0;
  int _weight = 0;

  TrackedSet(
    int? reps_done,
    int total_reps,
    int weight,
  ) {
    _reps_done = reps_done;
    _total_reps = total_reps;
    _weight = weight;
  }

  @override
  String toString() {
    return ('reps done: $reps_done, total reps: $total_reps');
  }

  factory TrackedSet.fromJson(Map<String, dynamic> json) =>
      _$TrackedSetFromJson(json);

  Map<String, dynamic> toJson() => _$TrackedSetToJson(this);

  int? get reps_done {
    return _reps_done;
  }

  set reps_done(int? reps_done) {
    _reps_done = reps_done;
  }

  int get total_reps {
    return _total_reps;
  }

  set total_reps(int total_reps) {
    _total_reps = total_reps;
  }

  int get weight {
    return _weight;
  }

  set weight(int weight) {
    _weight = weight;
  }
}
