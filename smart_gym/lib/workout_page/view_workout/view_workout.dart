import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import 'package:smart_gym/workout_page/widgets/workout_widgets.dart';
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
  Workout? preSaveWorkout;
  bool working = false;
  final SubmitController _submitController = SubmitController();

  Future<void> updateWorkout(
    BuildContext context,
    Workout workout,
    VoidCallback onFailure,
  ) async {
    setState(() {
      working = true;
    });

    Routines routines = await loadRoutines();
    routines.replaceWorkout(widget.workout, widget.index);

    Future.delayed(const Duration(seconds: 1), () async {
      if (await saveRoutines(routines)) {
        Navigator.of(context).pop(Pair(true, 'Create'));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(createFailedSnackBar(context));
      }
    });
  }

  void openEdit() {
    String workoutJson = jsonEncode(widget.workout.toJson());
    preSaveWorkout = Workout.fromJson(jsonDecode(workoutJson));

    setState(() {
      editable = true;
    });
  }

  void saveEdit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    _submitController.saveWorkout!();
  }

  void cancelEdit() {
    widget.workout = preSaveWorkout!;

    setState(() {
      editable = false;
    });
  }

  void deleteWorkout() async {
    setState(() {
      working = true;
    });

    Routines routines = await loadRoutines();
    routines.deleteWorkout(widget.index);

    Future.delayed(const Duration(seconds: 1), () async {
      if (await saveRoutines(routines)) {
        Navigator.of(context).pop(Pair(true, 'Delete'));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(deleteFailedSnackBar(context));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.workout);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewing Workout'),
      ),
      body: Column(
        children: [
          if (!working)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
          if (working)
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
            child: WorkoutForm(
              editable: editable,
              viewing: true,
              workout: widget.workout,
              saveWorkout: updateWorkout,
              submitController: _submitController,
            ),
          )
        ],
      ),
    );
  }
}
