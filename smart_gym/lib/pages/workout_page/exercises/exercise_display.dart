import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/exercises/exercises.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/refresh_widgets.dart';
import 'package:smart_gym/utils/function_utils.dart';

const EdgeInsets exerciseDisplayPadding =
    EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0);
const TextStyle exerciseTextStyle = TextStyle(
  // fontWeight: FontWeight.bold,
  fontSize: exerciseListFontSize,
);

class ExerciseDisplay extends StatefulWidget {
  final String exercise;
  final bool custom;
  final int? index;
  final Function? remove;

  const ExerciseDisplay({
    Key? key,
    required this.exercise,
    required this.custom,
    this.index,
    this.remove,
  }) : super(key: key);

  @override
  ExerciseDisplayState createState() => ExerciseDisplayState();
}

class ExerciseDisplayState extends State<ExerciseDisplay> {
  @override
  Widget build(BuildContext context) {
    Widget text = ListTile(
      title: Text(
        widget.exercise,
        style: exerciseTextStyle,
      ),
      dense: true,
      // contentPadding: EdgeInsets.zero,
      minLeadingWidth: 0,
      onTap: () {},
    );
    // Padding(
    //   padding: exerciseDisplayPadding,
    //   child: Text(
    //     style: exerciseTextStyle,
    //     widget.exercise,
    //   ),
    // );

    // print(widget.custom);

    return widget.custom
        ? Dismissible(
            background: Container(
              color: Colors.red,
              child: const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 6.0),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            direction: DismissDirection.endToStart,
            key: ValueKey<String>(widget.exercise),
            onDismissed: (DismissDirection direction) {
              setState(() {
                widget.remove!(widget.index);
              });
            },
            child: text,
          )
        : text;
  }
}

class ExerciseInput extends StatefulWidget {
  final VoidCallbackString submitPressed;
  final VoidCallback cancelPressed;
  final bool loading;

  const ExerciseInput({
    Key? key,
    required this.submitPressed,
    required this.cancelPressed,
    required this.loading,
  }) : super(key: key);

  @override
  ExerciseInputState createState() => ExerciseInputState();
}

class ExerciseInputState extends State<ExerciseInput> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    textEditingController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets buttonPadding = EdgeInsets.only(right: 4.0);
    const double buttonSize = 24;
    const double buttonSplashRadius = 20;
    // const double sidePadding = 12;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 4.0, 0.0),
      child:
          // Column(
          //   children: [
          // const Text(
          //   style: exerciseTextStyle,
          //   'New Exercise',
          // ),
          Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: TextFormField(
                    autofocus: true,
                    focusNode: focusNode,
                    controller: textEditingController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name.';
                      }

                      return null;
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(4.0),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!widget.loading)
            Row(
              children: [
                iconButton(
                  context: context,
                  icon: const Icon(Icons.close),
                  padding: buttonPadding,
                  onPressed: widget.cancelPressed,
                  size: buttonSize,
                  splashRadius: buttonSplashRadius,
                ),
                iconButton(
                  context: context,
                  icon: const Icon(Icons.check),
                  padding: buttonPadding,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      widget.submitPressed(textEditingController.text);
                    }
                  },
                  size: buttonSize,
                  splashRadius: buttonSplashRadius,
                ),
              ],
            ),
          if (widget.loading)
            loadingSpinner(
              size: 20,
              padding: const EdgeInsets.all(4.0),
            ),
        ],
      ),
      //   ],
      // ),
    );
  }
}
