import 'package:flutter/material.dart';
import 'package:smart_gym/workout_page/widgets/workout_widgets.dart';
import '../workout.dart';

class CreateWorkoutRoute extends StatelessWidget {
  const CreateWorkoutRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Create Workout'),
      ),
      body: const CreateWorkoutWidget(),
    );
  }
}

class CreateWorkoutWidget extends StatefulWidget {
  const CreateWorkoutWidget({super.key});

  @override
  CreateWorkoutWidgetState createState() {
    return CreateWorkoutWidgetState();
  }
}

class CreateWorkoutWidgetState extends State<CreateWorkoutWidget> {
  @override
  Widget build(BuildContext context) {
    return WorkoutForm(
      editable: true,
      workout: Workout(
        '',
        [
          Exercise(
              exerciseChoices.first,
              [
                Set(
                  0,
                  0,
                  0,
                )
              ],
              false,
              false,
              false),
        ],
      ),
    );
  }
}
