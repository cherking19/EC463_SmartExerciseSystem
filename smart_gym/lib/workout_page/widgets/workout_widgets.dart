import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../workout.dart';

class WorkoutForm extends StatefulWidget {
  final bool editable;
  final Workout workout;

  const WorkoutForm({
    Key? key,
    required this.editable,
    required this.workout,
  }) : super(key: key);

  @override
  WorkoutFormState createState() {
    return WorkoutFormState();
  }
}

class WorkoutFormState extends State<WorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final WorkoutWidgetController submitController = WorkoutWidgetController();
  // final TextEditingController _setsRepsController = TextEditingController();
  // bool _isExerciseErrorVisible = false;

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

  bool validateRoutine() {
    // print(routine.toString());
    return widget.workout.validateRoutine();
  }

  void getExercises(List<Exercise> exercises) {
    // print('getting');
    widget.workout.exercises = exercises;
    // print(widget.workout);
  }

  Future<void> submitWorkout(
      BuildContext context, VoidCallback onSuccess) async {
    // print(routine.getSets(index));
    // print(routine.toJson());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    String routinesJson = prefs.getString(routinesJsonKey) ?? "";
    Routines routines;
    if (routinesJson.isEmpty) {
      routines = Routines([]);
    } else {
      routines = Routines.fromJson(jsonDecode(routinesJson));
    }

    routines.addWorkout(widget.workout);
    routinesJson = jsonEncode(routines.toJson());

    // String workoutJson = jsonEncode(workout.toJson());
    // print(workoutJson);

    await prefs.setString(routinesJsonKey, routinesJson);
    // print(result);
    onSuccess.call();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.workout);
    nameController.text = widget.workout.name;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          WorkoutName(
            formKey: _formKey,
            nameController: nameController,
            editable: widget.editable,
          ),
          Expanded(
            child: ExercisesWidget(
              submitController: submitController,
              sendExercisesCallback: getExercises,
              editable: widget.editable,
              exercises: widget.workout.exercises,
            ),
          ),
          if (widget.editable)
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.workout.name = nameController.text;
                  submitController.passDataToParent();
                  if (validateRoutine()) {
                    submitWorkout(context, () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Creating Workout')),
                      );
                      Navigator.pop(context);
                    });
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

class WorkoutWidgetController {
  late void Function() passDataToParent;
}

class WorkoutName extends StatelessWidget {
  final GlobalKey formKey;
  final TextEditingController nameController;
  final bool editable;

  const WorkoutName({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.editable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        controller: nameController,
        enabled: editable,
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
  final WorkoutWidgetController submitController;
  final void Function(List<Exercise>) sendExercisesCallback;
  final bool editable;
  final List<Exercise> exercises;

  const ExercisesWidget({
    Key? key,
    required this.submitController,
    required this.sendExercisesCallback,
    required this.editable,
    required this.exercises,
  }) : super(key: key);

  @override
  _ExercisesWidgetState createState() {
    return _ExercisesWidgetState(submitController);
  }
}

class _ExercisesWidgetState extends State<ExercisesWidget> {
  _ExercisesWidgetState(WorkoutWidgetController submitController) {
    submitController.passDataToParent = submitExercises;
  }

  void addExercise() {
    widget.exercises.add(
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
    setState(() {});
  }

  void updateExerciseName(int index, String name) {
    setState(() {
      widget.exercises[index].name = name;
    });
  }

  void deleteExercise(int index) {
    setState(() {
      widget.exercises.removeAt(index);
    });
  }

  void addSet(int index) {
    setState(() {
      widget.exercises[index].addSet();
    });
  }

  void setWeightSameFlag(int index, bool value) {
    setState(() {
      widget.exercises[index].sameWeight = value;
    });
  }

  void setRepsSameFlag(int index, bool value) {
    setState(() {
      widget.exercises[index].sameReps = value;
    });
  }

  void setRestSameFlag(int index, bool value) {
    setState(() {
      widget.exercises[index].sameRest = value;
    });
  }

  void setWeight(int exerciseIndex, int setIndex, int weight) {
    setState(() {
      widget.exercises[exerciseIndex].setWeight(setIndex, weight);
    });
  }

  void setReps(int exerciseIndex, int setIndex, int reps) {
    setState(() {
      widget.exercises[exerciseIndex].setReps(setIndex, reps);
    });
  }

  void setRepsSame(int index, int reps) {
    setState(() {
      widget.exercises[index].setRepsSame(reps);
    });
  }

  void setRest(int exerciseIndex, int setIndex, int rest) {
    setState(() {
      widget.exercises[exerciseIndex].setRest(setIndex, rest);
    });
  }

  void setWeightSame(int index, int weight) {
    setState(() {
      widget.exercises[index].setWeightSame(weight);
    });
  }

  void setRestSame(int index, int rest) {
    setState(() {
      widget.exercises[index].setRestSame(rest);
    });
  }

  void deleteSet(int exerciseIndex, int setIndex) {
    setState(() {
      widget.exercises[exerciseIndex].deleteSet(setIndex);
    });
  }

  void submitExercises() {
    // print('submitting');
    widget.sendExercisesCallback(widget.exercises);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: widget.exercises.length,
              itemBuilder: (BuildContext context, int index) {
                return ExerciseWidget(
                  editable: widget.editable,
                  index: index,
                  name: widget.exercises[index].name,
                  sets: widget.exercises[index].sets,
                  onlyExercise: widget.exercises.length == 1,
                  sameWeightFlag: widget.exercises[index].sameWeight,
                  sameRepsFlag: widget.exercises[index].sameReps,
                  sameRestFlag: widget.exercises[index].sameRest,
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
        if (widget.editable)
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
                child: Text('Add Exercise'),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: addExercise,
              ),
            ],
          )
      ],
    );
  }
}

class ExerciseWidget extends StatefulWidget {
  final bool editable;
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
    required this.editable,
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
                  readOnly: !widget.editable,
                  index: widget.index,
                  name: widget.name,
                  updateName: widget.updateName,
                ),
              ),
            ),
            if (!widget.onlyExercise && widget.editable)
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
        if (widget.editable)
          Column(
            children: [
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
                                widget.index, widget.sets[0].weight);
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
                                widget.index, widget.sets[0].reps);
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
                                widget.index, widget.sets[0].rest);
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
            ],
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
                      editable: widget.editable,
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
      ],
    );
    // );
  }
}

class ExerciseNameDropdown extends StatefulWidget {
  final bool readOnly;
  final int index;
  final String name;
  final Function updateName;

  const ExerciseNameDropdown({
    Key? key,
    required this.readOnly,
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
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   setInitialName();
    // });
  }

  @override
  Widget build(BuildContext context) {
    // widget.updateName(widget.index, exerciseChoices.first);

    return DropdownButton<String>(
      value: widget.name,
      disabledHint: Text(widget.name),
      icon: const Icon(Icons.arrow_downward),
      isExpanded: true,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.blue,
      ),
      onChanged: widget.readOnly
          ? null
          : (String? value) {
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
  final bool editable;
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
    required this.editable,
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
                  enabled: widget.editable,
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
                  enabled: widget.editable,
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
                  enabled: widget.editable,
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
          if (!widget.onlySet && widget.editable)
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
