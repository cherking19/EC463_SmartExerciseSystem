import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
// import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/utils/function_utils.dart';

TextButton deleteButton(
    BuildContext context, VoidBoolCallback confirmationResult) {
  void click() {
    Future result = showConfirmationDialog(
      context,
      confirmDeleteDialogTitle,
      confirmDeleteDialogMessage,
    );

    result.then(
      (value) {
        confirmationResult(value);
      },
    );
  }

  return TextButton(
    onPressed: () {
      click();
    },
    child: const Text(
      'Delete',
      style: TextStyle(
        color: Color.fromARGB(255, 255, 0, 0),
      ),
    ),
  );
}
