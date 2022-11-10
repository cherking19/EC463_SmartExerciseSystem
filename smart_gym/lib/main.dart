import 'package:flutter/material.dart';
import 'workout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Gym',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Smart Gym'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPage = 0;
  // static List<String> pageTitles = ['Workout', 'History', 'Social', 'Settings'];
  // String pageTitle = pageTitles[0];
  List<Widget> bodyWidgets = [
    const WorkoutPage(),
    const HistoryPage(),
    const SocialPage(),
    const SettingsPage(),
  ];

  void _onPageTapped(int index) {
    setState(() {
      _selectedPage = index;
      // pageTitle = pageTitles[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: bodyWidgets[_selectedPage],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedPage,
        selectedItemColor: Colors.blue,
        onTap: _onPageTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          alignment: Alignment.topLeft,
          // color: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Workout',
                style: TextStyle(fontSize: 18.0),
              ),
              TextButton(
                child: const Text('Create Workout'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateWorkoutRoute()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateWorkoutRoute extends StatelessWidget {
  const CreateWorkoutRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
      ),
      body: const CreateWorkoutForm(),
    );
  }
}

class CreateWorkoutForm extends StatefulWidget {
  const CreateWorkoutForm({super.key});

  @override
  CreateWorkoutFormState createState() {
    return CreateWorkoutFormState();
  }
}

class CreateWorkoutFormState extends State<CreateWorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isExerciseErrorVisible = false;

  WorkoutRoutine routine = WorkoutRoutine();

  void addExercise() {
    int index = routine.addExercise();
    setState(() {
      _isExerciseErrorVisible = false;
    });
  }

  bool validateExercises() {
    if (routine.getExercises().isEmpty) {
      setState(() {
        _isExerciseErrorVisible = true;
      });

      return false;
    }

    _isExerciseErrorVisible = false;

    return true;
  }

  void updateExerciseName(int index, String name) {
    setState(() {
      routine.updateExerciseName(index, name);
    });
  }

  void deleteExercise(int index) {
    setState(() {
      routine.deleteExercise(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Workout Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: routine.getExercises().length,
                itemBuilder: (BuildContext context, int index) {
                  // print('build ' + routine.getExercises()[index].getName());

                  return ExerciseWidget(
                    index: index,
                    name: routine.getExercises()[index].getName(),
                    updateName: updateExerciseName,
                    delete: deleteExercise,
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
              child: Text('Add Exercise'),
            ),
            Visibility(
              visible: _isExerciseErrorVisible,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                child: Text(
                  'Please add at least 1 exercise',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: addExercise,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &
                        validateExercises()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Creating Workout')),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          alignment: Alignment.topLeft,
          // color: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const <Widget>[
              Text(
                'History',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SocialPage extends StatelessWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          alignment: Alignment.topLeft,
          // color: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const <Widget>[
              Text(
                'Social',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          alignment: Alignment.topLeft,
          // color: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const <Widget>[
              Text(
                'Settings',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
