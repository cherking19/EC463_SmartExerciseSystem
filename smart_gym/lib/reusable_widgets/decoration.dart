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

const InputDecoration minimalInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.all(0.0),
  isDense: true,
);
