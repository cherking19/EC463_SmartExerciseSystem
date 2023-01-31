import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/utils/function_utils.dart';

ButtonStyle minimalButtonStyle({
  required BuildContext context,
  EdgeInsets? padding,
  Color? textColorOverride,
}) {
  return TextButton.styleFrom(
    foregroundColor: textColorOverride ?? Theme.of(context).primaryColor,
    minimumSize: Size.zero,
    padding: padding ?? EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

Widget iconButton({
  required Icon icon,
  required EdgeInsets padding,
  required BuildContext context,
  VoidCallback? onPressed,
  double? size,
  double? splashRadius,
  Color? splashColor,
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
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith(
              (states) => splashColor ?? Theme.of(context).splashColor),
        ),
      ),
    ),
  );
}

Widget stackIconButton({
  required BuildContext context,
  required double radius,
  required IconData? icon,
  VoidCallback? onPressed,
  Color? color,
  Color? splashColor,
}) {
  return Material(
    borderRadius: BorderRadius.circular(radius),
    color: color,
    child: InkWell(
      borderRadius: BorderRadius.circular(radius),
      radius: radius,
      onTap: onPressed,
      splashColor: splashColor ?? Theme.of(context).splashColor,
      child: SizedBox(
        width: radius,
        height: radius,
        child: Icon(
          icon,
          size: radius,
        ),
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
