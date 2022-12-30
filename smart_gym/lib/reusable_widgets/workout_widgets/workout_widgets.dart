import 'package:flutter/material.dart';
// import 'package:smart_gym/pages/workout_page/track_workout/track_workout.dart';
// import 'package:flutter/widgets.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/exercise_widgets/exercise_widget.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/utils/widget_utils.dart';

import '../../services/TimerService.dart';

// this widget is meant to be used in the track and history contexts
// sets are meant to be animated
class WorkoutWidget extends StatefulWidget {
  final WidgetType type;
  final Workout workout;

  const WorkoutWidget({
    Key? key,
    required this.type,
    required this.workout,
  }) : super(key: key);

  @override
  WorkoutWidgetState createState() => WorkoutWidgetState();
}

class WorkoutWidgetState extends State<WorkoutWidget> {
  void startSetTimer(int seconds) {
    TimerService.ofSet(context).restart(seconds);
  }

  String getDuration() {
    if (widget.type == WidgetType.track &&
        TimerService.ofWorkout(context).isRunning) {
      return getFormattedDuration(Duration(
          seconds: TimerService.ofWorkout(context).elapsedMilli ~/ 1000));
    } else if (widget.type == WidgetType.history) {
      return getFormattedDuration(Duration(seconds: widget.workout.duration!));
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TimerService.ofSet(context),
      builder: (context, child) {
        return Flexible(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  children: [
                    Text(
                      widget.workout.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.type == WidgetType.track ||
                        widget.type == WidgetType.history)
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            child: AnimatedBuilder(
                              animation: TimerService.ofWorkout(context),
                              builder: (context, child) =>
                                  Text('Duration: ${getDuration()}'),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: widget.workout.exercises.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding:
                            // index == widget.workout.exercises.length - 1
                            //     ? const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0)
                            //     :
                            const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                        child: ExerciseWidget(
                          type: widget.type,
                          index: index,
                          exercise: widget.workout.exercises[index],
                          startSetTimer: startSetTimer,
                          // startWorkoutTimer: startWorkoutTimer,
                          editWorkout: () {},
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
