

import 'package:intl/intl.dart';


// *******************************************************************************
// must switch from development to production server
// *******************************************************************************

//  development server database
const String API = 'http://10.0.2.2:8000';


// *** Production Server database
// const String API = 'https://cardiacpeak.net';


// const String test_server = 'https://cardiacpeak.net'; //For video - must change when we change ngrok

// late double my_screenWidth;
// late double my_screenheight;
late CurrentUser currUser;
late Store currStore;
  
late double my_screenWidth;
late double my_screenHeight;


class GlobalVar {


  String shopDate = 'Select';     // this is the date that marks - NO Date Picked
  bool changesMadeMenu = false;
  bool changesMadeBuy = false;
  // bool changesMadeVerify = false;
  bool shopThreshMet = false;


  int menuActiveTab = 1;
  int shopActiveTab = 1;

  int shopSubStore = 0;
  int shopSubCat = 0;

  List<Store> userStores = [];


  int _MINS_UPDATE_MENU = 5; 
  DateTime _dateUpdatedMenu = DateTime(1976, 1, 1);
  
  int get MINS_UPDATE_MENU => _MINS_UPDATE_MENU;
  DateTime get dateUpdatedMenu => _dateUpdatedMenu;

  int _MINS_UPDATE_SHOP = 5; 
  DateTime _dateUpdatedShop = DateTime(1976, 1, 1);
  
  int get MINS_UPDATE_SHOP => _MINS_UPDATE_SHOP;
  DateTime get dateUpdatedShop => _dateUpdatedShop;

  List<dynamic> menuCommit = [];
  Map<String, dynamic> activeMenu = {};

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
  
  // List<dynamic> get shopAll => _shopAll;
  
  // void popShopAll(List<dynamic> newList) {
  //   _shopAll = newList;
  // }
  // void updatedShopAll(DateTime updated) {
  //   _dateUpdatedShop = updated;
  // }




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

}


class CurrentUser {
  
  int userID;
  String userIDString;
  int userServeSize;
  
  CurrentUser(
      {required this.userID,
      required this.userIDString,
      required this.userServeSize,
    });

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
