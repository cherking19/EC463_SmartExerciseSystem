import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/services/TimerService.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';

class TrackWorkoutRoute extends StatelessWidget {
  final Workout workout;
  final TrackedWorkout trackedWorkout;
  // int rest;

  const TrackWorkoutRoute({
    Key? key,
    required this.workout,
    required this.trackedWorkout,
    // required this.rest,
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
        // rest: rest,
      ),
    );
  }
}

class TrackWorkout extends StatefulWidget {
  final Workout workout;
  final TrackedWorkout trackedWorkout;
  // int rest;

  const TrackWorkout({
    Key? key,
    required this.workout,
    required this.trackedWorkout,
    // required this.rest,
  }) : super(key: key);

  @override
  State<TrackWorkout> createState() => TrackWorkoutState();
}

class TrackWorkoutState extends State<TrackWorkout> {
  List<bool> editable = [];

  void startSetTimer(int seconds) {
    TimerService.ofSet(context).restart(seconds);
  }

  void startWorkoutTimer() {
    if (!TimerService.ofWorkout(context).isRunning) {
      TimerService.ofWorkout(context).restart(null);
      widget.trackedWorkout.dateStarted = DateTime.now();
      // print('now time');
    }
  }

  void stopWorkout(BuildContext context) {
    if (!widget.trackedWorkout.isWorkoutStarted()) {
      Future result = showConfirmationDialog(
        context,
        confirmFinishDialogTitle,
        confirmNoStartDialogMessage,
      );

      result.then((value) {
        if (value) {
          finishTracking(context);
          Navigator.of(context).pop(
            NavigatorResponse(true, cancelAction, null),
          );
        }
      });
    } else if (!widget.trackedWorkout.isWorkoutDone()) {
      Future result = showConfirmationDialog(
        context,
        confirmFinishDialogTitle,
        confirmFinishDialogMessage,
      );

      result.then((value) {
        if (value) {
          finishTracking(context);
          Navigator.of(context).pop(
            NavigatorResponse(true, finishAction, null),
          );
        }
      });
    } else {
      finishTracking(context);
      Navigator.of(context).pop(
        NavigatorResponse(true, finishAction, null),
      );
    }
  }

  void cancelWorkout(BuildContext context) {
    Future result = showConfirmationDialog(
      context,
      confirmCancelDialogTitle,
      confirmCancelWorkoutDialogMessage,
    );

    result.then((value) {
      if (value) {
        finishTracking(context);
        Navigator.of(context).pop(
          NavigatorResponse(true, cancelAction, null),
        );
      }
    });
  }

  void finishTracking(BuildContext context) {
    TimerService.ofSet(context).stop();
    TimerService.ofWorkout(context).stop();
    widget.trackedWorkout.totalTime =
        TimerService.ofWorkout(context).elapsedMilli ~/ 1000;
  }

