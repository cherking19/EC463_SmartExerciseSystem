import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smart_gym/pages/workout_page/track_workout/track_widgets/track_set.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';

class TrackExerciseWidget extends StatefulWidget {
  final int index;
  final Exercise exercise;

  const TrackExerciseWidget({
    Key? key,
    required this.index,
    required this.exercise,
  }) : super(key: key);

  @override
  TrackExerciseWidgetState createState() {
    return TrackExerciseWidgetState();
  }
}

class TrackExerciseWidgetState extends State<TrackExerciseWidget> {
  ScrollController scrollController = ScrollController();

  void update() {
    setState(() {});
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets setWidgetPadding = EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 8.0);

    List<Widget> setWidgets = List.generate(
      widget.exercise.sets.length,
      (index) {
        TrackSetController controller = TrackSetController();

        return Padding(
          padding: setWidgetPadding,
          child: TrackSetWidget(
            index: index,
            exercise: widget.exercise,
            set: widget.exercise.sets[index],
            updateParent: update,
            controller: controller,
          ),
        );
      },
    );

    // setWidgets.add(
    //   Padding(
    //     padding: setWidgetPadding,
    //     child: Align(
    //       alignment: Alignment.topCenter,
    //       child: TextButton(
    //         onPressed: () {
    //           setState(() {
    //             widget.exercise.addSet();
    //           });
    //           SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //             scrollController
    //                 .jumpTo(scrollController.position.maxScrollExtent);
    //           });
    //         },
    //         style: setButtonStyle(),
    //         child: const Icon(Icons.add),
    //       ),
    //     ),
    //   ),
    // );

    return Container(
      decoration: globalBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 16.0, 0.0, 4.0),
                  child: Text(
                    widget.exercise.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // DONT DELETE
                // Expanded(
                //   child: Align(
                //     alignment: Alignment.centerRight,
                //     child: TextButton(
                //       onPressed: () {
                //         // editWorkout();
                //       },
                //       child: const Text('Edit'),
                //     ),
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 4.0, 10.0, 0.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    child: IntrinsicHeight(
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: setWidgets,
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
