import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
import '../user/user_benefits.dart';
import 'more_help.dart';


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

  bool _hasConnect = true;
  final double _sliderMargin = 90.0;
  bool _sliderBadConnect = false;

  Map<String, dynamic> userVerify = {};
  String updateNeeded = 'good';

  @override
  void initState() {
    super.initState();

    // production - turn both off
    // once user is logged in, they can't change users (for now)

    if (isTest == true) {
      // testNoUser(); // this skips loading of SharedPreferences
      loginUser(); // this will load defined SharedPreferences
    }

    checkConnectionInBackground();
    startApp();

  }

  void startApp() {
  
    getAppVersion();
    startTimer();
  }

  void checkConnectionInBackground() {
    // Run the connection check in the background
    Future.microtask(() async {
      _hasConnect = await httpSavory.checkConnection();

      if (!_hasConnect) {
        // Handle the connection failure (e.g., show a message)
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
              _sliderBadConnect = true; 
          });
        });
      }
    });
  }

  
  shopCancelConnect() {
    setState(() {
      _sliderBadConnect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    my_screenWidth = MediaQuery.of(context).size.width;
    my_screenHeight = MediaQuery.of(context).size.height;
    my_screenDisplay = MediaQuery.of(context).size.height -    // total height 
      kToolbarHeight -                      // top AppBar height
      MediaQuery.of(context).padding.top -  // top padding
      kBottomNavigationBarHeight;            // BottomNavigationBar height

    return Scaffold(
      body: Stack(
        children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    // image: AssetImage("images/cardiac_pic.jpg"),
                    image: AssetImage("images/genie_female.jpg"),
                    fit: BoxFit.fitHeight),
              ),
            ),

            // Bad Connection
            AnimatedPositioned(
              top: (my_screenHeight - my_screenDisplay) / 2,  //, 100.0,
              left: _sliderBadConnect ? (_sliderMargin / 2) : (my_screenWidth + 80.0),
              duration: const Duration(milliseconds: 500),
              child: SliderBadConnection(
                sliderMargin: _sliderMargin,
                fromPage: 'splash',
                cancelConnect: shopCancelConnect,
              )
            )

      ],)



      // body: Container(
      //   decoration: const BoxDecoration(
      //     image: DecorationImage(
      //         // image: AssetImage("images/cardiac_pic.jpg"),
      //         image: AssetImage("images/genie_female.jpg"),
      //         fit: BoxFit.fitHeight),
      //   ),
      // ),
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
    prefs.setInt("currentUserID",1);    // 3-jessica
    prefs.setInt("userServeSize",4);  
    prefs.setInt('appVersion', 1);
    prefs.setInt('userPlan', 2);
    // prefs.setStringList('store_list', ["1"]);
    prefs.setString('seenInfo', '0222222222');      // take to 0 if we never show again
    // seenInfo [0]-menu_create, [1]-shop-locked
    


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

    print('-----   in start timer  ------');

    Future.delayed(const Duration(seconds: 2), () {
      isUserLogedIn();
    });
  }

  bypassedUpgrade() {

    updateNeeded = 'bypassed';

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
        updateNeeded = await sendUpdatedVersionToServer(prefs.getInt('currentUserID')!, 'update');
      } else {
        updateNeeded = await sendUpdatedVersionToServer(prefs.getInt('currentUserID')!, 'same');
      }
    } else {
      // we send cpAppVersion if we had an update
      if (cpAppVersion != prefs.getInt('appVersion')) {
        prefs.setInt("appVersion", cpAppVersion);
        updateNeeded = await sendUpdatedVersionToServer(prefs.getInt('currentUserID')!, 'update');    
      } else {
        updateNeeded = await sendUpdatedVersionToServer(prefs.getInt('currentUserID')!, 'same');    
      }
    }

    // was on cardiac peak like this?
    // if (prefs?.getString('seenInfo') == null) {       // ** this is when user upgrades
    //   prefs?.setString('seenInfo', '0002222222');     // 0-onboard, 1-intro, 2-goal-slider, 
    // }

  }


  Future<String> sendUpdatedVersionToServer(int userId, String sendingUpdate) async {
    // cpAppVersion is a global variable, so no need to send here

    print('------   sending update version ----');

    Map<String, dynamic> result = {};

    result = await httpSavory.sendAppVersionUpdates(userId, cpAppVersion, sendingUpdate);
    // options are: good, force (must update), request (ask to update)

    print('-- result from update api -- ' + result['result'].toString());
    updateNeeded = result['result'];

    return result['result'];
  }


  void isUserLogedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //  updateNeeded - // options are: good, force (must update), request (ask to update)
    print('---------      in  is user logged in   --------');

    if (prefs.getBool('isLoggedIn') == null) {
      prefs.setBool("isLoggedIn", false);
    }



    var status = prefs.getBool('isLoggedIn'); // ?? false;
    print('------  isUserLogedIn  -------');
    print(status);
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

      // print('444444444444444444444444444444444');
      // print(updateNeeded);
      
      if (updateNeeded == 'force' || updateNeeded == 'request') {
        print('***   Force User to Update ****');
        Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) =>
              ForceUpgrade(
                upgradeNeeded: updateNeeded,
                bypassUpgradeClicked: bypassedUpgrade,
                )));
        return;
      }


      currUser = CurrentUser(
        userID: prefs.getInt("currentUserID")!,
        userIDString: prefs.getInt("currentUserID").toString(),
        userServeSize: prefs.getInt("userServeSize")!,
        userPlan: prefs.getInt("userPlan")!,
        seenInfo: prefs.getString("seenInfo")!,
      );

      // print('33333333333333333333333333333');
      // print(prefs.getInt("currentUserID"));
      // print(currUser.userID);
      // print(currUser.userIDString);

      // this is on in Cardiac Peak - but should never be null - so commented out
      if (currUser.userID == null || currUser.userIDString == null) {
        // Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => UserSignup()));
        Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => UserBenefits()));
        return;
      }

      if (prefs.getInt('currentUserID')! <= 30) {
        // == 1 || prefs.getInt('currentUserID') == 34 || prefs.getInt('currentUserID') == 41 || prefs.getInt('currentUserID') == 53) {
        Provider.of<GlobalVar>(context, listen: false).setIsAdmin(true);
      }

      userVerify = await httpSavory.getVerifiedUser(currUser.userID, cpAppVersion);   // sending appVersion in case user is not logged into an old version
      if (userVerify['error'] == 'noconnection'){
        print('********  no connection ******');
        // repeating below code so we can keep const - since it is the nav bar
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MyBottomNavigationBar(noInternetConnection: true,),
            transitionDuration: const Duration(seconds: 3),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ),
        );
      }


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
          pageBuilder: (_, __, ___) => const MyBottomNavigationBar(noInternetConnection: false,),
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
            // pageBuilder: (_, __, ___) => UserSignup(),
            pageBuilder: (_, __, ___) => UserBenefits(),
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

