import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../blocs/authorizationBloc.dart';
import '../blocs/groupsBloc.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final ScrollController _scrollController = ScrollController();
  late Database db;

  @override
  void initState() {
    super.initState();
    getDatabase();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthorizationBloc authorizationBloc = Provider.of<AuthorizationBloc>(context);
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(), // prevent user from scrolling
            controller: _scrollController,
            children: [
              Image.asset(
                "images/church_splash.jpg",
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width * 1.5,
                fit: BoxFit.fitHeight,
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: const Center(
                  child: Text(
                    "CHURCH MEETUP APP",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                height: MediaQuery.of(context).size.height - 250,
                width: MediaQuery.of(context).size.width - 50,
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      String token = await getAuthToken(authorizationBloc);
                      if (token.isNotEmpty) {
                        Navigator.of(context).pushReplacementNamed('/HomeScreen');
                      } else {
                        Navigator.of(context).pushReplacementNamed('/Login');
                      }
                    },
                    child: const Text(
                      "WELCOME",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> getDatabase() async {
    try {
      var databasesPath = await getDatabasesPath();
      String path = p.join(databasesPath, 'churchApp.db');

      // open the database
      db = await openDatabase(
        path,
        version: 2,
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE IF NOT EXISTS Token (id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT)');
          await db.execute('CREATE TABLE IF NOT EXISTS userData (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, phoneNumber TEXT)');
          print('Tables created.');
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion < 2) {
            await db.execute('CREATE TABLE IF NOT EXISTS userData (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, phoneNumber TEXT)');
            print('Table "userData" created on upgrade.');
          }
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
    }
  }


  Future<String> getAuthToken(AuthorizationBloc authorizationBloc) async {
    try {
      List<Map> userToken = await db.rawQuery('SELECT * FROM Token');
      List<Map> userName = await db.rawQuery('SELECT * FROM userData');
      if (userToken.isNotEmpty) {
        String token = userToken[0]['key'].toString();
        if (userName.isNotEmpty) {
          String user = userName[0]['name'].toString();
          print("The user is: $user");
        } else {
          print("Table not created");
        }
        return token;
      } else {
        return "";
      }
    } catch (e) {
      print('Error fetching token: $e');
      return "";
    }
  }
}
