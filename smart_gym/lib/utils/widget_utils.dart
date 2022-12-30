const List<String> sundayWeekAbbr = ['S', 'M', 'T', 'W', 'TH', 'F', 'S'];

const String cancelAction = 'Cancel';
const String editAction = 'Edit';
const String deleteAction = 'Delete';
const String finishAction = 'Finish';
const String trackAction = 'Track';

class NavigatorResponse {
  bool success;
  String action;
  Object? data;

  NavigatorResponse(
    this.success,
    this.action,
    this.data,
  );
}

String getFormattedDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

  return "$twoDigitMinutes:$twoDigitSeconds";
}

const List<double> availablePlates = [45, 25, 10, 5, 2.5];

List<double> calculatePlates(double weight) {
  // print(weight);
  // print('hi');
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
