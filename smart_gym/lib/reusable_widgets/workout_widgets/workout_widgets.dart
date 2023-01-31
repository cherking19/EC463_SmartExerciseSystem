import 'package:duration/duration.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/exercise_widgets/exercise_widget.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
import 'package:smart_gym/utils/widget_utils.dart';

import '../../services/TimerService.dart';

// this widget is meant to be used in the track and history contexts
// sets are meant to be animated
class WorkoutWidget extends StatefulWidget {
  final WidgetType type;
  final Workout workout;
  final bool editable;

  const WorkoutWidget({
    Key? key,
    required this.type,
    required this.workout,
    required this.editable,
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
      return getFormattedDuration(
        Duration(
          seconds: TimerService.ofWorkout(context).elapsedMilli ~/ 1000,
        ),
        DurationFormat(
          TimeFormat.digital,
          DigitalTimeFormat(
            true,
            true,
            true,
          ),
        ),
      );
    } else if (widget.type == WidgetType.history) {
      return getFormattedDuration(
        widget.workout.duration!,
        DurationFormat(
          TimeFormat.word,
          DurationTersity.minute,
        ),
      );
    }

    return '';
  }

  void changeDateStarted() async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: widget.workout.dateStarted!,
      firstDate: DateTime(
        widget.workout.dateStarted!.year - 1,
        widget.workout.dateStarted!.month,
      ),
      lastDate: DateTime.now(),
      // currentDate: DateTime.now(),
    );

    if (newDate != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          widget.workout.dateStarted!,
        ),
      );

      if (time != null) {
        setState(() {
          widget.workout.dateStarted = DateTime(
            newDate.year,
            newDate.month,
            newDate.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void changeDuration() async {
    Duration? duration = await showDurationPicker(
      context: context,
      initialTime: widget.workout.duration!,
    );

    if (duration != null) {
      setState(() {
        widget.workout.duration = duration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.editable);
    // print(widget.workout);
    // print('build workout widget');
    Text dateTextWidget = Text(
      DateFormat(DateFormat.ABBR_MONTH_DAY)
          .add_jm()
          .format(widget.workout.dateStarted!),
      style: globalTitleTextStyle,
    );

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
                      '${widget.workout.name} - ',
                      style: globalTitleTextStyle,
                    ),
                    if (!widget.editable) dateTextWidget,
                    if (widget.editable)
                      TextButton(
                        style: minimalButtonStyle(),
                        onPressed: () async {
                          changeDateStarted();
                        },
                        child: dateTextWidget,
                      ),
                    if (widget.type == WidgetType.track ||
                        widget.type == WidgetType.history)
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Duration - '),
                            if (!widget.editable)
                              AnimatedBuilder(
                                animation: TimerService.ofWorkout(context),
                                builder: (context, child) =>
                                    Text(getDuration()),
                              ),
                            if (widget.editable)
                              TextButton(
                                style: minimalButtonStyle(),
                                onPressed: () {
                                  changeDuration();
                                },
                                child: Text(getDuration()),
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
                          editable: widget.editable,
                          index: index,
                          exercise: widget.workout.exercises[index],
                          startSetTimer: startSetTimer,
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
      },
    );
  }
}
