import 'package:flutter/material.dart';
import 'package:smart_gym/pages/history_page/view_history/view_history.dart';
import 'package:smart_gym/user_info/workout_info.dart';
import '../workout_page/workout.dart';
import 'package:intl/intl.dart';

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

    // print('history');
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
              Tab(text: 'Calendar'),
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
              const Text('Calendar'),
            ],
          ),
        ),
      ],
    );
  }
}

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

class HistoryListState extends State<HistoryList> {
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

  void openWorkout(Workout workout) {
    Future result = Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ViewHistoryRoute(workout: workout);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: RefreshIndicator(
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
                    openWorkout(widget.workouts[index]);
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
            }),
      ),
    );
  }
}
