import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/view_workout/view_workout.dart';
import 'package:smart_gym/reusable_widgets/input_validation.dart';
import '../workout.dart';

class WorkoutForm extends StatefulWidget {
  final bool editable;
  final bool viewing;
  final Workout workout;
  final void Function(
    BuildContext context,
    Workout workout,
    VoidCallback onFailure,
  ) saveWorkout;
  final SubmitController? submitController;

  const WorkoutForm({
    Key? key,
    required this.editable,
    required this.viewing,
    required this.workout,
    required this.saveWorkout,
    this.submitController,
  }) : super(key: key);

  @override
  WorkoutFormState createState() {
    return WorkoutFormState();
  }
}

class WorkoutFormState extends State<WorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  bool saving = false;

  // WorkoutFormState(SubmitController? submitController) {}

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
    return widget.workout.validateRoutine();
  }

  void getName(String name) {
    widget.workout.name = name;
  }

  void getExercises(List<Exercise> exercises) {
    widget.workout.exercises = exercises;
  }

  void saveWorkout() {
    if (_formKey.currentState!.validate() & validateRoutine()) {
      setState(() {
        saving = true;
      });
      widget.saveWorkout(
        context,
        widget.workout,
        onCreateFailure,
      );
    } else {
      showInvalidDialog(context);
    }
  }

  void onCreateFailure() {
    setState(() {
      saving = false;
    });
  }

  @override
  void initState() {
    widget.submitController?.saveWorkout = saveWorkout;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
              child: WorkoutName(
                formKey: _formKey,
                editable: widget.editable,
                workout: widget.workout,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: ExercisesWidget(
                  editable: widget.editable,
                  workout: widget.workout,
                ),
              ),
            ),
            if (widget.editable && !widget.viewing && !saving)
              TextButton(
                onPressed: () {
                  saveWorkout();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: const Text('Create'),
              ),
            if (!widget.viewing && saving)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(
                    value: null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WorkoutWidgetController {
  late void Function() passDataToParent;
}

class WorkoutName extends StatelessWidget {
  final GlobalKey formKey;
  final TextEditingController nameController = TextEditingController();
  final bool editable;
  final Workout workout;

  WorkoutName({
    Key? key,
    required this.formKey,
    required this.editable,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    nameController.text = workout.name;
    return TextFormField(
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
      onChanged: (value) {
        workout.name = value;
      },
    );
  }
}

class ExercisesWidget extends StatefulWidget {
  final bool editable;
  final Workout workout;

  const ExercisesWidget({
    Key? key,
    required this.editable,
    required this.workout,
  }) : super(key: key);

  @override
  State<ExercisesWidget> createState() {
    return _ExercisesWidgetState();
  }
}

class _ExercisesWidgetState extends State<ExercisesWidget> {
  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
              itemCount: widget.workout.exercises.length,
              itemBuilder: (BuildContext context, int index) {
                return ExerciseWidget(
                  editable: widget.editable,
                  index: index,
                  workout: widget.workout,
                  updateParent: update,
                );
              },
            ),
          ),
        ),
        if (widget.editable)
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 6.0),
                child: Text('Add Exercise'),
              ),
              SizedBox(
                height: 24.0,
                width: 24.0,
                child: IconButton(
                  icon: const Icon(Icons.add),
                  padding: const EdgeInsets.all(0.0),
                  iconSize: 24.0,
                  splashRadius: 24.0,
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    widget.workout.addExercise();
                    setState(() {});
                  },
                ),
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
  final Workout workout;
  final Function updateParent;

  const ExerciseWidget({
    Key? key,
    required this.editable,
    required this.index,
    required this.workout,
    required this.updateParent,
  }) : super(key: key);

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  bool onlyExercise = false;

  @override
  Widget build(BuildContext context) {
    onlyExercise = widget.workout.exercises.length == 1;
    EdgeInsets dropdownPadding = onlyExercise
        ? const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0)
        : const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0);

    // if (onlyExercise) {
    dropdownPadding = const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0);
    // }

    if (widget.editable) {
      dropdownPadding = onlyExercise
          ? const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0)
          : const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0);
    } else {
      dropdownPadding = const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0);
    }

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
                  exercise: widget.workout.exercises[widget.index],
                ),
              ),
            ),
            if (!onlyExercise && widget.editable)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.workout.deleteExercise(widget.index);
                  widget.updateParent();
                },
              ),
          ],
        ),
        SetsWidget(
          exercise: widget.workout.exercises[widget.index],
          editable: widget.editable,
        ),
      ],
    );
    // );
  }
}

class ExerciseNameDropdown extends StatefulWidget {
  final bool readOnly;
  final Exercise exercise;

  const ExerciseNameDropdown({
    Key? key,
    required this.readOnly,
    required this.exercise,
  }) : super(key: key);

  @override
  State<ExerciseNameDropdown> createState() => _ExerciseNameDropdownState();
}

class _ExerciseNameDropdownState extends State<ExerciseNameDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.exercise.name,
      disabledHint: Text(widget.exercise.name),
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
                widget.exercise.name = value!;
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
  final Exercise exercise;
  final bool editable;

  const SetsWidget({
    Key? key,
    required this.exercise,
    required this.editable,
  }) : super(key: key);

  @override
  State<SetsWidget> createState() => _SetsWidgetState();
}

