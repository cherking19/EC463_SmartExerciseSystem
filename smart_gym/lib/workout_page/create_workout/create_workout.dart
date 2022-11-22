import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../workout.dart';
import 'dart:convert';

class CreateWorkoutRoute extends StatelessWidget {
  const CreateWorkoutRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Create Workout'),
      ),
      body: const CreateWorkoutForm(),
    );
  }
}

class CreateWorkoutForm extends StatefulWidget {
  const CreateWorkoutForm({super.key});

  @override
  CreateWorkoutFormState createState() {
    return CreateWorkoutFormState();
  }
}

class CreateWorkoutFormState extends State<CreateWorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  // final TextEditingController _setsRepsController = TextEditingController();
  bool _isExerciseErrorVisible = false;

  WorkoutRoutine routine = WorkoutRoutine('', [
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
  ]);

  void showInvalidDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Missing Entries'),
        content: const Text('Please make sure all fields are filled'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void addExercise() {
    routine.addExercise();
    setState(() {
      _isExerciseErrorVisible = false;
    });
  }

  bool validateRoutine() {
    // print(routine.toString());
    return routine.validateRoutine();
  }

  // bool validateExercises() {
  //   if (routine.exercises.isEmpty || routine.anyEmptySets()) {
  //     setState(() {
  //       _isExerciseErrorVisible = true;
  //     });

  //     return false;
  //   }

  //   _isExerciseErrorVisible = false;

  //   return true;
  // }

  void updateExerciseName(int index, String name) {
    setState(() {
      routine.updateExerciseName(index, name);
    });
  }

  void deleteExercise(int index) {
    setState(() {
      routine.deleteExercise(index);
    });
  }

  void addSet(int index) {
    setState(() {
      routine.addSet(index);
    });
  }

  void setWeightSameFlag(int index, bool value) {
    setState(() {
      routine.setWeightSameFlag(index, value);
    });
  }

  void setRepsSameFlag(int index, bool value) {
    setState(() {
      routine.setRepsSameFlag(index, value);
    });
  }

  void setRestSameFlag(int index, bool value) {
    setState(() {
      routine.setRestSameFlag(index, value);
    });
  }

  void setWeight(int exerciseIndex, int setIndex, int weight) {
    setState(() {
      routine.setWeight(exerciseIndex, setIndex, weight);
    });
  }

  void setReps(int exerciseIndex, int setIndex, int reps) {
    setState(() {
      routine.setReps(exerciseIndex, setIndex, reps);
    });
  }

  void setRepsSame(int index, int reps) {
    setState(() {
      routine.setRepsSame(index, reps);
    });
  }

  void setRest(int exerciseIndex, int setIndex, int rest) {
    setState(() {
      routine.setRest(exerciseIndex, setIndex, rest);
    });
  }

  void setWeightSame(int index, int weight) {
    setState(() {
      routine.setWeightSame(index, weight);
    });
  }

  void setRestSame(int index, int rest) {
    setState(() {
      routine.setRestSame(index, rest);
    });
  }

  void deleteSet(int exerciseIndex, int setIndex) {
    setState(() {
      routine.deleteSet(exerciseIndex, setIndex);
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _setsRepsController.addListener(() {

  //   })
  // }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
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
              onChanged: (value) {
                routine.setName(value);
              },
            ),
          ),
          Flexible(
            child: Scrollbar(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: routine.exercises.length,
                itemBuilder: (BuildContext context, int index) {
                  return ExerciseWidget(
                    index: index,
                    name: routine.exercises[index].name,
                    sets: routine.getSets(index),
                    onlyExercise: routine.exercises.length == 1,
                    sameWeightFlag: routine.exercises[index].sameWeight,
                    sameRepsFlag: routine.exercises[index].sameReps,
                    sameRestFlag: routine.exercises[index].sameRest,
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
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
            child: Text('Add Exercise'),
          ),
          Visibility(
            visible: _isExerciseErrorVisible,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
              child: Text(
                'Please add at least 1 exercise',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addExercise,
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (validateRoutine()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating Workout')),
                  );
                  // print(routine.getSets(index));
                  // print(routine.toJson());
                  String workout = jsonEncode(routine.toJson());
                  print(workout);

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  bool result = await prefs.setString('workout', workout);
                  print(result);
                } else {
                  showInvalidDialog(context);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
