import 'package:flutter/material.dart';
import 'dart:convert';

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
    _exercises = [Exercise()];
  }

  @override
  String toString() {
    return ('$_name: $_exercises,');
  }

  factory WorkoutRoutine.fromJson(Map<String, dynamic> parsedJson) {
    return WorkoutRoutine();
  }

  Map<String, dynamic> toJson() {
    return {"name": _name, "exercises": jsonEncode(_exercises)};
  }

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

  void setName(String name) {
    _name = name;
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

  void deleteSet(int exerciseIndex, int setIndex) {
    _exercises[exerciseIndex].deleteSet(setIndex);
  }

  List<Set> getSets(int index) {
    return _exercises[index]._sets;
  }

  // bool anyEmptySets() {
  //   for (int i = 0; i < _exercises.length; i++) {
  //     if (_exercises[i]._sets.isEmpty) {
  //       return true;
  //     }
  //   }

  //   return false;
  // }

  void setWeightSameFlag(int index, bool value) {
    _exercises[index].setWeightSameFlag(value);
  }

  void setRepsSameFlag(int index, bool value) {
    _exercises[index].setRepsSameFlag(value);
  }

  void setRestSameFlag(int index, bool value) {
    _exercises[index].setRestSameFlag(value);
  }

  void setWeight(int exerciseIndex, int setIndex, int weight) {
    _exercises[exerciseIndex].setWeight(setIndex, weight);
  }

  void setReps(int exerciseIndex, int setIndex, int reps) {
    _exercises[exerciseIndex].setReps(setIndex, reps);
  }

  void setRepsSame(int index, int reps) {
    _exercises[index].setRepsSame(reps);
  }

  void setRest(int exerciseIndex, int setIndex, int rest) {
    _exercises[exerciseIndex].setRest(setIndex, rest);
  }

  void setWeightSame(int index, int weight) {
    _exercises[index].setWeightSame(weight);
  }

  void setRestSame(int index, int rest) {
    _exercises[index].setRestSame(rest);
  }
}

class Exercise {
  String _name = '';
  List<Set> _sets = [];
  bool _sameWeight = false;
  bool _sameReps = false;
  bool _sameRest = false;

  Exercise() {
    _name = exerciseChoices.first;
    _sets = [Set()];
    _sameWeight = false;
    _sameReps = false;
    _sameRest = false;
  }

  @override
  String toString() {
    return '$_name: $_sets ';
  }

  Map<String, dynamic> toJson() {
    return {
      "name": _name,
      "sameWeight": _sameWeight,
      "sameReps": _sameReps,
      "sameRest": _sameRest,
      "sets": jsonEncode(_sets)
    };
  }

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

  String getName() {
    return _name;
  }

  // adds a set to the exercise. Does not initialize the set to any useful properties
  void addSet() {
    Set newSet = Set();

    if (getWeightSameFlag()) {
      newSet.setWeight(_sets[0].getWeight());
    }

    if (getRepsSameFlag()) {
      newSet.setReps(_sets[0].getReps());
    }

    if (getRestSameFlag()) {
      newSet.setRest(_sets[0].getRest());
    }

    _sets.add(newSet);
  }

  void deleteSet(int index) {
    _sets.removeAt(index);
  }

  bool getWeightSameFlag() {
    return _sameWeight;
  }

  bool getRepsSameFlag() {
    return _sameReps;
  }

  bool getRestSameFlag() {
    return _sameRest;
  }

  void setWeightSameFlag(bool value) {
    _sameWeight = value;
  }

  void setRepsSameFlag(bool value) {
    _sameReps = value;
  }

  void setRestSameFlag(bool value) {
    _sameRest = value;
  }

  void setWeight(int index, int weight) {
    _sets[index].setWeight(weight);
  }

  void setWeightSame(int weight) {
    for (int i = 0; i < _sets.length; i++) {
      _sets[i].setWeight(weight);
    }
  }

  void setReps(int index, int reps) {
    _sets[index].setReps(reps);
  }

  void setRepsSame(int reps) {
    for (int i = 0; i < _sets.length; i++) {
      _sets[i].setReps(reps);
    }
  }

  void setRest(int index, int rest) {
    _sets[index].setRest(rest);
  }

