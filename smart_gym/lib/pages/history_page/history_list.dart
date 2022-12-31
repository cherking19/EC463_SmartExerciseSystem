import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';

class HistoryList extends StatefulWidget {
  final List<Workout> workouts;
  final Function refresh;

  const HistoryList({
    Key? key,
    required this.workouts,
    required this.refresh,
  }) : super(key: key);

  @override
  HistoryListState createState() {
    return HistoryListState();
  }
}

class HistoryListState extends State<HistoryList>
    with AutomaticKeepAliveClientMixin {
  List<Widget> generateLabel(Workout workout) {
    List<Widget> widgets = [
      Row(
        children: [
          Text(workout.name),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text((DateFormat.yMMMEd().format(workout.dateStarted!))),
            ),
          )
        ],
      ),
      const Divider(
        color: Color.fromARGB(255, 0, 0, 0),
        thickness: 1,
      ),
    ];

    for (int i = 0; i < workout.exercises.length; i++) {
      if (i > 2) {
        widgets.add(const Text('...'));
        break;
      }

      widgets.add(Text(workout.exercises[i].name));
    }

    return widgets;
  }

  Future<void> refreshHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    widget.refresh();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.workouts.isEmpty) {
      return noRecordedWidgets(context, refreshHistory);
    }

    return Scrollbar(
      child: CustomRefreshIndicator(
        trigger: IndicatorTrigger.leadingEdge,
        onRefresh: () {
          return refreshHistory();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: widget.workouts.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
              child: ElevatedButton(
                onPressed: () {
                  openViewWorkout(
                    context,
                    widget.workouts[index],
                    refreshHistory,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: generateLabel(widget.workouts[index]),
                  ),
                ),
              ),
            );
          },
        ),
        builder: (
          BuildContext context,
          Widget child,
          IndicatorController controller,
        ) {
          return customRefreshIndicatorLeading(context, child, controller);
        },
      ),
    );
  }
}
