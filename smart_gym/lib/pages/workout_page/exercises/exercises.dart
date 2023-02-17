import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_gym/main.dart';
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
  Map<String, CustomExerciseChoice> customExercises = HashMap();
  bool refreshing = false;
  bool adding = false;
  bool loading = false;

  void loadExercises() async {
    setState(() {
      refreshing = true;
    });

    customExercises = await loadCustomExercises(
      navigatorKey.currentContext!,
    );
    // appendDefault: false,

    Future.delayed(
      globalPseudoDelay,
      () {
        setState(() {
          refreshing = false;
        });
      },
    );
  }

  void getExercises(BuildContext context) {
    customExercises =
        Provider.of<ExerciseService>(context, listen: false).customExercises;
  }

  void startAddExercise() {
    setState(() {
      adding = true;
    });
  }

  void addExercise(
    BuildContext context, {
    required String name,
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
  }) async {
    await saveCustomExercise(
      context,
      newExercise: name,
    )
        ? onSuccess.call()
        : onFailure.call();
  }

  void cancelAddExercise() {
    setState(() {
      adding = false;
    });
  }

  void removeExercise(String uuid, BuildContext context) {
    Future result = deleteCustomExercise(
      context,
      uuid: uuid,
    );

    result.then((value) {
      if (value as bool) {
        ScaffoldMessenger.of(navigatorKey.currentContext!)
            .showSnackBar(createSnackBar(
          title: 'Delete Exercise Success',
          color: successColor,
        ));
      } else {
        ScaffoldMessenger.of(navigatorKey.currentContext!)
            .showSnackBar(createSnackBar(
          title: 'Delete Exercise Failed',
          color: failureColor,
        ));

        getExercises(context);
      }
    });

    setState(() {
      customExercises.remove(uuid);
    });
  }

  @override
  void initState() {
    super.initState();

    loadExercises();
  }

  @override
  Widget build(BuildContext context) {
    void onRenameSuccess() {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        createSnackBar(
          title: 'Rename Exercise Success',
          color: successColor,
        ),
      );

      if (context.mounted) {
        setState(() {
          getExercises(context);
        });
      }
    }

    void onRenameFailure() {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        createSnackBar(
          title: 'Exercise Exists Already',
          color: failureColor,
        ),
      );
    }

    // submit a new exercise to be added or updated
    void submitExercise(String? uuid, String name) async {
      setState(() {
        loading = true;
      });

      Future.delayed(globalPseudoDelay, () {
        addExercise(
          context,
          name: name,
          onSuccess: () {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              createSnackBar(
                title: 'Create Exercise Success',
                color: successColor,
              ),
            );

            if (context.mounted) {
              getExercises(context);
              setState(() {
                loading = false;
                adding = false;
              });
            }
          },
          onFailure: () {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              createSnackBar(
                title: 'Exercise Exists Already',
                color: failureColor,
              ),
            );
            if (context.mounted) {
              setState(() {
                loading = false;
                adding = false;
              });
            }
          },
        );
      });
    }

    Widget exerciseListTile({
      required String tileTitle,
      required Map<String, String> exercises,
      required bool custom,
    }) {
      List<MapEntry<String, String>> exerciseEntries =
          exercises.entries.toList();

      return ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          tileTitle,
          style: const TextStyle(
            fontSize: exerciseHeaderFontSize,
            fontWeight: exerciseListHeaderFontWeight,
          ),
        ),
        onExpansionChanged: (value) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  exerciseEntries.length,
                  (int index) {
                    return ExerciseDisplay(
                      exercise: exerciseEntries[index].value,
                      uuid: exerciseEntries[index].key,
                      custom: custom,
                      index: index,
                      remove: removeExercise,
                      onRenameSuccess: onRenameSuccess,
                      onRenameFailure: onRenameFailure,
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
                    exercises: ExerciseService.defaultExercises,
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
                      exercises: customExercises.map(
                        (key, value) => MapEntry<String, String>(
                          key,
                          value.name,
                        ),
                      ),
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
