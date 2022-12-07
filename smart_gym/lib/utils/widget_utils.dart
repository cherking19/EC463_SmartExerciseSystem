// class Pair<T1, T2> {
//   final T1 a;
//   final T2 b;

//   Pair(
//     this.a,
//     this.b,
//   );
// }

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
