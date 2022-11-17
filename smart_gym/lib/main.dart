import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_gym/Screens/signin.dart';
import 'dart:convert';
import 'workout.dart';
// import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: const SignInScreen(), //MyHomePage(title: 'Smart Gym'),//
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
    // return GestureDetector(
    //   onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    //   child:
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
      // ),
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
              TextButton(
                child: const Text('View Workouts'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ViewWorkoutRoute()),
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
  // final TextEditingController _setsRepsController = TextEditingController();
  bool _isExerciseErrorVisible = false;

  WorkoutRoutine routine = WorkoutRoutine();

  void showInvalidDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Missing Entries'),
        content: const Text('Please make sure all fields are filled'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void addExercise() {
    routine.addExercise();
    setState(() {
      _isExerciseErrorVisible = false;
    });
  }

  bool validateRoutine() {
    print(routine.toString());
    return routine.validateRoutine();
  }

  // bool validateExercises() {
  //   if (routine.getExercises().isEmpty || routine.anyEmptySets()) {
  //     setState(() {
  //       _isExerciseErrorVisible = true;
  //     });

  //     return false;
  //   }

  //   _isExerciseErrorVisible = false;

  //   return true;
  // }

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

  void addSet(int index) {
    setState(() {
      routine.addSet(index);
    });
  }

  void setWeightSameFlag(int index, bool value) {
    setState(() {
      routine.setWeightSameFlag(index, value);
    });
  }

  void setRepsSameFlag(int index, bool value) {
    setState(() {
      routine.setRepsSameFlag(index, value);
    });
  }

  void setRestSameFlag(int index, bool value) {
    setState(() {
      routine.setRestSameFlag(index, value);
    });
  }

  void setWeight(int exerciseIndex, int setIndex, int weight) {
    setState(() {
      routine.setWeight(exerciseIndex, setIndex, weight);
    });
  }

  void setReps(int exerciseIndex, int setIndex, int reps) {
    setState(() {
      routine.setReps(exerciseIndex, setIndex, reps);
    });
  }

  void setRepsSame(int index, int reps) {
    setState(() {
      routine.setRepsSame(index, reps);
    });
  }

  void setRest(int exerciseIndex, int setIndex, int rest) {
    setState(() {
      routine.setRest(exerciseIndex, setIndex, rest);
    });
  }

  void setWeightSame(int index, int weight) {
    setState(() {
      routine.setWeightSame(index, weight);
    });
  }

  void setRestSame(int index, int rest) {
    setState(() {
      routine.setRestSame(index, rest);
    });
  }

  void deleteSet(int exerciseIndex, int setIndex) {
    setState(() {
      routine.deleteSet(exerciseIndex, setIndex);
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _setsRepsController.addListener(() {

  //   })
  // }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Workout Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onChanged: (value) {
                routine.setName(value);
              },
            ),
          ),
          Flexible(
            child: Scrollbar(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: routine.getExercises().length,
                itemBuilder: (BuildContext context, int index) {
                  return ExerciseWidget(
                    index: index,
                    name: routine.getExercises()[index].getName(),
                    sets: routine.getSets(index),
                    onlyExercise: routine.getExercises().length == 1,
                    sameWeightFlag:
                        routine.getExercises()[index].getWeightSameFlag(),
                    sameRepsFlag:
                        routine.getExercises()[index].getRepsSameFlag(),
                    sameRestFlag:
                        routine.getExercises()[index].getRestSameFlag(),
                    updateName: updateExerciseName,
                    delete: deleteExercise,
                    addSet: addSet,
                    setWeight: setWeight,
                    setReps: setReps,
                    setRest: setRest,
                    setWeightSameFlag: setWeightSameFlag,
                    setRepsSameFlag: setRepsSameFlag,
                    setRestSameFlag: setRestSameFlag,
                    setWeightSame: setWeightSame,
                    setRepsSame: setRepsSame,
                    setRestSame: setRestSame,
                    deleteSet: deleteSet,
                  );
                },
              ),
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
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (validateRoutine()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating Workout')),
                  );
                  // String workout = jsonEncode(routine);
                  // print(workout);

                  // SharedPreferences prefs =
                  //     await SharedPreferences.getInstance();
                  // bool result = await prefs.setString('workout', workout);
                  // print(result);
                } else {
                  showInvalidDialog(context);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class ViewWorkoutRoute extends StatelessWidget {
  const ViewWorkoutRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Workouts'),
      ),
      body: const ViewWorkout(),
    );
  }
}

class ViewWorkout extends StatefulWidget {
  const ViewWorkout({super.key});

  @override
  ViewWorkoutState createState() {
    return ViewWorkoutState();
  }
}

class ViewWorkoutState extends State<ViewWorkout> {
  void loadWorkouts() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String p = prefs.getString('workout') ?? "";
    // Map userMap = jsonDecode(p);
    // var workout = WorkoutRoutine.fromJson(userMap);
  }

  @override
  Widget build(BuildContext context) {
    return Column();
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
            children: <Widget>[
              Text(
                'Hello ${FirebaseAuth.instance.currentUser!.displayName.toString()}',
                style: TextStyle(fontSize: 18.0),
              ),
              ElevatedButton(
                child: Text("Logout"),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInScreen()));
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
