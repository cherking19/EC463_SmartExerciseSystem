// class Pair<T1, T2> {
//   final T1 a;
//   final T2 b;

//   Pair(
//     this.a,
//     this.b,
//   );
// }

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
