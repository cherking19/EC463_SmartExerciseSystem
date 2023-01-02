import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'weight_tooltip.dart';

class SetWidget extends StatefulWidget {
  final WidgetType type;
  final bool editable;
  final int index;
  final Exercise exercise;
  final Set set;
  final Function updateParent;
  final Function startSetTimer;

  const SetWidget({
    Key? key,
    required this.type,
    required this.editable,
    required this.index,
    required this.exercise,
    required this.set,
    required this.updateParent,
    required this.startSetTimer,
  }) : super(key: key);

  @override
  State<SetWidget> createState() {
    return SetWidgetState();
  }
}

class SetWidgetState extends State<SetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController progressController;
  // String repsDisplay = '';

  bool isSetIndicatorEnabled() {
    if (widget.type == WidgetType.track) {
      return widget.index != 0
          ? (widget.exercise.sets[widget.index - 1].repsDone != null)
          : true;
    } else if (widget.type == WidgetType.history && widget.editable) {
      return true;
    }

    return false;
  }

  void clickSet() {
    if (widget.type == WidgetType.track || widget.type == WidgetType.history) {
      if (widget.set.repsDone == null) {
        widget.startSetTimer(widget.set.rest);
      }

      // widget.startWorkoutTimer();

      if (widget.set.repsDone == null || widget.set.repsDone == 0) {
        widget.set.repsDone = widget.set.reps;
        // progressController.animateTo(1.0);
        animateProgress();
        widget.updateParent();
      } else {
        widget.set.repsDone = widget.set.repsDone! - 1;
        animateProgress();
        // progressController.animateBack(widget.set.repsDone! / widget.set.reps);
      }

      // repsDisplay = widget.set.repsDone.toString();
    }
    // else if (widget.type == WidgetType.history && widget.editable) {
    //   print('edit');
    // }
  }

  void animateProgress() {
    if (widget.set.repsDone != null) {
      // repsDisplay = widget.set.repsDone.toString();
      progressController.animateTo(widget.set.repsDone! / widget.set.reps);
    }
  }

  @override
  void initState() {
    progressController = AnimationController(
      vsync: this,
      duration: globalAnimationSpeed,
    )..addListener(() {
        setState(() {});
      });

    animateProgress();

    // else {
    //   repsDisplay = widget.set.reps.toString();
    // }

    super.initState();
  }

  @override
  void dispose() {
    progressController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(SetWidget oldWidget) {
    // print(widget.set);

    // if (widget.set.repsDone != null) {
    //   // repsDisplay = widget.set.repsDone.toString();
    //   progressController.value = widget.set.repsDone! / widget.set.reps;
    // }
    animateProgress();

    super.didUpdateWidget(oldWidget);
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
              onPressed: isSetIndicatorEnabled() ? clickSet : null,
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 190, 190, 190),
                fixedSize: const Size(50, 50),
                shape: const CircleBorder(),
              ),
              child: Text(
                widget.set.repsDone != null
                    ? widget.set.repsDone.toString()
                    : widget.set.reps.toString(),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
          child: !widget.editable
              ? WeightTooltip(
                  weight: widget.set.weight,
                  enabled: widget.editable,
                )
              : TextButton(
                  style: minimalButtonStyle(),
                  onPressed: () {},
                  child: Text(
                    widget.set.weight.toString(),
                  ),
                ),
        ),
      ],
    );
  }
}
