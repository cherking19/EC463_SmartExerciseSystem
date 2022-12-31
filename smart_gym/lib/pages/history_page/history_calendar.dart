import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/dialogs.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:tuple/tuple.dart';

class HistoryCalendar extends StatefulWidget {
  final List<Workout> workouts;
  final Function refresh;

  const HistoryCalendar({
    Key? key,
    required this.workouts,
    required this.refresh,
  }) : super(key: key);

  @override
  HistoryCalendarState createState() => HistoryCalendarState();
}

class HistoryCalendarState extends State<HistoryCalendar>
    with AutomaticKeepAliveClientMixin {
  List<Tuple2<int, int>> months = [];
  late ScrollController scrollController;

  void calculateMonths() {
    Workout newestWorkout = widget.workouts.first;
    Workout oldestWorkout = widget.workouts.last;
    Tuple2<int, int> newestDate = Tuple2<int, int>(
        newestWorkout.dateStarted!.month, newestWorkout.dateStarted!.year);
    Tuple2<int, int> oldestDate = Tuple2<int, int>(
        oldestWorkout.dateStarted!.month, oldestWorkout.dateStarted!.year);

    int month = oldestDate.item1;
    int year = oldestDate.item2;

    while (year <= newestDate.item2) {
      while (
          year == newestDate.item2 ? month <= newestDate.item1 : month <= 12) {
        months.add(Tuple2<int, int>(month, year));
        month++;
      }

      month = 1;
      year++;
    }

    // for (int i = 0; i < months.length; i++) {
    //   print(months[i]);
    // }
  }

  List<Workout> getMonthsWorkouts(int month, int year) {
    List<Workout> workouts = [];

    for (int i = 0; i < widget.workouts.length; i++) {
      if (widget.workouts[i].dateStarted!.year < year) {
        continue;
      } else if (widget.workouts[i].dateStarted!.year > year) {
        break;
      }

      if (widget.workouts[i].dateStarted!.month == month) {
        workouts.add(widget.workouts[i]);
      }
    }

    return workouts;
  }

  Future<void> refreshHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    widget.refresh();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.workouts.isNotEmpty) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.workouts.isEmpty) {
      return noRecordedWidgets(context, refreshHistory);
    }

    months = [];
    calculateMonths();
    scrollController = ScrollController();

    return CustomRefreshIndicator(
      trigger: IndicatorTrigger.trailingEdge,
      onRefresh: () {
        return refreshHistory();
      },
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        // padding: const EdgeInsets.all(16.0),
        itemCount: months.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: globalBoxDecoration,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 6.0),
                child: CalendarMonth(
                  month: months[index].item1,
                  year: months[index].item2,
                  workouts: getMonthsWorkouts(
                    months[index].item1,
                    months[index].item2,
                  ),
                  refresh: widget.refresh,
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
        return customRefreshIndicator(context, child, controller);
      },
    );
  }
}

class CalendarMonth extends StatelessWidget {
  final int month;
  final int year;
  final List<Workout> workouts;
  final Function refresh;
  List<int> days = [];

  CalendarMonth({
    Key? key,
    required this.month,
    required this.year,
    required this.workouts,
    required this.refresh,
  }) : super(key: key);

  void calculateDays() {
    int numDays = DateUtils.getDaysInMonth(year, month);

    for (int i = 0; i < numDays; i++) {
      int day = DateTime(year, month, i + 1).weekday + 1;

      if (day == 8) {
        day = 1;
      }

      days.add(day);
    }

    addEmptyDays();
  }

  void addEmptyDays() {
    int start = days.first;

    for (int i = 1; i < start; i++) {
      days.insert(0, -1);
    }

    int end = days.last;

    for (int i = end; i < 7; i++) {
      days.add(-1);
    }
  }

  List<Workout>? getDaysWorkouts(int date) {
    List<Workout>? daysWorkouts;

    int index =
        workouts.indexWhere((workout) => workout.dateStarted!.day == date);

    while (index >= 0 &&
        index < workouts.length &&
        workouts[index].dateStarted!.day == date) {
      daysWorkouts ??= [];

      daysWorkouts.add(workouts[index]);
      index++;
    }

    return daysWorkouts;
  }

  List<List<Widget>> generateCalendarWidgets(BuildContext context) {
    List<List<Widget>> month = [];
    List<Widget> week = [];

    for (int i = 0; i < days.length; i++) {
      int date = i - days.indexWhere((day) => day > 0) + 1;

      if (days[i] < 0) {
        week.add(const SizedBox.shrink());
      } else {
        List<Workout>? daysWorkouts = getDaysWorkouts(date);

        week.add(
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: daysWorkouts != null
                ? () {
                    if (daysWorkouts.length > 1) {
                      showMultipleWorkoutsDialog(
                        context,
                        daysWorkouts,
                        refresh,
                      );
                    } else {
                      openViewWorkout(
                        context,
                        daysWorkouts[0],
                        refresh,
                      );
                    }
                  }
                : null,
            child: Text(
              date.toString(),
            ),
          ),
        );
      }

      if (week.length == 7) {
        month.add(week);
        week = [];
      }
    }

    if (week.isNotEmpty) {
      month.add(week);
    }

    return month;
  }

  @override
  Widget build(BuildContext context) {
    calculateDays();
    List<List<Widget>> weeks = generateCalendarWidgets(context);

    return Column(
      children: [
        Text(
          DateFormat('${DateFormat.MONTH} ${DateFormat.YEAR}').format(
            DateTime(year, month),
          ),
          style: const TextStyle(
            // fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          children: List.generate(
            weeks.length,
            (i) => Padding(
              padding: const EdgeInsets.only(
                top: 4.0,
              ),
              child: Row(
                children: List.generate(
                  weeks[i].length,
                  (j) => Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: weeks[i][j],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
