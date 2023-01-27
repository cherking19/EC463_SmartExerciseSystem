import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smart_gym/pages/workout_page/widgets/create_workout_widgets.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/input.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/snackbars.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import '../workout.dart';

class CreateRoutineRoute extends StatelessWidget {
  const CreateRoutineRoute({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showConfirmationDialog(
          context,
          confirmCancelDialogTitle,
          confirmCancelDialogMessage,
        );
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Create Workout'),
          ),
          body: const Padding(
            padding: EdgeInsets.all(12.0),
            child: CreateRoutine(),
          ),
        ),
      ),
    );
  }
}

class CreateRoutine extends StatefulWidget {
  const CreateRoutine({
    Key? key,
  }) : super(key: key);

  @override
  CreateRoutineState createState() => CreateRoutineState();
}

class CreateRoutineState extends State<CreateRoutine> {
  final formKey = GlobalKey<FormState>();

  Workout workout = Workout(
    '',
    [
      Exercise(
        defaultExercises.first,
        [
          Set(
            0,
            0,
            defaultRestDuration,
            null,
          )
        ],
        false,
        false,
        false,
      ),
    ],
  );

  Future<void> submitWorkout(
    BuildContext context,
    Workout workout,
    VoidCallback onFailure,
  ) async {
    Future.delayed(
      globalPseudoDelay,
      () async {
        if (await saveRoutine(workout)) {
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(createFailedSnackBar(context));
          onFailure.call();
        }
      },
    );
  }

  void tryCreate() {
    if (formKey.currentState!.validate()) {
      // print('saving');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          WorkoutName(
            workout: workout,
          ),
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                itemCount: workout.exercises.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: CreateRoutineExercise(
                      workout: workout,
                      index: index,
                      deleteExercise: () {
                        setState(() {
                          workout.deleteExercise(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    workout.addExercise();
                  });
                },
                icon: const Icon(Icons.add),
              ),
              TextButton(
                onPressed: () {
                  tryCreate();
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreateRoutineExercise extends StatefulWidget {
  // final Exercise exercise;
  final Workout workout;
  final int index;
  final Function deleteExercise;

  const CreateRoutineExercise({
    Key? key,
    // required this.exercise,
    required this.workout,
    required this.index,
    required this.deleteExercise,
  }) : super(key: key);

  @override
  CreateRoutineExerciseState createState() => CreateRoutineExerciseState();
}

class CreateRoutineExerciseState extends State<CreateRoutineExercise> {
  ScrollController scrollController = ScrollController();

  Exercise getExercise() {
    return widget.workout.exercises[widget.index];
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets setWidgetPadding = EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 8.0);

    List<Widget> setWidgets = List.generate(
      getExercise().sets.length,
      (index) => CreateRoutineSet(),
    );

    setWidgets.add(
      Padding(
        padding: EdgeInsets.zero, //setWidgetPadding,
        child: Align(
          alignment: Alignment.topCenter,
          child: TextButton(
            onPressed: () {
              setState(() {
                getExercise().addSet();
              });
              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                scrollController
                    .jumpTo(scrollController.position.maxScrollExtent);
              });
            },
            style: setButtonStyle(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    return Container(
      decoration: globalBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ExerciseNameDropdown(
                    readOnly: false,
                    exercise: getExercise(),
                  ),
                ),
                if (widget.workout.exercises.length > 1)
                  IconButton(
                    onPressed: () {
                      widget.deleteExercise();
                    },
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Checkbox(
                    value: getExercise().sameWeight,
                    onChanged: (bool? value) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        getExercise().sameWeight = value!;
                      });
                    },
                  ),
                ),
                const Expanded(
                  child: Text('Same Weight'),
                ),
                Expanded(
                  child: Checkbox(
                    value: getExercise().sameReps,
                    onChanged: (bool? value) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        getExercise().sameReps = value!;
                      });
                    },
                  ),
                ),
                const Expanded(
                  child: Text('Same Reps'),
                ),
                Expanded(
                  child: Checkbox(
                    value: getExercise().sameRest,
                    onChanged: (bool? value) {
                      setState(() {
                        FocusManager.instance.primaryFocus?.unfocus();
                        getExercise().sameRest = value!;
                      });
                    },
                  ),
                ),
                const Expanded(
                  child: Text('Same Rest'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: scrollController,
                  child: IntrinsicHeight(
                    child: Row(
                      children: setWidgets,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateRoutineSet extends StatefulWidget {
  const CreateRoutineSet({
    Key? key,
  }) : super(key: key);

  @override
  CreateRoutineSetState createState() => CreateRoutineSetState();
}

class CreateRoutineSetState extends State<CreateRoutineSet> {
  late TextEditingController repsController;

  @override
  void initState() {
    super.initState();

    repsController = TextEditingController();
  }

  @override
  void dispose() {
    repsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: null,
          style: setButtonStyle(),
          child: SizedBox(
            width: 30,
            child: TextFormField(
              controller: repsController,
              // focusNode: repsFocusNode,
              // autofocus: widget.type != WidgetType.create,
              inputFormatters: positiveInteger,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.parse(repsController.text) <= 0) {
                  return '';
                }

                return null;
              },
              decoration: minimalInputDecoration(
                hint: 'reps',
                errorStyle: minimalTextStyling,
              ),
              style: const TextStyle(fontSize: 14.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
