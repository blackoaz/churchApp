import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../blocs/authorizationBloc.dart';
import 'Homepage.dart';

class Events extends StatelessWidget {
  const Events({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthorizationBloc authorizationBloc = Provider.of<AuthorizationBloc>(context);
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.orangeAccent,
        elevation: 2,
        child: ListView(
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
            // if (authtoken.isEmpty)
            //   ListTile(
            //     leading: Icon(Icons.login, color: Colors.white),
            //     title: Text('Login', style: TextStyle(color: Colors.white)),
            //     onTap: () async {
            //       Navigator.of(context).pop();
            //       Navigator.pushAndRemoveUntil(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => LoginScreen(),
            //           ),
            //               (Route<dynamic> route) => false);
            //     },
            //   ),
            // if (authtoken.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  try {
                    Navigator.pop(context);
                    authorizationBloc.alertDialogPleaseWait(
                        context);

                    // Call the logout function and handle the result
                    Map<String, dynamic> results =
                    await authorizationBloc.logoutUser();

                    // Close the progress dialog
                    Navigator.of(context).pop();

                    if (results['success']) {
                      // Navigate to HomeScreen if logout is successful
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Homepage(),
                          ),
                              (Route<dynamic> route) => false);
                    } else {
                      // Display an error message if logout fails
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
                        is401: false);
                  }
                },
              ),
          ],
          
        ),
      ),
      appBar: AppBar(
        title: const Text("Events"),
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
              // Handle notification button press
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Events",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search for an event',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildEventCard(
                    'images/lent.jpeg',
                    '12',
                    'Mar',
                    'Celebrate recovery',
                    'Pass over from all the evil...',
                    'Tegeta Nyuki Dar es Salaam, 09:00 AM',
                  ),
                  _buildEventCard(
                    'images/matters_of_blood.jpeg',
                    '19',
                    'Mar',
                    'Matters of the blood',
                    'Come join pastor Tony...',
                    'Millennium Towers Dar, 05:00 PM',
                  ),
                  _buildEventCard(
                    'images/good_friday.jpeg',
                    '29',
                    'Mar',
                    'Good Friday service',
                    'You are welcome at passover...',
                    'Bahari Beach Dar es Salaam, 06:00 AM',
                  ),
                  _buildEventCard(
                    'images/easter_service.jpeg',
                    '31',
                    'Mar',
                    'Easter Service',
                    'Jesus is risen Aleluuyah',
                    'St Joseph Cathedral Dar, 07:00 AM',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(String imagePath, String day, String month, String title, String description, String location) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.black.withOpacity(0.7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        month,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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
}


