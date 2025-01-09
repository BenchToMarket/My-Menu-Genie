

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_genie/pages/save/save_month.dart';
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart';
import 'dart:convert';

import '../menu/menu_create.dart';
import '../shop/shop_create.dart';
import '../cook/cook_page.dart';
import '../admin/more_help.dart';
import '../admin/global_classes.dart';
import '../admin/savory_api.dart';


// Nav Bar
// https://stackoverflow.com/questions/49681415/flutter-persistent-navigation-bar-with-named-routes
// https://www.youtube.com/watch?v=18PVdmBOEQM


class MyBottomNavigationBar extends StatefulWidget {

  // final bool fromStart;
  final bool noInternetConnection; 
  const MyBottomNavigationBar({required this.noInternetConnection, Key? key}) : super(key: key);

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}


class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
 
 late GlobalVar globals;
 final HttpService httpSavory = HttpService();

 int _selectedNav = 0;
  // bool isNewMember = false;

  List<Widget> _children = [];  // is widget controller for botton Nav Bar


  void _onNavigationTapped(int index) {
    setState(() {
      _selectedNav = index;
    });
  }

  // void startTimer() {
  //   _timer = Timer(Duration(minutes: 10), () {
  //   _onNavigationTapped(0);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // createCurrentUserTesting();
    globals = Provider.of<GlobalVar>(context, listen: false);
    popNavBar();
  }

  // createCurrentUserTesting() {
  //   currUser = CurrentUser(
  //       userID: 1,
  //       userIDString: '1',
  //       userServeSize: 2,
  //     );
  //   currStore = Store(
  //       storeID: 1,
  //       storeName: 'Publix',
  //     );

  //   // my_screenWidth = MediaQuery.of(context).size.width;
  //   // my_screenheight = MediaQuery.of(context).size.height;
  // }



  void popNavBar() {
    
    // DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day); 
    // DateTime memberIsNewToday = DateTime.parse(curr_user.memberSince);

    // if (memberIsNewToday.compareTo(today) == 0) {
    //   isNewMember = true;
    // }

    _children = [

      // const ShopDate(),
      MenuCreate(noInternetConnection: widget.noInternetConnection,),
      const ShopCreate(),
      const SaveMonthly(),
      const CookPage(),
      const MoreHelp(),

    ];
  }

  @override
  Widget build(BuildContext context) {
    // my_screenWidth = MediaQuery.of(context).size.width;
    // my_screenHeight = MediaQuery.of(context).size.height;

    // prevent using Android nav tools (back button)
    // return WillPopScope(
    //   onWillPop: () async => false,
    //   child: Scaffold(

    return Scaffold(
        body: _children[_selectedNav],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: goldColor,  //  Color.fromARGB(255, 225, 193, 53),   //  Color(0xFFe9813f), //  Color(0xFFe9813f), // Color(0xFFF8B249),  //
          selectedFontSize: 16.0,
          unselectedFontSize: 16.0,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            
            BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 0.0),
                    // child: Icon(FontAwesomeIcons.userGroup),
                    child: Icon(Icons.menu),   
                  ),
                  label: 'Menu',
                ),

            BottomNavigationBarItem(
                // icon: Icon(FontAwesomeIcons.personRunning),
                icon: Icon(Icons.shopping_cart),   
                label: 'Shop', 
              ),

              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.dollarSign), 
                // icon: Icon(FontAwesomeIcons.kitchenSet), 
                // icon: Icon(Icons.fireplace),   
                label: 'Save', 
              ),

            
            BottomNavigationBarItem(
                // icon: Icon(FontAwesomeIcons.fire), 
                icon: Icon(FontAwesomeIcons.bowlRice), 
                // icon: Icon(FontAwesomeIcons.kitchenSet), 
                // icon: Icon(Icons.fireplace),   
                label: 'Cook', 
              ),


            BottomNavigationBarItem(
              // icon: Icon(FontAwesomeIcons.ellipsis),
              icon: Icon(Icons.more_horiz),   
              label: 'More',
            ),
          ],

          currentIndex: _selectedNav,
          selectedItemColor: blueColor, //  Colors.white, // Colors.greenAccent[400], // Colors.yellow, // Colors.green[900], //Colors.green[700], // blueColor,      
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
          // onTap: _onNavigationTapped,

          onTap: (index) async {   
            if (_selectedNav == 0) {
              globals.isSaving = await checkForChangesMenu();
            } else if (_selectedNav == 1) {
              globals.isSaving = await checkForChangesShopStep1DetermineStatus();
            }
            // print('-----    nav bar selected  -------');
            // print(_selectedNav);
            // print(globals.isSaving);

            // might want to only check isSaving for Menu - saving a shopping list does not affect the menu (just shopping list wont be right until menu is saved completely)
            if (globals.isSaving == false && globals.creatingMenu == false) {
              // print('888888888888888888888888888888888888');
              _onNavigationTapped(index);
            }

          },
        ),
      );
    // );
  }





    Future<bool> checkForChangesMenu() async {
      // we are updating menu_user_recp_join table by user_id & recp_dates_id - did user
      // - recp_accept or reject
      // - recp_cook (not here) but same api
      // - serv_size
      // return;

      globals.isSaving = true;

      // Future.delayed(const Duration(milliseconds: 3000), () {
      //   // delay for testing
      //   // below code must be in here
      // });

      if (kDebugMode) { print('-----------------        checking for changes    ----------------'); }
      if (kDebugMode) { print(globals.changesMadeMenu); }

      if (globals.changesMadeMenu == false) {
        return false;
      }
      globals.changesMadeMenu = false;             // do here so we dont try to change the same changes twice
      globals.changesMadeMenuToCook = true;       // so pull another cook menu

      List<dynamic> onlyChanged = [];

      for (var m in globals.menuAll) {        
          if (m['changed'] == true) {
            onlyChanged.add({
              'user_join_id': m['user_join_id'],
              'recp_dates_id': m['recp_dates_id'],
              'recp_accept': m['recp_accept'],
              'recp_cook': m['recp_cook'],
              'serv_size': m['serv_size'],
              'changed': m['changed'],
              });
              m['changed'] = false;
        }
      }

      final jsonChanged = json.encode(onlyChanged);

      await httpSavory.sendMenuUpdates(jsonChanged);

      return false;

    }



  Future<bool> checkForChangesShopStep1DetermineStatus() async {

    print('---   saving step 1  ---');
    // print(globals.activeMenu);

    bool _isSaving = false;
    
    if (globals.activeMenu.isNotEmpty) {
      if (globals.shopThreshMet == true) {
        if (globals.activeMenu['commit_status'] > 2) {
          // 2 - started shopping, but if they have already passed this, we default to current
          _isSaving = await checkForChangesShop(globals.activeMenu['commit_status']);
        } else{ 
          _isSaving = await checkForChangesShop(2);
        }

      } else {
        _isSaving = await checkForChangesShop(globals.activeMenu['commit_status']);
      }
    }

    return _isSaving;
  }
    
  Future<bool> checkForChangesShop(int newStatus) async {

    // print('111111111111111111');
    // print(globals.shopThreshMet);
    
    if (globals.shopThreshMet == false) {return false;}
    print('----    checking for changes on shopping list---- new status:  ' + newStatus.toString());

    // print(globals.changesMadeBuy);
    // print(globals.activeMenu['commit_status']);
    for (var mc in globals.menuCommit) {
      // print(mc);
      if (mc['id'] == globals.activeMenu['id']) {
        if (mc['commit_status_new'] < newStatus) {
          mc['commit_status_new'] = newStatus;
        }
      }
    }
    // print('-------------------  shop buy  ALL -------------');
    // for (var p in globals.shopBuyAll) {
    //   print(p);
    // }

    Map<String, dynamic> shopMap = {'menu': globals.activeMenu, 'buy': globals.shopBuyAll, 'verify': globals.shopVerifyAll};

    final jsonChanged = json.encode(shopMap);

    // print(jsonChanged);

    bool success = await httpSavory.sendShopUpdates(jsonChanged);

    // *** do we need to change in global menu list - or just active
    if (globals.activeMenu['commit_status'] < newStatus) {
        // *** we only do like this IF we are creating a shopping list, if we have do something else
        if (success == true) {
          globals.activeMenu['commit_status'] = newStatus;
          // for (var mc in globals.menuCommit) {
          //   if (mc['id'] == globals.activeMenu['id']) {
          //     if (mc['commit_status'] < 2) {
          //       mc['commit_status_new'] = 2;
          //     }
          //     print('  -----     our active menu commit  ------');
          //   }
          // }
        }
    }

    return false;   // not still saving 

  }





}




