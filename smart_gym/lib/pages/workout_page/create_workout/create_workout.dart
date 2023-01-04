import 'package:flutter/material.dart';
import 'package:smart_gym/api.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/snackbars.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import 'package:smart_gym/pages/workout_page/widgets/create_workout_widgets.dart';
import '../workout.dart';

class CreateWorkoutRoute extends StatelessWidget {
  const CreateWorkoutRoute({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Create Workout'),
        ),
        body: const CreateWorkoutWidget(),
      ),
      onWillPop: () async {
        return await showConfirmationDialog(
          context,
          confirmCancelDialogTitle,
          confirmCancelDialogMessage,
        );
      },
    );
  }
}

class CreateWorkoutWidget extends StatefulWidget {
  const CreateWorkoutWidget({
    Key? key,
  }) : super(key: key);

  @override
  CreateWorkoutWidgetState createState() {
    return CreateWorkoutWidgetState();
  }
}

class CreateWorkoutWidgetState extends State<CreateWorkoutWidget> {
  Workout workout = Workout(
    '',
    [
      Exercise(
          exerciseChoices.first,
          [
            Set(
              0,
              0,
              0,
              null,
            )
          ],
          false,
          false,
          false),
    ],
  );

  Future<void> submitWorkout(
    BuildContext context,
    Workout workout,
    VoidCallback onFailure,
  ) async {
    Routines routines = await loadRoutines();
    routines.addWorkout(workout);
    addWorkout(workout);

    Future.delayed(const Duration(seconds: 2), () async {
      if (await saveRoutines(routines)) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(createFailedSnackBar(context));
        onFailure.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WorkoutForm(
      editable: true,
      viewing: false,
      workout: workout,
      saveWorkout: submitWorkout,
    );
  }
}
