import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/workout_widgets/workout_widgets.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import '../../workout_page/workout.dart';

class ViewHistoryRoute extends StatelessWidget {
  final Workout workout;

  const ViewHistoryRoute({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Completed Workout'),
      ),
      body: ViewHistory(
        workout: workout,
      ),
    );
  }
}

class ViewHistory extends StatefulWidget {
  Workout workout;

  ViewHistory({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  State<ViewHistory> createState() {
    return ViewHistoryState();
  }
}

class ViewHistoryState extends State<ViewHistory> {
  bool editable = false;
  Workout? preEditWorkout;

  void deleteWorkout(bool result) {
    if (result) {
      deleteTrackedWorkout(widget.workout.uuid!);
      Navigator.of(context).pop(
        NavigatorResponse(true, deleteAction, null),
      );
    }
  }

  void startEdit() {
    preEditWorkout = widget.workout.copy();

    setState(() {
      editable = true;
    });
  }

  void cancelEdit() async {
    if (await showConfirmationDialog(
      context,
      confirmCancelDialogTitle,
      confirmCancelDialogMessage,
    )) {
      widget.workout = preEditWorkout!;

      // print(widget.workout);

      setState(() {
        editable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('view: $editable');
    return Column(
      children: [
        // Text(widget.workout.name),
        WorkoutWidget(
          type: WidgetType.history,
          workout: widget.workout,
          editable: editable,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (editable)
              TextButton(
                onPressed: () {
                  cancelEdit();
                },
                child: const Text('Cancel'),
              ),
            if (editable)
              TextButton(
                onPressed: () {},
                child: const Text('Save'),
              ),
            if (!editable)
              TextButton(
                onPressed: () {
                  // stopWorkout(context);
                  // setState(() {
                  //   editable = true;
                  // });
                  startEdit();
                },
                child: const Text('Edit'),
              ),
            // TextButton(
            //   onPressed: () {
            //     // cancelWorkout(context);
            //   },
            //   child: const Text(
            //     'Delete',
            //     style: TextStyle(
            //       color: Color.fromARGB(255, 255, 0, 0),
            //     ),
            //   ),
            // ),
            deleteButton(
              context,
              true,
              deleteWorkout,
            ),
          ],
        ),
      ],
    );
  }
}
