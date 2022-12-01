import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_gym/utils/notifications.dart';
import 'package:smart_gym/workout_page/widgets/workout_widgets.dart';
import 'dart:convert';
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
  WorkoutFormState createState() {
    return WorkoutFormState();
  }
}

class CreateWorkoutWidgetState extends State<