import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_gym/Screens/signin.dart';
import 'package:smart_gym/services/exercise_service.dart';
import 'package:smart_gym/utils/color_utils.dart';
import 'package:smart_gym/utils/user_auth_provider.dart';
import 'pages/workout_page/workout_page.dart';
import 'Screens/ble_settings.dart';
import 'package:provider/provider.dart';
import 'package:smart_gym/services/TimerService.dart';
import 'package:smart_gym/utils/widget_utils.dart';
import 'pages/history_page/history_page.dart';
import 'pages/workout_page/workout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final TimerService setTimerService = TimerService();
  final TimerService workoutTimerService = TimerService();
  runApp(
    TimerServiceProvider(
      setService: setTimerService,
      workoutService: workoutTimerService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ExerciseService exerciseService = ExerciseService();

    return MultiProvider(
        providers: [
          Provider<AuthenticationProvider>(
            create: (_) => AuthenticationProvider(FirebaseAuth.instance),
          ),
          StreamProvider(
            create: (context) =>
                context.read<AuthenticationProvider>().authState,
            initialData: null,
          ),
          ChangeNotifierProvider(
            create: (context) => ExerciseService(),
          ),
        ],
        child: MaterialApp(
          title: 'Smart Gym',
          scaffoldMessengerKey: rootScaffoldMessengerKey,
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
            tabBarTheme: const TabBarTheme(),
          ),
          home: Authenticate(),
        ));
  }
}

class Authenticate extends StatelessWidget {
  const Authenticate({super.key});
  @override
  Widget build(BuildContext context) {
    //Instance to know the authentication state.
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const MyHomePage(title: 'Smart Gym');
    }
    return const SignInScreen();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

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
  Workout? currentWorkout;
  // TrackedWorkout? trackedWorkout;
  int _selectedPage = 0;
  List<Widget> bodyWidgets = [];
  PageController pageController = PageController(
    initialPage: 0,
  );

  void _onPageTapped(int index) {
    pageController.animateToPage(index,
        duration: const Duration(
          milliseconds: 200,
        ),
        curve: Curves.easeIn);
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  void initState() {
    super.initState();

    bodyWidgets = [
      WorkoutPage(
        workout: currentWorkout,
        // trackedWorkout: trackedWorkout,
      ),
      const HistoryPage(),
      // const SocialPage(),
      const SettingsPage(),
    ];
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
      body: PageView(
        controller: pageController,
        onPageChanged: (int index) {
          setState(() {
            _selectedPage = index;
          });
        },
        children: bodyWidgets,
      ),

      // bodyWidgets[_selectedPage],
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.chat),
          //   label: 'Social',
          // ),
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
          child: ListView(
            children: <Widget>[
              Text(
                'Hello! \n${FirebaseAuth.instance.currentUser!.displayName.toString()}',
                style: const TextStyle(fontSize: 18.0),
              ),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      child: makeProfilePic(
                          FirebaseAuth.instance.currentUser!.displayName
                              .toString(),
                          10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor),
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 10))
                        ],
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        )),
                  ],
                ),
              ),
              ElevatedButton(
                child: const Text("Bluetooth Settings"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FlutterBlueApp()));
                },
              ),
              ElevatedButton(
                child: const Text("Logout"),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInScreen()));
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
