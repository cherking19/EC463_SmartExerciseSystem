// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
