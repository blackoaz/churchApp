import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../blocs/authorizationBloc.dart';

class LoginUser extends StatefulWidget {
  const LoginUser({super.key});

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  late String _userName, _password;

  @override
  Widget build(BuildContext context) {
    final AuthorizationBloc authorizationBloc =
    Provider.of<AuthorizationBloc>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sign In",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Form(
              key: _formkey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Username",
                      filled: true,
                      fillColor: Colors.black,
                      hintStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSaved: (inputText)=>{
                      _userName = inputText!.trim()
                    },
                    validator: (inputText) => null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.black,
                      hintStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSaved: (inputText)=>{
                    _password = inputText!.trim()
                  },
                    validator: (inputText) => null,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      loginUser(context,authorizationBloc);
                      // Navigator.of(context).pushReplacementNamed('/HomeScreen');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/ForgotPassword');
                    },
                    child: const Text(
                      "Forgot Password? Reset",
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/SignUp');
                    },
                    child: const Text(
                      "Don't have an account? SignUp",
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void loginUser(BuildContext context, AuthorizationBloc authorizationBloc) async{
    final formState = _formkey.currentState;
    if (formState!.validate()) {
      formState.save(); // save values // onSaved

      if (_userName.isEmpty) {
        alertDialogShowError(context, "Username is Empty");
        return;
      } else if (_password.isEmpty) {
        alertDialogShowError(context, "Password is Empty");
        return;
      }
      alertDialogPleaseWait(context);
      authorizationBloc.setLoginDetails(_userName, _password);
      Map<String, dynamic> results =
          await authorizationBloc.loginUserToServer();
      print("The result is: $results");
      Navigator.of(context).pop(); // progress bar
      if (results['success']) {
        Navigator.of(context).pushReplacementNamed('/HomeScreen');
      } else {
        alertDialogShowError(context, results['message'],);
      }
    }
  }

  void alertDialogShowError(BuildContext context, String error) {
    double screenHeight = MediaQuery.of(context).size.height;

    var alert = AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          error,
          style: TextStyle(
            color: Colors.black,
            fontSize: screenHeight * 0.03,  // Dynamic font size based on screen height
            fontFamily: 'Quicksand',  // Custom font family
          ),
        ),
      ),
      actions: [
        // OK button to dismiss the dialog
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();  // Dismiss the dialog
          },
          child: const Text(
            "OK",
            style: TextStyle(
              color: Colors.black,
              fontSize: 32.0,  // Large font size for emphasis
              fontFamily: 'Quicksand',  // Custom font family
              fontWeight: FontWeight.bold,  // Bold text
            ),
          ),
        ),
      ],
    );

    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return alert;
      },
    );
  }


  bool isWeakPassword(String password) {
    bool isWeak = false;
    var weakPasswords = ['123456', '012345', 'password', 'abcdef', '000000'];
    for (int i = 0; i < weakPasswords.length; i++) {
      if (password == weakPasswords[i]) {
        isWeak = true;
      }
    }
    return isWeak;
  }

  void alertDialogPleaseWait(BuildContext context,
      {String message = "Verifying user details"}) {
    double screenHeight = MediaQuery.of(context).size.height;

    var alert = AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            // Progress indicator with fixed size
            const SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                value: null,  // Indeterminate progress
                color: Colors.white,
              ),
            ),
            const SizedBox(
              width: 10,  // Space between progress indicator and text
            ),
            // Message text with dynamic font size
            Text(
              message,
              style: TextStyle(
                color: Colors.black,
                fontSize: screenHeight * 0.024,  // Dynamic font size based on screen height
                fontFamily: 'Quicksand',  // Custom font family
              ),
            ),
          ],
        ),
      ),
    );

    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,  // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext ctx) {
        return alert;
      },
    );
  }
}

