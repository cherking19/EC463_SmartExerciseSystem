import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../workout.dart';

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

  Workout workout = Workout('', [
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
    workout.addExercise();
    setState(() {
      _isExerciseErrorVisible = false;
    });
  }

  bool validateRoutine() {
    // print(routine.toString());
    return workout.validateRoutine();
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
      workout.updateExerciseName(index, name);
    });
  }

  void deleteExercise(int index) {
    setState(() {
      workout.deleteExercise(index);
    });
  }

  void addSet(int index) {
    setState(() {
      workout.addSet(index);
    });
  }

  void setWeightSameFlag(int index, bool value) {
    setState(() {
      workout.setWeightSameFlag(index, value);
    });
  }

  void setRepsSameFlag(int index, bool value) {
    setState(() {
      workout.setRepsSameFlag(index, value);
    });
  }

  void setRestSameFlag(int index, bool value) {
    setState(() {
      workout.setRestSameFlag(index, value);
    });
  }

  void setWeight(int exerciseIndex, int setIndex, int weight) {
    setState(() {
      workout.setWeight(exerciseIndex, setIndex, weight);
    });
  }

  void setReps(int exerciseIndex, int setIndex, int reps) {
    setState(() {
      workout.setReps(exerciseIndex, setIndex, reps);
    });
  }

  void setRepsSame(int index, int reps) {
    setState(() {
      workout.setRepsSame(index, reps);
    });
  }

  void setRest(int exerciseIndex, int setIndex, int rest) {
    setState(() {
      workout.setRest(exerciseIndex, setIndex, rest);
    });
  }

  void setWeightSame(int index, int weight) {
    setState(() {
      workout.setWeightSame(index, weight);
    });
  }

  void setRestSame(int index, int rest) {
    setState(() {
      workout.setRestSame(index, rest);
    });
  }

  void deleteSet(int exerciseIndex, int setIndex) {
    setState(() {
      workout.deleteSet(exerciseIndex, setIndex);
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _setsRepsController.addListener(() {

  //   })
  // }

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

    routines.addWorkout(workout);
    routinesJson = jsonEncode(routines.toJson());

    // String workoutJson = jsonEncode(workout.toJson());
    // print(workoutJson);

    await prefs.setString(routinesJsonKey, routinesJson);
    // print(result);
    onSuccess.call();
  }

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
                workout.setName(value);
              },
            ),
          ),
          Flexible(
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
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
          padding: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
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
