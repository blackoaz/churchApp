import 'dart:convert';

import 'package:ChurchMeetupApp/blocs/paymentBloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import '../blocs/authorizationBloc.dart';
import 'drawer_file.dart';

class Offerings extends StatefulWidget {
  const Offerings({super.key});

  @override
  State<Offerings> createState() => _OfferingsState();
}

class _OfferingsState extends State<Offerings> {
  late Database db;
  String _phoneNumber = '';
  String? _selectedOffering, _selectedMno;
  List<Map<String, String>> _paymentMethods = [];
  List<Map<String, dynamic>> _offerings = [];
  final List<bool> _selectedFrequency = [true, false, false, false];
  final TextEditingController _amountController =
      TextEditingController(text: "0");
  final TextEditingController _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initialize();
    getMnos();
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
    await getOfferings();
  }

  Future<void> getMnos() async {
    var url =
        Uri.parse('https://evmak.com/church/public/api/v1/payment-methods');

    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(minutes: 4));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        print("Retrieved Mnos : $data");

        setState(() {
          List<dynamic> dataList = data['data'] as List<dynamic>;
          _paymentMethods = dataList.map((item) {
            if (item is Map<String, dynamic>) {
              return item.map(
                  (key, value) => MapEntry(key.toString(), value.toString()));
            }
            return <String, String>{};
          }).toList();
        });
      } else {
        setState(() {
          _paymentMethods = [];
        });
      }
    } catch (error) {
      print("Error fetching payment methods: $error");
      setState(() {
        _paymentMethods = [];
      });
    }
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

  Future<void> getOfferings() async {
    print("we are here to fetch offerings");
    final AuthorizationBloc authorizationBloc =
        Provider.of<AuthorizationBloc>(context, listen: false);
    String token = await getAuthToken(authorizationBloc);
    var url = Uri.parse('https://evmak.com/church/public/api/v1/offerings');

    try {
      var response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }).timeout(const Duration(minutes: 4));
      print(response.statusCode);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        print("Retrieved offerings: $data");

        setState(() {
          List<dynamic> dataList = data['data'] as List<dynamic>;

          // Map the retrieved offerings to a more usable structure
          _offerings = dataList.map((item) {
            if (item is Map<String, dynamic>) {
              return {
                'id': item['id'].toString(),
                'name': item['name'],
              };
            }
            return <String, String>{};
          }).toList();
        });
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403) {
        print(response.body);
        setState(() {
          _offerings = [];
        });
      } else {
        setState(() {
          _offerings = [];
        });
      }
    } catch (error) {
      print("Error fetching offerings: $error");
      setState(() {
        _offerings = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthorizationBloc authorizationBloc =
        Provider.of<AuthorizationBloc>(context);
    return Scaffold(
      drawer: const Drawer(
        backgroundColor: Colors.orangeAccent,
        elevation: 2,
        child: CustomDrawerList(),
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
                // Safely map the fetched offerings
                items: _offerings.isNotEmpty
                    ? _offerings.map((offering) {
                        return DropdownMenuItem<String>(
                          value: offering['id'],
                          child: Text(offering['name']),
                        );
                      }).toList()
                    : null, // No items if the list is empty
                onChanged: _offerings.isNotEmpty
                    ? (String? newValue) {
                        setState(() {
                          _selectedOffering = newValue;
                        });
                      }
                    : null, // Disable if the list is empty
                hint: Text(_offerings.isNotEmpty
                    ? 'Select Offering'
                    : 'Fetching offerings...'),
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
              // DropdownButtonFormField<String>(
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //   ),
              //   value: _selectedMno,
              //   // Safely map the fetched payment methods
              //   items: _paymentMethods.isNotEmpty
              //       ? _paymentMethods.map((method) {
              //           return DropdownMenuItem<String>(
              //             value:
              //                 method['value'] as String, // Cast value to String
              //             child: Text(method['label']
              //                 as String), // Cast label to String
              //           );
              //         }).toList()
              //       : null,
              //   onChanged: _paymentMethods.isNotEmpty
              //       ? (String? newValue) {
              //           setState(() {
              //             _selectedMno = newValue;
              //           });
              //         }
              //       : null,
              //   hint: Text(_paymentMethods.isNotEmpty
              //       ? 'Select Payment Method'
              //       : 'Fetching data...'),
              // ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                value: _selectedMno,
                items: _paymentMethods.isNotEmpty
                    ? _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method['value'] as String,
                    child: Text(method['label'] as String),
                  );
                }).toList()
                    : null,
                onChanged: _paymentMethods.isNotEmpty
                    ? (String? newValue) {
                  setState(() {
                    _selectedMno = newValue;
                  });
                }
                    : null,
                hint: Text(_paymentMethods.isNotEmpty
                    ? 'Select Payment Method'
                    : 'Fetching data...'),
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
              // Row(
              //   children: [
              //     IconButton(
              //       icon: const Icon(Icons.add),
              //       onPressed: () {
              //         // Implement add another fund functionality
              //       },
              //     ),
              //     const Text('Add another fund'),
              //   ],
              // ),
              // const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  makeOfferingPayment();
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

  Future<String> getAuthToken(AuthorizationBloc authorizationBloc) async {
    List<Map> userToken = await db.rawQuery('SELECT * FROM Token');
    if (userToken.isNotEmpty) {
      return userToken[0]['key'].toString();
    } else {
      return "";
    }
  }

  getUsersNumber() async {
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

  void makeOfferingPayment() async{
    final PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context, listen: false);
    final AuthorizationBloc authorizationBloc = Provider.of<AuthorizationBloc >(context, listen: false);
    String token = await getAuthToken(authorizationBloc);

    if (_selectedOffering == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select the offering to donate to.")));
      return;
    } else if (_selectedMno == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select the Payment Network")));
      return;
    } else if (_numberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your mobile number")));
      return;
    } else if (_amountController.text.isEmpty || int.tryParse(_amountController.text)! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid amount")));
      return;
    }

    // Get the inputs from the user
    String phoneNumber = _numberController.text;
    int amount = int.tryParse(_amountController.text) ?? 0;

    // Find the selected offering label
    String offeringName = _offerings.firstWhere(
            (offering) => offering['id'] == _selectedOffering)['name'];

    // get the offering id
    paymentBloc.offeringId = _selectedOffering!;
    // Find the selected mobile network operator label
    String? mobileNetworkOperator = _paymentMethods.firstWhere(
            (method) => method['value'] == _selectedMno,
        orElse: () => {'label': 'Unknown Operator'}
    )['value'];


    alertDialogPleaseWait(context);

    // Calling the makePayments function in PaymentBloc
    Map<String, dynamic> results = await paymentBloc.makePayments(phoneNumber, offeringName, amount, mobileNetworkOperator!, token);

    Navigator.of(context).pop(); //progress Dialog
    if (results['success']){
      alertDialogShowError(context,results['message']);
    }else{
      alertDialogShowError(context,results['message']);
    }
  }

  void alertDialogPleaseWait(BuildContext context,
      {String message = "Processing Payment request"}) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;

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
                value: null, // Indeterminate progress
                color: Colors.white,
              ),
            ),
            const SizedBox(
              width: 10, // Space between progress indicator and text
            ),
            // Message text wrapped in Flexible to prevent overflow
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenHeight * 0.024,
                  fontFamily: 'Quicksand',
                ),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return alert;
      },
    );
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
}
