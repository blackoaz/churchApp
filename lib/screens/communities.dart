import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../blocs/authorizationBloc.dart';
import '../blocs/groupsBloc.dart';
import 'Homepage.dart';
import 'drawer_file.dart';
import 'groupsDetailScreen.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  late Database db;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await getDatabase();
    await fetchData();
  }

  Future<void> fetchData() async {
    final GroupsBloc groupsBloc = Provider.of<GroupsBloc>(context, listen: false);
    final AuthorizationBloc authorizationBloc = Provider.of<AuthorizationBloc>(context, listen: false);
    String token = await getAuthToken(authorizationBloc);
    await groupsBloc.fetchGroups(token);
  }

  @override
  Widget build(BuildContext context) {
    final GroupsBloc groupsBloc = Provider.of<GroupsBloc>(context);
    final AuthorizationBloc authorizationBloc = Provider.of<AuthorizationBloc>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Groups",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: Colors.orange),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // You can use this button for other actions if needed
            },
          ),
        ],
      ),
      drawer: const Drawer(
        backgroundColor: Colors.orangeAccent,
        elevation: 2,
        child: CustomDrawerList(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search for a Group",
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Popular Groups",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.orange),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/AddCommunity');
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: groupsBloc.groups.map<Widget>((group) {
                  return _buildCommunityCircle(group['name']);
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "All Groups",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: groupsBloc.groups.map<Widget>((group) {
                  return GestureDetector(
                    onTap: () {
                      print('Tapped on ${group['name']}');
                      // Example navigation to a new screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GroupDetailScreen(name: group['name']), // Pass group data to the detail screen
                        ),
                      );
                    },
                    child: _buildCommunityTile(
                      group['name'],
                      group['description'] ?? 'No Groups available',
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCircle(String communityName) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.orangeAccent,
            child: CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage('images/community_logo.jpeg'),
            ),
          ),
          const SizedBox(height: 5),
          Text(communityName, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCommunityTile(String communityName, String description) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.orangeAccent,
        backgroundImage: AssetImage('images/community_logo.jpeg'),
      ),
      title: Text(
        communityName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(description),
    );
  }

  getDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'churchApp.db');
    // open the database
    db = await openDatabase(path);
  }

  Future<String> getAuthToken(AuthorizationBloc authorizationBloc) async {
    List<Map> userToken = await db.rawQuery('SELECT * FROM Token');
    if (userToken.isNotEmpty) {
      return userToken[0]['key'].toString();
    } else {
      return "";
    }
  }
}







