import 'package:flutter/material.dart';

class GroupDetailScreen extends StatelessWidget {
  final String name;

  // Constructor to accept group name
  const GroupDetailScreen({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(name), // Use the group name in the app bar title
      ),
      body: Center(
        child: Text(
          'Welcome to the $name group!',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}


