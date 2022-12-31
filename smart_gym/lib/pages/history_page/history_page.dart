import 'package:flutter/material.dart';
import 'package:smart_gym/pages/history_page/history_calendar.dart';
import 'package:smart_gym/pages/history_page/history_list.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import '../workout_page/workout.dart';

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

    // for (int i = 0; i < finishedWorkouts.length; i++) {
    //   print(finishedWorkouts[i].uuid);
    // }
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
              HistoryList(
                workouts: finishedWorkouts,
                refresh: loadHistory,
              ),
              HistoryCalendar(
                workouts: finishedWorkouts,
                refresh: loadHistory,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
