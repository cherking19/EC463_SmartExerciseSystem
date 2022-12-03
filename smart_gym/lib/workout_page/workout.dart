import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void updateExerciseName(int index, String name) {
    _exercises[index]._name = name;
    // print(name);
  }

  // adds a set to the exercise at the specified index. Does not initialize the set to any useful properties
  void addSet(int index) {
    // assert(index > 0 && index < _exercises.length > )
    _exercises[index].addSet();
  }

  void deleteSet(int exerciseIndex, int setIndex) {
    _exercises[exerciseIndex].deleteSet(setIndex);
  }

  List<Set> getSets(int index) {
    return _exercises[index]._sets;
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
      print('same weight');
      for (Set set in sets) {
        set.weight = weight;
      }
    } else {
      sets[index].weight = weight;
    }
  }

  // void setWeightSame(int weight) {
  //   for (int i = 0; i < _sets.length; i++) {
  //     _sets[i].weight = weight;
  //   }
  // }

  void setReps(int index, int reps) {
    if (sameReps) {
      for (Set set in sets) {
        set.reps = reps;
      }
    } else {
      sets[index].reps = reps;
    }
  }

  void setRepsSame(int reps) {
    for (int i = 0; i < _sets.length; i++) {
      _sets[i].reps = reps;
    }
  }

  void setRest(int index, int rest) {
    _sets[index].rest = rest;
  }

  void setRestSame(int rest) {
    for (int i = 0; i < _sets.length; i++) {
      _sets[i].rest = rest;
    }
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
}

class ExerciseWidget extends StatefulWidget {
  final int index;
  final String name;
  final List<Set> sets;
  final bool onlyExercise;
  final bool sameWeightFlag;
  final bool sameRepsFlag;
  final bool sameRestFlag;
  final Function updateName;
  final Function delete;
  final Function addSet;
  final Function setWeight;
  final Function setReps;
  final Function setRest;
  final Function setWeightSameFlag;
  final Function setRepsSameFlag;
  final Function setRestSameFlag;
  final Function setWeightSame;
  final Function setRepsSame;
  final Function setRestSame;
  final Function deleteSet;

  const ExerciseWidget({
    Key? key,
    required this.index,
    required this.name,
    required this.sets,
    required this.onlyExercise,
    required this.sameWeightFlag,
    required this.sameRepsFlag,
    required this.sameRestFlag,
    required this.updateName,
    required this.delete,
    required this.addSet,
    required this.setWeight,
    required this.setReps,
    required this.setRest,
    required this.setWeightSameFlag,
    required this.setRepsSameFlag,
    required this.setRestSameFlag,
    required this.setWeightSame,
    required this.setRepsSame,
    required this.setRestSame,
    required this.deleteSet,
  }) : super(key: key);

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  // bool _isExerciseSetsErrorVisible = false;
  // List<int> sets = [];
  bool isSetsWeightSame = false;
  bool isSetsRepsSame = false;
  bool isSetsRestSame = false;

  // void addRep(int index) {}

