import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/utils/function_utils.dart';

ButtonStyle minimalButtonStyle() {
  return TextButton.styleFrom(
    minimumSize: Size.zero,
    padding: EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

TextButton deleteButton(
    BuildContext context, bool enabled, VoidBoolCallback confirmationResult) {
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

  // print('enabled: $enabled');

  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: Colors.red,
    ),
    onPressed: enabled
        ? () {
            click();
          }
        : null,
    child: const Text(
      'Delete',
    ),
  );
}
