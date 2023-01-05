import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/refresh_widgets.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
//import 'package:smart_gym/api.dart';
// import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/snackbars.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import 'package:smart_gym/pages/workout_page/view_workout/view_workout.dart';
import '../../../utils/widget_utils.dart';
import '../workout.dart';

class ViewWorkoutsRoute extends StatelessWidget {
  const ViewWorkoutsRoute({
    Key? key,
  }) : super(key: key);

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
  bool refreshing = false;

  void loadWorkouts() async {
    setState(() {
      refreshing = true;
    });
    Future.delayed(globalPseudoDelay, () async {
      workouts = await loadRoutines();

      setState(() {
        refreshing = false;
      });
    });
  }

  // void deleteWorkout(int index) async {
  //   setState(() {
  //     workouts.removeAt(index);
  //   });
  // }

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

    result.then(
      (value) {
        if (value != null) {
          NavigatorResponse response = value as NavigatorResponse;

          if (response.action == NavigatorAction.edit) {
            if (response.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                editSuccessSnackBar(context),
              );
            }
          } else if (response.action == NavigatorAction.delete) {
            loadWorkouts();
            response.success
                ? ScaffoldMessenger.of(context).showSnackBar(
                    deleteSuccessSnackBar(context),
                  )
                : ScaffoldMessenger.of(context).showSnackBar(
                    deleteFailedSnackBar(context),
                  );
          } else if (response.action == NavigatorAction.track) {
            Navigator.of(context).pop(response);
          }
        }
      },
    );
  }

  @override
  void initState() {
    loadWorkouts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          if (refreshing)
            const Center(
              child: loadingSpinner,
            ),
          if (!refreshing)
            if (workouts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Text('No Routines'),
                ),
              ),
          if (workouts.isNotEmpty)
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
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
