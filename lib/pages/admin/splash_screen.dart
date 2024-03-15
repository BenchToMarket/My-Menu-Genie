import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

import 'navigation_bar.dart';
import 'global_classes.dart';
// import 'more_help.dart';
// import '../user/user_login.dart';
import '../user/user_signup.dart';
import 'phoenix.dart';
import 'savory_api.dart';
import 'force_action.dart';


import 'package:package_info_plus/package_info_plus.dart';
// version info:  https://stackoverflow.com/questions/23613279/access-to-pubspec-yaml-attributes-version-from-dart-app

// shared preferences & splash screen
// https://stackoverflow.com/questions/57405433/flutter-how-to-keep-user-logged-in-and-make-logout

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  // final CurrentUser userService = CurrentUser();
  
  // ***********************************
  // this is the entry point
  // ***********************************

  final PhoenixFunctions fx = PhoenixFunctions();
  String sh = '';
  final HttpService httpSavory = HttpService();

  Map<String, dynamic> userVerify = {};

  @override
  void initState() {
    super.initState();

    // production - turn both off
    // once user is logged in, they can't change users (for now)

    if (isTest == true) {
      //testNoUser(); // this skips loading of SharedPreferences
      loginUser(); // this will load defined SharedPreferences
    }

    getAppVersion();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    my_screenWidth = MediaQuery.of(context).size.width;
    my_screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              // image: AssetImage("images/cardiac_pic.jpg"),
              image: AssetImage("images/genie_female.jpg"),
              fit: BoxFit.fitHeight),
        ),
      ),
    );
  }

  // ** ToDo - only for testing, remove this b/c this will be saved on device
  void loginUser() async {
    print('--- for testing only - loginUser -----');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // list of store prefs
    // https://stackoverflow.com/questions/60220216/flutter-how-to-store-list-of-int-in-shared-preference
    // real user for testing
    prefs.setBool("isLoggedIn", true); // set to false to test Login
    prefs.setInt("currentUserID",52);  
    prefs.setInt("userServeSize",2);  
    prefs.setInt('appVersion', 1);
    // prefs.setStringList('store_list', ["1"]);
    


    if (prefs.getInt('currentUserID')! <= 30) {
      Provider.of<GlobalVar>(context, listen: false).setIsAdmin(true);
    }
        
    // prefs.clear();   // testing only - replicate brand new user
  }

  void testNoUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggedIn", false); // set to false to test Login
  }

  void startTimer() {
    // verifyUser 
    Future.delayed(const Duration(seconds: 2), () {
      isUserLogedIn();
    });
  }

  void getAppVersion() async {
    
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      // not sure if google is restricting PackageInfo on some devices
      // we are getting erroor on create-user, b/c of null cpAppVersion
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      if (isTest == true) {
        if (kDebugMode) { print('userID: ${prefs.getInt('currentUserID')}'); }
        if (kDebugMode) { print('Connection: $API'); }
        if (kDebugMode) { print('in Testing mode: $isTest'); } 
        if (kDebugMode) { print('Menu Genie AI version: ${packageInfo.version}'); }
      }

      cpAppVersion = int.parse(packageInfo.version.substring(4));

    } catch (err) {
      // await httpService.sendAppError(context, err.toString());
      // await httpService.sendAppError(context, 'canLaunchURL_os:  ' + Platform.operatingSystemVersion.toString());
      cpAppVersion = 1;
    }

    // print('-- cp app version -- ' + cpAppVersion.toString());

    // ** turn on for new versions ** 
    // if (isTest == true) {
    //   // this will increase when we release, so we are pretending we have already released while testing
    //   cpAppVersion += 1;
    //   // cpAppVersion -=1;       // *******   only for progress tesing - go back to adding 1
    // }

    // update on server if changed, but not during testing
    if (isTest == true) {
      if (prefs.getInt('currentUserID') != null) {
        if (prefs.getInt('currentUserID')! > 30) {
          // print('testing app or user --- ' + isTest.toString());
          // If testing and using real users - do not reset version on server
          return;
        }
      }
    }

    // print('-- app versions --');
    // print(cpAppVersion);
    // print(prefs.getInt('appVersion'));
    // // return;


    if (prefs.getInt('appVersion') == null) {
      // if null - this is the 1st time the user updated the App when checking version
      // prior to 1.0.4 - we did not have this, so server assumes version 1.0.3 (or 3)
      // 1.0.4 and after - we will send any changes to the server
      // version 2.0.1 - will be 2000001 in server
      prefs.setInt("appVersion", cpAppVersion);
      if (prefs.getInt('currentUserID') != null) {
        sendUpdatedVersionToServer(prefs.getInt('currentUserID')!);
      }
    } else {
      // we send cpAppVersion if we had an update
      if (cpAppVersion != prefs.getInt('appVersion')) {
        prefs.setInt("appVersion", cpAppVersion);
        sendUpdatedVersionToServer(prefs.getInt('currentUserID')!);
      }
    }

  }


  Future<bool> sendUpdatedVersionToServer(int userId) async {
    // cpAppVersion is a global variable, so no need to send here

    print('------   sending update version ----');

    bool success = httpSavory.sendAppVersionUpdates(userId, cpAppVersion);

    return success;
  }


  void isUserLogedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('isLoggedIn') == null) {
      prefs.setBool("isLoggedIn", false);
    }


    var status = prefs.getBool('isLoggedIn'); // ?? false;
    // print('------  isUserLogedIn  -------');
    // print(status);
    // print(prefs.getInt("currentUserID"));
    // print(prefs.getInt("currentUserID"));
    // print(prefs.getString("currentUserName"));

    // print('11111111111111111111111111');
    // print(status);
    // print(prefs.getBool('isLoggedIn'));
    // print(prefs.getInt("currentUserID"));

    if (status! == true) {
      // curr_user = await userService.PopulateCurrentUser();
      // print('222222222222222222222222222');
      currUser = CurrentUser(
        userID: prefs.getInt("currentUserID")!,
        userIDString: prefs.getInt("currentUserID").toString(),
        userServeSize: prefs.getInt("userServeSize")!,
      );

      // print('33333333333333333333333333333');
      // print(prefs.getInt("currentUserID"));
      // print(currUser.userID);
      // print(currUser.userIDString);

      // this is on in Cardiac Peak - but should never be null - so commented out
      if (currUser.userID == null || currUser.userIDString == null) {
        Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => UserSignup()));
        return;
      }

      if (prefs.getInt('currentUserID')! <= 30) {
        // == 1 || prefs.getInt('currentUserID') == 34 || prefs.getInt('currentUserID') == 41 || prefs.getInt('currentUserID') == 53) {
        Provider.of<GlobalVar>(context, listen: false).setIsAdmin(true);
      }

      userVerify = await httpSavory.getVerifiedUser(currUser.userID, cpAppVersion);   // sending appVersion in case user is not logged into an old version

      if (userVerify['force_action'] == 'upgrade' || userVerify['force_action'] == 'stop') {
        // go to force upgrade screen
        // ForceAction(appVersion: cpAppVersion.toString());
        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ForceAction(appVersion: cpAppVersion.toString(), userVerify: userVerify,),
              transitionDuration: const Duration(seconds: 3),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ),
          );
        
        return;

      }

      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyBottomNavigationBar()));
      // ignore: use_build_context_synchronously

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MyBottomNavigationBar(),
          transitionDuration: const Duration(seconds: 3),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    } else {
      
      // userVerify = await httpSavory.getVerifiedUser(-1, cpAppVersion); 

     
        // print('666666666666666666666666666666666'); 
        // login screen - when done, now going to dashboard
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserLogin()));
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => UserSignup(),
            transitionDuration: const Duration(seconds: 2),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ),
        );
    }
  }
}

class NewVersion {
  int appVersion;
  // String last_login;   - got error on Server when sending String, error in App in json.encode with Date

  NewVersion({required this.appVersion});

  Map<String, dynamic> toJson() {
    return {
      "app_version": appVersion,
      // "last_login": last_login,
    };
  }
}
