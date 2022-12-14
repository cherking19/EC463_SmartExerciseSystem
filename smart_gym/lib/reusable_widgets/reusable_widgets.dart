import 'dart:async';
import 'package:flutter/material.dart';

const String confirmCancelDialogTitle = 'Confirm Cancel';
const String confirmCancelDialogMessage = 'Are you sure you want to cancel?';

const String confirmDeleteDialogTitle = 'Confirm Delete';
const String confirmDeleteDialogMessage = 'Are you sure you want to delete?';

const String confirmFinishDialogTitle = 'Confirm Finish';
const String confirmFinishDialogMessage =
    'The workout is not complete. Are you sure you want to finish?';

const BoxDecoration globalBoxDecoration = BoxDecoration(
  color: globalContainerColor,
  borderRadius: BorderRadius.all(
    Radius.circular(globalBorderRadius),
  ),
);

const double globalBorderRadius = 10.0;
const Color globalContainerColor = Color.fromARGB(255, 220, 220, 220);

const Duration globalAnimationSpeed = Duration(milliseconds: 500);

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    color: Colors.white,
  );
}

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      labelText: text,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        child: Text(
          isLogin ? 'Log In' : 'Sign Up',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        )),
  );
}

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

Future<bool> showConfirmationDialog(
    BuildContext context, String title, String message) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('No'),
          ),
        ],
      );
    },
  );

  if (result != null) {
    return result;
  } else {
    return false;
  }
}
