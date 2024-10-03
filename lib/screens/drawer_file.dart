import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'Homepage.dart';
import 'package:ChurchMeetupApp/blocs/authorizationBloc.dart';

class CustomDrawerList extends StatefulWidget {
  const CustomDrawerList({Key? key}) : super(key: key);

  @override
  State<CustomDrawerList> createState() => _CustomDrawerListState();
}

class _CustomDrawerListState extends State<CustomDrawerList> {
  Map<String, dynamic>? userDetails;
  bool isLoading = true;
  late Database db;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await getDatabase();
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    final AuthorizationBloc authorizationBloc =
        Provider.of<AuthorizationBloc>(context, listen: false);

    String authKey = await getAuthToken(authorizationBloc);

    // Fetch user details
    Map<String, dynamic> result = await fetchUserDetails(authKey);

    if (result['success'] == true) {
      setState(() {
        userDetails = result['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails(String authKey) async {
    var url = Uri.parse("https://evmak.com/church/public/api/v1/user-details");
    var headers = {
      'Authorization': 'Bearer $authKey',
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };

    try {
      var response = await http
          .get(url, headers: headers)
          .timeout(const Duration(minutes: 4));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return json.decode(response.body);
      }
    } catch (error) {
      print(error);
      return {"success": false, "message": error.toString(), "data": {}};
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthorizationBloc authorizationBloc =
        Provider.of<AuthorizationBloc>(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Center(
            child: Container(
              height: 120,
              width: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage('images/community_logo.jpeg'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        isLoading
            ? const Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator if data is being fetched
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: userDetails?['profile_picture'] != null
                          ? ClipOval(
                              child: Image.network(
                                userDetails?['profile_picture'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.black,
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userDetails?['name'] ?? 'User Name', // Fetched user name
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      userDetails?['phone_no'] ??
                          'Phone Number', // Fetched phone number
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      userDetails?['community']['name'] ??
                          'Community', // Fetched phone number
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
        const Divider(color: Colors.white70),
        // ListTile(
        //   leading: const Icon(Icons.logout, color: Colors.white),
        //   title: const Text('Logout', style: TextStyle(color: Colors.white)),
        //   onTap: () async {
        //
        //     final BuildContext currentContext = context;
        //
        //     try {
        //       Navigator.pop(currentContext);
        //
        //       authorizationBloc.alertDialogPleaseWait(currentContext);
        //
        //       Map<String, dynamic> results = await authorizationBloc.logoutUser();
        //
        //       // Safely pop the progress dialog
        //       if (currentContext.mounted && Navigator.canPop(currentContext)) {
        //         Navigator.pop(currentContext);
        //       }
        //
        //       if (results['success']) {
        //         if (currentContext.mounted) {
        //           Navigator.pushAndRemoveUntil(
        //             currentContext,
        //             MaterialPageRoute(
        //               builder: (context) => const Homepage(),
        //             ),
        //                 (Route<dynamic> route) => false,
        //           );
        //         }
        //       } else {
        //         int statusCode = results['status_code'] ?? 100;
        //         if (currentContext.mounted) {
        //           authorizationBloc.alertDialogShowError(
        //             currentContext,
        //             results['message'].toString(),
        //             is401: statusCode == 401,
        //           );
        //         }
        //       }
        //     } catch (e) {
        //       // Safely pop the progress dialog in case of error
        //       if (currentContext.mounted && Navigator.canPop(currentContext)) {
        //         Navigator.pop(currentContext);
        //       }
        //
        //       if (currentContext.mounted) {
        //         authorizationBloc.alertDialogShowError(
        //           currentContext,
        //           'An error occurred during logout. Please try again.',
        //           is401: false,
        //         );
        //       }
        //     }
        //   },
        // ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          onTap: () async {
            try {
              //Navigator.of(context).pop();
              authorizationBloc.alertDialogPleaseWait(context);

              Map<String, dynamic> results =
                  await authorizationBloc.logoutUser();

              Navigator.of(context).pop();

              if (results['success']) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Homepage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              } else {
                int statusCode = results['status_code'] ?? 100;
                authorizationBloc.alertDialogShowError(
                  context,
                  results['message'].toString(),
                  is401: statusCode == 401,
                );
              }
            } catch (e) {
              Navigator.of(context).pop();
              authorizationBloc.alertDialogShowError(
                context,
                'An error occurred during logout. Please try again.',
                is401: false,
              );
            }
          },
        ),
      ],
    );
  }

  Future<String> getAuthToken(AuthorizationBloc authorizationBloc) async {
    List<Map> userToken = await db.rawQuery('SELECT * FROM Token');
    if (userToken.isNotEmpty) {
      return userToken[0]['key'].toString();
    } else {
      return "";
    }
  }

  getDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'churchApp.db');
    // open the database
    db = await openDatabase(path);
  }
}
