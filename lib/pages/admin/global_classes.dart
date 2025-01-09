

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:math';

// *******************************************************************************
// must switch from development to production server
// *******************************************************************************

//  development server database
const String API = 'http://10.0.2.2:8000';


// *** Production Server database
// const String API = 'https://cardiacpeak.net';


// test on actual device
// const String API = 'http://192.168.1.64:8000';   # check my ipconfig - wireless LAN Adapter
// const String API = 'http://192.168.1.99:8000';
// need to run server with: python manage.py runserver 0.0.0.0:8000


// **** production - set to false, also comment out loginUser(); in admin_splash_screen
bool isTest = true;

// const String test_server = 'https://cardiacpeak.net'; //For video - must change when we change ngrok

// late double my_screenWidth;
// late double my_screenheight;
late CurrentUser currUser;
Store? currStore;
  
late double my_screenWidth;
late double my_screenHeight;
late double my_screenDisplay;
int cpAppVersion = -1;    // -1 sent to server means did not fail in getAppVersion, but somewhere else

const headers = {
  "Content-Type": "application/json"
}; // , "Connection": "keep-alive"};
// AWS headers - https://lightsail.aws.amazon.com/ls/docs/en_us/articles/amazon-lightsail-distribution-request-and-response#request-custom-headers-behavior


const Color blueColor = Color(0xFF2076AE);
const Color goldColor = Color(0xFFEAC13B);  //  Color(0xFFFDBB00);  //  Color(0xFFDBCA4C);  //   Color(0xFFffb102);

const Color goldColorLight = Color(0xFFF6E6B0); 

const Color greenColor = Color(0xFF3CBC6D);
const Color orangeColor = Color(0xFFe9813f);

// iamge for splashscreen: https://otvet.mail.ru/question/214851297


class GlobalVar {


  String menuDate = 'Select';     // this is the date that marks - NO Date Picked
  String shopDate = 'Select';     // this is the date that marks - NO Date Picked

  // this is the new way to track changes, we dont have to fetch menu unless changes
  bool changesMadeMenu = false;
  bool changesMadeBuy = false;
  bool changesMadeMenuToCook = false;
  // bool changesMadeVerify = false;
  bool creatingMenu = false;
  bool shopThreshMet = false;
  bool shoppingListPopulated = false;

  // use both together (with dateShopCommmit) to show committed shopping for 60 minutes
  bool changedMenuCommit = true;
  int lastMenuWeShow = 4;   

  // updated is for items like defaults, not item changes
  bool updatedStores = true;  // when startup we will need to reload data 
  bool updatedServings = true;


  bool isSaving = false;

  int menuActiveTab = 1;
  int shopActiveTab = 1;

  int shopSubStore = 0;
  int shopSubCat = 0;

  List<Store> userStores = [];

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;
  void setIsAdmin(bool newValue) {
    _isAdmin = newValue;
  }

 

  // int _MINS_UPDATE_STORE = 60; 
  // DateTime _dateUpdatedStore = DateTime(1976, 1, 1);
  
  // int get MINS_UPDATE_STORE => _MINS_UPDATE_STORE;
  // DateTime get dateUpdatedStore => _dateUpdatedStore;

  int _MINS_UPDATE_MENU = 60; // = 2; // = 60; 
  DateTime _dateUpdatedMenu = DateTime(1976, 1, 1);
  
  int get MINS_UPDATE_MENU => _MINS_UPDATE_MENU;
  DateTime get dateUpdatedMenu => _dateUpdatedMenu;

  int _MINS_UPDATE_SHOP = 60; //  = 2; // = 60; 
  DateTime _dateUpdatedShop = DateTime(1976, 1, 1);
  
  int get MINS_UPDATE_SHOP => _MINS_UPDATE_SHOP;
  DateTime get dateUpdatedShop => _dateUpdatedShop;

  int _MINS_SHOP_COMMIT = 2; // = 60; 
  DateTime _dateShopCommit = DateTime(1976, 1, 1);    // when re-start - will not show committed menu 
  
  int get MINS_SHOP_COMMIT => _MINS_SHOP_COMMIT;
  DateTime get dateShopCommit => _dateShopCommit;
 
  int _MINS_UPDATE_COOK = 60; //  = 2; // = 60; 
  DateTime _dateUpdatedCook = DateTime(1976, 1, 1);
  
  int get MINS_UPDATE_COOK => _MINS_UPDATE_COOK;
  DateTime get dateUpdatedCook => _dateUpdatedCook;


  List<dynamic> menuCommit = [];
  Map<String, dynamic> activeMenu = {};
  Map<String, dynamic> activeShop = {};

  List<dynamic> _menuAll = [];

