import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import 'package:smart_gym/workout_page/workout.dart';

import '../../reusable_widgets/TimerWidget.dart';

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

class TrackWorkout extends StatefulWidget {
  final Workout workout;
  final TrackedWorkout trackedWorkout;

  const TrackWorkout({
    Key? key,
    required this.workout,
    required this.trackedWorkout,
  }) : super(key: key);

  @override
  State<TrackWorkout> createState() => TrackWorkoutState();
}

class TrackWorkoutState extends State<TrackWorkout> {
  int? rest;
  TimerWidget? timer;

  void startTimer(int seconds) {
    // print('set state timer');
    // print(seconds);
    // setState(() {
    //   timer = null;
    // });

    setState(() {
      timer = TimerWidget(
        key: UniqueKey(),
        seconds: seconds,
      );
    });
  }

  void finishWorkout(BuildContext context) {
    if (!widget.trackedWorkout.isWorkoutDone()) {
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
    } else {
      Navigator.of(context).pop(
        NavigatorResponse(true, finishAction, null),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.workout.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.workout.exercises.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                  child: TrackExercise(
                    exercise: widget.workout.exercises[index],
                    trackedExercise: widget.trackedWorkout.exercises[index],
                    startTimer: startTimer,
                  ),
                );
              },
            ),
          ),
        ),
        if (timer != null) timer!,
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

class TrackExercise extends StatefulWidget {
  final Exercise exercise;
  final TrackedExercise trackedExercise;
  final Function startTimer;

  const TrackExercise({
    Key? key,
    required this.exercise,
    required this.trackedExercise,
    required this.startTimer,
  }) : super(key: key);

  @override
  TrackExerciseState createState() {
    return TrackExerciseState();
  }
}

class TrackExerciseState extends State<TrackExercise> {
  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.exercise.name),
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 0.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    widget.exercise.sets.length,
                    (index) => Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                      child: TrackSet(
                        index: index,
                        set: widget.exercise.sets[index],
                        trackedExercise: widget.trackedExercise,
                        updateParent: update,
                        startTimer: widget.startTimer,
                      ),
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
  final TrackedExercise trackedExercise;
  final Function updateParent;
  final Function startTimer;

  const TrackSet({
    Key? key,
    required this.index,
    required this.set,
    required this.trackedExercise,
    required this.updateParent,
    required this.startTimer,
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
    if (widget.trackedExercise.sets[widget.index].reps_done == null) {
      widget.startTimer(widget.set.rest);
    }

    if (progressController.value == 0.0) {
      widget.trackedExercise.sets[widget.index].reps_done =
          widget.trackedExercise.sets[widget.index].total_reps;
      progressController.animateTo(1.0);
      widget.updateParent();
    } else {
      widget.trackedExercise.sets[widget.index].reps_done =
          widget.trackedExercise.sets[widget.index].reps_done! - 1;
      progressController.animateBack(
          widget.trackedExercise.sets[widget.index].reps_done! /
              widget.trackedExercise.sets[widget.index].total_reps);
    }

    repsDisplay =
        widget.trackedExercise.sets[widget.index].reps_done.toString();
  }

  @override
  void initState() {
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });

    if (widget.trackedExercise.sets[widget.index].reps_done != null) {
      repsDisplay =
          widget.trackedExercise.sets[widget.index].reps_done.toString();
      progressController.value =
          widget.trackedExercise.sets[widget.index].reps_done! /
              widget.trackedExercise.sets[widget.index].total_reps;
    } else {
      repsDisplay =
          widget.trackedExercise.sets[widget.index].total_reps.toString();
    }
    super.initState();
  }

  @override
  void dispose() {
    progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
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
              onPressed: (widget.index != 0
                      ? (widget.trackedExercise.sets[widget.index - 1]
                              .reps_done !=
                          null)
                      : true)
                  ? clickSet
                  : null,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.0),
                fixedSize: const Size(50, 50),
                shape: const CircleBorder(),
              ),
              child: Text(repsDisplay),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
          child: Text(
            widget.trackedExercise.sets[widget.index].weight.toString(),
          ),
        ),
      ],
    );
  }
}
