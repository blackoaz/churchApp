import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../blocs/authorizationBloc.dart';
import 'communities.dart';
import 'events.dart';
import 'offerings.dart';
import 'topics.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Events(),
    const Topics(),
    const Offerings(),
    const CommunitiesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthorizationBloc authorizationBloc = Provider.of<AuthorizationBloc>(context);
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.orangeAccent,
        elevation: 2,
        child: ListView(
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
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () async {
                try {
                  Navigator.pop(context);
                  authorizationBloc.alertDialogPleaseWait(context);

                  Map<String, dynamic> results = await authorizationBloc.logoutUser();

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
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          _buildBottomNavItem(Icons.calendar_today, 'Events', 0),
          _buildBottomNavItem(Icons.chat, 'Topics', 1),
          _buildBottomNavItem(Icons.volunteer_activism_outlined, 'Offering', 2),
          _buildBottomNavItem(Icons.people, 'Groups', 3),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 5,
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isSelected ? 60 : 40,
        height: isSelected ? 60 : 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.transparent,
        ),
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: isSelected ? Colors.orange : Colors.grey,
          size: isSelected ? 30 : 24,
        ),
      ),
      label: label,
    );
  }
}