  void editWorkout(int index) {}

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TimerService.ofSet(context),
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
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
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                        child: Text(
                          TimerService.ofWorkout(context).isRunning
                              ? getFormattedDuration(
                                  Duration(
                                      seconds: TimerService.ofWorkout(context)
                                              .elapsedMilli ~/
                                          1000),
                                )
                              : '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    // padding: const EdgeInsets.all(16.0),
                    itemCount: widget.workout.exercises.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: index == widget.workout.exercises.length - 1
                            ? const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0)
                            : const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                        child: TrackExercise(
                          index: index,
                          exercise: widget.workout.exercises[index],
                          trackedExercise:
                              widget.trackedWorkout.exercises[index],
                          startSetTimer: startSetTimer,
                          startWorkoutTimer: startWorkoutTimer,
                          editWorkout: editWorkout,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (TimerService.ofSet(context).isRunning)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RestTimer(),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      cancelWorkout(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      stopWorkout(context);
                    },
                    child: const Text('Finish'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class TrackExercise extends StatefulWidget {
  final int index;
  final Exercise exercise;
  final TrackedExercise trackedExercise;
  final Function startSetTimer;
  final Function startWorkoutTimer;
  final Function editWorkout;

  const TrackExercise({
    Key? key,
    required this.index,
    required this.exercise,
    required this.trackedExercise,
    required this.startSetTimer,
    required this.startWorkoutTimer,
    required this.editWorkout,
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

  void editWorkout() {
    widget.editWorkout(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: globalBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 6.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 0.0),
                  child: Text(
                    widget.exercise.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        editWorkout();
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 4.0, 10.0, 0.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        widget.exercise.sets.length,
                        (index) => Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 8.0),
                          child: TrackSet(
                            index: index,
                            set: widget.exercise.sets[index],
                            trackedExercise: widget.trackedExercise,
                            updateParent: update,
                            startSetTimer: widget.startSetTimer,
                            startWorkoutTimer: widget.startWorkoutTimer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackSet extends StatefulWidget {
  final int index;
  final Set set;
  final TrackedExercise trackedExercise;
  final Function updateParent;
  final Function startSetTimer;
  final Function startWorkoutTimer;

  const TrackSet({
    Key? key,
    required this.index,
    required this.set,
    required this.trackedExercise,
    required this.updateParent,
    required this.startSetTimer,
    required this.startWorkoutTimer,
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

  void clickSet() {
    if (widget.trackedExercise.sets[widget.index].repsDone == null) {
      widget.startSetTimer(widget.set.rest);
    }

    widget.startWorkoutTimer();

    if (progressController.value == 0.0) {
      widget.trackedExercise.sets[widget.index].repsDone =
          widget.trackedExercise.sets[widget.index].totalReps;
      progressController.animateTo(1.0);
      widget.updateParent();
    } else {
      widget.trackedExercise.sets[widget.index].repsDone =
          widget.trackedExercise.sets[widget.index].repsDone! - 1;
      progressController.animateBack(
          widget.trackedExercise.sets[widget.index].repsDone! /
              widget.trackedExercise.sets[widget.index].totalReps);
    }

    repsDisplay = widget.trackedExercise.sets[widget.index].repsDone.toString();
  }

  @override
  void initState() {
    progressController = AnimationController(
      vsync: this,
      duration: globalAnimationSpeed,
    )..addListener(() {
        setState(() {});
      });

    if (widget.trackedExercise.sets[widget.index].repsDone != null) {
      repsDisplay =
          widget.trackedExercise.sets[widget.index].repsDone.toString();
      progressController.value =
          widget.trackedExercise.sets[widget.index].repsDone! /
              widget.trackedExercise.sets[widget.index].totalReps;
    } else {
      repsDisplay =
          widget.trackedExercise.sets[widget.index].totalReps.toString();
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
                              .repsDone !=
                          null)
                      : true)
                  ? clickSet
                  : null,
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 190, 190, 190),
                fixedSize: const Size(50, 50),
                shape: const CircleBorder(),
              ),
              child: Text(repsDisplay),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
          child: WeightTooltip(
              weight: widget.trackedExercise.sets[widget.index].weight),
          // Text(
          //   widget.trackedExercise.sets[widget.index].weight.toString(),
          // ),
        ),
        // const Text(
        //   'lbs',
        // ),
      ],
    );
  }
}

class WeightTooltip extends StatelessWidget {
  final int weight;

  const WeightTooltip({
    Key? key,
    required this.weight,
  }) : super(key: key);

  String trimPlate(double plate) {
    int whole = plate.truncate();
    double remainder = plate - whole;

    if (remainder > 0) {
      return plate.toString();
    } else {
      String plateS = plate.toString();
      return plateS.substring(0, plateS.indexOf('.'));
    }
  }

  String printPlates(List<double> plates) {
    String config = '';

    for (double plate in plates) {
      config += '${trimPlate(plate)}, ';
    }

    return config.substring(0, config.length - 2);
  }

  @override
  Widget build(BuildContext context) {
    // print('bye');
    return Tooltip(
      message:
          'Plates per side\n${printPlates(calculatePlates(weight.toDouble()))}',
      child: Text(
        weight.toString(),
      ),
    );
  }
}

class RestTimer extends StatefulWidget {
  const RestTimer({
    Key? key,
  }) : super(key: key);

  @override
  State<RestTimer> createState() => RestTimerState();
}

class RestTimerState extends State<RestTimer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TimerService.ofSet(context),
      builder: (context, child) {
        return Container(
          decoration: globalBoxDecoration,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    getFormattedDuration(
                      Duration(
                        seconds:
                            TimerService.ofSet(context).elapsedMilli ~/ 1000,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 6.0),
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(
                      begin: 0,
                      end: TimerService.ofSet(context).elapsedMilli /
                          (TimerService.ofSet(context).duration! * 1000),
                    ),
                    duration: globalAnimationSpeed,
                    builder: ((context, value, child) {
                      // print(value);
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: const Color.fromARGB(
                          0,
                          0,
                          0,
                          0,
                        ),
                        // valueColor: const AlwaysStoppedAnimation<Color>(
                        //   Colors.white,
                        // ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
