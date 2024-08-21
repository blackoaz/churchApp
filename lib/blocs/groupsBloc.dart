// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
//
// class GroupsBloc extends ChangeNotifier{
//
//   Future<Map<String, dynamic>> fetchGroups(String authKey) async {
//     var url = Uri.parse('https://evmak.com/church/public/api/v1/groups/');
//     try {
//       var response = await http.get(
//         url,
//         headers: {
//           'Content-type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $authKey'
//         },
//       ).timeout(const Duration(minutes: 4));
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> data = jsonDecode(response.body);
//         return {
//           "success": true,
//           "message": "Data fetched successfully",
//           "data": data['data'] ?? []
//         };
//       } else if (response.statusCode == 404) {
//         return {
//           "success": false,
//           "message": "Groups not found",
//           "data": []
//         };
//       } else {
//         return {
//           "success": false,
//           "message": "Unexpected error occurred",
//           "data": []
//         };
//       }
//     } on TimeoutException catch (e) {
//       return {
//         "success": false,
//         "message": "Request timed out",
//         "data": []
//       };
//     } on FormatException catch (e) {
//       return {
//         "success": false,
//         "message": "Bad response format",
//         "data": []
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "message": "An error occurred",
//         "data": []
//       };
//     }
//   }
//
// }
//
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class GroupsBloc extends ChangeNotifier {
  List<Map<String, dynamic>> _groups = [];

  // Getter method to access the list of groups
  List<Map<String, dynamic>> get groups => _groups;

  // Setter method to update the list of groups
  set groups(List<Map<String, dynamic>> newGroups) {
    _groups = newGroups;
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchGroups(String authKey) async {
    print("We are here to fetch groups");
    var url = Uri.parse('https://evmak.com/church/public/api/v1/groups/');
    try {
      var response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authKey'
        },
      ).timeout(const Duration(minutes: 4));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        groups = List<Map<String, dynamic>>.from(data['data'] ?? []);
        print("Fetched Groups are: $groups");
        return {
          "success": true,
          "message": "Data fetched successfully",
          "data": groups,
        };
      } else if (response.statusCode == 404) {
        groups = []; // Clear groups if nothing is found
        return {
          "success": false,
          "message": "Groups not found",
          "data": groups,
        };
      } else {
        groups = []; // Clear groups if an unexpected error occurs
        return {
          "success": false,
          "message": "Unexpected error occurred",
          "data": groups,
        };
      }
    } on TimeoutException catch (e) {
      groups = []; // Clear groups on timeout
      return {
        "success": false,
        "message": "Request timed out",
        "data": groups,
      };
    } on FormatException catch (e) {
      groups = []; // Clear groups on format exception
      return {
        "success": false,
        "message": "Bad response format",
        "data": groups,
      };
    } catch (e) {
      groups = []; // Clear groups on generic error
      return {
        "success": false,
        "message": "An error occurred",
        "data": groups,
      };
    }
  }

}
