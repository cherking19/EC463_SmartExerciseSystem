import 'package:flutter/material.dart';
import 'package:smart_gym/main.dart';
import 'package:smart_gym/pages/workout_page/exercises/exercises.dart';
import 'package:smart_gym/reusable_widgets/buttons.dart';
import 'package:smart_gym/reusable_widgets/refresh_widgets.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/user_info/workout_info.dart';

const EdgeInsets exerciseDisplayPadding =
    EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0);
const TextStyle exerciseTextStyle = TextStyle(
  fontSize: exerciseListFontSize,
);

class ExerciseDisplay extends StatefulWidget {
  final String exercise;
  final String uuid;
  final bool custom;
  final int? index;
  final Function? remove;
  final VoidCallback onRenameSuccess;
  final VoidCallback onRenameFailure;

  const ExerciseDisplay({
    Key? key,
    required this.exercise,
    required this.uuid,
    required this.custom,
    this.index,
    this.remove,
    required this.onRenameSuccess,
    required this.onRenameFailure,
  }) : super(key: key);

  @override
  ExerciseDisplayState createState() => ExerciseDisplayState();
}

class ExerciseDisplayState extends State<ExerciseDisplay> {
  bool editable = false;
  bool loading = false;

  void renameExercise({
    required String uuid,
    required String newName,
  }) async {
    Future.delayed(globalPseudoDelay, () async {
      await renameCustomExercise(navigatorKey.currentContext!,
              uuid: uuid, newName: newName)
          ? widget.onRenameSuccess.call()
          : widget.onRenameFailure.call();

      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget text = ListTile(
      title: widget.custom && editable
          ? ExerciseInput(
              submitPressed: (String? uuid, String name) async {
                FocusScope.of(context).requestFocus(FocusNode());
                renameExercise(
                  uuid: uuid!,
                  newName: name,
                );
                setState(() {
                  loading = true;
                });
              },
              cancelPressed: () {
                setState(() {
                  editable = false;
                });
              },
              uuid: widget.uuid,
              loading: false)
          : Text(
              widget.exercise,
              style: exerciseTextStyle,
            ),
      dense: true,
      minLeadingWidth: 0,
      // onTap: () {},
      trailing: loading
          ? loadingSpinner(
              padding: EdgeInsets.zero, size: defaultLoadingSpinnerSize)
          : widget.custom && !editable
              ? IconButton(
                  icon: const Icon(Icons.create_outlined),
                  onPressed: () {
                    setState(() {
                      editable = true;
                    });
                  },
                )
              : null,
    );

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
              // setState(() {
              widget.remove!(widget.uuid, context);
              // });
            },
            child: text,
          )
        : text;
  }
}

class ExerciseInput extends StatefulWidget {
  final Function(String? uuid, String name) submitPressed;
  final VoidCallback cancelPressed;
  final bool loading;
  final String? uuid;

  const ExerciseInput({
    Key? key,
    required this.submitPressed,
    required this.cancelPressed,
    required this.loading,
    this.uuid,
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
    focusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        widget.cancelPressed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets buttonPadding = EdgeInsets.only(right: 4.0);
    const double buttonSize = 24;
    const double buttonSplashRadius = 20;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 4.0, 0.0),
      child: Row(
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
                    textEditingController.text =
                        textEditingController.text.trim();

                    if (formKey.currentState!.validate()) {
                      widget.submitPressed(
                        widget.uuid,
                        textEditingController.text,
                      );
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
    );
  }
}
