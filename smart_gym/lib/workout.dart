import 'package:flutter/material.dart';

const List<String> exerciseChoices = <String>[
  'Squat',
  'Bench Press',
  'Deadlift',
  'Overhead Press',
  'Barbell Row'
];

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

    // for (int i = 0; i < _exercises.length; i++) {
    //   print(_exercises[i].getName());
    // }
  }

  // adds a set to the exercise at the specified index. Does not initialize the set to any useful properties
  void addSet(int index) {
    // assert(index > 0 && index < _exercises.length > )
    _exercises[index].addSet();
  }

  List<Set> getSets(int index) {
    return _exercises[index]._sets;
  }
}

class Exercise {
  String _name = '';
  List<Set> _sets = [];

  Exercise() {
    _name = exerciseChoices.first;
    _sets = [];
  }

  String getName() {
    return _name;
  }

  // adds a set to the exercise. Does not initialize the set to any useful properties
  void addSet() {
    _sets.add(Set());
  }
}

class Set {
  // the number of reps. In practice should be greater than 0
  int _reps = 0;

  // the rest time in seconds. Should be greater than 0
  int _rest = 0;

  Set() {
    _reps = 0;
    _rest = 0;
  }

  // set the reps of this set. Should be greater than 0
  void setReps(int reps) {
    assert(reps > 0, 'The passed reps is not greater than 0');
    _reps = reps;
  }

  // set the rest of this set in seconds. Should be greater than 0
  void setRest(int rest) {
    assert(rest > 0, 'The passed rest is not greater than 0');
    _rest = rest;
  }
}

class ExerciseWidget extends StatefulWidget {
  final int index;
  final String name;
  final List<Set> sets;
  final Function updateName;
  final Function delete;
  final Function addSet;
  final GlobalKey<FormState> formKey;

  const ExerciseWidget({
    Key? key,
    required this.index,
    required this.name,
    required this.sets,
    required this.formKey,
    required this.updateName,
    required this.delete,
    required this.addSet,
  }) : super(key: key);

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  bool _isExerciseSetsErrorVisible = false;
  // List<int> sets = [];
  bool isSetsRepsSame = false;
  bool isSetsRestSame = false;

  @override
  Widget build(BuildContext context) {
    return
        // Form(
        //   key: widget.formKey,
        //   child:
        Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                child: ExerciseNameDropdown(
                  index: widget.index,
                  name: widget.name,
                  updateName: widget.updateName,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                widget.delete(widget.index);
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
          child: Row(
            children: [
              Checkbox(
                // checkColor: Colors.white,
                value: isSetsRepsSame,
                onChanged: (bool? value) {
                  setState(() {
                    isSetsRepsSame = value!;
                  });
                },
              ),
              const Text('Same Reps'),
              Checkbox(
                // checkColor: Color,
                value: isSetsRestSame,
                onChanged: (bool? value) {
                  setState(() {
                    isSetsRestSame = value!;
                  });
                },
              ),
              const Text('Same Rest Time'),
            ],
          ),
        ),
        Container(
          // Flexible(
          height: 65,
          // fit: FlexFit.loose,
          child: Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              // shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.sets.length,
              itemBuilder: (BuildContext context, int index) {
                // return Text('Set');
                return SetsWidget(
                  index: index,
                  isSameReps: isSetsRepsSame,
                  isSameRest: isSetsRestSame,
                );
                // TextFormField(validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter a rep number';
                //   }
                //   return null;
                // });
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
          child: Text('Add Set'),
        ),
        Visibility(
          visible: _isExerciseSetsErrorVisible,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
            child: Text(
              'Please add at least 1 set',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            widget.addSet(widget.index);
          },
        ),
      ],
    );
    // );
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

class SetsWidget extends StatefulWidget {
  final int index;
  final bool isSameReps;
  final bool isSameRest;

  const SetsWidget({
    Key? key,
    required this.index,
    required this.isSameReps,
    required this.isSameRest,
  }) : super(key: key);

  @override
  State<SetsWidget> createState() => _SetsWidgetState();
}

class _SetsWidgetState extends State<SetsWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set ${widget.index + 1}'),
          Row(
            children: [
              Text('Reps'),
            ],
          ),
          Row(
            children: [
              Text('Rest'),
            ],
          ),
          // Text('Rest'),
        ],
      ),
    );
  }
}
