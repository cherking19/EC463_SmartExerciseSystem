import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';

const String confirmCancelDialogTitle = 'Confirm Cancel';
const String confirmCancelDialogMessage = 'Are you sure you want to cancel?';
const String confirmCancelWorkoutDialogMessage =
    'Are you sure you want to cancel? If yes, the workout results will not be saved.';

const String confirmDeleteDialogTitle = 'Confirm Delete';
const String confirmDeleteDialogMessage = 'Are you sure you want to delete?';

const String confirmFinishDialogTitle = 'Confirm Finish';
const String confirmFinishDialogMessage =
    'The workout is not complete. Are you sure you want to finish?';
const String confirmNoStartDialogMessage =
    'The workout has not been started. Are you sure you want to finish? If yes, no results will be saved.';

Future<bool> showConfirmationDialog(
    BuildContext context, String title, String message) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('No'),
          ),
        ],
      );
    },
  );

  if (result != null) {
    return result;
  } else {
    return false;
  }
}

void showMultipleWorkoutsDialog(
    BuildContext context, List<Workout> workouts, Function refresh) {
  showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text('Multiple Workouts'),
        children: List.generate(
          workouts.length,
          (index) => SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              openViewWorkout(
                context,
                workouts[index],
                refresh,
              );
            },
            child: Text(
              '${workouts[index].name} - ${DateFormat('hh:mm a').format(workouts[index].dateStarted!)}',
            ),
          ),
        ),
      );
    },
  );
}

void showInvalidFormDialog({
  required BuildContext context,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Invalid Form'),
        content: const Text(
            'One or more fields is invalid. They have been marked in red.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Ok'),
          ),
        ],
      );
    },
  );
}
