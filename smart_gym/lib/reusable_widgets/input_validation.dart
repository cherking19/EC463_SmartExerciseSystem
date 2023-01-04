import 'package:flutter/services.dart';

List<TextInputFormatter> positiveInteger = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
  FilteringTextInputFormatter.deny(
    RegExp(r'^0+'),
  )
];
