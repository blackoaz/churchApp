import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../blocs/authorizationBloc.dart';
import 'Homepage.dart';

class Offerings extends StatefulWidget {
  const Offerings({super.key});

  @override
  State<Offerings> createState() => _OfferingsState();
}

class _OfferingsState extends State<Offerings> {
  late Database db;
  String _phoneNumber = '';
  String? _selectedOffering, _selectedMno;
  final List<bool> _selectedFrequency = [true, false, false, false];
  final TextEditingController _amountController = TextEditingController(text: "0");
  final TextEditingController _numberController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initialize();
    _amountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    await getDatabase();
    await fetchNumber();
  }

  Future<void> fetchNumber() async {
    try {
      _phoneNumber = await getUsersNumber();
      if (_phoneNumber.isNotEmpty) {
        setState(() {
          _numberController.text = _phoneNumber;
        });
      }
    } catch (e) {
      print("Error fetching phone number: $e");
    }
  }

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
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () async {
                try {
                  Navigator.pop(context);
                  authorizationBloc.alertDialogPleaseWait(context);

                  // Call the logout function and handle the result
                  Map<String, dynamic> results = await authorizationBloc.logoutUser();

                  // Close the progress dialog
                  Navigator.of(context).pop();

                  if (results['success']) {
                    // Navigate to HomeScreen if logout is successful
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Homepage(),
                      ),
                          (Route<dynamic> route) => false,
                    );
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
                    is401: false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Give'),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.orangeAccent, // Change the color here
        ),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What is your offering?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                value: _selectedOffering,
                items: <String>['Offering 1', 'Offering 2', 'Offering 3']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOffering = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Frequency',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ToggleButtons(
                isSelected: _selectedFrequency,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selectedFrequency.length; i++) {
                      _selectedFrequency[i] = i == index;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8.0),
                selectedColor: Colors.white,
                fillColor: Colors.orange,
                color: Colors.black,
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                children: const [
                  Text('One time'),
                  Text('Weekly'),
                  Text('Monthly'),
                  Text('Every two weeks'),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Select your Payment Method',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                value: _selectedMno,
                items: <String>['Tigo Cash', 'Airtel Money', 'Mpesa', 'Bank A', 'Bank B']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMno = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: 'Amount (TZS)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Implement add another fund functionality
                    },
                  ),
                  const Text('Add another fund'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement continue functionality
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Continue to Give TZS ${_amountController.text}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getUsersNumber() async{
    try {
      List<Map> userName = await db.rawQuery('SELECT * FROM userData');
        if (userName.isNotEmpty) {
          String user = userName[0]['phoneNumber'].toString();
          print("The user is: $user");
        return user;
      } else {
        return "";
      }
    } catch (e) {
      print('Error fetching phone Number: $e');
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

