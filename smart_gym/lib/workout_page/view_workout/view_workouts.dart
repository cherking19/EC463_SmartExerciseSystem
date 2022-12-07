import 'package:flutter/material.dart';
//import 'package:smart_gym/api.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import 'package:smart_gym/workout_page/view_workout/view_workout.dart';
import '../../utils/widget_utils.dart';
import '../workout.dart';

class ViewWorkoutsRoute extends StatelessWidget {
  const ViewWorkoutsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Workouts'),
      ),
      body: const ViewWorkouts(),
    );
  }
}

class ViewWorkouts extends StatefulWidget {
  const ViewWorkouts({super.key});

  @override
  ViewWorkoutsState createState() {
    return ViewWorkoutsState();
  }
}

class ViewWorkoutsState extends State<ViewWorkouts> {
  List<Workout> workouts = [];

  void initialLoadWorkouts() async {
    // print(workout);
    //getWorkouts();
    workouts = (await loadRoutines()).workouts;
    setState(() {});
  }

  void deleteWorkout(int index) async {
    setState(() {
      workouts.removeAt(index);
    });
  }

  void openWorkout(int index) {
    Future result = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewWorkoutRoute(
          workout: workouts[index],
          index: index,
        ),
      ),
    );

    result.then((value) {
      if (value != null) {
        NavigatorResponse response = value as NavigatorResponse;

        if (response.action == 'Edit') {
          if (response.success) {
            ScaffoldMessenger.of(context)
                .showSnackBar(editSuccessSnackBar(context));
          }
        } else if (response.action == 'Delete') {
          response.success
              ? ScaffoldMessenger.of(context)
                  .showSnackBar(deleteSuccessSnackBar(context))
              : ScaffoldMessenger.of(context)
                  .showSnackBar(deleteFailedSnackBar(context));
        } else if (response.action == 'Track') {
          Navigator.of(context).pop(response);
        }
      }
    });
  }

  @override
  void initState() {
    // workouts = (await loadRoutines()).workouts;
    initialLoadWorkouts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //initialLoadWorkouts();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: workouts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TextButton(
                      onPressed: () => openWorkout(index),
                      child: Text(workouts[index].name),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
