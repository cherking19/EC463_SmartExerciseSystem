import 'package:flutter/material.dart';
import 'package:smart_gym/pages/history_page/history_calendar.dart';
import 'package:smart_gym/pages/history_page/history_list.dart';
import 'package:smart_gym/reusable_widgets/refresh_widgets.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import '../workout_page/workout.dart';

enum HistoryPageTabType {
  list,
  calendar,
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() {
    return HistoryPageState();
  }
}

class HistoryPageState extends State<HistoryPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  List<Workout> finishedWorkouts = [];
  late TabController _tabController;
  bool recentFirst = true;

  void loadHistory() async {
    finishedWorkouts = await loadFinishedWorkouts();

    if (recentFirst) {
      finishedWorkouts = finishedWorkouts.reversed.toList();
    }

    // clearFinishedWorkouts();

    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    loadHistory();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        ColoredBox(
          color: Colors.grey,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                text: 'List',
              ),
              Tab(
                text: 'Calendar',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              HistoryPageTab(
                type: HistoryPageTabType.list,
                workouts: finishedWorkouts,
                refresh: () async {
                  loadHistory();
                },
              ),
              HistoryPageTab(
                type: HistoryPageTabType.calendar,
                workouts: finishedWorkouts,
                refresh: () async {
                  loadHistory();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HistoryPageTab extends StatefulWidget {
  final HistoryPageTabType type;
  final List<Workout> workouts;
  final Function refresh;

  const HistoryPageTab({
    Key? key,
    required this.type,
    required this.workouts,
    required this.refresh,
  }) : super(key: key);

  @override
  HistoryPageTabState createState() {
    return HistoryPageTabState();
  }
}

class HistoryPageTabState extends State<HistoryPageTab> {
  bool orderedRefresh = false;

  void orderRefresh() {
    setState(() {
      orderedRefresh = true;
    });

    Future.delayed(
      globalPseudoDelay,
      () async {
        await widget.refresh();

        setState(() {
          orderedRefresh = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return orderedRefresh
        ? const Center(
            child: loadingSpinner,
          )
        : widget.type == HistoryPageTabType.list
            ? HistoryList(
                workouts: widget.workouts,
                refresh: widget.refresh,
                orderedRefresh: orderRefresh,
              )
            : HistoryCalendar(
                workouts: widget.workouts,
                refresh: widget.refresh,
                orderRefresh: orderRefresh,
              );
  }
}