class ForceUpgrade extends StatelessWidget {

final String upgradeNeeded;
final VoidCallback? bypassUpgradeClicked;

const ForceUpgrade({required this.upgradeNeeded, required this.bypassUpgradeClicked, Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
return Scaffold(
  backgroundColor: Colors.white.withOpacity(0.85), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text(upgradeNeeded == 'force' ? 'Upgrade Reuqired' : 'Upgrade Suggested', style: TextStyle(color: Colors.white))),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text((upgradeNeeded == 'force') ? "Upgrade Required" : 'Upgrade Suggested', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),),
          ),

          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              margin: EdgeInsets.all(50.0),
              child: Text(
                upgradeNeeded == 'force' 
                  ? 'We have made Major Updates to how our App funcitons. As update is required to use. \n\nFor support, email support@MenuGenie.ai' 
                  : 'We have made Updates to how our App funcitons. An App Update is preferred, but not required. You may experience some odd functionality. \n\nFor support, email support@MenuGenie.ai', 
                style: TextStyle(fontSize: 18.0),)),
          ),

          Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 30.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary:  blueColor, // background
                  onPrimary: Colors.black, // foreground
                  padding: EdgeInsets.all(16.0),    
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),) 
                ),
                onPressed: () {

                  try {
                    String link_google = 'https://play.google.com/store/apps/details?id=ai.menu_genie';
                    launchUrl(Uri.parse(link_google), mode: LaunchMode.externalApplication);
                  } catch (err) {
                    if (kDebugMode) { print('WTF - $err'); }
                  }

                  Future.delayed(const Duration(seconds: 2), () {
                    SystemNavigator.pop();
                  });
                  
                },
                child:  Text('Upgrade on Google Play', style: TextStyle(fontSize: 18.0)),
            ),
          ),


          (upgradeNeeded == 'request')
            ?
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: FlatButton(
                  // color: Colors.teal[400],
                  onPressed: () {
                    bypassUpgradeClicked!();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Keep Current Version',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: blueColor,
                    ),
                  ),
                ),
              )
            : Container()


        ],
      ),
  );
 }
}
