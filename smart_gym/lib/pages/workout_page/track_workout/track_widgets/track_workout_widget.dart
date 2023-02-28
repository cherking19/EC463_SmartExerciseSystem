import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_gym/pages/workout_page/track_workout/track_widgets/track_exercise.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
import 'package:smart_gym/services/TimerService.dart';
import 'package:smart_gym/services/track_workout_service.dart';
import 'package:smart_gym/utils/widget_utils.dart';

class TrackWorkoutWidget extends StatefulWidget {
  final Workout workout;

  const TrackWorkoutWidget({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  TrackWorkoutWidgetState createState() => TrackWorkoutWidgetState();
}

class TrackWorkoutWidgetState extends State<TrackWorkoutWidget> {
  String getDuration() {
    if (TimerService.ofWorkout(context).isRunning) {
      return getFormattedDuration(
        TimerService.ofWorkout(context).elapsed,
        DurationFormat(
          TimeFormat.digital,
          DigitalTimeFormat(
            hours: true,
            minutes: true,
            seconds: true,
            twoDigit: false,
          ),
        ),
      );
    }

    return '';
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      TrackWorkoutService.of(context).loadWorkout(widget.workout);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (TrackWorkoutService.of(context).trackedWorkout == null) {
      return const SizedBox.shrink();
    } else {
      Workout workout = TrackWorkoutService.of(context).trackedWorkout!;

      // return AnimatedBuilder(
      //   animation: TimerService.ofSet(context),
      //   builder: (context, child) {
      return Flexible(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Row(
                children: [
                  Text(
                    '${workout.name} - ',
                    style: globalTitleTextStyle,
                  ),
                  Text(
                    DateFormat(DateFormat.ABBR_MONTH_DAY)
                        .add_jm()
                        .format(workout.dateStarted!),
                    style: globalTitleTextStyle,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Duration - '),
                        AnimatedBuilder(
                          animation: TimerService.ofWorkout(context),
                          builder: (context, child) => Text(getDuration()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: workout.exercises.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: TrackExerciseWidget(
                        index: index,
                        exercise: widget.workout.exercises[index],
                        // startSetTimer: startSetTimer,
                        // editWorkout: () {},
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
      // },
      // );
    }
  }
}
