import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smart_gym/pages/workout_page/widgets/create_workout_widgets.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/input.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/set_widgets/set_widget.dart';
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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
      key: formKey,
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
        exercise: getExercise(),
        index: index,
        updateExercise: (int index) {
          updateSets(
            indexToIgnore: index,
          );
        },
        refreshController: refreshController,
      );
    });

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
  final Exercise exercise;
  final int index;
  final Function(int) updateExercise;
  final ChildUpdateController refreshController;

  const CreateRoutineSet({
    Key? key,
    required this.exercise,
    required this.index,
    required this.updateExercise,
    required this.refreshController,
  }) : super(key: key);

  @override
  CreateRoutineSetState createState() => CreateRoutineSetState();
}

class CreateRoutineSetState extends State<CreateRoutineSet> {
  final TextEditingController repsController = TextEditingController();
  final TextEditingController restController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  void update() {
    widget.refreshController.update = null;

    repsController.value = TextEditingValue(
      text: getInitialRepsValue(),
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
    print('Set ${widget.index + 1}: ${getSet().weight}');

    widget.refreshController.update = update;
  }

  Set getSet() {
    return widget.exercise.sets[widget.index];
  }

  String getInitialRepsValue() {
    return getSet().reps > 0 ? getSet().reps.toString() : '';
  }

  String getWeightString() {
    return getSet().weight > 0 ? getSet().weight.toString() : '';
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
  }

  @override
  void didUpdateWidget(CreateRoutineSet oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.refreshController.update = update;
  }

  @override
  void dispose() {
    repsController.dispose();

    super.dispose();
  }

  bool onlySet = false;

  // void checkRepsInput(BuildContext context) {
  //   int reps = 0;

  //   if (repsController.text.isNotEmpty) {
  //     reps = int.parse(repsController.text);
  //   }

  //   widget.exercise.setReps(widget.index, reps);

  //   if (widget.exercise.sameReps) {
  //     widget.updateExercise(widget.index);
  //   }
  // }

  // void checkRestInput(BuildContext context) {
  //   int rest = 0;

  //   if (restController.text.isNotEmpty) {
  //     rest = int.parse(restController.text);
  //   }

  //   widget.exercise.setRest(widget.index, rest);

  //   if (widget.exercise.sameRest) {
  //     widget.updateParent();
  //   }
  // }

  // void checkWeightInput(BuildContext context) {
  //   int weight = 0;

  //   if (weightController.text.isNotEmpty) {
  //     weight = int.parse(weightController.text);
  //   }

  //   widget.exercise.setWeight(widget.index, weight);

  //   if (widget.exercise.sameWeight) {
  //     widget.updateParent();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // if (widget.exercise.sets[widget.index].weight > 0) {
    //   weightController.text =
    //       widget.exercise.sets[widget.index].weight.toString();
    // } else {
    //   weightController.text = '';
    // }

    // if (widget.exercise.sets[widget.index].reps > 0) {
    //   repsController.text = widget.exercise.sets[widget.index].reps.toString();
    // } else {
    //   repsController.text = '';
    // }

    // if (widget.exercise.sets[widget.index].rest > 0) {
    //   restController.text = widget.exercise.sets[widget.index].rest.toString();
    // } else {
    //   restController.text = '';
    // }

    // weightController.selection = TextSelection.collapsed(
    //   offset: weightController.text.length,
    // );
    // repsController.selection = TextSelection.collapsed(
    //   offset: repsController.text.length,
    // );
    // restController.selection = TextSelection.collapsed(
    //   offset: restController.text.length,
    // );

    // onlySet = widget.exercise.sets.length == 1;

    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   repsController.addListener(update);
    // });

    // print(!onlySet && widget.editable);

    // TextButton(
    //         onPressed: null,
    //         style: setButtonStyle(),
    //         child: SizedBox(
    //           width: 30,
    //           child: TextFormField(
    //             // key: UniqueKey,
    //             controller: repsController,
    //             // initialValue: getInitialRepsValue(),
    //             onChanged: (value) {
    //               int reps = 0;

    //               if (repsController.text.isNotEmpty) {
    //                 reps = int.parse(repsController.text);
    //               }

    //               widget.exercise.setReps(widget.index, reps);

    //               if (widget.exercise.sameReps) {
    //                 widget.updateExercise();
    //               }
    //             },
    //             // focusNode: repsFocusNode,
    //             // autofocus: widget.type != WidgetType.create,
    //             inputFormatters: positiveInteger,
    //             keyboardType: TextInputType.number,
    //             validator: (value) {
    //               if (value == null ||
    //                   value.isEmpty ||
    //                   int.parse(repsController.text) <= 0) {
    //                 return '';
    //               }

    //               return null;
    //             },
    //             decoration: minimalInputDecoration(
    //               hint: 'reps',
    //               errorStyle: minimalTextStyling,
    //             ),
    //             style: const TextStyle(fontSize: 14.0),
    //             textAlign: TextAlign.center,
    //           ),
    //         ),
    //       ),

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: null,
          style: setButtonStyle(),
          child: SizedBox(
            width: 30,
            child: TextFormField(
              controller: repsController,
              keyboardType: TextInputType.number,
              inputFormatters: positiveInteger,
              // onChanged: (value) {
              //   checkRepsInput(context);
              // },
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
        Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
          ),
          child: SizedBox(
            width: 45,
            child: TextFormField(
              controller: weightController,
              keyboardType: TextInputType.number,
              inputFormatters: positiveInteger,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.parse(weightController.text) <= 0) {
                  return '';
                }
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
          // SetWeight(
          //   type: WidgetType.create,
          //   set: getSet(),
          //   editable: true,
          // ),
        ),
      ],
    );
    // Padding(
    //   padding: const EdgeInsets.all(8.0),
    //   child: Row(
    //     children: [
    //       Text(
    //         'Set ${widget.index + 1}',
    //         style: const TextStyle(
    //           fontSize: 16.0,
    //         ),
    //       ),
    //       // if (!onlySet && widget.editable)
    //       //   Padding(
    //       //     padding: const EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 0.0),
    //       //     child: Align(
    //       //       alignment: Alignment.center,
    //       //       child: SizedBox(
    //       //         height: 16.0,
    //       //         width: 16.0,
    //       //         child: IconButton(
    //       //           icon: const Icon(Icons.close),
    //       //           padding: const EdgeInsets.all(0.0),
    //       //           iconSize: 16.0,
    //       //           splashRadius: 16.0,
    //       //           onPressed: () {
    //       //             FocusManager.instance.primaryFocus?.unfocus();
    //       //             widget.exercise.deleteSet(widget.index);
    //       //             widget.updateParent();
    //       //           },
    //       //         ),
    //       //       ),
    //       //     ),
    //       //   ),
    //     ],
    //   ),
    // ),
    // SizedBox(
    //   width: 90,
    //   child: Padding(
    //     padding: const EdgeInsets.all(4.0),
    //     child: TextField(
    //       enabled: widget.editable,
    //       decoration: const InputDecoration(
    //         border: OutlineInputBorder(),
    //         labelText: 'Weight (lb)',
    //         isDense: true,
    //         contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
    //       ),
    //       controller: weightController,
    //       keyboardType: TextInputType.number,
    //       inputFormatters: positiveInteger,
    //       onChanged: (value) {
    //         checkWeightInput(context);
    //       },
    //     ),
    //   ),
    // ),
    // SizedBox(
    //   width: 90,
    //   child: Padding(
    //     padding: const EdgeInsets.all(4.0),
    //     child: TextField(
    //       // enabled: widget.editable,
    //       decoration: const InputDecoration(
    //         border: OutlineInputBorder(),
    //         labelText: 'Reps',
    //         isDense: true,
    //         contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
    //       ),
    //       controller: repsController,
    //       keyboardType: TextInputType.number,
    //       inputFormatters: positiveInteger,
    //       onChanged: (value) {
    //         checkRepsInput(context);
    //       },
    //     ),
    //   ),
    // ),
    // SizedBox(
    //   width: 90,
    //   child: Padding(
    //     padding: const EdgeInsets.all(4.0),
    //     child: TextField(
    //       enabled: widget.editable,
    //       decoration: const InputDecoration(
    //         border: OutlineInputBorder(),
    //         labelText: 'Rest (s)',
    //         isDense: true,
    //         contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
    //       ),
    //       controller: restController,
    //       keyboardType: TextInputType.number,
    //       inputFormatters: positiveInteger,
    //       onChanged: (value) {
    //         checkRestInput(context);
    //       },
    //     ),
    //   ),
    // ),
    //     ],
    //   ),
    // );
  }
}

