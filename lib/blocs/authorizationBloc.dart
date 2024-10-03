import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../screens/Authentication/user_login.dart';

class AuthorizationBloc extends ChangeNotifier {

  late Database db;
  late String _username, _password, _fullName, _email, _phoneNumber,
      _usernameReg, _passwordReg, _confirmPassword;
  String _otpReason = "";
  String _otp = "";
  late int _resendToken;
  String _authKey = "";
  String _community = "";

  // registration credentials
  String get fullName => _fullName;

  String get email => _email;

  String get community => _community;

  String get phoneNumber => _phoneNumber;

  String get usernameReg => _usernameReg;

  String get passwordReg => _passwordReg;

  String get confirmPassword => _confirmPassword;
  String _verificationId = "";
  // login credentials
  String get authKey => _authKey;

  String get username => _username;

  String get password => _password;
  String get otpReason => _otpReason;
  int get resendToken => _resendToken;
  String get verificationId => _verificationId;


  set fullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  set email(String value) {
    _email = value;
    notifyListeners();
  }


  set community(String value) {
    _community= value;
    notifyListeners();
  }

  set phoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  set usernameReg(String value) {
    _usernameReg = value;
    notifyListeners();
  }

  set passwordReg(String value) {
    _passwordReg = value;
    notifyListeners();
  }

  set confirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  set username(String value) {
    _username = value;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  set verificationId(String id) {
    _verificationId = id;
    notifyListeners();
  }
  set authKey(String value) {
    _authKey = value;
    notifyListeners();
  }
  set otp(String code) {
    _otp = code;
    notifyListeners();
  }

  set resendToken(int token) {
    _resendToken = token;
    notifyListeners();
  }

  set otpReason(String reason) {
    _otpReason = reason;
    notifyListeners();
  }

  setOTPCode(String smsCode) {
    otp = smsCode;
  }

  setReasonForOTP(String reason) {
    otpReason = reason;
  }

  setResendToken(int token) {
    resendToken = token;
  }

  setVerificationId(String id) {
    verificationId = id;
  }


  setLoginDetails(String user, String pass) {
    username = user;
    password = pass;
  }

  setAuthToken(String token) {
    authKey = token;
  }

  setSignUpDetails(String full_name, String Regemail, String phone_number,
      String username, String password, String c_password,String communityId)
  {
    fullName = full_name;
    email = Regemail;
    phoneNumber = phone_number;
    usernameReg = username;
    passwordReg = password;
    confirmPassword = c_password;
    community = communityId;

  }

  Future<Map<String, dynamic>> registerUserToServer() async {
    getDataBase();
    String community1 = community;
    print("Inside register community is: $community1",);
    var url = Uri.parse('https://evmak.com/church/public/api/v1/register');
    try {
      var response = await http.post(
        url,
        body: json.encode({
          "full_name": fullName,
          "email": email,
          "phone_no": phoneNumber,
          "role_id": 2,
          "community_id":community,
          "username": usernameReg,
          "password": passwordReg,
          "c_password": confirmPassword
        }),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(minutes: 4));
      print("===============register User===============");
      print("The status code ${response.statusCode}");
      print("The responseBody ${response.body}");
      if (response.statusCode == 200) {
        Map<String, dynamic > data = json.decode(response.body);

        // authKey = data['data']['token'];
        if (data.containsKey('data') && data['data'].containsKey('token')) {
          authKey = data['data']['token'];
          try {
            await db.transaction((txn) async {
              int id = await txn.rawInsert('INSERT INTO Token(key) VALUES(?)', [authKey]);
              int id2 = await txn.rawInsert(
                  'INSERT INTO userData(name, email, phoneNumber) VALUES(?, ?, ?)',
                  [fullName, email, phoneNumber]
              );
              print('row inserted: $id');
              print('row inserted: $id2');
            });

            return {
              "success": true,
              "message": data['message']
            };
          } catch (e) {
            print('Transaction failed: $e');
            return {
              "success": false,
              "message": "Database transaction failed"
            };
        }
        }else {
        return {
          "success": true,
          "message":data['message']
        };
      }
      } else if (response.statusCode >= 400 && response.statusCode <= 422) {
        Map<String, dynamic > data = json.decode(response.body);
        print("ResponseBody: $data");
        return {
          "success": false,
          "message":  data['message']
        };
      } else if (response.statusCode == 500) {
        Map<String, dynamic > data = json.decode(response.body);
        print("ResponseBody: $data");
        // server error
        return {
          "success": false,
          "message": "Error, could not connect to the server"
        };
      } else {
        return {
          "success": false,
          "message": "An Error occurred, Please try again later"
        };
      }
    } on TimeoutException catch (ex) {
      return {
        "success": false,
        "message": "Timeout error, Please try again later"
      };
    } on Error catch (error) {
      return {
        "success": false,
        "message": "Error, could not connect to the server: $error"
      };
    }
  }


  Future<Map<String, dynamic>> loginUserToServer() async {
    getDataBase();
    var url = Uri.parse('https://evmak.com/church/public/api/v1/login');
    try {
      var response = await http.post(
        url,
        body: json.encode({
          "email": username,
          "password": password,
        }),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(minutes: 4));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        if (authKey.isEmpty) {
          // if there is no token saved in sqlite database
          await db.transaction((txn) async {
            int id = await txn.rawInsert('INSERT INTO Token(key) VALUES(?)',
                [data['data']['token']]);
          });
        } else {
          // update user token
          int count = await db.rawUpdate('UPDATE Token SET key = ?',
              [authKey]); // this table will always contain one record only

        }

        return {
          "success": true,
          "message": data['message']
        };
      } else if (response.statusCode == 400 || response.statusCode == 403) {
        Map<String, dynamic> data = json.decode(response.body);
        return {
          "success": false,
          "message": data['message']
        };
      } else if (response.statusCode == 401) {
        return {
          "success": false,
          "message": "You are not authorized to perform this action"
        };
      } else if (response.statusCode == 500) {
        return {
          "success": false,
          "message": "Error, could not connect to the server"
        };
      } else {
        return {
          "success": false,
          "message": "An Error occurred, Please try again later"
        };
      }
    } on TimeoutException catch (ex) {
      print("TimeoutException: $ex");
      return {
        "success": false,
        "message": "Timeout error, Please try again later"
      };
    } on FormatException catch (error) {
      return {
        "success": false,
        "message": "Response format is not valid JSON"
      };
    } on Error catch (error) {
      return {
        "success": false,
        "message": "Error, could not connect to the server"
      };
    }
  }

