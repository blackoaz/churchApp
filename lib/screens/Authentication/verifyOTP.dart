import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:provider/provider.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../../blocs/authorizationBloc.dart';


class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  late String _smsCode;
  String _message = "Verifying the code";

  @override
  Widget build(BuildContext context) {
    final AuthorizationBloc authorizationBloc =
    Provider.of<AuthorizationBloc>(context);
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    AppBar appBar = AppBar(
      title: const Text(
        "Verify Phone Number",
        style: TextStyle(color: Colors.white, fontFamily: 'Quicksand'),
      ),
      backgroundColor:
      Colors.orangeAccent,
      iconTheme: const IconThemeData(color: Colors.white), systemOverlayStyle: SystemUiOverlayStyle.light,
    );
    return Scaffold(
        appBar: appBar,
        body: SizedBox(
          width: screenWidth,
          child: SingleChildScrollView(
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: screenWidth * 0.17, bottom: screenWidth * 0.13),
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.3,
                      alignment: Alignment.center,
                      child: RichText(
                          text: TextSpan(
                            text: 'Enter the code we have sent to ${authorizationBloc.phoneNumber}',
                            style: TextStyle(
                                fontSize: screenHeight * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Quicksand'),
                          ),
                          textAlign: TextAlign.center),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: screenWidth * 0.8,
                      child: OTPTextFieldV2(
                        length: 6,
                        width: screenWidth * 0.8,
                        fieldWidth: screenWidth * 0.11,
                        style: TextStyle(fontSize: screenHeight * 0.030),
                        keyboardType: TextInputType.phone,
                        textFieldAlignment: MainAxisAlignment.spaceAround,
                        fieldStyle: FieldStyle.box,
                        onCompleted: (pin) {
                          setState(() {
                            _smsCode = pin;
                          });
                          //verifyOTP(context, colorsBloc, authorizationBloc);
                        },
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.only(
                          top: screenWidth * 0.1, bottom: screenWidth * 0.1),
                      child: ElevatedButton(
                        onPressed: () {
                          verifyOTP(context,authorizationBloc);
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.orangeAccent),
                            shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                )),
                            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.only(
                                  top: 14, bottom: 14, left: 30, right: 30),
                            )),
                        child: Text(
                          "Verify code",
                          style: TextStyle(
                              fontSize: screenHeight * 0.030, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )),

        ));
    }

  verifyOTP(BuildContext context,
      AuthorizationBloc authorizationBloc) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final formState = _formkey.currentState;
    if (formState!.validate()) {
      formState.save();
      if (_smsCode.isEmpty) {
        alertDialogShowError(context, "Verification code is Empty");
        return;
      }

      alertDialogPleaseWait(context);
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: authorizationBloc.verificationId, smsCode: _smsCode);
      // Sign the user in (or link) with the credential // Firebase
      try {
        await auth.signInWithCredential(credential);

        switch (authorizationBloc.otpReason) {
          case "register":
            {
              setState(() {
                _message = "Saving user details";
              });
              Map<String, dynamic> results =
              await authorizationBloc.registerUserToServer();
              Navigator.of(context).pop(); // progress bar
              if (results['success']) {
                Navigator.of(context).pushReplacementNamed('/Login');
              } else {
                alertDialogShowError(context, results['message']);
              }
            }
            break;
          case "forgot_password":
            {
              setState(() {
                _message = "Checking user details";
              });
              Map<String, dynamic> results =
              await authorizationBloc.userForgotPassword();
              Navigator.of(context).pop(); // progress bar
              if (results['success']) {
                Navigator.of(context)
                    .pushReplacementNamed('/ResetPasswordScreen');
              } else {
                alertDialogShowError(context, results['message']);
              }
            }
            break;

          default:
            {}
            break;
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-verification-code') {
          Navigator.of(context).pop();
          alertDialogShowError(
              context, "The verification code is invalid.");
        } else {
          Navigator.of(context).pop();
          alertDialogShowError(
              context, "Phone number verification failed.");
        }
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


