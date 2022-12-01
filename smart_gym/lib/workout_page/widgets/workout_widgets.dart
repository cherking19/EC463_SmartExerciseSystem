import 'package:flutter/material.dart';

class WorkoutName extends StatelessWidget {
  final GlobalKey formKey;

  WorkoutName({
    Key? key,
    required this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Workout Name',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a name';
          }
          return null;
        },
        // onChanged: (value) {
        //   workout.setName(value);
        // },
      ),
    );
  }
}

class ExercisesWidget extends StatefulWidget {
  @override
  _ExercisesWidgetState createState() {
    return _ExercisesWidgetState();
  }
}

class _ExercisesWidgetState extends State<ExercisesWidget> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: workout.exercises.length,
          itemBuilder: (BuildContext context, int index) {
            return ExerciseWidget(
              index: index,
              name: workout.exercises[index].name,
              sets: workout.getSets(index),
              onlyExercise: workout.exercises.length == 1,
              sameWeightFlag: workout.exercises[index].sameWeight,
              sameRepsFlag: workout.exercises[index].sameReps,
              sameRestFlag: workout.exercises[index].sameRest,
              updateName: updateExerciseName,
              delete: deleteExercise,
              addSet: addSet,
              setWeight: setWeight,
              setReps: setReps,
              setRest: setRest,
              setWeightSameFlag: setWeightSameFlag,
              setRepsSameFlag: setRepsSameFlag,
              setRestSameFlag: setRestSameFlag,
              setWeightSame: setWeightSame,
              setRepsSame: setRepsSame,
              setRestSame: setRestSame,
              deleteSet: deleteSet,
            );
          },
        ),
      ),
    );
  }
}

// class _WorkoutNameState extends State<WorkoutName> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: TextFormField(
//         decoration: const InputDecoration(
//           labelText: 'Workout Name',
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please enter a name';
//           }
//           return null;
//         },
//         // onChanged: (value) {
//         //   workout.setName(value);
//         // },
//       ),
//     );
//   }
// }

