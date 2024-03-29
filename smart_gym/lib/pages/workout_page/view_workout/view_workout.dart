import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/create_routine/create_routine.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/snackbars.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import '../workout.dart';

class SubmitController {
  void Function()? saveWorkout;
}

class ViewWorkoutRoute extends StatefulWidget {
  Workout routine;
  final int index;

  ViewWorkoutRoute({
    Key? key,
    required this.routine,
    required this.index,
  }) : super(key: key);

  @override
  State<ViewWorkoutRoute> createState() => _ViewWorkoutRouteState();
}

class _ViewWorkoutRouteState extends State<ViewWorkoutRoute> {
  bool editable = false;
  Workout? editRoutine;
  bool loading = false;
  bool edited = false;
  final SubmitController submitController = SubmitController();

  void updateWorkout(
    BuildContext context,
    Workout workout,
    VoidCallback onComplete,
  ) async {
    setState(() {
      loading = true;
    });
  }

  void trackWorkout() {
    Navigator.of(context).pop(
      NavigatorResponse(
        true,
        NavigatorAction.track,
        widget.routine,
      ),
    );
  }

  void openEdit() {
    // String workoutJson = jsonEncode(widget.workout.toJson());
    // preSaveWorkout = Workout.fromJson(jsonDecode(workoutJson));

    setState(() {
      editRoutine = widget.routine.copy();
      editable = true;
    });
  }

  void saveEdit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    print('async');

    submitController.saveWorkout!();
  }

  void cancelEdit() async {
    if (await showConfirmationDialog(
      context,
      confirmCancelDialogTitle,
      confirmCancelDialogMessage,
    )) {
      // print('pre: $preEditWorkout');
      // widget.workout = preEditWorkout!;
      // print(widget.workout);

      setState(() {
        editable = false;
      });
    }
  }

  void deleteWorkout(Function onComplete) async {
    if (await showConfirmationDialog(
      context,
      confirmDeleteDialogTitle,
      confirmDeleteDialogMessage,
    )) {
      setState(() {
        loading = true;
      });

      onComplete(
        await deleteRoutine(widget.routine.uuid!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          // key: globalScaffoldKey,
          appBar: AppBar(
            title: const Text('Viewing Workout'),
          ),
          body: Column(
            children: [
              // if (!loading)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: loading ? null : trackWorkout,
                    child: const Text('Track'),
                  ),
                  TextButton(
                    onPressed: loading
                        ? null
                        : editable
                            ? cancelEdit
                            : openEdit,
                    child: Text(editable ? 'Cancel' : 'Edit'),
                  ),
                  // TextButton(
                  //   onPressed: editable ? saveEdit : null,
                  //   child: const Text('Save'),
                  // ),
                  // TextButton(
                  //   onPressed: editable ? cancelEdit : null,
                  //   child: const Text('Cancel'),
                  // ),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            deleteWorkout(
                              (bool result) {
                                Navigator.of(context).pop(
                                  NavigatorResponse(
                                    result,
                                    NavigatorAction.delete,
                                    null,
                                  ),
                                );
                              },
                            );
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
              // if (loading)
              //   loadingSpinner(
              //     size: defaultLoadingSpinnerSize,
              //     padding: EdgeInsets.zero,
              //   ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                  child: CreateRoutine(
                    routine: editable ? editRoutine! : widget.routine,
                    editable: editable,
                    saveWorkout: ({
                      required BuildContext context,
                      required Workout routine,
                      required VoidCallback onComplete,
                    }) {
                      setState(() {
                        loading = true;
                      });

                      Future.delayed(
                        globalPseudoDelay,
                        () async {
                          if (await updateRoutine(routine)) {
                            setState(() {
                              edited = true;
                              loading = false;
                              editable = false;
                              widget.routine = editRoutine!;
                            });
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(createFailedSnackBar(context));
                          }

                          onComplete.call();
                        },
                      );
                    },
                  ),
                  // child: WorkoutForm(
                  //   editable: editable,
                  //   viewing: true,
                  //   workout: widget.workout,
                  //   saveWorkout: updateWorkout,
                  //   submitController: submitController,
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        if (editable) {
          if (await showConfirmationDialog(
            context,
            confirmCancelDialogTitle,
            confirmCancelDialogMessage,
          )) {
            if (edited) {
              Navigator.of(context).pop(
                NavigatorResponse(
                  true,
                  NavigatorAction.edit,
                  null,
                ),
              );
            } else {
              return true;
            }
          } else {
            return false;
          }
        } else {
          if (edited) {
            Navigator.of(context).pop(
              NavigatorResponse(
                true,
                NavigatorAction.edit,
                null,
              ),
            );
          }
        }

        return true;
      },
    );
  }
}
