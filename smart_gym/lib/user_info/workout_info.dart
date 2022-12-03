import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../workout_page/workout.dart';

const String routinesJsonKey = 'routines';

Future<Routines> loadRoutines() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = prefs.getString(routinesJsonKey) ?? "";
  Routines routines = Routines([]);
  if (routinesJson.isNotEmpty) {
    routines = Routines.fromJson(jsonDecode(routinesJson));
  }

  return routines;
}

Future<bool> saveRoutines(Routines routines) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String routinesJson = jsonEncode(routines.toJson());

  return await prefs.setString(routinesJsonKey, routinesJson);
}
