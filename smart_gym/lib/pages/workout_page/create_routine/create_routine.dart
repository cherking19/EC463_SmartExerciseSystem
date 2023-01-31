import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smart_gym/pages/workout_page/widgets/create_workout_widgets.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/input.dart';
import 'package:smart_gym/reusable_widgets/refresh_widgets.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/snackbars.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import '../workout.dart';

const double windowSidePadding = 12.0;

class CreateRoutineRoute extends StatelessWidget {
  CreateRoutineRoute({
    Key? key,
  }) : super(key: key);

  final Workout routine = Workout(
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
          body: Padding(
            padding: const EdgeInsets.all(0.0),
            child: CreateRoutine(
              routine: routine,
              editable: true,
            ),
          ),
        ),
      ),
    );
  }
}

class CreateRoutine extends StatefulWidget {
  final Workout routine;
  final bool editable;

  const CreateRoutine({
    Key? key,
    required this.routine,
    required this.editable,
  }) : super(key: key);

  @override
  CreateRoutineState createState() => CreateRoutineState();
}

class CreateRoutineState extends State<CreateRoutine> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool saving = false;

  Future<void> submitWorkout({
    required BuildContext context,
    required Workout workout,
    required VoidCallback onFailure,
  }) async {
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
      setState(() {
        saving = true;
      });
      submitWorkout(
        context: context,
        workout: widget.routine,
        onFailure: () {
          setState(() {
            saving = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: windowSidePadding,
            ),
            child: WorkoutName(
              workout: widget.routine,
              editable: widget.editable,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: widget.routine.exercises.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                          windowSidePadding, 6.0, windowSidePadding, 6.0),
                      child: CreateRoutineExercise(
                        workout: widget.routine,
                        index: index,
                        editable: widget.editable,
                        deleteExercise: () {
                          setState(() {
                            widget.routine.deleteExercise(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (widget.editable)
            Stack(
              children: [
                Visibility(
                  visible: !saving,
                  maintainAnimation: true,
                  maintainSize: true,
                  maintainState: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      iconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            widget.routine.addExercise();
                          });
                        },
                        size: 25,
                        splashRadius: 20,
                        padding: const EdgeInsets.only(top: 10.0),
                        context: context,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: TextButton(
                          onPressed: () {
                            tryCreate();
                          },
                          style: TextButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: saving,
                  child: loadingSpinner(
                    padding: const EdgeInsets.all(16.0),
                    size: 30,
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }
}

class CreateRoutineExercise extends StatefulWidget {
  final Workout workout;
  final int index;
  final bool editable;
  final Function deleteExercise;

  const CreateRoutineExercise({
    Key? key,
    required this.workout,
    required this.index,
    required this.editable,
    required this.deleteExercise,
  }) : super(key: key);

  @override
  CreateRoutineExerciseState createState() => CreateRoutineExerciseState();
}

class CreateRoutineExerciseState extends State<CreateRoutineExercise> {
  ScrollController scrollController = ScrollController();
  List<ChildUpdateController> updateSetsControllers = [];

  Exercise getExercise() {
    return widget.workout.exercises[widget.index];
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets setWidgetPadding = EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 8.0);

    updateSetsControllers.clear();

    void updateSets({
      int? indexToIgnore,
    }) {
      for (int i = 0; i < updateSetsControllers.length; i++) {
        if (indexToIgnore == null || i != indexToIgnore) {
          if (updateSetsControllers[i].update != null) {
            updateSetsControllers[i].update!();
          }
        }
      }
    }

    List<Widget> setWidgets = List.generate(getExercise().sets.length, (index) {
      ChildUpdateController refreshController = ChildUpdateController();
      updateSetsControllers.add(refreshController);
      return CreateRoutineSet(
        editable: widget.editable,
        exercise: getExercise(),
        index: index,
        updateExercise: (int? index) {
          updateSets(
            indexToIgnore: index,
          );
        },
        refreshController: refreshController,
        deleteSet: (index) {
          setState(() {
            getExercise().deleteSet(index);
          });
          // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          //   updateSets();
          // });
        },
        refreshSet: () {
          setState(() {});
        },
      );
    });

    if (widget.editable) {
      setWidgets.add(
        Padding(
          padding: EdgeInsets.zero, //setWidgetPadding,
          child: Align(
            alignment: Alignment.topCenter,
            child: TextButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
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
    }

    bool onlyExercise() {
      return widget.workout.exercises.length == 1;
    }

    final double rightSidePadding = onlyExercise() ? 12.0 : 8.0;

    return Container(
      decoration: globalBoxDecoration,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.0, 2.0, rightSidePadding, 12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ExerciseNameDropdown(
                    editable: widget.editable,
                    exercise: getExercise(),
                  ),
                ),
                if (widget.editable && !onlyExercise())
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: stackIconButton(
                      context: context,
                      onPressed: () {
                        widget.deleteExercise();
                      },
                      radius: 30,
                      icon: Icons.close,
                      color: globalContainerColor,
                      splashColor: globalContainerWidgetColor,
                    ),
                  ),
              ],
            ),
            if (widget.editable)
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
                        updateSets();
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
                        updateSets();
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
                        updateSets();
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

class ChildUpdateController {
  void Function()? update;
}

class CreateRoutineSet extends StatefulWidget {
  final bool editable;
  final Exercise exercise;
  final int index;
  final Function(int?) updateExercise;
  final ChildUpdateController refreshController;
  final Function(int) deleteSet;
  final Function refreshSet;

  const CreateRoutineSet({
    Key? key,
    required this.editable,
    required this.exercise,
    required this.index,
    required this.updateExercise,
    required this.refreshController,
    required this.deleteSet,
    required this.refreshSet,
  }) : super(key: key);

  @override
  CreateRoutineSetState createState() => CreateRoutineSetState();
}

class CreateRoutineSetState extends State<CreateRoutineSet> {
  final TextEditingController repsController = TextEditingController();
  // final TextEditingController restController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  static final restFormat = DurationFormat(
    TimeFormat.digital,
    DigitalTimeFormat(
      hours: false,
      minutes: true,
      seconds: true,
      twoDigit: false,
    ),
  );

  bool restValid = true;

  void update() {
    widget.refreshController.update = null;

    repsController.value = TextEditingValue(
      text: getRepsString(),
      selection: TextSelection.collapsed(
        offset: repsController.text.length,
      ),
    );

    weightController.value = TextEditingValue(
      text: getWeightString(),
      selection: TextSelection.collapsed(
        offset: weightController.text.length,
      ),
    );
    // print('Set ${widget.index + 1}: ${getSet().weight}');

    // restController.text = getRestString();

    widget.refreshController.update = update;
  }

  Set getSet() {
    return widget.exercise.sets[widget.index];
  }

  String getRepsString() {
    return getSet().reps > 0 ? getSet().reps.toString() : '';
  }

  String getWeightString() {
    return getSet().weight > 0 ? getSet().weight.toString() : '';
  }

  String getRestString() {
    return getSet().rest != Duration.zero
        ? getFormattedDuration(getSet().rest, restFormat)
        : '';
  }

  @override
  void initState() {
    super.initState();

    widget.refreshController.update = update;

    repsController.addListener(() {
      var reps = int.tryParse(repsController.text);
      reps ??= 0;
      widget.exercise.setReps(widget.index, reps);
      widget.updateExercise(widget.index);
    });

    weightController.addListener(() {
      var weight = int.tryParse(weightController.text);
      weight ??= 0;
      widget.exercise.setWeight(widget.index, weight);
      widget.updateExercise(widget.index);
    });

    update();
  }

  @override
  void didUpdateWidget(CreateRoutineSet oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.refreshController.update = update;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      update();
    });
  }

  @override
  void dispose() {
    repsController.dispose();

    super.dispose();
  }

  bool onlySet = false;

  void inputDuration() async {
    Duration? rest = await showDurationPicker(
      context: context,
      initialTime: getSet().rest,
      baseUnit: BaseUnit.second,
    );

    if (rest != null) {
      widget.exercise.setRest(widget.index, rest);
      print(rest);
      widget.refreshSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    void validateRest() {
      setState(() {
        restValid = getSet().rest > Duration.zero;
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            TextButton(
              onPressed: null,
              style: setButtonStyle(),
              child: SizedBox(
                width: 30,
                child: TextFormField(
                  enabled: widget.editable,
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: positiveInteger,
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
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // button to delete the set if there is more than 1 set in the exercise
            if (widget.editable && widget.exercise.sets.length > 1)
              stackIconButton(
                context: context,
                onPressed: () {
                  widget.deleteSet(widget.index);
                },
                radius: 12.5,
                icon: Icons.close,
                color: globalContainerColor,
                splashColor: globalContainerWidgetColor,
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
          ),
          child: SizedBox(
            width: 45,
            child: TextFormField(
              enabled: widget.editable,
              controller: weightController,
              keyboardType: TextInputType.number,
              inputFormatters: positiveInteger,
              validator: (value) {
                validateRest();

                if (value == null ||
                    value.isEmpty ||
                    int.parse(weightController.text) <= 0) {
                  return '';
                }

                return null;
              },
              decoration: minimalInputDecoration(
                hint: 'lbs',
                errorStyle: minimalTextStyling,
              ),
              style: const TextStyle(
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextButton(
            onPressed: widget.editable
                ? () {
                    inputDuration();
                  }
                : null,
            style: minimalButtonStyle(
              context: context,
              padding: const EdgeInsets.all(4.0),
              textColorOverride: restValid ? null : Colors.red,
            ),
            child: Text(getSet().rest.inSeconds > 0
                ? getFormattedDuration(
                    getSet().rest,
                    DurationFormat(
                      TimeFormat.digital,
                      DigitalTimeFormat(
                        hours: false,
                        minutes: true,
                        seconds: true,
                        twoDigit: false,
                      ),
                    ),
                  )
                : 'rest'),
          ),
          // child: SetRest(
          //   set: getSet(),
          // ),
          // child: SizedBox(
          //   width: 45,
          //   child: Focus(
          //     onFocusChange: (value) async {
          //       if (value) {
          //         Duration? rest = await showDurationPicker(
          //           context: context,
          //           initialTime: getSet().rest,
          //           baseUnit: BaseUnit.second,
          //         );

          //         if (rest != null && rest != Duration.zero) {
          //           restController.text = getFormattedDuration(
          //             rest,
          //             restFormat,
          //           );
          //           widget.exercise.setRest(widget.index, rest);
          //           widget.updateExercise(widget.index);
          //         } else {
          //           widget.exercise.setRest(widget.index, Duration.zero);
          //           restController.text = '';
          //         }

          //         if (mounted) {
          //           FocusScope.of(context).requestFocus(FocusNode());
          //         }
          //       }
          //     },
          //     child: TextFormField(
          //       controller: restController,
          //       validator: (value) {
          //         if (value == null || value.isEmpty) {
          //           return '';
          //         }

          //         return null;
          //       },
          //       showCursor: false,
          //       readOnly: true,
          //       decoration: minimalInputDecoration(
          //         hint: 'rest',
          //         errorStyle: minimalTextStyling,
          //       ),
          //       style: const TextStyle(
          //         fontSize: 14.0,
          //       ),
          //       textAlign: TextAlign.center,
          //     ),
          //   ),
          // ),
        ),
      ],
    );
  }
}
