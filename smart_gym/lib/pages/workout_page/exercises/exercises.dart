import 'package:flutter/material.dart';
import 'package:smart_gym/pages/workout_page/exercises/exercise_display.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/colors.dart';
import 'package:smart_gym/reusable_widgets/refresh_widgets.dart';
import 'package:smart_gym/reusable_widgets/reusable_widgets.dart';
import 'package:smart_gym/reusable_widgets/snackbars.dart';
import 'package:smart_gym/services/exercise_service.dart';
import 'package:smart_gym/user_info/workout_info.dart';

const double exerciseListFontSize = 16;
const double exerciseHeaderFontSize = 20;
const FontWeight exerciseListHeaderFontWeight = FontWeight.bold;

class ViewExercisesRoute extends StatelessWidget {
  const ViewExercisesRoute({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('View Exercises'),
        ),
        body: const ViewExercises(),
      ),
    );
  }
}

class ViewExercises extends StatefulWidget {
  const ViewExercises({
    Key? key,
  }) : super(key: key);

  @override
  ViewExercisesState createState() => ViewExercisesState();
}

class ViewExercisesState extends State<ViewExercises> {
  List<String> customExercises = [];
  bool refreshing = false;
  bool adding = false;
  bool loading = false;

  void loadExercises() async {
    setState(() {
      refreshing = true;
    });

    Future.delayed(globalPseudoDelay, () async {
      customExercises = await loadCustomExercises(false);

      setState(() {
        refreshing = false;
      });
    });
  }

  void startAddExercise() {
    setState(() {
      adding = true;
    });
  }

  void addExercise({
    required String name,
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
  }) async {
    await saveCustomExercise(name) ? onSuccess.call() : onFailure.call();
  }

  void cancelAddExercise() {
    setState(() {
      adding = false;
    });
  }

  void removeExercise(int index) {
    deleteCustomExercise(customExercises[index]);

    setState(() {
      customExercises.removeAt(index);
    });
  }

  @override
  void initState() {
    loadExercises();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void submitExercise(String name) async {
      setState(() {
        loading = true;
      });

      Future.delayed(globalPseudoDelay, () {
        addExercise(
          name: name,
          onSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              createSnackBar(
                title: 'Create Exercise Success',
                color: successColor,
              ),
            );

            setState(() {
              loading = false;
              adding = false;
              customExercises.add(name);
            });
          },
          onFailure: () {
            ScaffoldMessenger.of(context).showSnackBar(
              createSnackBar(
                title: 'Exercise Exists Already',
                color: failureColor,
              ),
            );
            setState(() {
              loading = false;
              adding = false;
            });
          },
        );
      });
    }

    Widget exerciseListTile({
      required String tileTitle,
      required List<String> exercises,
      required bool custom,
    }) {
      return ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          tileTitle,
          style: const TextStyle(
            fontSize: exerciseHeaderFontSize,
            fontWeight: exerciseListHeaderFontWeight,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  exercises.length,
                  (int index) {
                    return ExerciseDisplay(
                      exercise: exercises[index],
                      custom: custom,
                      index: index,
                      remove: removeExercise,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  exerciseListTile(
                    tileTitle: 'Default Exercises',
                    exercises: ExerciseService.defaultExerciseNames,
                    custom: false,
                  ),
                  if (refreshing)
                    Padding(
                      padding: const EdgeInsets.all(42.0),
                      child: loadingSpinner(
                        size: defaultLoadingSpinnerSize,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  if (!refreshing)
                    exerciseListTile(
                      tileTitle: 'Custom Exercises',
                      exercises: customExercises,
                      custom: true,
                    ),
                ],
              ),
            ),
          ),
          if (!refreshing)
            if (adding)
              ExerciseInput(
                submitPressed: submitExercise,
                cancelPressed: cancelAddExercise,
                loading: loading,
              ),
          if (!refreshing)
            IconButton(
              onPressed: adding ? null : startAddExercise,
              padding: EdgeInsets.zero,
              splashRadius: 24,
              icon: const Icon(Icons.add),
            ),
        ],
      ),
    );
  }
}
