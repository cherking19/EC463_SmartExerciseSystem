import 'package:flutter/material.dart';
// import 'package:smart_gym/pages/workout_page/track_workout/track_workout.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/set_widgets/set_widget.dart';
import 'package:smart_gym/reusable_widgets/workout_widgets/decoration.dart';

import '../reusable_widgets.dart';

class ExerciseWidget extends StatefulWidget {
  final WidgetType type;
  final bool editable;
  final int index;
  final Exercise exercise;
  final Function startSetTimer;
  // final Function editWorkout;

  const ExerciseWidget({
    Key? key,
    required this.type,
    required this.editable,
    required this.index,
    required this.exercise,
    required this.startSetTimer,
    // required this.editWorkout,
  }) : super(key: key);

  @override
  ExerciseWidgetState createState() {
    return ExerciseWidgetState();
  }
}

class ExerciseWidgetState extends State<ExerciseWidget> {
  late AnimationController progressController;

  void update() {
    setState(() {});
    // print('update 2');
  }

  @override
  Widget build(BuildContext context) {
    // print('build exercise widget');
    return Container(
      decoration: globalBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 16.0, 6.0, 8.0),
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
                    child: Row(
                      children: List.generate(
                        widget.exercise.sets.length,
                        (index) => Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 8.0),
                          child: SetWidget(
                            type: widget.type,
                            editable: widget.editable,
                            index: index,
                            exercise: widget.exercise,
                            set: widget.exercise.sets[index],
                            updateParent: update,
                            startSetTimer: widget.startSetTimer,
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
