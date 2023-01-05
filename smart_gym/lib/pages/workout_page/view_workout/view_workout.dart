import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/refresh_widgets.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/snackbars.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import 'package:smart_gym/pages/workout_page/widgets/create_workout_widgets.dart';
import '../workout.dart';

class SubmitController {
  void Function()? saveWorkout;
}

class ViewWorkoutRoute extends StatefulWidget {
  Workout workout;
  final int index;

  ViewWorkoutRoute({
    Key? key,
    required this.workout,
    required this.index,
  }) : super(key: key);

  @override
  State<ViewWorkoutRoute> createState() => _ViewWorkoutRouteState();
}

class _ViewWorkoutRouteState extends State<ViewWorkoutRoute> {
  bool editable = false;
  Workout? preEditWorkout;
  bool loading = false;
  final SubmitController submitController = SubmitController();

  Future<void> updateWorkout(
    BuildContext context,
    Workout workout,
    VoidCallback onFailure,
  ) async {
    setState(() {
      loading = true;
    });

    Routines routines = await loadRoutines();
    routines.replaceWorkout(widget.workout, widget.index);

    Future.delayed(
      globalPseudoDelay,
      () async {
        if (await saveRoutines(routines)) {
          Navigator.of(context).pop(
            NavigatorResponse(
              true,
              NavigatorAction.edit,
              null,
            ),
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(editFailedSnackBar(context));
        }
      },
    );
  }

  void trackWorkout() {
    Navigator.of(context).pop(
      NavigatorResponse(
        true,
        NavigatorAction.track,
        widget.workout,
      ),
    );
  }

  void openEdit() {
    // String workoutJson = jsonEncode(widget.workout.toJson());
    // preSaveWorkout = Workout.fromJson(jsonDecode(workoutJson));
    preEditWorkout = widget.workout.copy();

    setState(() {
      editable = true;
    });
  }

  void saveEdit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    submitController.saveWorkout!();
  }

  void cancelEdit() async {
    if (await showConfirmationDialog(
      context,
      confirmCancelDialogTitle,
      confirmCancelDialogMessage,
    )) {
      widget.workout = preEditWorkout!;

      setState(() {
        editable = false;
      });
    }
  }

  void deleteWorkout() async {
    if (await showConfirmationDialog(
      context,
      confirmDeleteDialogTitle,
      confirmDeleteDialogMessage,
    )) {
      setState(() {
        loading = true;
      });

      Routines routines = await loadRoutines();
      routines.deleteWorkout(widget.index);

      Future.delayed(
        const Duration(seconds: 1),
        () async {
          if (await saveRoutines(routines)) {
            Navigator.of(context).pop(
              NavigatorResponse(
                true,
                NavigatorAction.delete,
                null,
              ),
            );
          } else {
            Navigator.of(context).pop(
              NavigatorResponse(
                false,
                NavigatorAction.delete,
                null,
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        // key: globalScaffoldKey,
        appBar: AppBar(
          title: const Text('Viewing Workout'),
        ),
        body: Column(
          children: [
            if (!loading)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: trackWorkout,
                    child: const Text('Track'),
                  ),
                  TextButton(
                    onPressed: !editable ? openEdit : null,
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: editable ? saveEdit : null,
                    child: const Text('Save'),
                  ),
                  TextButton(
                    onPressed: editable ? cancelEdit : null,
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: deleteWorkout,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            if (loading) loadingSpinner,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                child: WorkoutForm(
                  editable: editable,
                  viewing: true,
                  workout: widget.workout,
                  saveWorkout: updateWorkout,
                  submitController: submitController,
                ),
              ),
            )
          ],
        ),
      ),
      onWillPop: () async {
        if (editable) {
          return await showConfirmationDialog(
            context,
            confirmCancelDialogTitle,
            confirmCancelDialogMessage,
          );
        }

        return true;
      },
    );
  }
}
