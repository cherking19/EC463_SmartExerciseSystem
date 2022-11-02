class Exercise {
  String _name = '';
  List<int> _sets = [];

  Exercise() {
    _name = '';
    _sets = [];
  }
}

class WorkoutRoutine {
  String _name = '';
  List<Exercise> _exercises = [];

  WorkoutRoutine() {
    _name = '';
    _exercises = [];
  }

  int addExercise() {
    _exercises.add(Exercise());
    return _exercises.length - 1;
  }

  List<Exercise> getExercises() {
    return _exercises;
  }
}
