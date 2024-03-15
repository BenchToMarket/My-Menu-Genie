
import 'dart:async';
import 'dart:convert';


import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


import 'global_classes.dart';
import 'phoenix.dart';

// const headers = {
//   "Content-Type": "application/json"
// }; // , "Connection": "keep-alive"};
// // AWS headers - https://lightsail.aws.amazon.com/ls/docs/en_us/articles/amazon-lightsail-distribution-request-and-response#request-custom-headers-behavior



class HttpService {
  final PhoenixFunctions fx = PhoenixFunctions();
  String sh = '';

  Future<List<dynamic>> getStoreDetail(int storeID) async {
    
    sh = fx.determinephoenix();

    try {

      if (kDebugMode) { print( '************  fetch Store Detail   *********** '); }
      final response = await http.get(Uri.parse('$API/menu-store-detail/$storeID/$sh/'));
      
      // final response = await http.get(Uri.parse(API + '/user-profile/' + '1' + '/' + sh + '/'));

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        // if (kDebugMode) { print(response.body); }

        return result;
      } else {
        throw "Can't get user profile.";
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return [];
    }
  }



  Future<Map<String, dynamic>> getVerifiedUser(int userId, int version) async {

    sh = fx.determinephoenix();
    try {
      if (kDebugMode) { print( '************ fetch  verifing user & version   *********** '); }
      final response = await http.get(Uri.parse('$API/user-verify/$userId/$version/$sh/'));
      
      // print(response.statusCode);

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);

        // print(result);
        return result;
      } else {
        throw "Can't verify user.";
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      if (err.runtimeType.toString() == 'SocketException' || err.runtimeType.toString() == '_ClientSocketException') {
        // return {'error': 'noconnection'};
        return {'error': 'noconnection'};
      } else {
        return {};
      }
    }
  }


  Future<int> createNewUser(String userDetails) async {

    sh = fx.determinephoenix();
    int newID = -1;

    try {
    
      final response = await http.patch(Uri.parse('$API/user-create/$sh/'), headers: headers, body: userDetails);

      if (response.statusCode == 200) {
        // print(response.body);
        newID = int.parse(response.body);
        return  newID;
      } else {
        throw "Can't create  user.";
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return newID;
    }
  }



  
  Future<List<dynamic>> getMenuCommit() async {
    // shopDate = '2024-01-05';

    sh = fx.determinephoenix();
    try {
      if (kDebugMode) { print( '************ fetch Menu Commit -   *********** '); }
      final response = await http.get(Uri.parse('$API/menu-commit/${currUser.userIDString}/$sh/'));
      
      // print(response.statusCode);

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        print(result);
        return result;
      } else {
        throw "Can't get Menu Commit .";
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return [];
    }
  }

  
  
  Future<List<dynamic>> getStores(String shopDate) async {
    // shopDate = '2024-01-05';
    // not sending date - but we may later 

    sh = fx.determinephoenix();
    try {
      if (kDebugMode) { print( '************ fetch   User Stores -   *********** '); }
      final response = await http.get(Uri.parse('$API/user-stores/${currUser.userIDString}/$shopDate/$sh/'));
      
      // print(response.statusCode);

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        // print(result);
        return result;
      } else {
        throw "Can't get User Stores .";
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      if (err.runtimeType.toString() == 'SocketException' || err.runtimeType.toString() == '_ClientSocketException') {
        // return {'error': 'noconnection'};
        return [{'error': 'noconnection'}];
      } else {
        // return {};
        return [];
      }
      // return {};
    }
  }


  
  
  Future<List<dynamic>> getMenuMap(String shopDate) async {
    // shopDate = '2024-01-05';

    sh = fx.determinephoenix();
    try {
      if (kDebugMode) { print( '************ fetch Menu Map -   *********** '); }
      final response = await http.get(Uri.parse('$API/menu-by-store/${currStore!.storeID}/${currUser.userIDString}/$shopDate/$sh/'));
      
      // print(response.statusCode);

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        // print(result);
        return result;
      } else {
        throw "Can't get Menu.";
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      if (err.runtimeType.toString() == 'SocketException' || err.runtimeType.toString() == '_ClientSocketException') {
        // return {'error': 'noconnection'};
        return [{'error': 'noconnection'}];
      } else {
        // return {};
        return [];
      }
      // return {};
    }
  }


  
  Future<List<dynamic>> getShoppingList(String shopDate, int activeMenuID) async {
    // shopDate = '2024-01-05';
    // no longer fetching by shopDate just acitveMenuID - keeping in case for later - error with menuID, etc

    sh = fx.determinephoenix();
    try {
      if (kDebugMode) { print( '************ fetch  shopping list  -   *********** '); }
      final response = await http.get(Uri.parse('$API/shop-list/${currStore!.storeID}/${currUser.userIDString}/$shopDate/$activeMenuID/$sh/'));
      
      // print(response.statusCode);
      // print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        // print(result);
        return result;
      } else {
        throw "Can't get Shopping List.";
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return [];
    }
  }


  
  Future<List<dynamic>> getSavingsSpan(String bySpan, String byStore) async {
    
    // byStore = -1 for all stores. 
    
    sh = fx.determinephoenix();
    try {
      if (kDebugMode) { print( '************ fetch  saving by span/store -   *********** '); }
      final response = await http.get(Uri.parse('$API/save-span/${currUser.userIDString}/$bySpan/$byStore/$sh/'));
      
      // print(response.statusCode);
      // print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        // print(result);
        return result;
      } else {
        throw "Can't get Savings.";
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return [];
    }
  }

  Future<List<dynamic>> getRecipeIngred(String sURL, String jsonObject, String shopDate) async {

    sh = fx.determinephoenix();

    try {

      final response = await http.get(Uri.parse('$API/$sURL/$jsonObject/$shopDate/$sh/'));
      // final response = await http.get(Uri.parse('$API/$sh/'), headers: headers, body: jsonObject);
      
      // print('555555555555555555555555555555');
      // print(response.statusCode);
      // print(response.body);
      
      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);
        return result;
      } else {
        throw "Can't get recipe ingredients.";
      }

    } catch(err) {
      if (kDebugMode) { print('WTF - $err'); }
      return [];
    } 
  }


  

  
  Future<List<dynamic>> getCookPageList(String listType) async {
    
    // byStore = -1 for all stores. 
    
    sh = fx.determinephoenix();
    try {
      if (kDebugMode) { print( '************ fetch  cooking list  -   *********** '); }
      final response = await http.get(Uri.parse('$API/cook-list/${currUser.userIDString}/$listType/$sh/'));
      
      // print(response.statusCode);
      // print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        // print(result);
        return result;
      } else {
        throw "Can't get Cooking List.";
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return [];
    }
  }







  // ****************    updates  *******

  sendMenuUpdates(String menuChanges) async {

    sh = fx.determinephoenix();

    try {
      // final response = await http.patch(Uri.parse('$API/menu-update/$menuChanges/${currUser.userIDString}/$sh/'), headers: headers, body: menuChanges);
      final response = await http.patch(Uri.parse('$API/menu-update/${currUser.userIDString}/$sh/'), headers: headers, body: menuChanges);

      if (response.statusCode == 200) {
        return true;
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return false;
    }
  }


  sendAppVersionUpdates(int userId, int newVersion) async {

    sh = fx.determinephoenix();

    try {
      // final response = await http.patch(Uri.parse('$API/menu-update/$menuChanges/${currUser.userIDString}/$sh/'), headers: headers, body: menuChanges);
      final response = await http.patch(Uri.parse('$API/user-version/$userId/$newVersion/$sh/'));   //  headers: headers, body: menuChanges);

      if (response.statusCode == 200) {
        return true;
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return false;
    }
  }






  Future<bool> sendShopUpdates(String shopChanges) async {

    sh = fx.determinephoenix();

    try {
      final response = await http.patch(Uri.parse('$API/shop-update/${currUser.userIDString}/$sh/'), headers: headers, body: shopChanges);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return false;
    }
  }





}