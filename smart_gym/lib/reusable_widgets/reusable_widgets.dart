import 'dart:async';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:smart_gym/pages/history_page/view_history/view_history.dart';
import 'package:smart_gym/pages/workout_page/workout.dart';
import 'package:smart_gym/reusable_widgets/refresh_widgets.dart';
// import 'package:smart_gym/utils/function_utils.dart';
import 'package:smart_gym/utils/widget_utils.dart';

enum WidgetType {
  none,
  create,
  view,
  track,
  history,
}

const Duration globalAnimationSpeed = Duration(
  milliseconds: 500,
);
const Duration globalPseudoDelay = Duration(
  milliseconds: 500,
);

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
      ),
    ),
  );
}

void openViewWorkout(
  BuildContext context,
  Workout workout,
  Function refresh,
) {
  Future result = Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return ViewHistoryRoute(workout: workout);
      },
    ),
  );

  result.then(
    (value) {
      if (value != null) {
        NavigatorResponse response = value as NavigatorResponse;

        if (response.success) {
          if (response.action == NavigatorAction.delete ||
              response.action == NavigatorAction.edit) {
            refresh();
          }
        }

        // responseCallback(response);
      }
    },
  );
}

Widget noRecordedWidgets(BuildContext context, Function refresh) {
  return CustomRefreshIndicator(
    onRefresh: () {
      return refresh();
    },
    child: ListView(
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 100),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'No Recorded Workouts',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ),
      ],
    ),
    builder: (
      BuildContext context,
      Widget child,
      IndicatorController controller,
    ) {
      return customRefreshIndicatorLeading(context, child, controller);
    },
  );
}
