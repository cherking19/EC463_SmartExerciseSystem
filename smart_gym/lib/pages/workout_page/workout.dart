import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:smart_gym/services/exercise_service.dart';
import 'package:uuid/uuid.dart';

part 'workout.g.dart';

// @JsonSerializable(explicitToJson: true)
class ExerciseChoice {
  late String _name;
  late String _uuid;

  ExerciseChoice({
    required String name,
    required String uuid,
  }) {
    _name = name;
    _uuid = uuid;
  }

  // factory ExerciseChoice.fromJson(Map<String, dynamic> json) =>
  //     _$ExerciseChoiceFromJson(json);

  // Map<String, dynamic> toJson() => _$ExerciseChoiceToJson(this);

  @override
  bool operator ==(Object other) =>
      other is ExerciseChoice && other.name == name && other.uuid == uuid;

  String get name {
    return _name;
  }

  set name(String value) {
    _name = value;
  }

  String get uuid {
    return _uuid;
  }

  set uuid(String value) {
    _uuid = uuid;
  }
}

@JsonSerializable(explicitToJson: true)
class CustomExerciseChoice {
  String _name = '';

  // a list of the uuid's of exercises that use this custom exercise
  List<String> _exercisesUuid = [];

  CustomExerciseChoice({
    required String name,
    required List<String> exercisesUuid,
  }) {
    _name = name;
    _exercisesUuid = exercisesUuid;
  }

  factory CustomExerciseChoice.fromJson(Map<String, dynamic> json) =>
      _$CustomExerciseChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$CustomExerciseChoiceToJson(this);

  String get name {
    return _name;
  }

  set name(String value) {
    _name = value;
  }

  List<String> get exercisesUuid {
    return _exercisesUuid;
  }

  set exercisesUuid(List<String> value) {
    _exercisesUuid = exercisesUuid;
  }
}

const defaultRestDuration = Duration(seconds: 0);

@JsonSerializable(explicitToJson: true)
class Workout {
  String _name = '';
  List<Exercise> _exercises = [];

  String? _uuid;
  Duration? _duration;
  DateTime? _dateStarted;

  Workout({
    required String name,
    required List<Exercise> exercises,
  }) {
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

  static Workout defaultWorkout() {
    return Workout(
      name: '',
      exercises: [
        Exercise.defaultExercise(),
      ],
    );
  }

  Workout copy() {
    String json = jsonEncode(toJson());
    return Workout.fromJson(jsonDecode(json));
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
    exercises.add(Exercise.defaultExercise());

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
}

@JsonSerializable(explicitToJson: true)
class Exercise {
  String _exerciseUuid = '';
  // late ExerciseChoice _exerciseChoice;
  List<Set> _sets = [];
  bool _sameWeight = false;
  bool _sameReps = false;
  bool _sameRest = false;

  Exercise({
    required String exerciseUuid,
    // required ExerciseChoice exerciseChoice,
    required List<Set> sets,
    required bool sameWeight,
    required bool sameReps,
    required bool sameRest,
  }) {
    _exerciseUuid = exerciseUuid;
    // _exerciseChoice = exerciseChoice;
    _sets = sets;
    _sameWeight = sameWeight;
    _sameReps = sameReps;
    _sameRest = sameRest;
  }

  @override
  String toString() {
    return '$_exerciseUuid: $_sets ';
  }

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  static Exercise defaultExercise() {
    return Exercise(
      exerciseUuid: const Uuid().v5(ExerciseService.exerciseNamespace,
          ExerciseService.defaultExerciseNames.first.toLowerCase()),
      sets: [
        Set(
          0,
          0,
          defaultRestDuration,
          null,
        )
      ],
      sameWeight: false,
      sameReps: false,
      sameRest: false,
    );
  }

  // returns whether the linked exercise choice is still in the data model
  // bool isValidExercise() {}

  String get exerciseUuid {
    return _exerciseUuid;
  }

  set exerciseUuid(String value) {
    _exerciseUuid = value;
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
    return _sameWeight;
  }

  bool get sameReps {
    return _sameReps;
  }

  bool get sameRest {
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
}