  @override
  Widget build(BuildContext context) {
    EdgeInsets dropdownPadding = widget.onlyExercise
        ? const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0)
        : const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0);
    isSetsWeightSame = widget.sameWeightFlag;
    isSetsRepsSame = widget.sameRepsFlag;
    isSetsRestSame = widget.sameRestFlag;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
              child: Text('${widget.index + 1}'),
            ),
            Expanded(
              child: Padding(
                padding: dropdownPadding,
                child: ExerciseNameDropdown(
                  index: widget.index,
                  name: widget.name,
                  updateName: widget.updateName,
                ),
              ),
            ),
            if (!widget.onlyExercise)
              IconButton(
                icon: const Icon(Icons.close),
                // padding: EdgeInsets.all(0.0),
                // iconSize: 16.0,
                onPressed: () {
                  widget.delete(widget.index);
                },
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: Row(
            children: [
              Checkbox(
                // checkColor: Color,
                value: isSetsWeightSame,
                onChanged: (bool? value) {
                  setState(() {
                    isSetsWeightSame = value!;
                    widget.setWeightSameFlag(widget.index, value);
                    if (isSetsWeightSame) {
                      widget.setWeightSame(widget.index, widget.sets[0].weight);
                    }
                  });
                },
              ),
              const Text('Same Weight'),
              Checkbox(
                // checkColor: Colors.white,
                value: isSetsRepsSame,
                onChanged: (bool? value) {
                  setState(() {
                    isSetsRepsSame = value!;
                    widget.setRepsSameFlag(widget.index, value);
                    if (isSetsRepsSame) {
                      widget.setRepsSame(widget.index, widget.sets[0].reps);
                    }
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
                    widget.setRestSameFlag(widget.index, value);
                    if (isSetsRestSame) {
                      widget.setRestSame(widget.index, widget.sets[0].rest);
                    }
                  });
                },
              ),
              const Text('Same Rest'),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
          child: Text('Add Set'),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            widget.addSet(widget.index);
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // reverse: true,
                child: Row(
                  children: List.generate(
                    widget.sets.length,
                    (index) => SetsWidget(
                      exerciseIndex: widget.index,
                      setIndex: index,
                      isSameWeight: isSetsWeightSame,
                      isSameReps: isSetsRepsSame,
                      isSameRest: isSetsRestSame,
                      set: widget.sets[index],
                      onlySet: widget.sets.length == 1,
                      setWeight: widget.setWeight,
                      setReps: widget.setReps,
                      setRest: widget.setRest,
                      setWeightSame: widget.setWeightSame,
                      setRepsSame: widget.setRepsSame,
                      setRestSame: widget.setRestSame,
                      delete: widget.deleteSet,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Visibility(
        //   visible: _isExerciseSetsErrorVisible,
        //   child: const Padding(
        //     padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
        //     child: Text(
        //       'Please add at least 1 set',
        //       style: TextStyle(color: Colors.red),
        //     ),
        //   ),
        // ),
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

  void setInitialName() {
    widget.updateName(widget.index, exerciseChoices.first);
  }

  @override
  void initState() {
    // dropdownValue = widget.name;
    // print('dropdown ' + dropdownValue);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setInitialName();
    });
  }

  @override
  Widget build(BuildContext context) {
    // widget.updateName(widget.index, exerciseChoices.first);

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
  final int exerciseIndex;
  final int setIndex;
  final bool isSameWeight;
  final bool isSameReps;
  final bool isSameRest;
  final Set set;
  final bool onlySet;
  final Function setWeight;
  final Function setReps;
  final Function setRest;
  final Function setWeightSame;
  final Function setRepsSame;
  final Function setRestSame;
  final Function delete;

  const SetsWidget({
    Key? key,
    required this.exerciseIndex,
    required this.setIndex,
    required this.isSameWeight,
    required this.isSameReps,
    required this.isSameRest,
    required this.set,
    required this.onlySet,
    required this.setWeight,
    required this.setReps,
    required this.setRest,
    required this.setWeightSame,
    required this.setRepsSame,
    required this.setRestSame,
    required this.delete,
  }) : super(key: key);

  @override
  State<SetsWidget> createState() => _SetsWidgetState();
}

class _SetsWidgetState extends State<SetsWidget> {
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _restController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  void checkRepsInput(BuildContext context) {
    if (_repsController.text.isEmpty) {
      if (widget.set.reps > 0) {
        setState(() {});
        showInputDialog(context);
      }

      return;
    }

    try {
      var reps = int.parse(_repsController.text);
      if (reps < 1) {
        _repsController.text = "";
        showInputDialog(context);
      } else {
        widget.setReps(widget.exerciseIndex, widget.setIndex, reps);
        if (widget.isSameReps) {
          widget.setRepsSame(widget.exerciseIndex, widget.set.reps);
        }
      }
    } catch (e) {
      if (widget.set.reps > 0) {
        _repsController.text = widget.set.reps.toString();
      } else {
        _repsController.text = "";
      }
      showInputDialog(context);
    }
  }

  void checkRestInput(BuildContext context) {
    if (_restController.text.isEmpty) {
      if (widget.set.rest > 0) {
        setState(() {});
        showInputDialog(context);
      }

      return;
    }

    try {
      var rest = int.parse(_restController.text);
      if (rest < 1) {
        _restController.text = "";
        showInputDialog(context);
      } else {
        widget.setRest(widget.exerciseIndex, widget.setIndex, rest);
        if (widget.isSameRest) {
          widget.setRestSame(widget.exerciseIndex, widget.set.rest);
        }
      }
    } catch (e) {
      if (widget.set.rest > 0) {
        _restController.text = widget.set.rest.toString();
      } else {
        _restController.text = "";
      }

      showInputDialog(context);
    }
  }

  void checkWeightInput(BuildContext context) {
    if (_weightController.text.isEmpty) {
      if (widget.set.weight > 0) {
        setState(() {});
        showInputDialog(context);
      }

      return;
    }

    try {
      var weight = int.parse(_weightController.text);
      if (weight < 1) {
        _weightController.text = "";
        showInputDialog(context);
      } else {
        widget.setWeight(widget.exerciseIndex, widget.setIndex, weight);
        if (widget.isSameWeight) {
          widget.setWeightSame(widget.exerciseIndex, widget.set.weight);
        }
      }
    } catch (e) {
      if (widget.set.weight > 0) {
        _weightController.text = widget.set.weight.toString();
      } else {
        _weightController.text = "";
      }
      showInputDialog(context);
    }
  }

  void showInputDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Input Error'),
        content: const Text('Please enter an integer greater than 0'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // _repsController.addListener(() {
  //   //   var reps = int.parse(_repsController.text);
  //   //   print(reps);
  //   // });
  // }

  @override
  void dispose() {
    super.dispose();

    _repsController.dispose();
    _restController.dispose();
    _weightController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.set.weight > 0) {
      _weightController.text = widget.set.weight.toString();
    } else {
      _weightController.text = '';
    }

    if (widget.set.reps > 0) {
      _repsController.text = widget.set.reps.toString();
    } else {
      _repsController.text = '';
    }

    if (widget.set.rest > 0) {
      _restController.text = widget.set.rest.toString();
    } else {
      _restController.text = '';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 6.0),
            child: Text('Set ${widget.setIndex + 1}'),
          ),
          SizedBox(
            width: 90,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Focus(
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Weight (lb)',
                    isDense: true,
                    contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  ),
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    checkWeightInput(context);
                  }
                },
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Focus(
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Reps',
                    isDense: true,
                    contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  ),
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    checkRepsInput(context);
                  }
                },
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Focus(
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Rest (s)',
                    isDense: true,
                    contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  ),
                  controller: _restController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    checkRestInput(context);
                  }
                },
              ),
            ),
          ),
          if (!widget.onlySet)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                widget.delete(widget.exerciseIndex, widget.setIndex);
              },
            ),
        ],
      ),
    );
  }
}
