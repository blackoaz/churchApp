import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../blocs/authorizationBloc.dart';

class SignUpUsers extends StatefulWidget {
  const SignUpUsers({super.key});

  @override
  State<SignUpUsers> createState() => _SignUpUsersState();
}

class _SignUpUsersState extends State<SignUpUsers> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<FormState> _phoneNumberKey = GlobalKey<FormState>();
  late String _full_name, _email, _username, _password, _confirm_password;
  late String _textPhoneNumber = '';
  late String _serverPhoneNumber  = '';


  PhoneNumber _phoneNumber = PhoneNumber(
    isoCode: 'TZ',
    dialCode: '+255',
  );


  @override
  Widget build(BuildContext context) {
    final AuthorizationBloc authorizationBloc =
    Provider.of<AuthorizationBloc>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                "SignUp",
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
                        hintText: "Full Name",
                        filled: true,
                        fillColor: Colors.black,
                        hintStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSaved: (value){
                        _full_name = value!.trim();
                      },
                    ),
                    // const SizedBox(height: 20),
                    // TextFormField(
                    //   decoration: InputDecoration(
                    //     hintText: "Last Name",
                    //     filled: true,
                    //     fillColor: Colors.black,
                    //     hintStyle: const TextStyle(color: Colors.white),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       borderSide: BorderSide.none,
                    //     ),
                    //   ),
                    //   style: const TextStyle(color: Colors.white),
                    // ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Email",
                        filled: true,
                        fillColor: Colors.black,
                        hintStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSaved: (value){
                          _email = value!.trim();
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .black,
                            borderRadius:
                                BorderRadius.circular(10),
                            // Rounded corners
                          ),

                          child: CountryCodePicker(
                            textStyle: const TextStyle(
                              color: Colors.white
                            ),
                            onChanged: (CountryCode countryCode) {
                              setState(() {
                                _phoneNumber = PhoneNumber(
                                  dialCode: countryCode.dialCode,
                                  isoCode: countryCode.code,
                                );
                              });
                            },
                            initialSelection: _phoneNumber.isoCode,
                            favorite: const ['TZ'],
                            showFlagMain: true,
                            showFlagDialog: true,
                          ),
                        ),
                        const SizedBox(
                            width:
                                10),
                        Expanded(
                          child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  _textPhoneNumber = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Phone Number",
                                filled: true,
                                fillColor: Colors.black,
                                hintStyle: const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              ),
                              style: const TextStyle(color: Colors.white), // Text color inside the text field
                              keyboardType: TextInputType.phone,
                              onSaved: (value) {
                                if (value != null) {
                                  _textPhoneNumber = savePhoneNumber();
                              }
                                print(_textPhoneNumber);
                              }
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 20),
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
                      onSaved: (value){
                          _username = value!.trim();
                      },
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
                      style: const TextStyle(color: Colors.white),
                      onSaved: (value){
                        _password = value!.trim();
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        filled: true,
                        fillColor: Colors.black,
                        hintStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSaved: (value){
                        _confirm_password = value!.trim();
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        signupUser(context, authorizationBloc);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "SignUp",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/Login');
                      },
                      child: const Text(
                        "Already have an account? SignIn",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 40), // Space at the bottom to prevent overflow
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    String savePhoneNumber() {
    String fullPhoneNumber = '${_phoneNumber.dialCode}$_textPhoneNumber'.trim().replaceAll(" ", "").replaceAll("-", "");

    if (kDebugMode) {
      print('Full Phone Number: $fullPhoneNumber');
    }
    return fullPhoneNumber;
    }

  signupUser(BuildContext context, AuthorizationBloc authorizationBloc)async{

    final formState = _formkey.currentState;
    if (formState!.validate()) {
      formState.save();

      // remove + from phone number sent to the backend
      _serverPhoneNumber = removePlusSign(_textPhoneNumber);

      // validing the form Inputs
      if (_full_name.isEmpty) {
        alertDialogShowError(context, "Your name is Empty");
        return;
      } else if (_email.isEmpty) {
        alertDialogShowError(context, "Email is Empty");
        return;
      } else if (_password.length < 6) {
        alertDialogShowError(
            context, "Password must contain at least 6 characters");
        return;
      }else if (_password != _confirm_password) {
        alertDialogShowError(
            context, "Password and Confirm password do not match");
        return;
      }
      else if (isWeakPassword(_password)) {
        alertDialogShowError(
            context,
            "Your password is weak, please choose a stronger password");
        return;
      } else if (_textPhoneNumber.isEmpty) {
        alertDialogShowError(context, "Phone Number is Empty");
        return;
      } else if (_textPhoneNumber.length < 13 || _textPhoneNumber.length > 13) {
        alertDialogShowError(context, "Invalid Phone Number");
        return;
      }

      authorizationBloc.setSignUpDetails(_full_name,_email,_serverPhoneNumber,_username, _password,_confirm_password);
      // firebase phone auth here
      alertDialogPleaseWait(context);
      // Map<String, dynamic> results =
      // await authorizationBloc.registerUserToServer();
      // Navigator.of(context).pop(); // progress bar
      // if (results['success']) {
      //   Navigator.of(context).pushReplacementNamed('/Login');
      // } else {
      //   alertDialogShowError(context, results['message']);
      // }
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _textPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          String otp = credential.smsCode!;
          print("======= verificationCompleted  smsCode: $otp");
          authorizationBloc.setOTPCode(otp);
          FirebaseAuth auth = FirebaseAuth.instance;
          await auth.signInWithCredential(credential);
          alertDialogPleaseWait(context, message: "Saving user details");
          Map<String, dynamic> results =
          await authorizationBloc.registerUserToServer();
          Navigator.of(context).pop(); // progress bar
          if (results['success']) {
            Navigator.of(context).pushReplacementNamed('/Login');
          } else {
            alertDialogShowError(context, results['message']);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
          Navigator.of(context).pop(); // progress dialog
          if (e.code == 'invalid-phone-number') {
            alertDialogShowError(
                context, "The provided phone number is not valid.");
          } else {
            // ignore: unnecessary_null_comparison
            if (authorizationBloc.resendToken != null) {
              alertDialogVerifyNumberFailed(
                  context,authorizationBloc);
            } else {
              alertDialogShowError(
                  context, "Failed to verify your phone number");
            }
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          authorizationBloc.setReasonForOTP("register");
          Navigator.of(context).pop(); // progress dialog
          Navigator.of(context).pushNamed('/VerifyOTPScreen');
          authorizationBloc.setVerificationId(verificationId);
          if (resendToken != null) {
            // A resendToken is only supported on Android devices, iOS devices will always return a null value
            authorizationBloc.setResendToken(resendToken);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle a timeout of when automatic SMS code handling fails.
          print("Verifying your number has taken long.");
        },
        //timeout: const Duration(seconds: 30), // default is 30 seconds  // timeout for automatic SMS code resolution // codeAutoRetrievalTimeout // works on Android only
      );
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

  void alertDialogVerifyNumberFailed(BuildContext context,
      AuthorizationBloc authorizationBloc,
      {String message = "Failed to verify your phone number"}) {
    var screenHeight = MediaQuery.of(context).size.height;
    var alert = AlertDialog(
      content: Padding(
        padding: EdgeInsets.all(5.0),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.black,
            fontSize: screenHeight * 0.032,
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // dismiss this dialog
            forceResendingToken(context, authorizationBloc);
          },
          child: Text(
            "Try Again",
            style: TextStyle(
                color: Colors.white,
                fontSize: screenHeight * 0.030,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return alert;
        });
  }

  void forceResendingToken(BuildContext context,
      AuthorizationBloc authorizationBloc) async {
    // firebase phone auth here
    alertDialogPleaseWait(context);
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _textPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          String otp = credential.smsCode!;
          print("======= verificationCompleted  smsCode: " + otp);
          authorizationBloc.setOTPCode(otp);
          FirebaseAuth auth = FirebaseAuth.instance;
          // works on ANDROID ONLY!
          // Sign the user in  // Firebase
          await auth.signInWithCredential(credential);
          alertDialogPleaseWait(context,
              message: "Saving user details");
          Map<String, dynamic> results =
          await authorizationBloc.registerUserToServer();
          Navigator.of(context).pop(); // progress bar
          if (results['success']) {
            Navigator.of(context).pushReplacementNamed('/Login');
          } else {
            alertDialogShowError(context, results['message']);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
          Navigator.of(context).pop(); // progress dialog
          if (e.code == 'invalid-phone-number') {
            alertDialogShowError(
                context, "The provided phone number is not valid.");
          } else {
            alertDialogShowError(
                context, "Failed to verify your phone number");
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          authorizationBloc.setReasonForOTP("register");
          Navigator.of(context).pop(); // progress dialog
          Navigator.of(context).pushNamed('/VerifyOTPScreen');
          authorizationBloc.setVerificationId(verificationId);
          if (resendToken != null) {
            // A resendToken is only supported on Android devices, iOS devices will always return a null value
            authorizationBloc.setResendToken(resendToken);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle a timeout of when automatic SMS code handling fails.
          print("Verifying your number has taken long.");
        },
        //timeout: const Duration(seconds: 30),  // timeout for automatic SMS code resolution // codeAutoRetrievalTimeout // works on Android only
        forceResendingToken: authorizationBloc.resendToken);
  }

  // remove + sysmbol from number
  String removePlusSign(String phoneNumber) {
    if (phoneNumber.startsWith('+')) {
      print("Received phone Number: $phoneNumber");
      return phoneNumber.substring(1);
    }
    return phoneNumber;
  }
}
