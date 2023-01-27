import 'package:flutter/material.dart';

const BoxDecoration globalBoxDecoration = BoxDecoration(
  color: globalContainerColor,
  borderRadius: BorderRadius.all(
    Radius.circular(globalBorderRadius),
  ),
);

const double globalBorderRadius = 10.0;
const Color globalContainerColor = Color.fromARGB(255, 220, 220, 220);

const TextStyle globalTitleTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

InputDecoration minimalInputDecoration({
  String? hint,
  TextStyle? errorStyle,
}) =>
    InputDecoration(
      contentPadding: const EdgeInsets.all(0.0),
      isDense: true,
      hintText: hint,
      errorStyle: errorStyle,
    );

const TextStyle minimalTextStyling = TextStyle(
  height: 0,
);

const double setCircleDiameter = 50;

ButtonStyle setButtonStyle() {
  return TextButton.styleFrom(
    backgroundColor: const Color.fromARGB(
      255,
      190,
      190,
      190,
    ),
    fixedSize: const Size(
      setCircleDiameter,
      setCircleDiameter,
    ),
    shape: const CircleBorder(),
  );
}
