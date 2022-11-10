import 'package:flutter/material.dart';

const List<String> exerciseChoices = <String>[
  'Squat',
  'Bench Press',
  'Deadlift',
  'Overhead Press',
  'Barbell Row'
];

class Exercise {
  String _name = '';
  List<int> _sets = [];

  Exercise() {
    _name = exerciseChoices.first;
    _sets = [];
  }

  String getName() {
    return _name;
  }
}

class WorkoutRoutine {
  String _name = '';
  List<Exercise> _exercises = [];

  WorkoutRoutine() {
    _name = '';
    _exercises = [];
  }

  int addExercise() {
    _exercises.add(Exercise());
    return _exercises.length - 1;
  }

  List<Exercise> getExercises() {
    return _exercises;
  }

  void updateExerciseName(int index, String name) {
    _exercises[index]._name = name;
    // print(name);
  }

  void deleteExercise(int index) {
    _exercises.removeAt(index);
    // print(index);

    for (int i = 0; i < _exercises.length; i++) {
      print(_exercises[i].getName());
    }
  }
}

class ExerciseWidget extends StatefulWidget {
  final int index;
  final String name;
  final Function updateName;
  final Function delete;

  const ExerciseWidget({
    Key? key,
    required this.index,
    required this.updateName,
    required this.delete,
    required this.name,
  }) : super(key: key);

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ExerciseNameDropdown(
            index: widget.index,
            name: widget.name,
            updateName: widget.updateName,
          ),
        ),
        Expanded(
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              widget.delete(widget.index);
            },
          ),
        )
      ],
    );
  }
}

class ExerciseNameDropdown extends StatefulWidget {
  final int index;
  final String name;
  final Function updateName;

  const ExerciseNameDropdown({
    Key? key,
    required this.index,
    required this.updateName,
    required this.name,
  }) : super(key: key);

  @override
  State<ExerciseNameDropdown> createState() => _ExerciseNameDropdownState();
}

class _ExerciseNameDropdownState extends State<ExerciseNameDropdown> {
  // String dropdownValue = '';

  // @override
  // void initState() {
  //   // dropdownValue = widget.name;
  //   print('dropdown ' + dropdownValue);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // widget.updateName(widget.index, dropdownValue);

    return DropdownButton<String>(
      value: widget.name,
      icon: const Icon(Icons.arrow_downward),
      isExpanded: true,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.blue,
      ),
      onChanged: (String? value) {
        setState(() {
          // dropdownValue = value!;
          widget.updateName(widget.index, value);
        });
      },
      items: exerciseChoices.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