class _SetsWidgetState extends State<SetsWidget> {
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _restController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  void update() {
    setState(() {});
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
    EdgeInsets setWidgetItemPadding =
        const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0);

    List<Widget> sets = List<Widget>.generate(
      widget.exercise.sets.length,
      (index) => Padding(
        padding: setWidgetItemPadding,
        child: SetWidget(
          editable: widget.editable,
          exercise: widget.exercise,
          index: index,
          updateParent: update,
        ),
      ),
    );
    if (widget.editable) {
      sets.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 6.0),
                child: Text('Add Set'),
              ),
              SizedBox(
                height: 24.0,
                width: 24.0,
                child: IconButton(
                  icon: const Icon(Icons.add),
                  padding: const EdgeInsets.all(0.0),
                  iconSize: 24.0,
                  splashRadius: 24.0,
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      widget.exercise.addSet();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (widget.editable)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Checkbox(
                        value: widget.exercise.sameWeight,
                        onChanged: (bool? value) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            widget.exercise.sameWeight = value!;
                          });
                        },
                      ),
                    ),
                    const Expanded(
                      child: Text('Same Weight'),
                    ),
                    Expanded(
                      child: Checkbox(
                        value: widget.exercise.sameReps,
                        onChanged: (bool? value) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            widget.exercise.sameReps = value!;
                          });
                        },
                      ),
                    ),
                    const Expanded(
                      child: Text('Same Reps'),
                    ),
                    Expanded(
                      child: Checkbox(
                        value: widget.exercise.sameRest,
                        onChanged: (bool? value) {
                          setState(() {
                            FocusManager.instance.primaryFocus?.unfocus();
                            widget.exercise.sameRest = value!;
                          });
                        },
                      ),
                    ),
                    const Expanded(
                      child: Text('Same Rest'),
                    ),
                  ],
                ),
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
                child: Row(
                  children: sets,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SetWidget extends StatefulWidget {
  final bool editable;
  final Exercise exercise;
  final int index;
  final Function updateParent;

  const SetWidget({
    Key? key,
    required this.editable,
    required this.exercise,
    required this.index,
    required this.updateParent,
  }) : super(key: key);

  @override
  State<SetWidget> createState() => _SetWidgetState();
}

class _SetWidgetState extends State<SetWidget> {
  // double deleteSize = 100;

  final TextEditingController repsController = TextEditingController();
  final TextEditingController restController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  bool onlySet = false;

  void checkRepsInput(BuildContext context) {
    int reps = 0;

    if (repsController.text.isNotEmpty) {
      reps = int.parse(repsController.text);
    }

    widget.exercise.setReps(widget.index, reps);

    if (widget.exercise.sameReps) {
      widget.updateParent();
    }
  }

  void checkRestInput(BuildContext context) {
    int rest = 0;

    if (restController.text.isNotEmpty) {
      rest = int.parse(restController.text);
    }

    widget.exercise.setRest(widget.index, rest);

    if (widget.exercise.sameRest) {
      widget.updateParent();
    }
  }

  void checkWeightInput(BuildContext context) {
    int weight = 0;

    if (weightController.text.isNotEmpty) {
      weight = int.parse(weightController.text);
    }

    widget.exercise.setWeight(widget.index, weight);

    if (widget.exercise.sameWeight) {
      widget.updateParent();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exercise.sets[widget.index].weight > 0) {
      weightController.text =
          widget.exercise.sets[widget.index].weight.toString();
    } else {
      weightController.text = '';
    }

    if (widget.exercise.sets[widget.index].reps > 0) {
      repsController.text = widget.exercise.sets[widget.index].reps.toString();
    } else {
      repsController.text = '';
    }

    if (widget.exercise.sets[widget.index].rest > 0) {
      restController.text = widget.exercise.sets[widget.index].rest.toString();
    } else {
      restController.text = '';
    }

    weightController.selection = TextSelection.collapsed(
      offset: weightController.text.length,
    );
    repsController.selection = TextSelection.collapsed(
      offset: repsController.text.length,
    );
    restController.selection = TextSelection.collapsed(
      offset: restController.text.length,
    );

    onlySet = widget.exercise.sets.length == 1;

    // print(!onlySet && widget.editable);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Set ${widget.index + 1}',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                if (!onlySet && widget.editable)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 0.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 16.0,
                        width: 16.0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          padding: const EdgeInsets.all(0.0),
                          iconSize: 16.0,
                          splashRadius: 16.0,
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            widget.exercise.deleteSet(widget.index);
                            widget.updateParent();
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                enabled: widget.editable,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Weight (lb)',
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                ),
                controller: weightController,
                keyboardType: TextInputType.number,
                inputFormatters: positiveInteger,
                onChanged: (value) {
                  checkWeightInput(context);
                },
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                enabled: widget.editable,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Reps',
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                ),
                controller: repsController,
                keyboardType: TextInputType.number,
                inputFormatters: positiveInteger,
                onChanged: (value) {
                  checkRepsInput(context);
                },
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                enabled: widget.editable,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Rest (s)',
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                ),
                controller: restController,
                keyboardType: TextInputType.number,
                inputFormatters: positiveInteger,
                onChanged: (value) {
                  checkRestInput(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
