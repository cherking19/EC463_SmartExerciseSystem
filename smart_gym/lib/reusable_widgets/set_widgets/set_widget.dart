import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/input.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
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
  bool enterable = false;
  TextEditingController? weightController;
  late FocusNode focusNode;

  bool isSetIndicatorEnabled() {
    if (widget.type == WidgetType.track ||
        (widget.type == WidgetType.history && widget.editable)) {
      return widget.index != 0
          ? (widget.exercise.sets[widget.index - 1].repsDone != null)
          : true;
    }
    // else if (widget.type == WidgetType.history && widget.editable) {
    //   return true;
    // }

    return false;
  }

  void clickSet() {
    if (widget.type == WidgetType.track || widget.type == WidgetType.history) {
      if (widget.set.repsDone == null) {
        widget.startSetTimer(widget.set.rest);
      }

      if (widget.set.repsDone == null || widget.set.repsDone == 0) {
        widget.set.repsDone = widget.set.reps;
        widget.updateParent();
      } else {
        widget.set.repsDone = widget.set.repsDone! - 1;
      }

      animateProgress();
    }
  }

  void animateProgress() {
    if (widget.set.repsDone != null) {
      progressController.animateTo(widget.set.repsDone! / widget.set.reps);
    } else {
      progressController.animateTo(0.0);
    }
  }

  void editWeight() {
    // print('edit');
    setState(() {
      enterable = true;
      // focusNode = FocusNode();
    });
  }

  @override
  void initState() {
    progressController = AnimationController(
      vsync: this,
      duration: globalAnimationSpeed,
    )..addListener(
        () {
          setState(() {});
        },
      );

    animateProgress();

    focusNode = FocusNode()
      ..addListener(
        () {
          // print("Has focus: ${focusNode.hasFocus}");

          if (!focusNode.hasFocus) {
            // print('not enterable');
            // focusNode.unfocus();
            if (weightController!.text.isNotEmpty) {
              widget.set.weight = int.parse(weightController!.text);
              // print('change');
            }

            setState(() {
              enterable = false;
              // focusNode!.dispose();
            });
          }
        },
      );

    super.initState();
  }

  @override
  void dispose() {
    // print('dispose');
    progressController.dispose();
    weightController?.dispose();
    focusNode.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(SetWidget oldWidget) {
    animateProgress();
    // focusNode?.dispose();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (enterable) {
      if (weightController == null) {
        weightController ??= TextEditingController();
        weightController!.text = widget.set.weight.toString();
      }

      // if (focusNode == null) {

      // focusNode!.addListener(() {
      //   print("Has focus: ${focusNode!.hasFocus}");

      //   if (!focusNode!.hasFocus) {
      //     print('not enterable');
      //     focusNode!.unfocus();
      //     setState(() {
      //       enterable = false;
      //       // focusNode!.dispose();
      //     });
      //   }
      // });

      FocusScope.of(context).requestFocus(focusNode);
      // }
    }

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
              : enterable
                  ? SizedBox(
                      width: 40,
                      child: TextField(
                        controller: weightController,
                        focusNode: focusNode,
                        autofocus: true,
                        inputFormatters: positiveInteger,
                        decoration: minimalInputDecoration,
                        style: const TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : TextButton(
                      style: minimalButtonStyle(),
                      onPressed: widget.set.repsDone != null
                          ? () {
                              editWeight();
                            }
                          : null,
                      child: Text(
                        widget.set.weight.toString(),
                      ),
                    ),
        ),
      ],
    );
  }
}