// class _SetWidgetState extends State<SetWidget> {
//   // double deleteSize = 100;

//   final TextEditingController repsController = TextEditingController();
//   final TextEditingController restController = TextEditingController();
//   final TextEditingController weightController = TextEditingController();
//   bool onlySet = false;

//   void checkRepsInput(BuildContext context) {
//     int reps = 0;

//     if (repsController.text.isNotEmpty) {
//       reps = int.parse(repsController.text);
//     }

//     widget.exercise.setReps(widget.index, reps);

//     if (widget.exercise.sameReps) {
//       widget.updateParent();
//     }
//   }

//   // void checkRestInput(BuildContext context) {
//   //   int rest = 0;

//   //   if (restController.text.isNotEmpty) {
//   //     rest = int.parse(restController.text);
//   //   }

//   //   widget.exercise.setRest(widget.index, rest);

//   //   if (widget.exercise.sameRest) {
//   //     widget.updateParent();
//   //   }
//   // }

//   // void checkWeightInput(BuildContext context) {
//   //   int weight = 0;

//   //   if (weightController.text.isNotEmpty) {
//   //     weight = int.parse(weightController.text);
//   //   }

//   //   widget.exercise.setWeight(widget.index, weight);

//   //   if (widget.exercise.sameWeight) {
//   //     widget.updateParent();
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.exercise.sets[widget.index].weight > 0) {
//       weightController.text =
//           widget.exercise.sets[widget.index].weight.toString();
//     } else {
//       weightController.text = '';
//     }

//     if (widget.exercise.sets[widget.index].reps > 0) {
//       repsController.text = widget.exercise.sets[widget.index].reps.toString();
//     } else {
//       repsController.text = '';
//     }

//     if (widget.exercise.sets[widget.index].rest > 0) {
//       restController.text = widget.exercise.sets[widget.index].rest.toString();
//     } else {
//       restController.text = '';
//     }

//     weightController.selection = TextSelection.collapsed(
//       offset: weightController.text.length,
//     );
//     repsController.selection = TextSelection.collapsed(
//       offset: repsController.text.length,
//     );
//     restController.selection = TextSelection.collapsed(
//       offset: restController.text.length,
//     );

//     onlySet = widget.exercise.sets.length == 1;

//     // print(!onlySet && widget.editable);

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Text(
//                   'Set ${widget.index + 1}',
//                   style: const TextStyle(
//                     fontSize: 16.0,
//                   ),
//                 ),
//                 if (!onlySet && widget.editable)
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(6.0, 0.0, 0.0, 0.0),
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: SizedBox(
//                         height: 16.0,
//                         width: 16.0,
//                         child: IconButton(
//                           icon: const Icon(Icons.close),
//                           padding: const EdgeInsets.all(0.0),
//                           iconSize: 16.0,
//                           splashRadius: 16.0,
//                           onPressed: () {
//                             FocusManager.instance.primaryFocus?.unfocus();
//                             widget.exercise.deleteSet(widget.index);
//                             widget.updateParent();
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           SizedBox(
//             width: 90,
//             child: Padding(
//               padding: const EdgeInsets.all(4.0),
//               child: TextField(
//                 enabled: widget.editable,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Weight (lb)',
//                   isDense: true,
//                   contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
//                 ),
//                 controller: weightController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: positiveInteger,
//                 onChanged: (value) {
//                   checkWeightInput(context);
//                 },
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 90,
//             child: Padding(
//               padding: const EdgeInsets.all(4.0),
//               child: TextField(
//                 enabled: widget.editable,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Reps',
//                   isDense: true,
//                   contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
//                 ),
//                 controller: repsController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: positiveInteger,
//                 onChanged: (value) {
//                   checkRepsInput(context);
//                 },
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 90,
//             child: Padding(
//               padding: const EdgeInsets.all(4.0),
//               child: TextField(
//                 enabled: widget.editable,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Rest (s)',
//                   isDense: true,
//                   contentPadding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
//                 ),
//                 controller: restController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: positiveInteger,
//                 onChanged: (value) {
//                   checkRestInput(context);
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
