import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/input.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
import 'package:smart_gym/reusable_widgets/set_widgets/weight_tooltip.dart';
import 'package:smart_gym/services/TimerService.dart';
import 'package:smart_gym/services/track_workout_service.dart';
import 'package:smart_gym/utils/widget_utils.dart';

class TrackSetController {
  Function()? repCount;
  BuildContext? context;
}

class TrackSetWidget extends StatefulWidget {
  final int index;
  final Exercise exercise;
  final Set set;
  final Function updateParent;
  final TrackSetController controller;

  const TrackSetWidget({
    Key? key,
    required this.index,
    required this.exercise,
    required this.set,
    required this.updateParent,
    required this.controller,
  }) : super(key: key);

  @override
  State<TrackSetWidget> createState() {
    return TrackSetWidgetState();
  }
}

class TrackSetWidgetState extends State<TrackSetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController progressController;
  late TextEditingController repsController;
  late FocusNode repsFocusNode;

  bool isSetIndicatorEnabled() {
    return widget.index != 0
        ? (widget.exercise.sets[widget.index - 1].repsDone != null)
        : true;
  }

  void finishSet() {
    TrackWorkoutService.of(context).stopListening(context);
    TimerService.ofSet(context).restart(widget.set.rest);
  }

  void clickSet() {
    if (widget.set.repsDone == null) {
      widget.set.repsDone = 1;
      widget.updateParent();
    } else if (widget.set.repsDone == widget.set.reps) {
      widget.set.repsDone = 0;
    } else {
      widget.set.repsDone = widget.set.repsDone! + 1;
      if (widget.set.repsDone == widget.set.reps) {
        finishSet();
      }
    }

    animateProgress();
  }

  void animateProgress() {
    if (widget.set.repsDone != null) {
      progressController.animateTo(widget.set.repsDone! / widget.set.reps);
    } else {
      progressController.animateTo(0.0);
    }
  }

  @override
  void initState() {
    super.initState();

    progressController = AnimationController(
      vsync: this,
      duration: globalAnimationSpeed,
    )..addListener(
        () {
          setState(() {});
        },
      );

    animateProgress();

    repsFocusNode = FocusNode()
      ..addListener(
        () {
          if (!repsFocusNode.hasFocus) {
            if (repsController.text.isNotEmpty) {
              widget.set.weight = int.parse(repsController.text);
            }
          }
        },
      );

    repsController = TextEditingController();

    widget.controller.repCount = clickSet;
    widget.controller.context = context;

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   TrackWorkoutService.of(context).updateSetController(
    //     controller: widget.controller,
    //   );
    // });
  }

  @override
  void dispose() {
    progressController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(TrackSetWidget oldWidget) {
    animateProgress();

    widget.controller.repCount = clickSet;
    widget.controller.context = context;

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
                width: setCircleDiameter,
                height: setCircleDiameter,
                child: CircularProgressIndicator(
                  value: progressController.value,
                ),
              ),
            ),
            TextButton(
              onPressed: isSetIndicatorEnabled() ? clickSet : null,
              style: setButtonStyle(),
              child: Text(
                widget.set.repsDone != null
                    ? widget.set.repsDone.toString()
                    : widget.set.reps.toString(),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
          child: SetWeight(
            type: WidgetType.track,
            set: widget.set,
            editable: false,
          ),
        ),
        TextButton(
          onPressed: isSetIndicatorEnabled()
              ? () {
                  TrackWorkoutService.of(context).beginListening(
                    context,
                    controller: widget.controller,
                  );
                }
              : null,
          style: minimalButtonStyle(
            context,
            textColorOverride: Colors.green,
          ),
          child: const Text('Analyze'),
        ),
        TextButton(
          onPressed: isSetIndicatorEnabled()
              ? () {
                  finishSet();
                }
              : null,
          style: minimalButtonStyle(
            context,
            textColorOverride: Colors.red,
          ),
          child: const Text('Stop'),
        ),
      ],
    );
  }
}

class SetWeight extends StatefulWidget {
  final WidgetType type;
  final Set set;
  final bool editable;
  final GlobalKey? formKey;

  const SetWeight({
    Key? key,
    required this.type,
    required this.set,
    required this.editable,
    this.formKey,
  }) : super(key: key);

  @override
  SetWeightState createState() => SetWeightState();
}

class SetWeightState extends State<SetWeight> {
  late TextEditingController weightController;
  late FocusNode focusNode;
  bool enterable = false;

  @override
  void initState() {
    focusNode = FocusNode()
      ..addListener(
        () {
          if (!focusNode.hasFocus) {
            if (weightController.text.isNotEmpty) {
              widget.set.weight = int.parse(weightController.text);
            }

            setState(() {
              enterable = false;
            });
          }
        },
      );
    weightController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    weightController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (enterable) {
      FocusScope.of(context).requestFocus(focusNode);
      weightController.text =
          widget.set.weight > 0 ? widget.set.weight.toString() : '';
      weightController.selection =
          TextSelection.collapsed(offset: weightController.text.length);
    }

    if (widget.type == WidgetType.create) {
      return SizedBox(
        width: 40,
        child: TextFormField(
          controller: weightController,
          focusNode: focusNode,
          autofocus: widget.type != WidgetType.create,
          inputFormatters: positiveInteger,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null ||
                value.isEmpty ||
                int.parse(weightController.text) <= 0) {
              return '';
            }

            return null;
          },
          decoration: minimalInputDecoration(
            hint: 'lb',
            errorStyle: minimalTextStyling,
          ),
          style: const TextStyle(fontSize: 14.0),
          textAlign: TextAlign.center,
        ),
      );
    } else if (widget.editable) {
      return enterable
          ? SizedBox(
              width: 40,
              child: TextField(
                controller: weightController,
                focusNode: focusNode,
                autofocus: widget.type != WidgetType.create,
                inputFormatters: positiveInteger,
                keyboardType: TextInputType.number,
                decoration: minimalInputDecoration(hint: 'lb'),
                style: const TextStyle(fontSize: 14.0),
                textAlign: TextAlign.center,
              ),
            )
          : TextButton(
              style: minimalButtonStyle(
                context,
              ),
              onPressed: widget.set.repsDone != null
                  ? () {
                      setState(() {
                        enterable = true;
                      });
                    }
                  : null,
              child: Text(
                widget.set.weight.toString(),
              ),
            );
    } else {
      return WeightTooltip(
        weight: widget.set.weight,
        enabled: widget.editable,
      );
    }
  }
}

class SetRest extends StatefulWidget {
  final Set set;

  const SetRest({
    Key? key,
    required this.set,
  }) : super(key: key);

  @override
  SetRestState createState() => SetRestState();
}

class SetRestState extends State<SetRest> {
  void inputDuration() async {
    Duration? duration = await showDurationPicker(
      context: context,
      initialTime: widget.set.rest,
      baseUnit: BaseUnit.second,
    );

    if (duration != null) {
      setState(() {
        widget.set.rest = duration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        inputDuration();
      },
      style: minimalButtonStyle(
        context,
        padding: const EdgeInsets.all(4.0),
      ),
      child: Text(widget.set.rest.inSeconds > 0
          ? getFormattedDuration(
              widget.set.rest,
              DurationFormat(
                TimeFormat.digital,
                DigitalTimeFormat(
                  hours: false,
                  minutes: true,
                  seconds: true,
                  twoDigit: false,
                ),
              ),
            )
          : 'rest'),
    );
  }
}
