import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_gym/pages/workout_page/workout_page.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
import 'package:smart_gym/reusable_widgets/workout_widgets/workout_widgets.dart';
import 'package:smart_gym/services/notifications_service.dart';
import 'package:smart_gym/services/timer_service.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';

class TrackWorkoutRoute extends StatelessWidget {
  // final Workout workout;

  const TrackWorkoutRoute({
    Key? key,
    // required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout In Progress'),
      ),
      body: const TrackWorkoutPage(
          // workout: workout,
          ),
    );
  }
}

class TrackWorkoutPage extends StatefulWidget {
  const TrackWorkoutPage({
    Key? key,
  }) : super(key: key);

  @override
  TrackWorkoutPageState createState() => TrackWorkoutPageState();
}

class TrackWorkoutPageState extends State<TrackWorkoutPage> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      NotificationsService.of(context).requestPermissions();
    });

    return AnimatedBuilder(
      animation: TimerService.ofSet(context),
      builder: (context, child) {
        return Consumer<TrackedWorkoutModel>(
          builder: (context, tracked, child) {
            void stopTimers() {
              TimerService.ofSet(context).stop();
              TimerService.ofWorkout(context).stop();
            }

            void stopWorkout(BuildContext context) {
              stopTimers();
              tracked.stopTrack();
            }

            void cancelWorkout(BuildContext context) {
              stopWorkout(context);
              Navigator.of(context).pop(
                NavigatorResponse(
                  true,
                  NavigatorAction.cancel,
                  null,
                ),
              );
            }

            void finishWorkout(BuildContext context) {
              //save the current duration
              tracked.workout!.duration =
                  TimerService.ofWorkout(context).elapsed;
              saveTrackedWorkout(tracked.workout!);
              stopWorkout(context);

              Navigator.of(context).pop(
                NavigatorResponse(
                  true,
                  NavigatorAction.finish,
                  null,
                ),
              );
            }

            void initiateFinishWorkout(BuildContext context) {
              if (!tracked.workout!.isWorkoutStarted()) {
                Future result = showConfirmationDialog(
                  context,
                  confirmFinishDialogTitle,
                  confirmNoStartDialogMessage,
                );

                result.then((value) {
                  if (value) {
                    cancelWorkout(context);
                  }
                });
              } else if (!tracked.workout!.isWorkoutDone()) {
                Future result = showConfirmationDialog(
                  context,
                  confirmFinishDialogTitle,
                  confirmFinishDialogMessage,
                );

                result.then(
                  (value) {
                    if (value) {
                      finishWorkout(context);
                    }
                  },
                );
              } else {
                finishWorkout(context);
              }
            }

            void initiateCancelWorkout(BuildContext context) {
              Future result = showConfirmationDialog(
                context,
                confirmCancelDialogTitle,
                confirmCancelWorkoutDialogMessage,
              );

              result.then(
                (value) {
                  if (value) {
                    cancelWorkout(context);
                  }
                },
              );
            }

            return Column(
              children: [
                WorkoutWidget(
                  type: WidgetType.track,
                  workout: tracked.workout ?? Workout.emptyWorkout(),
                  editable: false,
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
                        initiateCancelWorkout(context);
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
                        initiateFinishWorkout(context);
                      },
                      child: const Text('Finish'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
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
                      TimerService.ofSet(context).elapsed,
                      DurationFormat(
                        TimeFormat.digital,
                        DigitalTimeFormat(
                          hours: false,
                          minutes: true,
                          seconds: true,
                          twoDigit: false,
                        ),
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
                      end: TimerService.ofSet(context).elapsed.inMilliseconds /
                          TimerService.ofSet(context)
                              .endDuration!
                              .inMilliseconds,

                      // TimerService.ofSet(context)
                      //     .endDuration!
                      //     .inMilliseconds,
                    ),
                    duration: globalAnimationSpeed,
                    builder: ((context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: const Color.fromARGB(
                          0,
                          0,
                          0,
                          0,
                        ),
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
