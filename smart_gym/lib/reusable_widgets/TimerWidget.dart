import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/widget_utils.dart';

class TimerWidget extends StatefulWidget {
  int seconds;

  TimerWidget({
    Key? key,
    required this.seconds,
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
      timer = Timer(
        const Duration(seconds: 1),
        countDown,
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    print('dipose');
    if (timer != null) {
      print('cancel');
      timer!.cancel();
    }

    super.dispose();
  }

  // @override
  // void didUpdateWidget(TimerWidget oldWidget) {
  //   if (widget.seconds > 0) {
  //     if (timer != null) {
  //       timer!.cancel();
  //     }

  //     timer = Timer(
  //       const Duration(seconds: 1),
  //       countDown,
  //     );
  //   }

  //   super.didUpdateWidget(oldWidget);
  // }

  void countDown() {
    setState(() {
      widget.seconds -= 1;
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
    print('build');
    return Text(getFormattedDuration(Duration(seconds: widget.seconds)));
  }
}
