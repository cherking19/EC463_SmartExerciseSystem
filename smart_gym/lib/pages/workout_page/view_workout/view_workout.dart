import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
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
  final SubmitController _submitController = SubmitController();

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

    Future.delayed(const Duration(seconds: 1), () async {
      if (await saveRoutines(routines)) {
        Navigator.of(context).pop(NavigatorResponse(true, 'Edit', null));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(editFailedSnackBar(context));
      }
    });
  }

  void trackWorkout() {
    Navigator.of(context)
        .pop(NavigatorResponse(true, trackAction, widget.workout));
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

    _submitController.saveWorkout!();
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

      Future.delayed(const Duration(seconds: 1), () async {
        if (await saveRoutines(routines)) {
          Navigator.of(context).pop(NavigatorResponse(true, 'Delete', null));
        } else {
          Navigator.of(context).pop(NavigatorResponse(false, 'Delete', null));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
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
            if (loading)
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                child: WorkoutForm(
                  editable: editable,
                  viewing: true,
                  workout: widget.workout,
                  saveWorkout: updateWorkout,
                  submitController: _submitController,
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
