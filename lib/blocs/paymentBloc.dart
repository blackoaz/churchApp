import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';


class PaymentBloc extends ChangeNotifier{

  String _offeringId = "";

  String get offeringId => _offeringId;

  set offeringId (String id){
    _offeringId = id;
    notifyListeners();
  }

  setCurrentOfferingId(String id){
    offeringId = id;
  }

  String generateHash(String user) {
    // Get the current UTC date in "d-m-Y" format
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now); // Example: 18-09-2024

    // Combine the user and date
    String input = '$user|$formattedDate';

    // Generate MD5 hash
    List<int> bytes = utf8.encode(input); // Convert to bytes
    Digest md5Hash = md5.convert(bytes);  // Calculate MD5 hash

    return md5Hash.toString();
  }

  String generateReferenceCode() {
    const String letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String digits = '0123456789';
    Random random = Random();

    String generatePart(String characters, int length) {
      return List.generate(length, (index) => characters[random.nextInt(characters.length)]).join();
    }

    String reference = generatePart(letters, 1) + generatePart(digits, 1) +
        generatePart(letters, 1) + generatePart(digits, 1) +
        generatePart(letters, 1) + generatePart(digits, 1) +
        generatePart(digits, 4);

    return reference;
  }

  Future<Map<String, dynamic>> getMnos() async {
    var url = Uri.parse('https://evmak.com/church/public/api/v1/payment-methods');

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

        return {
          "success": true,
          "message": data['message'],
          "data": data['data'],
        };
      } else if (response.statusCode == 400 || response.statusCode == 403) {
        Map<String, dynamic> data = json.decode(response.body);
        return {
          "success": false,
          "message": data['message'],
        };
      } else {
        return {
          "success": false,
          "message": "Unexpected error occurred with status code: ${response.statusCode}",
        };
      }
    } on TimeoutException catch (exception) {
      return {
        "success": false,
        "message": "The request took too long to respond: $exception",
      };
    } on FormatException catch (exception) {
      return {
        "success": false,
        "message": "Invalid JSON format: $exception",
      };
    } catch (error) {
      return {
        "success": false,
        "message": "An error occurred: $error",
      };
    }
  }
  
  Future<void> storeSuccessfulPaymentRequest(
      String authKey, Map<String, dynamic> body

      ) async{
    var url = Uri.parse('https://evmak.com/church/public/api/v1/payments');
    body['offering_id'] = offeringId;
    try{
      var response = await http.post(
          url,
          headers: {
          'Authorization': 'Bearer $authKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          },
          body:json.encode(body)
      ).timeout(const Duration(minutes: 4));

      if (response.statusCode == 200){
        Map<String, dynamic> data = json.decode(response.body);
        print("The data was successfully stored to the backend: $data");
      }else if(response.statusCode >= 400 && response.statusCode <= 404){
        Map<String, dynamic> data = json.decode(response.body);
        print("The data was permission error processing the storage: $data");
      }else{
        Map<String, dynamic> data = json.decode(response.body);
        print("There was an error: $data");
      }
    }catch(error){
      print("There was an error: $error");
    }
  }

  Future<Map<String, dynamic>> makePayments(
      String phoneNumber,
      String offering,
      int amount,
      String mobileNetworkOperator,
      String authKey

      ) async{

    String token = authKey;

    var url = Uri.parse("https://vodaapi.evmak.com/test/?user=church");
    Map<String,dynamic> paymentBody =
    {
      "api_source": "EvMak",
      "reference": generateReferenceCode(),
      "api_to": mobileNetworkOperator,
      "amount": amount,
      "product": offering,
      "callbackStatus": "",
      "callback":"https://evmak.com/church/public/api/v1/evpay/callback",
      "mobileNo": phoneNumber,
      "user": "church",
      "hash": generateHash('church')
    };
    if (mobileNetworkOperator == "Mpesa"){
      url = Uri.parse("https://vodaapi.evmak.com/test/?user=somi");
      paymentBody["user"] = "somi";
      paymentBody["hash"] = generateHash('somi');
    };

    var encodedBody = json.encode(paymentBody);
    print("=======Payment Request Body========");
    print(encodedBody);
    try{
      var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: encodedBody
      ).timeout(const Duration(minutes: 4));

      if (response.statusCode == 200){

        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['response_code'] == 200){
          await storeSuccessfulPaymentRequest(token, paymentBody);
          return {
            "success": true,
            "message": "Transaction Successful, check your phone to enter pin"
          };

        }else if (data['response_code'] == 403 || data['response_code'] == 401 || data['response_code'] == 403){
          print(data);
          return {
            "success": false,
            "message": "Transaction failed: ${data['response_desc']}"
          };
        }else{
          print(data);
          return {
            "success": false,
            "message": "Transaction failed: ${data['response_desc']}"
          };
        }
      }else if(response.statusCode == 403 || response.statusCode == 401 || response.statusCode == 403){
        Map<String, dynamic> data = jsonDecode(response.body);
        print(data);
        return {
          "success": false,
          "message": "Transaction failed: ${data['response_desc']}"
        };
      }else{
        Map<String, dynamic> data = jsonDecode(response.body);
        return {
          "success": false,
          "message": "Transaction failed: ${data['response_desc']}"
        };
      }


    }catch(error){
      return {
        "success": false,
        "message": error
      };
    }

  }


 }