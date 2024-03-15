

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_genie/pages/save/save_month.dart';


import '../menu/menu_create.dart';
import '../shop/shop_create.dart';
import '../cook/cook_page.dart';
import '../admin/more_help.dart';
import '../admin/global_classes.dart';



// Nav Bar
// https://stackoverflow.com/questions/49681415/flutter-persistent-navigation-bar-with-named-routes
// https://www.youtube.com/watch?v=18PVdmBOEQM


class MyBottomNavigationBar extends StatefulWidget {

  // final bool fromStart;
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}


class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
 
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
      const MenuCreate(),
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
          onTap: _onNavigationTapped,
        ),
      ),
    );
  }
}




