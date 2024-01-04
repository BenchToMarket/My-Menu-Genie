
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


import '../menu/menu_create.dart';
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
    createCurrentUserTesting();
    popNavBar();
  }

  createCurrentUserTesting() {
    currUser = CurrentUser(
        userID: 1,
        userIDString: '1',
        userServeSize: 2,
      );
    currStore = CurrentStore(
        storeID: 1,
        storeName: 'Publix',
      );

    // my_screenWidth = MediaQuery.of(context).size.width;
    // my_screenheight = MediaQuery.of(context).size.height;
  }



  void popNavBar() {
    
    // DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day); 
    // DateTime memberIsNewToday = DateTime.parse(curr_user.memberSince);

    // if (memberIsNewToday.compareTo(today) == 0) {
    //   isNewMember = true;
    // }

    _children = [

      const MenuCreate(),
      const MenuCreate(),
      const MenuCreate(),
      const MenuCreate(),

    ];
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _children[_selectedNav],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xFFF8B249),
          selectedFontSize: 16.0,
          unselectedFontSize: 16.0,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            
            BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.userGroup),
                  label: 'Menu',
                ),

            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.personRunning),
                label: 'Shop', 
              ),

            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.trophy), 
                label: 'Cook', 
              ),

            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.ellipsis),
              label: 'More',
            ),
          ],

          currentIndex: _selectedNav,
          selectedItemColor: Colors.green[700], // Color(0xFF3CBC6D),      
          onTap: _onNavigationTapped,
        ),
      ),
    );
  }
}




