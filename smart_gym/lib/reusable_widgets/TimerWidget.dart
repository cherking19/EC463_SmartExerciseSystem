import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/widget_utils.dart';

class TimerWidget extends StatefulWidget {
  int seconds;
  // int globalRest;

  TimerWidget({
    Key? key,
    required this.seconds,
    // required this.globalRest,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() {
    return TimerWidgetState();
  }
}

class TimerWidgetState extends State<TimerWidget> {
  Timer? timer;

  @override
  void initState() {
    if (widget.seconds > 0) {
      // widget.globalRest = widget.seconds;
      timer = Timer(
        const Duration(seconds: 1),
        countDown,
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }

    super.dispose();
  }

  void countDown() {
    setState(() {
      widget.seconds -= 1;
      // widget.globalRest = widget.seconds;
    });

    if (widget.seconds > 0) {
      timer = Timer(
        const Duration(seconds: 1),
        countDown,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      getFormattedDuration(
        Duration(seconds: widget.seconds),
      ),
    );
  }
}
