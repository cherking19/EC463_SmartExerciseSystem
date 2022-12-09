import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import 'package:smart_gym/workout_page/workout.dart';

class TrackWorkoutRoute extends StatelessWidget {
  final Workout workout;
  final TrackedWorkout trackedWorkout;

  const TrackWorkoutRoute({
    Key? key,
    required this.workout,
    required this.trackedWorkout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout In Progress'),
      ),
      body: TrackWorkout(
        workout: workout,
        trackedWorkout: trackedWorkout,
      ),
    );
  }
}

class TrackWorkout extends StatelessWidget {
  final Workout workout;
  final TrackedWorkout trackedWorkout;

  const TrackWorkout({
    Key? key,
    required this.workout,
    required this.trackedWorkout,
  }) : super(key: key);

  void finishWorkout(BuildContext context) {
    Future result = showConfirmationDialog(
      context,
      confirmFinishDialogTitle,
      confirmFinishDialogMessage,
    );

    result.then((value) {
      if (value) {
        Navigator.of(context).pop(
          NavigatorResponse(true, finishAction, null),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(workout.name),
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: workout.exercises.length,
              itemBuilder: (BuildContext context, int index) {
                return TrackExercise(
                  exercise: workout.exercises[index],
                  trackedExercise: trackedWorkout.exercises[index],
                );
              },
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            finishWorkout(context);
          },
          child: const Text('Finish'),
        ),
      ],
    );
  }
}

class TrackExercise extends StatelessWidget {
  final Exercise exercise;
  final TrackedExercise trackedExercise;

  const TrackExercise({
    Key? key,
    required this.exercise,
    required this.trackedExercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(exercise.name),
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    exercise.sets.length,
                    (index) => TrackSet(
                      index: index,
                      set: exercise.sets[index],
                      trackedSet: trackedExercise.sets[index],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TrackSet extends StatefulWidget {
  final int index;
  final Set set;
  final TrackedSet trackedSet;

  const TrackSet({
    Key? key,
    required this.index,
    required this.set,
    required this.trackedSet,
  }) : super(key: key);

  @override
  State<TrackSet> createState() {
    return TrackSetState();
  }
}

class TrackSetState extends State<TrackSet>
    with SingleTickerProviderStateMixin {
  late AnimationController progressController;
  String repsDisplay = '';
  // double progress = 0.0;

  void clickSet() {
    if (progressController.value == 0.0) {
      repsDisplay = widget.trackedSet.total_reps.toString();
      widget.trackedSet.reps_done = widget.trackedSet.total_reps;
      progressController.animateTo(1.0);
    } else {
      widget.trackedSet.reps_done = widget.trackedSet.reps_done - 1;
      repsDisplay = widget.trackedSet.reps_done.toString();
      progressController.animateBack(
          widget.trackedSet.reps_done / widget.trackedSet.total_reps);
    }
  }

  @override
  void initState() {
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });
    repsDisplay = widget.trackedSet.total_reps.toString();
    super.initState();
  }

  @override
  void dispose() {
    progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 7,
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: progressController.value,
            ),
          ),
        ),
        TextButton(
          onPressed: clickSet,
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue.withOpacity(0.0),
            fixedSize: const Size(50, 50),
            shape: const CircleBorder(),
          ),
          child: Text(repsDisplay),
        ),
      ],
    );
  }
}
