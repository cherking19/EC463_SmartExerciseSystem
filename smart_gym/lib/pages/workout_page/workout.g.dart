// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Routines _$RoutinesFromJson(Map<String, dynamic> json) => Routines(
      (json['workouts'] as List<dynamic>)
          .map((e) => Workout.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoutinesToJson(Routines instance) => <String, dynamic>{
      'workouts': instance.workouts.map((e) => e.toJson()).toList(),
    };

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout(
      json['name'] as String,
      (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'name': instance.name,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
    };

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      json['name'] as String,
      (json['sets'] as List<dynamic>)
          .map((e) => Set.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['sameWeight'] as bool,
      json['sameReps'] as bool,
      json['sameRest'] as bool,
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'name': instance.name,
      'sets': instance.sets.map((e) => e.toJson()).toList(),
      'sameWeight': instance.sameWeight,
      'sameReps': instance.sameReps,
      'sameRest': instance.sameRest,
    };

Set _$SetFromJson(Map<String, dynamic> json) => Set(
      json['weight'] as int,
      json['reps'] as int,
      json['rest'] as int,
    );

Map<String, dynamic> _$SetToJson(Set instance) => <String, dynamic>{
      'reps': instance.reps,
      'rest': instance.rest,
      'weight': instance.weight,
    };

TrackedWorkout _$TrackedWorkoutFromJson(Map<String, dynamic> json) =>
    TrackedWorkout(
      json['name'] as String,
      (json['exercises'] as List<dynamic>)
          .map((e) => TrackedExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..totalTime = json['totalTime'] as int?
      ..dateStarted = json['dateStarted'] == null
          ? null
          : DateTime.parse(json['dateStarted'] as String);

Map<String, dynamic> _$TrackedWorkoutToJson(TrackedWorkout instance) =>
    <String, dynamic>{
      'name': instance.name,
      'totalTime': instance.totalTime,
      'dateStarted': instance.dateStarted?.toIso8601String(),
      'exercises': instance.exercises,
    };

TrackedExercise _$TrackedExerciseFromJson(Map<String, dynamic> json) =>
    TrackedExercise(
      json['name'] as String,
      (json['sets'] as List<dynamic>)
          .map((e) => TrackedSet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TrackedExerciseToJson(TrackedExercise instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sets': instance.sets,
    };

TrackedSet _$TrackedSetFromJson(Map<String, dynamic> json) => TrackedSet(
      json['repsDone'] as int?,
      json['totalReps'] as int,
      json['weight'] as int,
    );

Map<String, dynamic> _$TrackedSetToJson(TrackedSet instance) =>
    <String, dynamic>{
      'repsDone': instance.repsDone,
      'totalReps': instance.totalReps,
      'weight': instance.weight,
    };
