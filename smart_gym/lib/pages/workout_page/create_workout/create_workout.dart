import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/snackbars.dart';
import 'package:smart_gym/reusable_widgets/workout_widgets/workout_widgets.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import '../workout.dart';

class CreateWorkoutRoute extends StatelessWidget {
  const CreateWorkoutRoute({
    Key? key,
  }) : super(key: key);

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
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Create Workout'),
        ),
        body: const CreateWorkoutWidget(),
      ),
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
  final formKey = GlobalKey<FormState>();

  Workout workout = Workout(
    '',
    [
      Exercise(
<<<<<<< Updated upstream
          defaultExercises.first,
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
=======
        exerciseChoices.first,
        [
          Set(
            0,
            0,
            defaultRestDuration,
            null,
          )
        ],
        false,
        false,
        false,
      ),
>>>>>>> Stashed changes
    ],
  );

  Future<void> submitWorkout(
    BuildContext context,
    Workout workout,
    VoidCallback onFailure,
  ) async {
    Future.delayed(
      globalPseudoDelay,
      () async {
        if (await saveRoutine(workout)) {
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(createFailedSnackBar(context));
          onFailure.call();
        }
      },
    );
  }

  void tryCreate() {
    if (formKey.currentState!.validate()) {
      // print('saving');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Column(
        children: [
          Form(
            key: formKey,
            child: WorkoutWidget(
              // key: formKey,
              type: WidgetType.create,
              workout: workout,
              editable: false,
              // formKey: formKey,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  tryCreate();
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
    // WorkoutForm(
    //   editable: true,
    //   viewing: false,
    //   workout: workout,
    //   saveWorkout: submitWorkout,
    // );
  }
}