  Future<Map<String, dynamic>>logoutUser() async{
    getDataBase();
    var url = Uri.parse('https://evmak.com/church/public/api/v1/logout');

    try{
      var response = await http.post(url,
        headers:{
          'Authorization':'Bearer $authKey',
          'Content-Type':'application/json',
          'Accept':'application/json',
        }
      ).timeout(const Duration(minutes: 4));
      print("===============logout User===============");
      print("The Token $authKey");
      print("The status code ${response.statusCode}");
      print("The responseBody ${response.body}");
      if(response.statusCode == 200){
        Map<String, dynamic > data = json.decode(response.body);
        // logout Firebase user
        FirebaseAuth auth = FirebaseAuth.instance;
        if (auth.currentUser != null) auth.signOut();
        // delete the saved token
        int delete = await db.rawDelete('DELETE FROM Token');
        await FirebaseAnalytics.instance.resetAnalyticsData();
        return {
          "success": data["success"],
          "message": data["message"]
        };
      }else if (response.statusCode == 400) {
        Map<String, dynamic > data = json.decode(response.body);
        return {
          "success": false,
          "message": []
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Unauthorized or Forbidden
        //token is no longer valid // delete the token
        int delete = await db.rawDelete('DELETE FROM Token');

        return {
          "success": false,
          "message": "You are not authorized to perform this action",
          "status_code": 401
        };
      } else if (response.statusCode == 500) {
        // server error
        return {
          "success": false,
          "message": "Error, could not connect to the server"
        };
      } else {
        return {
          "success": false,
          "message": "An Error occurred, Please try again later"
        };
      }
    } on TimeoutException catch (ex) {
      print('Timeout Exception: ${ex.message!}');
      return {
        "success": false,
        "message": "Timeout error, Please try again later"
      };
    } on Error catch (error) {
      print(error.toString());
      return {
        "success": false,
        "message": "Error, could not connect to the server"
      };
    }
  }

  userForgotPassword(){

  }

  void alertDialogShowError(BuildContext context, String error,
      {bool is401 = false}) {
    double screenHeight = MediaQuery.of(context).size.height;
    var alert = AlertDialog(
      content: Padding(
        padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
        child: Text(
          error,
          style: TextStyle(
            color: Colors.black,
            fontSize: screenHeight * 0.029,
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (is401) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginUser()),
                      (Route<dynamic> route) => false);
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            "Close",
            style: TextStyle(
                color: Colors.black,
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

  void alertDialogPleaseWait(BuildContext context,
      {String message = "Logging out"}) {
    double screenHeight = MediaQuery.of(context).size.height;
    var alert = AlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              const SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  value: null,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.black,
                  ),
                  strokeWidth: 3.0,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                message,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenHeight * 0.024,
                  fontFamily: 'Quicksand',
                ),
              )
            ],
          ),
        ));

    showDialog(
        context: context,
        barrierDismissible: false, // not dismissible on touch outside
        builder: (BuildContext ctx) {
          return alert;
        });
  }

  getDataBase() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'churchApp.db');
    // open the database
    db = await openDatabase(path);
    List<Map> userToken = await db.rawQuery('SELECT * FROM Token');
    for (var token in userToken) {
      authKey = token['key'].toString();
    }
  }

}