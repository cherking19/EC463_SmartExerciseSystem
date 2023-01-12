import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/set_widgets/set_widget.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';

=======
import 'package:flutter/scheduler.dart';
import 'package:smart_gym/pages/workout_page/widgets/create_workout_widgets.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/set_widgets/set_widget.dart';
import 'package:smart_gym/reusable_widgets/workout_widgets/decoration.dart';
>>>>>>> Stashed changes
import '../reusable_widgets.dart';

class ExerciseWidget extends StatefulWidget {
  final WidgetType type;
  final bool editable;
  final int index;
  final Exercise exercise;

  const ExerciseWidget({
    Key? key,
    required this.type,
    required this.editable,
    required this.index,
    required this.exercise,
  }) : super(key: key);

  @override
  ExerciseWidgetState createState() {
    return ExerciseWidgetState();
  }
}

class ExerciseWidgetState extends State<ExerciseWidget> {
  // late AnimationController progressController;
  ScrollController scrollController = ScrollController();

  void update() {
    setState(() {});
  }

  // @override
  // void initState() {
  //   scrollController = ScrollController();

  //   super.initState();
  // }

  // @override
  // void didUpdateWidget(ExerciseWidget oldWidget) {
  //   print('hello');

  //   super.didUpdateWidget(oldWidget);
  // }

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
      (index) => Padding(
        padding: setWidgetPadding,
        child: SetWidget(
          type: widget.type,
          editable: widget.editable,
          index: index,
          exercise: widget.exercise,
          set: widget.exercise.sets[index],
          updateParent: update,
        ),
      ),
    );

    setWidgets.add(
      Padding(
        padding: setWidgetPadding,
        child: Align(
          alignment: Alignment.topCenter,
          child: TextButton(
            onPressed: () {
              setState(() {
                widget.exercise.addSet();
              });
              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                scrollController
                    .jumpTo(scrollController.position.maxScrollExtent);
              });
            },
            style: setButtonStyle(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    return Container(
      decoration: globalBoxDecoration,
      child: Padding(
        padding: widget.type == WidgetType.create
            ? const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 4.0)
            : const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.type != WidgetType.create)
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
                if (widget.type == WidgetType.create)
                  Expanded(
                    child: ExerciseNameDropdown(
                      readOnly: false,
                      exercise: widget.exercise,
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
