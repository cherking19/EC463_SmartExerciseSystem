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
  final bool hours;
  final bool minutes;
  final bool seconds;
  final bool twoDigit;

  DigitalTimeFormat({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.twoDigit,
  });
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
  if (durationFormat.formatType == TimeFormat.digital) {
    DigitalTimeFormat format = durationFormat.format as DigitalTimeFormat;

    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String hours = format.twoDigit
        ? twoDigits(duration.inHours)
        : duration.inHours.toString();
    String minutes = format.hours || format.twoDigit
        ? twoDigits(duration.inMinutes.remainder(60))
        : duration.inMinutes.toString();
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "${format.hours ? '$hours:' : ''}${format.minutes ? '$minutes:' : ''}${format.seconds ? seconds : ''}";
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
