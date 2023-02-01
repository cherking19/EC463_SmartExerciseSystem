import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/create_routine/create_routine.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/decoration.dart';
import 'package:smart_gym/reusable_widgets/input.dart';
import 'package:smart_gym/utils/widget_utils.dart';

class CreateRoutineSet extends StatefulWidget {
  final bool editable;
  final Exercise exercise;
  final int index;
  final Function(int?) updateExercise;
  final ChildUpdateController refreshController;
  final Function(int) deleteSet;
  final Function refreshSet;
  final Function reportRestInvalid;

  const CreateRoutineSet({
    Key? key,
    required this.editable,
    required this.exercise,
    required this.index,
    required this.updateExercise,
    required this.refreshController,
    required this.deleteSet,
    required this.refreshSet,
    required this.reportRestInvalid,
  }) : super(key: key);

  @override
  CreateRoutineSetState createState() => CreateRoutineSetState();
}

class CreateRoutineSetState extends State<CreateRoutineSet> {
  final TextEditingController repsController = TextEditingController();
  // final TextEditingController restController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  static final restFormat = DurationFormat(
    TimeFormat.digital,
    DigitalTimeFormat(
      hours: false,
      minutes: true,
      seconds: true,
      twoDigit: false,
    ),
  );

  bool restValid = true;

  void update() {
    widget.refreshController.update = null;

    repsController.value = TextEditingValue(
      text: getRepsString(),
      selection: TextSelection.collapsed(
        offset: repsController.text.length,
      ),
    );

    weightController.value = TextEditingValue(
      text: getWeightString(),
      selection: TextSelection.collapsed(
        offset: weightController.text.length,
      ),
    );
    // print('Set ${widget.index + 1}: ${getSet().weight}');

    // restController.text = getRestString();

    widget.refreshController.update = update;
  }

  Set getSet() {
    return widget.exercise.sets[widget.index];
  }

  String getRepsString() {
    return getSet().reps > 0 ? getSet().reps.toString() : '';
  }

  String getWeightString() {
    return getSet().weight > 0 ? getSet().weight.toString() : '';
  }

  String getRestString() {
    return getSet().rest != Duration.zero
        ? getFormattedDuration(getSet().rest, restFormat)
        : '';
  }

  @override
  void initState() {
    super.initState();

    widget.refreshController.update = update;

    repsController.addListener(() {
      var reps = int.tryParse(repsController.text);
      reps ??= 0;
      widget.exercise.setReps(widget.index, reps);
      widget.updateExercise(widget.index);
    });

    weightController.addListener(() {
      var weight = int.tryParse(weightController.text);
      weight ??= 0;
      widget.exercise.setWeight(widget.index, weight);
      widget.updateExercise(widget.index);
    });

    update();
  }

  @override
  void didUpdateWidget(CreateRoutineSet oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.refreshController.update = update;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      update();
    });
  }

  @override
  void dispose() {
    repsController.dispose();

    super.dispose();
  }

  bool onlySet = false;

  void inputDuration() async {
    Duration? rest = await showDurationPicker(
      context: context,
      initialTime: getSet().rest,
      baseUnit: BaseUnit.second,
    );

    if (rest != null) {
      widget.exercise.setRest(widget.index, rest);
      widget.refreshSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    void validateRest() {
      setState(() {
        restValid = getSet().rest > Duration.zero;
      });

      if (!restValid) {
        widget.reportRestInvalid();
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            TextButton(
              onPressed: null,
              style: setButtonStyle(),
              child: SizedBox(
                width: 30,
                child: TextFormField(
                  enabled: widget.editable,
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: positiveInteger,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.parse(repsController.text) <= 0) {
                      return '';
                    }

                    return null;
                  },
                  decoration: minimalInputDecoration(
                    hint: 'reps',
                    errorStyle: minimalTextStyling,
                  ),
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // button to delete the set if there is more than 1 set in the exercise
            if (widget.editable && widget.exercise.sets.length > 1)
              stackIconButton(
                context: context,
                onPressed: () {
                  widget.deleteSet(widget.index);
                },
                radius: 12.5,
                icon: Icons.close,
                color: globalContainerColor,
                splashColor: globalContainerWidgetColor,
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
          ),
          child: SizedBox(
            width: 45,
            child: TextFormField(
              enabled: widget.editable,
              controller: weightController,
              keyboardType: TextInputType.number,
              inputFormatters: positiveInteger,
              validator: (value) {
                validateRest();

                if (value == null ||
                    value.isEmpty ||
                    int.parse(weightController.text) <= 0) {
                  return '';
                }

                return null;
              },
              decoration: minimalInputDecoration(
                hint: 'lbs',
                errorStyle: minimalTextStyling,
              ),
              style: const TextStyle(
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextButton(
            onPressed: widget.editable
                ? () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    inputDuration();
                  }
                : null,
            style: minimalButtonStyle(
              context: context,
              padding: const EdgeInsets.all(4.0),
              textColorOverride: restValid ? null : Colors.red,
            ),
            child: Text(getSet().rest.inSeconds > 0
                ? getFormattedDuration(
                    getSet().rest,
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
          ),
        ),
      ],
    );
  }
}
