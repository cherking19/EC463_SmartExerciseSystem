import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/refresh_widgets.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/snackbars.dart';
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
  Workout? editWorkout;
  bool loading = false;

  void deleteWorkout(bool result) async {
    if (result) {
      setState(() {
        loading = true;
      });

      if (await deleteTrackedWorkout(widget.workout.uuid!)) {
        Navigator.of(context).pop(
          NavigatorResponse(
            true,
            NavigatorAction.delete,
            null,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          deleteSuccessSnackBar(context),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          deleteFailedSnackBar(context),
        );
      }
    }
  }

  void startEdit() {
    editWorkout = widget.workout.copy();

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
      // print(widget.workout);
      setState(() {
        editable = false;
      });
    }
  }

  void saveEdit() async {
    setState(() {
      loading = true;
    });

    Future.delayed(
      globalPseudoDelay,
      () async {
        if (await updateTrackedWorkout(editWorkout!)) {
          Navigator.of(context).pop(
            NavigatorResponse(
              true,
              NavigatorAction.edit,
              null,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            editSuccessSnackBar(context),
          );

          setState(() {
            widget.workout = editWorkout!.copy();
            editable = false;
            loading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // print('view: $editable');
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        // print('request focus');
      },
      child: WillPopScope(
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
        child: Column(
          children: [
            // Text(widget.workout.name),
            WorkoutWidget(
              type: WidgetType.history,
              workout: editable ? editWorkout! : widget.workout,
              editable: editable,
            ),
            if (loading)
              loadingSpinner(
                padding: const EdgeInsets.all(16.0),
                size: 20,
              ),
            if (!loading)
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
                      onPressed: () {
                        saveEdit();
                      },
                      child: const Text('Save'),
                    ),
                  if (!loading)
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
        ),
      ),
    );
  }
}
