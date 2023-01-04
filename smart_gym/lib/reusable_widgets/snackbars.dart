import 'package:flutter/material.dart';

SnackBar createSuccessSnackBar(BuildContext context) {
  return SnackBar(
    content: const Text('Create Success'),
    backgroundColor: Colors.green,
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar;
      },
    ),
  );
}

SnackBar createFailedSnackBar(BuildContext context) {
  return SnackBar(
    content: const Text('Create Failed'),
    backgroundColor: Colors.red,
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar;
      },
    ),
  );
}

SnackBar editSuccessSnackBar(BuildContext context) {
  return SnackBar(
    content: const Text('Edit Success'),
    backgroundColor: Colors.green,
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar;
      },
    ),
  );
}

SnackBar editFailedSnackBar(BuildContext context) {
  return SnackBar(
    content: const Text('Edit Failed'),
    backgroundColor: Colors.red,
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar;
      },
    ),
  );
}

SnackBar deleteSuccessSnackBar(BuildContext context) {
  return SnackBar(
    content: const Text('Delete Success'),
    backgroundColor: Colors.green,
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar;
      },
    ),
  );
}

SnackBar deleteFailedSnackBar(BuildContext context) {
  return SnackBar(
    content: const Text('Delete Failed'),
    backgroundColor: Colors.red,
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar;
      },
    ),
  );
}

SnackBar workoutInProgressSnackBar(BuildContext context) {
  return SnackBar(
    content: const Text('There is already a workout in progress'),
    backgroundColor: Colors.red,
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar;
      },
    ),
  );
}
