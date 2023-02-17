import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_gym/pages/workout_page/create_routine/create_routine.dart';
import 'package:smart_gym/pages/workout_page/create_routine/create_routine_set.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
import 'package:smart_gym/services/exercise_service.dart';

class CreateRoutineExercise extends StatefulWidget {
  final Workout workout;
  final int index;
  final bool editable;
  final Function deleteExercise;
  final Function reportRestInvalid;

  const CreateRoutineExercise({
    Key? key,
    required this.workout,
    required this.index,
    required this.editable,
    required this.deleteExercise,
    required this.reportRestInvalid,
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
        reportRestInvalid: widget.reportRestInvalid,
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
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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

class ExerciseNameDropdown extends StatefulWidget {
  final bool editable;
  final Exercise exercise;

  const ExerciseNameDropdown({
    Key? key,
    required this.editable,
    required this.exercise,
  }) : super(key: key);

  @override
  State<ExerciseNameDropdown> createState() => _ExerciseNameDropdownState();
}

class _ExerciseNameDropdownState extends State<ExerciseNameDropdown> {
  @override
  Widget build(BuildContext context) {
    // return
    // FutureBuilder(
    //   future: loadCustomExercises(context),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    List<ExerciseChoice> exerciseChoices = Provider.of<ExerciseService>(context)
        .exercises
        .entries
        .map((entry) => ExerciseChoice(name: entry.value, uuid: entry.key))
        .toList();

    return DropdownButton<ExerciseChoice>(
      value: exerciseChoices.firstWhere((exerciseChoice) =>
          exerciseChoice.uuid == widget.exercise.exerciseUuid),
      disabledHint: Text(Provider.of<ExerciseService>(context)
          .exercises[widget.exercise.exerciseUuid]!),
      icon: const Icon(Icons.arrow_downward),
      isExpanded: true,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.blue,
      ),
      onChanged: widget.editable
          ? (ExerciseChoice? exerciseChoice) {
              setState(() {
                widget.exercise.exerciseUuid = exerciseChoice!.uuid;
              });
            }
          : null,
      items: exerciseChoices.map((choice) {
        return DropdownMenuItem<ExerciseChoice>(
          value: choice,
          child: Text(choice.name),
        );
      }).toList(),
    );
    //   } else if (snapshot.hasError) {
    //     return const Text('ERROR LOADING EXERCISES');
    //   } else {
    //     return const Text('Loading exercises.');
    //   }
    // },
    // );
  }
}
