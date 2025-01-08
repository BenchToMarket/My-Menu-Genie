
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
      
      print(response.statusCode);

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



  Future<Map<String, dynamic>> createNewUser(String userDetails) async {

    print('------      in create   new user -----------');
    sh = fx.determinephoenix();
    int newID = -1;

    try {
    
      final response = await http.patch(Uri.parse('$API/user-create/$sh/'), headers: headers, body: userDetails);

      if (response.statusCode == 200) {
        // print(response.body);
        Map<String, dynamic> result = jsonDecode(response.body);
        return result;
      } else {
        throw {'new_id': -1};
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return {'new_id': -1};
    }
  }


  // Future<int> createNewUser_old(String userDetails) async {

  //   sh = fx.determinephoenix();
  //   int newID = -1;

  //   try {
    
  //     final response = await http.patch(Uri.parse('$API/user-create/$sh/'), headers: headers, body: userDetails);

  //     if (response.statusCode == 200) {
  //       // print(response.body);
  //       newID = int.parse(response.body);
  //       return  newID;
  //     } else {
  //       throw "Can't create  user.";
  //     }
  //   } catch (err) {
  //     if (kDebugMode) { print('WTF - $err'); }
  //     return newID;
  //   }
  // }


  
  Future<Map<String, dynamic>> getUserPlan() async {

    sh = fx.determinephoenix();

    try {
    
      if (kDebugMode) { print( '************ fetch User Plan   *********** '); }
      final response = await http.get(Uri.parse('$API/user-plan/${currUser.userIDString}/$sh/'));

      if (response.statusCode == 200) {
        // print(response.body);
        Map<String, dynamic> result = jsonDecode(response.body);
        return result;
      } else {
        throw {'user_plan': -1};
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return {'user_plan': -1};
    }
  }

  
  Future<Map<String, dynamic>> getUserDefaults() async {

    sh = fx.determinephoenix();

    try {
    
      if (kDebugMode) { print( '************ fetch User Defaults   *********** '); }
      final response = await http.get(Uri.parse('$API/user-defaults/${currUser.userIDString}/$sh/'));

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);
        return result;
      } else {
        throw {'user_default': -1};
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return {'user_default': -1};
    }
  }

  sendDefaultUpdates(String defaultType, int intBeg, int intEnd, String strBeg, String strEnd) async {

    sh = fx.determinephoenix();

    try {
     
      final response = await http.patch(Uri.parse('$API/default-update/${currUser.userIDString}/$defaultType/$intBeg/$intEnd/$strBeg/$strEnd/$sh/')); 

      print(response.body);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return false;
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

        // print(result);
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
      // print(shopDate);
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


  Future<List<dynamic>> rateRecipeReturnNewCookList(int recpDateID, int rating,  String listType) async {
    
    // byStore = -1 for all stores. 
    
    sh = fx.determinephoenix();
    try {
      if (kDebugMode) { print( '************ rating recipe   and  fetch  cooking list  -   *********** '); }
      final response = await http.get(Uri.parse('$API/rate-recipe/${currUser.userIDString}/$recpDateID/$rating/$listType/$sh/'));
      
      // print(response.statusCode);
      // print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        // print(result);
        return result;
      } else {
        throw "Can't Rate Recipe.";
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return [];
    }
  }

  

  Future<bool> checkConnection() async {
    // final url = 'http://<your_django_server_url>/api/'; // Replace with your Django API endpoint

    try {
      final response = await http.get(Uri.parse(API)).timeout(
        Duration(seconds: 3), // Set a 2-second timeout
        onTimeout: () {
          // Handle timeout
          if (kDebugMode) { print('Connection timed out'); }
          return http.Response('Error: Timeout', 408);
          // return false; 
        },     
      );

      if (response.statusCode == 200) {
        if (kDebugMode) { print('Connected to Django API!'); }
        return true;
      } else {
        if (kDebugMode) { print('Failed to connect: ${response.statusCode}'); }
        return false;
      }
    } catch (e) {
      if (kDebugMode) { print('Error: $e'); }
      return false;
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


  Future<Map<String, dynamic>> sendAppVersionUpdates(int userId, int newVersion, String sendingUpdate) async {

    sh = fx.determinephoenix();

    try {
      // final response = await http.patch(Uri.parse('$API/menu-update/$menuChanges/${currUser.userIDString}/$sh/'), headers: headers, body: menuChanges);
      final response = await http.patch(Uri.parse('$API/user-version/$userId/$newVersion/$sendingUpdate/$sh/'));   //  headers: headers, body: menuChanges);

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);
        return result;
      } else {
        throw {'result': 'falied'};
      }
    } catch (err) {
      if (kDebugMode) { print('WTF - $err'); }
      return {'result': 'falied'};
    }
  }

  Future<bool> sendAppError(String appError) async {

    print('  ------ in  sendAppError  or NEW USER flag  ---------');
    try {
      final response = await http.post(Uri.parse(API + '/app-error/' + appError  + '/' + currUser.userIDString + '/'));

      return true;
    } catch (err) {
      print('WTF');
      print(err);
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