import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_gym/Screens/signin.dart';
import 'package:smart_gym/utils/color_utils.dart';
import 'package:flutter/material.dart';
import '../reusable_widgets/reusable_widgets.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Forgot Password",
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("2196F3"),
          hexStringToColor("2196F3")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * .2, 20, 0),
            child: Column(children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              reusableTextField("Enter Email", Icons.verified_user, false,
                  _emailTextController),
              const SizedBox(
                height: 20,
              ),
              forgotPasswordButton(context, () {
                FirebaseAuth.instance
                    .sendPasswordResetEmail(email: _emailTextController.text)
                    .then((value) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const SignInScreen()));
                }).onError((error, stackTrace) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Error"),
                      content: Text(error.toString()),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            child: const Text("Close"),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              }),
            ]),
          ),
        ),
      ),
    );
  }
}