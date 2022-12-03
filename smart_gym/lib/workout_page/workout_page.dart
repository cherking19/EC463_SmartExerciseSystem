import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'create_workout/create_workout.dart';
import 'view_workout/view_workouts.dart';

class WorkoutPage extends StatelessWidget {
  // final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const WorkoutPage({
    Key? key,
    // required this.scaffoldMessengerKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          alignment: Alignment.topLeft,
          // color: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Workout',
                style: TextStyle(fontSize: 18.0),
              ),
              TextButton(
                child: const Text('Create Workout'),
                onPressed: () {
                  Future result = Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateWorkoutRoute(),
                    ),
                  );

                  result.then((value) {
                    if (value) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(createSuccessSnackBar(context));
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(createFailedSnackBar(context));
                    }
                  });
                },
              ),
              TextButton(
                child: const Text('View Workouts'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewWorkoutsRoute(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
