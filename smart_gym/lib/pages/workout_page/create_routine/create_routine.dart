import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/create_routine/create_routine_exercise.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/refresh_widgets.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/snackbars.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import '../workout.dart';

const double windowSidePadding = 12.0;

class CreateRoutineRoute extends StatelessWidget {
  CreateRoutineRoute({
    Key? key,
  }) : super(key: key);

  final Workout routine = Workout.emptyWorkout();

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
          appBar: AppBar(
            title: const Text('Create Workout'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(0.0),
            child: CreateRoutine(
              routine: routine,
              editable: true,
              saveWorkout: ({
                required BuildContext context,
                required Workout routine,
                required VoidCallback onComplete,
              }) {
                Future.delayed(
                  globalPseudoDelay,
                  () async {
                    if (await saveRoutine(routine)) {
                      Navigator.of(context).pop(true);
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(createFailedSnackBar(context));
                    }

                    onComplete.call();
                  },
                );
              },
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
  final void Function({
    required BuildContext context,
    required Workout routine,
    required VoidCallback onComplete,
  }) saveWorkout;

  const CreateRoutine({
    Key? key,
    required this.routine,
    required this.editable,
    required this.saveWorkout,
  }) : super(key: key);

  @override
  CreateRoutineState createState() => CreateRoutineState();
}

class CreateRoutineState extends State<CreateRoutine> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ScrollController scrollController = ScrollController();
  bool saving = false;
  bool restValids = false;

  void tryCreate() {
    restValids = true;

    if (formKey.currentState!.validate() && restValids) {
      setState(() {
        saving = true;
      });
      widget.saveWorkout(
        context: context,
        routine: widget.routine,
        onComplete: () {
          setState(() {
            saving = false;
          });
        },
      );
    } else {
      showInvalidFormDialog(context: context);
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
                  controller: scrollController,
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
                        reportRestInvalid: () {
                          restValids = false;
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
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            widget.routine.addExercise();
                          });
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            scrollController.jumpTo(
                                scrollController.position.maxScrollExtent);
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
                            FocusScope.of(context).requestFocus(FocusNode());
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

class ChildUpdateController {
  void Function()? update;
}

class WorkoutName extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final bool editable;
  final Workout workout;

  WorkoutName({
    Key? key,
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
