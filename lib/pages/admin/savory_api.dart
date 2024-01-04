
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


import 'global_classes.dart';
import 'phoenix.dart';


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

  
  Future<List<dynamic>> getMenuMap() async {
    String shopDate = '2024-01-03';

    sh = fx.determinephoenix();
    try {
      if (kDebugMode) { print( '************ fetch Menu Map -   *********** '); }
      final response = await http.get(Uri.parse('$API/menu-by-store/${currStore.storeID}/${currUser.userIDString}/$shopDate/$sh/'));
      
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
}