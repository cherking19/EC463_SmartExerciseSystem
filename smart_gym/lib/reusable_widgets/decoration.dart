import 'package:flutter/material.dart';

const BoxDecoration globalBoxDecoration = BoxDecoration(
  color: globalContainerColor,
  borderRadius: BorderRadius.all(
    Radius.circular(globalBorderRadius),
  ),
);

const double globalBorderRadius = 10.0;

// the RGB scaling for how grey the decoration boxes are (ex: the boxes that contain the exercise widgets)
const int globalContainerColorScale = 220;
// the actual decoration box color defined
const Color globalContainerColor = Color.fromARGB(
  255,
  globalContainerColorScale,
  globalContainerColorScale,
  globalContainerColorScale,
);

// the RGB scaling for how grey colored widgets inside the decoration boxes are (ex: the set widgets and buttons within the exercise widget box)
// should be a function of the decoration box color scale and be darker
const int globalContainerWidgetColorScale = globalContainerColorScale - 30;
// the actual decoration box widgets color defined
const Color globalContainerWidgetColor = Color.fromARGB(
  255,
  globalContainerWidgetColorScale,
  globalContainerWidgetColorScale,
  globalContainerWidgetColorScale,
);

const int globalContainerWidgetSplashColorScale =
    globalContainerWidgetColorScale - 20;
const Color globalContainerWidgetSplashColor = Color.fromARGB(
    255,
    globalContainerWidgetSplashColorScale,
    globalContainerWidgetSplashColorScale,
    globalContainerWidgetSplashColorScale);

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
    backgroundColor: globalContainerWidgetColor,
    fixedSize: const Size(
      setCircleDiameter,
      setCircleDiameter,
    ),
    shape: const CircleBorder(),
  );
}
