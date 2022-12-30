import 'package:flutter/material.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/workout_widgets/workout_widgets.dart';
// import 'package:smart_gym/pages/workout_page/track_workout/track_workout.dart';
import '../../workout_page/workout.dart';

class ViewHistoryRoute extends StatelessWidget {
  final Workout workout;

  const ViewHistoryRoute({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Completed Workout'),
      ),
      body: ViewHistory(
        workout: workout,
      ),
    );
  }
}

class ViewHistory extends StatefulWidget {
  final Workout workout;

  const ViewHistory({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  State<ViewHistory> createState() {
    return ViewHistoryState();
  }
}

class ViewHistoryState extends State<ViewHistory> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text(widget.workout.name),
        WorkoutWidget(
          type: WidgetType.history,
          workout: widget.workout,
        )
      ],
    );
  }
}
