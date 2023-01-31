import 'package:duration/duration.dart';
import 'package:flutter/material.dart';

const List<String> sundayWeekAbbr = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

// final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

enum NavigatorAction {
  cancel,
  edit,
  delete,
  finish,
  track,
}

class NavigatorResponse {
  bool success;
  NavigatorAction action;
  Object? data;

  NavigatorResponse(
    this.success,
    this.action,
    this.data,
  );
}

enum TimeFormat {
  digital, // like a digital clock 12:59:59
  word // in the format '5d 23h 16m 50s'
}

class DigitalTimeFormat {
  final bool showHours;
  final bool showMinutes;
  final bool showSeconds;

  DigitalTimeFormat(
    this.showHours,
    this.showMinutes,
    this.showSeconds,
  );
}

class DurationFormat {
  final TimeFormat formatType;
  final Object format;

  DurationFormat(
    this.formatType,
    this.format,
  );
}

String getFormattedDuration(
  Duration duration,
  DurationFormat durationFormat,
) {
  // return prettyDuration(duration)
  if (durationFormat.formatType == TimeFormat.digital) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    DigitalTimeFormat format = durationFormat.format as DigitalTimeFormat;

    return "${format.showHours ? '$twoDigitHours:' : ''}${format.showMinutes ? '$twoDigitMinutes:' : ''}${format.showSeconds ? twoDigitSeconds : ''}";
  } else if (durationFormat.formatType == TimeFormat.word) {
    DurationTersity tersity = durationFormat.format as DurationTersity;

    return prettyDuration(
      duration,
      abbreviated: true,
      tersity: tersity,
    );
  }

  return '';
}

const List<double> availablePlates = [45, 25, 10, 5, 2.5, 1, 0.5];

List<double> calculatePlates(double weight) {
  List<double> plates = [];

  weight -= 45;
  weight /= 2;

  for (double plate in availablePlates) {
    int num = weight ~/ plate;
    weight -= plate * num;

    for (int i = 0; i < num; i++) {
      plates.add(plate);
    }

    if (weight == 0) {
      return plates;
    }
  }

  return plates;
}