  void setRestSame(int rest) {
    for (int i = 0; i < _sets.length; i++) {
      _sets[i].setRest(rest);
    }
  }
}

class Set {
  int _weight = 0;

  // the number of reps. In practice should be greater than 0
  int _reps = 0;

  // the rest time in seconds. Should be greater than 0
  int _rest = 0;

  Set() {
    _reps = 0;
    _rest = 0;
    _weight = 0;
  }

  @override
  String toString() {
    return 'weight: $_weight, reps: $_reps, rest: $_rest ';
  }

  Map<String, dynamic> toJson() {
    return {"weight": _weight, "reps": _reps, "rest": _rest};
  }

  bool validateSet() {
    return _reps > 0 && _rest > 0 && _weight > 0;
  }

  // set the reps of this set. Should be non-negative
  void setReps(int reps) {
    assert(reps >= 0, 'The passed reps is not non-negative');
    _reps = reps;
  }

  int getReps() {
    return _reps;
  }

  // set the rest of this set in seconds. Should be non-negative
  void setRest(int rest) {
    assert(rest >= 0, 'The passed rest is not non-negative');
    _rest = rest;
  }

  int getRest() {
    return _rest;
  }

  void setWeight(int weight) {
    _weight = weight;
  }

  int getWeight() {
    return _weight;
  }
}

class ExerciseWidget extends StatefulWidget {
  final int index;
  final String name;
  final List<Set> sets;
  final bool onlyExercise;
  // final bool sameRepsFlag;
  // final bool sameRestFlag;
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
    // required this.sameRepsFlag,
    // required this.sameRestFlag,
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
    // isSetsRepsSame = widget.sameRepsFlag;
    // isSetsRestSame = widget.sameRestFlag;

    return Column(
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
                      widget.setWeightSame(
                          widget.index, widget.sets[0].getWeight());
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
                      widget.setRepsSame(
                          widget.index, widget.sets[0].getReps());
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
                      widget.setRestSame(
                          widget.index, widget.sets[0].getRest());
                    }
                  });
                },
              ),
              const Text('Same Rest'),
            ],
          ),
        ),
        Container(
          // Expanded(
          height: 195,
          // fit: FlexFit.loose,
          child: Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              // shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.sets.length,
              itemBuilder: (BuildContext context, int index) {
                // return Text('Set');
                return Container(
                  width: 100,
                  child: SetsWidget(
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
// print(value);
    if (_repsController.text.isEmpty) {
      // widget.setReps(widget.exerciseIndex, widget.setIndex, 0);
      // if (widget.isSameReps) {
      //   widget.setRepsSame(widget.exerciseIndex, widget.set.getReps());
      // }
      if (widget.set.getReps() > 0) {
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
          widget.setRepsSame(widget.exerciseIndex, widget.set.getReps());
        }
      }
    } catch (e) {
      _repsController.text = "";
      showInputDialog(context);
    }
  }

  void checkRestInput(BuildContext context) {
    if (_restController.text.isEmpty) {
      // widget.setRest(widget.exerciseIndex, widget.setIndex, 0);
      // if (widget.isSameRest) {
      //   widget.setRestSame(widget.exerciseIndex, widget.set.getRest());
      // }
      if (widget.set.getRest() > 0) {
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
          widget.setRestSame(widget.exerciseIndex, widget.set.getRest());
        }
      }
    } catch (e) {
      _restController.text = "";
      showInputDialog(context);
    }
  }

  void checkWeightInput(BuildContext context) {
    if (_weightController.text.isEmpty) {
      if (widget.set.getWeight() > 0) {
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
          widget.setWeightSame(widget.exerciseIndex, widget.set.getWeight());
        }
      }
    } catch (e) {
      _weightController.text = "";
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

  @override
  void initState() {
    super.initState();
    // _repsController.addListener(() {
    //   var reps = int.parse(_repsController.text);
    //   print(reps);
    // });
  }

  @override
  void dispose() {
    super.dispose();

    _repsController.dispose();
    _restController.dispose();
    _weightController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.set.getWeight() > 0) {
      _weightController.text = widget.set.getWeight().toString();
    }

    if (widget.set.getReps() > 0) {
      _repsController.text = widget.set.getReps().toString();
    }

    if (widget.set.getRest() > 0) {
      _restController.text = widget.set.getRest().toString();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
      child: Column(
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
