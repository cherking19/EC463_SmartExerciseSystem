import 'package:flutter/material.dart';

hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}

makeProfilePic(String name, int colour){
  var colorlist = [Colors.pink,Colors.red,Colors.orange,Colors.amber,Colors.yellow,Colors.lime,
  Colors.lightGreen,Colors.green,Colors.teal,Colors.cyan,Colors.blue,Colors.indigo,Colors.purple,
  Colors.deepPurple,Colors.blueGrey,Colors.grey];
  var bubble = name[0].toUpperCase();
  return CircleAvatar(
    radius: 30,
    backgroundColor: colorlist[colour],
    child: Text
    (
      bubble,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 85,
      ),
    )
    ,
  );
}