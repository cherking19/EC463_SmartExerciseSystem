import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/set_widgets/set_widget.dart';
import 'package:smart_gym/utils/function_utils.dart';

ButtonStyle minimalButtonStyle({
  EdgeInsets? padding,
}) {
  return TextButton.styleFrom(
    minimumSize: Size.zero,
    padding: padding ?? EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

Widget iconButton({
  required Icon icon,
  required EdgeInsets padding,
  VoidCallback? onPressed,
  double? size,
  double? splashRadius,
}) {
  return Padding(
    padding: padding,
    child: SizedBox(
      height: size,
      width: size,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        iconSize: size,
        padding: const EdgeInsets.all(0.0),
        splashRadius: splashRadius,
      ),
    ),
  );
}

TextButton deleteButton(
    BuildContext context, bool enabled, VoidCallbackBool confirmationResult) {
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