  List<dynamic> menuSwipe = [];
  List<dynamic> menuAccept = [];
  List<dynamic> menuReject = [];
  // List<dynamic> menuMaster = [];
  List<int> recpAccept = [];           // subset of menuMaster that is accepted, used for costs & shopping
  List<dynamic> recpIngred = [];

  List<dynamic> get menuAll => _menuAll;
  
  void popMenuAll(List<dynamic> newList) {
    _menuAll = newList;
  }
  void updatedMenuAll(DateTime updated) {
    _dateUpdatedMenu = updated;
  }

  // void updatedStore(DateTime updated) {
  //   _dateUpdatedStore = updated;
  // }

  
  List<dynamic> _shoppingList = [];
  List<dynamic> get shoppingList => _shoppingList;
  
  void popShoppingList(List<dynamic> newList) {
    _shoppingList = newList;
    // _shoppingList = {'storeID': storeID, 'shopping:ist':newMap};
  }

  List<dynamic> shopCategory = [];
  List<dynamic> shopBuyAll= [];
  List<dynamic> shopBuy = [];
  List<dynamic> shopDontBuy = [];
  List<dynamic> shopVerifyAll = [];
  List<dynamic> shopVerify = [];
  List<dynamic> shopDontVerify = [];


  List<dynamic> cookingList = [];
  
  // List<dynamic> get shopAll => _shopAll;
  
  // void popShopAll(List<dynamic> newList) {
  //   _shopAll = newList;
  // }
  // void updatedShopAll(DateTime updated) {
  //   _dateUpdatedShop = updated;
  // }

  void updatedShopCommit(DateTime updated) {
    _dateShopCommit= updated;
  }

  void updatedCook(DateTime updated) {
    _dateUpdatedCook= updated;
  }


  // Map<String, dynamic> _shoppingList = {};
  // Map<String, dynamic> get shoppingList => _shoppingList;
  
  // void popShoppingList(Map<String, dynamic> newMap) {
  //   _shoppingList = newMap;
  //   // _shoppingList = {'storeID': storeID, 'shopping:ist':newMap};
  // }


}


class GlobalFunctions {
  String formatDate(String d) {
    // date result: "2020-09-12",
    // formating help for other - String date = ((d.split(" ")[0]) + ' ' + (d.split(" ")[1]) + ' ' + (d.split(" ")[1]));

    DateTime toDate = DateTime.parse(d);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String toString = formatter.format(toDate);

    return toString;
  }


  String FormatDate(String d) {
    // date result: "2020-09-12",
    // formating help for other - String date = ((d.split(" ")[0]) + ' ' + (d.split(" ")[1]) + ' ' + (d.split(" ")[1]));

    DateTime toDate = DateTime.parse(d);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String toString = formatter.format(toDate);

    return toString;
  }

  String FormatDateDow(String d) {
    // date result: "Monday, Aug 22",

    DateTime toDate = DateTime.parse(d);
    final DateFormat formatter = DateFormat('EEEE, MMM dd');
    final String toString = formatter.format(toDate);

    return toString;
  }

  // String FormatDateLong(String d) {
  //   // date result: "Monday, August 22",

  //   DateTime toDate = DateTime.parse(d);
  //   final DateFormat formatter = DateFormat('EEEE, MMMM dd');
  //   final String toString = formatter.format(toDate);

  //   return toString;
  // }

  String toLowerCaseButFirst(String s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase();


  static const chars = "abcdefghjkmnopqrstuvwxyzABCDEFGHJKMNOPQRTUVWXYZ0123456789";

  String RandomString(int strlen) {
    Random rnd = Random(new DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < strlen; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
  }

  seenInfoSet(int pos, String value) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    currUser.seenInfo = currUser.seenInfo.replaceRange(pos, pos+1, value);
    prefs.setString('seenInfo', currUser.seenInfo);

  }

}


class CurrentUser {
  
  int userID;
  String userIDString;
  int userServeSize;
  // List<int> userStores;
  int userPlan;

  String seenInfo;
  
  CurrentUser(
      {required this.userID,
      required this.userIDString,
      required this.userServeSize,
      // required this.userStores,
      required this.userPlan,
      required this.seenInfo,
    });

  // Future<CurrentUser> 
  changeCurrentUser(String whatChange, int id, int servSize, BuildContext context) async {
    // this.userID = id;
    // this.userIDString = id.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (whatChange == 'serving') {
      this.userServeSize = servSize;
      prefs.setInt("userServeSize",servSize);
    }
    
    
  }


}


class Store {
  Store(
      {required this.storeID,
      required this.storeName,
    });

  int storeID;
  String storeName;

  ChangeStore(int id, String name) {

    this.storeID = id;
    this.storeName = name;

  }
  
}
