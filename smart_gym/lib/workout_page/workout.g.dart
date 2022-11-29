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