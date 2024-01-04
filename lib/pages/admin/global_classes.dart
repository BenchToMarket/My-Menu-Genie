

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
late CurrentStore currStore;


class GlobalVar {

  int _MINS_UPDATE_MENU = 5; 
  DateTime _dateUpdatedMenu = DateTime(1976, 1, 1);
  
  int get MINS_UPDATE_MENU => _MINS_UPDATE_MENU;
  DateTime get dateUpdatedMenu => _dateUpdatedMenu;

  late List<dynamic> _menuAll;

  List<dynamic> get menuAll => _menuAll;
  List<dynamic> menuSwipe = [];
  List<dynamic> menuAccept = [];
  List<dynamic> menuReject = [];
  List<dynamic> menuMaster = [];
  
  void popMenuAll(List<dynamic> newList) {
    _menuAll = newList;
  }
  void updatedMenuAll(DateTime updated) {
    _dateUpdatedMenu = updated;
  }


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


class CurrentStore {
  CurrentStore(
      {required this.storeID,
      required this.storeName,
    });

  int storeID;
  String storeName;
}
