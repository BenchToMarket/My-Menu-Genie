// ignore_for_file: prefer_const_constructors


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:swipe_to/swipe_to.dart';
import 'dart:convert';
import 'dart:async';

import '../admin/global_classes.dart';
import '../admin/savory_api.dart';
import 'menu_shop_date.dart';


class MenuCreate extends StatefulWidget {
  const MenuCreate({Key? key}) : super(key: key);

  @override
  State<MenuCreate> createState() => _MenuCreateState();
}

class _MenuCreateState extends State<MenuCreate> {

  bool _isLoading = false;  
  bool _noInternetConnection = false;

  late GlobalVar globals;
  final HttpService httpSavory = HttpService();

  // late double my_screenWidth;
  // late double my_screenheight;
  // bool changesWereMade = false;

  bool _isDateSelected = true;

  // ignore: todo
  // TODO - timer is to save changes - might not save if user exits app without hitting another tab
  // need to test on device itself 
  // late Timer timer;
  // int timerPeriod = 5;

  // List<int> recpDatesList = [];    this was to add menu to menu_user_recp_join - but doing on server
  
  /// menuMaster - list of list to update changes
  /// [recp_dates_id, recp_accept, servings, changed]

  @override
  void initState() { 

    globals = Provider.of<GlobalVar>(context, listen: false);

    super.initState();
    startFetching();
    // startChangeTimer();
  }

  @override
  void dispose() {
    checkForChanges();
    // if (timer != null) {
    //   timer.cancel();
    // }
    super.dispose();
  } 

  startFetching() async {
     // *** move to splash screen
    // my_screenWidth = MediaQuery.of(context).size.width;
    // my_screenheight = MediaQuery.of(context).size.height;

    print('55555555555555555555555555');
    // print(globals.shopDate);

    // TODO - we will later fetch from server
    globals.userStores = [
      Store( storeID: 1, storeName: 'Publix'), Store( storeID: 2, storeName: 'Fresh Market'),
    ];


    if (globals.shopDate == 'Select') {
      _isDateSelected = false;
      // ** TODO - need to move - after testing internet or 
      fetchMenuCommit();
      return;
    }

    _noInternetConnection = await fetchMenu();

    if (_noInternetConnection == true) {
      if (!mounted) return;
      setState(() { });
    }
  }

  // startChangeTimer() {   
  //   timer = Timer.periodic(Duration(seconds: timerPeriod), (timer) {
  //     // checkForChanges();
  //   });
  // }

  checkForChanges() async {
    // we are updating menu_user_recp_join table by user_id & recp_dates_id - did user
    // - recp_accept or reject
    // - recp_cook (not here) but same api
    // - serv_size
    // return;

    print('-----------------        checking for changes    ----------------');
    // print(globals.changesMadeMenu);

    if (globals.changesMadeMenu == false) return;
    globals.changesMadeMenu = false;             // do here so we dont try to change the same changes twice

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

    httpSavory.sendMenuUpdates(jsonChanged);

  }




  /// **************************************************************************
  /// populating and saving menu changes
  /// menu_user_recp_join table holds the recipes by recp_dates_id (plural) and user
  /// it is empty first time user create a menu for this location / date
  /// 1. we check if empty, if empty put all recipes for this date in here with accept 0 serv_size as user
  ///   -- do we only want to populate if accepted or rejected (probably always pop)
  /// 2. if user moves to accept, we update accept col (accept = -1 for rejection)
  /// 3. if user changes servings, we update serv_size col
  /// Must reconcile this table with globals.swipe and accept and reject
  /// Must update this table if any changes, must check for updates every
  ///   - upped tab, nav bar or x seconds (maybe every 5 seconds)
  /// ****************************************************************************
  /// 
  
  fetchMenuCommit() async {
      globals.menuCommit = await httpSavory.getMenuCommit();
      // print(globals.menuCommit);

  }

  fetchMenu() async {
    
    // globals = Provider.of<GlobalVar>(context, listen: false);
    bool noConnection = false;
    int servSize = currUser.userServeSize;


    int minsSinceUpdate = DateTime.now().difference(globals.dateUpdatedMenu).inMinutes;
    // ********************* for testing
    // minsSinceUpdate = 99999999999999;

    print('mins since updated MENU _--- $minsSinceUpdate');
    if (minsSinceUpdate > globals.MINS_UPDATE_MENU) {
      _isLoading = true;

      fetchMenuCommit();

      List<dynamic> menu = await httpSavory.getMenuMap(globals.shopDate);

      if (menu[0]["error"] == 'noconnection') {
        noConnection = true;
        return noConnection;
      } else {

        clearAllMenus();
        globals.popMenuAll(menu);

        if (globals.menuAll.isNotEmpty) {
          globals.updatedMenuAll(DateTime.now());
        }

        // globals.menuAll.add(globals.menuAll);  testing


        // If globals.menuAll['serv_size'] == -1 - then NOT in menu_user_recp_join - need to add
        // doing on server - no need here 
        // testAndAddToRespJoin();

        // print('1111111111111111111111111111111111111111111111111111111111111111111111');
        for (var m in globals.menuAll) {
          // print(m['recp_dates_id']);
          // recpDatesList.add(m['recp_dates_id']);

          m['recipe_serv_price'] = {'serv_price': 0.00, 'serv_deal': 0.00, 'serv_save': -0.00};

          if (m['recp_accept'] == 0) {
            globals.menuSwipe.add(m);
          } else if (m['recp_accept'] == 1) {
            globals.menuAccept.add(m); 
          } else if (m['recp_accept'] == -1) {
            globals.menuReject.add(m);
          }

          // [recp_dates_id, recp_accept, servings, changed]
          // globals.menuMaster.add([m['recp_dates_id'], m['recp_accept'], m['serv_size'], 0]);

          // print(m['recp_dates_id']);
          // print(m['recp_accept']);
        }

        // print('2222222222222222222222');
        // for (var m in globals.menuSwipe) {
        //   print(m['recp_dates_id']);
        //   print(m['recp_accept']);
        //   print(m['serv_size']);
        // }
        // globals.menuSwipe = globals.menuAll;

        // print('3333333333333333333333333333333333');
        // for (var m in globals.menuAll) {
        //     print('----------------------------------');
        //     print(m['recp_dates_id']);
        //     print(m['recp_accept']);
        //     print(m['serv_size']);
        //     print(m['changed']);
        // }

        // globals.challengesMine = globals.challengesAll['mine'];
        // globals.challengesOpen = globals.challengesAll['open'];
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    return noConnection;
  }

  clearAllMenus() {

      globals.menuAll.clear();
      globals.menuSwipe.clear();
      globals.menuAccept.clear();
      globals.menuReject.clear();
      // globals.menuMaster.clear();
      // recpDatesList = [];
  }



  // **** change top tabs
  fetchMenuCosts() async {

    globals.recpAccept.clear();
    ///  [recp_dates_id, recp_accept, servings, changed]
    /// 1. we have to fetch all accepted Menu and costs
    /// 2. adjust changes to accepted, rejected or back to swipe in menu_user_recp_join
    /// can retrieve by recp_dates_id (this is how user acceptance is recorded)
    /// on server, then we fetch recp_id
    /// then by item, option_id and price, deal_price (if any) & calc savings - all by single serving 
    /// menu_user_recp_join - should remember # of servings for accepted menu

    // // [recp_dates_id, recp_accept, servings, changed]
    // for (var mm in globals.menuMaster) {
    //   if(mm[1] == 1) {
    //     globals.recpAccept.add(mm[0]);
    //   }
    // }

    for (var mm in globals.menuAccept) {
      globals.recpAccept.add(mm['recp_dates_id']);
    }

    final jsonAccepted = json.encode(globals.recpAccept);   // ([1,2]);  // globals.recpAccept);

    globals.recpIngred = await httpSavory.getRecipeIngred('recp-ingred', jsonAccepted, globals.shopDate);

    // there is a much better way to map
    for (var ri in globals.recpIngred) {
      for (var ma in globals.menuAccept) {
        if (ri['recp_dates_id'] == ma['recp_dates_id']) {
          ma['recipe_serv_price'] = ri['recipe_serv_price'];
        }
      }
    }

    setState(() {});      // this is set price and savings by just fetched price data
  }


  createMenuSelected(String selectedDate, bool sameStore) {
    // print('------    create menu selected  -------');
    // print(selectedDate);
    // print(globals.shopDate);
    
    globals.menuActiveTab = 1;

    Future.delayed(const Duration(milliseconds: 100), () {
      // Navigator.of(context).pop();
      setState(() {
        // this resets that shopDate - thus changes display
        _isDateSelected = true;
      });
    });
    
    if (selectedDate != globals.shopDate || sameStore == false) {
        globals.shopDate = selectedDate;
        // globals.shopDate = '2024-01-05';          // *** testing only
        globals.updatedMenuAll(DateTime(1976, 1, 1));         // reset so we pull another menu 
        startFetching();
    }
  }

  chooseNewDate() {
    setState(() {
      _isDateSelected = false;
    });
  }
  

  @override
  Widget build(BuildContext context) {

    if (_noInternetConnection == true) {
      return Center(
        child: Text(
          'Server Connection Error',
          style: TextStyle(color: Colors.yellow, fontSize: 24),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_isLoading) { return Center(child: CircularProgressIndicator()); }

    return DefaultTabController(
      length: 3,
      initialIndex:globals.menuActiveTab, //    1,
      child: Scaffold(
        appBar: AppBar(
              bottom: PreferredSize(
                preferredSize: Size(10.0, 0.0),
                child: TabBar(
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 4.0, color: Colors.white),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.w800
                  ),
                  onTap: (index) async {
                    globals.menuActiveTab = index;
                      if (index == 0) {
                      } else if (index == 1) {
                      } else if (index == 2) {
                        fetchMenuCosts();
                      } 
                      checkForChanges();      // i think we can do after, fetching above pulls based on changed in app
                  },
                  tabs: const [
                    Tab(child: Text('Reject')),
                    Tab(child: Text('Swipe')),
                    Tab(child: Text('Menu')),
                  ],
                ),
              ),

            ),
            body: TabBarView(
              children: [
    
                (_isDateSelected == false)
                  ?
                    ShopDatePicker(startShopDate: globals.shopDate,startStore: currStore.storeID, menuCreatedSelect: createMenuSelected,)
                  : 
                    Center(child: MenuList(
                      listTab: 'reject',
                      activeList: globals.menuReject,
                      serveSize: currUser.userServeSize,
                      servingChanged: updateServing,      // only required in Accept
                      recipeSwiped: swipeMethod,
                      newDateSelected: chooseNewDate,
                      )
                    ),


                (_isDateSelected == false)
                  ?
                    ShopDatePicker(startShopDate: globals.shopDate,startStore: currStore.storeID,  menuCreatedSelect: createMenuSelected,)
                  : 
                    Center(child: MenuList(
                      listTab: 'swipe',
                      activeList: globals.menuSwipe,
                      serveSize: currUser.userServeSize,
                      servingChanged: updateServing,
                      recipeSwiped: swipeMethod,
                      newDateSelected: chooseNewDate,
                      )
                    ),

                (_isDateSelected == false)
                  ?
                    ShopDatePicker(startShopDate: globals.shopDate,startStore: currStore.storeID,  menuCreatedSelect: createMenuSelected,)
                  : 
                    Center(child: MenuList(
                      listTab: 'menu',
                      activeList: globals.menuAccept,
                      serveSize: currUser.userServeSize,
                      servingChanged: updateServing,
                      recipeSwiped: swipeMethod,
                      newDateSelected: chooseNewDate,
                      )
                    ),

    
              ],
            ),
      ),
    );
    
  }

  swipeMethod(String fromTab, String direction, int idx) {
    globals.changesMadeMenu = true;

    if (fromTab == 'swipe') {
        if (direction == 'right') {
          setState(() {
            globals.menuAccept.add( globals.menuSwipe[idx]);
            updateSwipe(globals.menuSwipe[idx]['recp_dates_id'], 1);
            globals.menuSwipe.removeWhere((item) => item['recp_dates_id'] == globals.menuSwipe[idx]['recp_dates_id']);
          });
        } else {
          setState(() {
            globals.menuReject.add(globals.menuSwipe[idx]);
            updateSwipe(globals.menuSwipe[idx]['recp_dates_id'], -1);
            globals.menuSwipe.removeWhere((item) => item['recp_dates_id'] == globals.menuSwipe[idx]['recp_dates_id']);
          });
        }

    } else if (fromTab == 'reject') {
        // will only be right, left is rejected
        setState(() {
          globals.menuSwipe.add( globals.menuReject[idx]);
          updateSwipe(globals.menuReject[idx]['recp_dates_id'], 0);
          globals.menuReject.removeWhere((item) => item['recp_dates_id'] == globals.menuReject[idx]['recp_dates_id']);
        });
    } else {
      // will only be left, right is rejected
      setState(() {
        globals.menuSwipe.add( globals.menuAccept[idx]);
        updateSwipe(globals.menuAccept[idx]['recp_dates_id'], 0);
        globals.menuAccept.removeWhere((item) => item['recp_dates_id'] == globals.menuAccept[idx]['recp_dates_id']);
      });
    }

    // print('menu swipe --- ${globals.menuSwipe.length}');
    // print('menu accept --- ${globals.menuAccept.length}');
    // print('menu reject --- ${globals.menuReject.length}');

  }

  updateSwipe(int id, int pos) {
    // [recp_dates_id, recp_accept, servings, changed]

    for (var all in globals.menuAll) {
      print(all['recp_dates_id']);
      if (all['recp_dates_id'] == id) {
        all['recp_accept'] = pos;
        all['changed'] = true;
      }
    }
    // globals.changesMadeMenu = true;  in above method
  }

  updateServing(int id) {     // }, int servChg) {

      // this is change in the Menu List 
      for (var all in globals.menuAll) {
        if (all['recp_dates_id'] == id) {
          all['changed'] = true;
        }
      }
      globals.changesMadeMenu = true;
  }


}




class MenuList extends StatefulWidget {

  final String listTab;
  final List activeList;
  int serveSize;
  final Function(String, String, int) recipeSwiped;
  final Function(int) servingChanged;
  final VoidCallback newDateSelected;
  // ** function to change serving size

  MenuList({required this.listTab, required this.activeList, required this.serveSize, 
    required this.servingChanged, required this.recipeSwiped, required this.newDateSelected,
    Key? key}) : super(key: key);

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {

  late List al;
  final GlobalFunctions fx = GlobalFunctions();  
  late GlobalVar globals;

  @override
  void initState() {
    super.initState();

    al = widget.activeList;
    globals = Provider.of<GlobalVar>(context, listen: false);                
   
  }
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18.0, bottom: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text('Shopping Date: ', style: TextStyle(fontSize: 18.0)),
              Text("Shop ${currStore.storeName}:", style: TextStyle(fontSize: 18.0)),

              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary:  Color(0xFF3CBC6D), // background
                    onPrimary: Colors.black, // foreground
                    padding: EdgeInsets.all(8.0),    
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),) 
                  ),
                  onPressed: () {
                    widget.newDateSelected();
                  },
                  child:  Text((globals.shopDate == 'Select') ? globals.shopDate : fx.FormatDateDow(globals.shopDate.toString()), style: TextStyle(fontSize: 18.0)),
              ),
              )
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            separatorBuilder: (_, __) => Divider(height: 0),
            itemCount: al.length,
            
            itemBuilder: (context, index) {
              // GestureDetector - 2 methods: https://stackoverflow.com/questions/55050463/how-to-detect-swipe-in-flutter
              // DIsmissable - something with the swipping - if swipe not accepted or something
              return Container(              
                    height: (widget.listTab == 'menu') ? 400 : 350,
                    // width: 70,
                    // color: Colors.red,
                child: Dismissible(
                  key: Key(al[index]['recp_json']['title']),
        
                  confirmDismiss: (direction) async {
                     if (direction == DismissDirection.startToEnd) {
                          if (widget.listTab == 'menu') {
                            return false;
                          } else {
                              widget.recipeSwiped(widget.listTab, 'right', index);
                              return true;     
                          }
        
                    } else {
                          if (widget.listTab == 'reject') {
                            return false;
                          } else {
                            widget.recipeSwiped(widget.listTab, 'left', index);
                            return true;     
                          }            
                    }
                  },
        
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xFF3CBC6D), width: 8.0),
                      borderRadius: BorderRadius.circular(10),
                      ),
                    margin: EdgeInsets.only(top: (index == 0 ) ? 10 : 30, right:30, left: 30),
                    // color: Colors.grey,
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
        
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              child: Text(al[index]['recp_json']['title'],
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),),
                            onTap: () {
                              print('------    NEED TO ADD A SLIDER ------');
                              print(al[index]['recp_json']['recipe']['ingredients']);
                            },
                            )
                          ),
        
                          Text(al[index]['recp_json']['description']), //, style: TextStyle(fontSize: 15.0)),
        
                          // SizedBox(height: 10.0,),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //   children: [
                          //     Text(fx.toLowerCaseButFirst(al[index]['recp_json']['complexity'])),
                          //     Text(" Prep: " + al[index]['recp_json']['time']['prep'].toString() + "  |  Cook: " + al[index]['recp_json']['time']['cook'].toString()),
                          //     // Text("Cook: " + al[index]['recp_json']['time']['cook'].toString()),
                          // ],),
        
                          // Text(al[1]['recp_json']['shopping_list']['purchase'][2]['item']),
        
        
                                            
                            SizedBox(height: 6),
                            Container(
                              // color: Colors.orange[100],
                              height: 22,
                              width: MediaQuery.of(context).size.width * .8,
                              padding: EdgeInsets.all(4),
                              // decoration: BoxDecoration(
                              //     color:  Color(0xFFfce0b6),
                              //     borderRadius: BorderRadius.all(Radius.circular(8))
                              //   ),
                              child: Center(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: al[index]['recp_json']['tags']['descriptors'].length,
                                  itemBuilder: (context, idx) {
        
                                    return (idx == 0)
                                      ? Text(al[index]['recp_json']['tags']['descriptors'][idx], )
                                      : Text(' | ' + al[index]['recp_json']['tags']['descriptors'][idx], );         
                                  }
                                ),
                              )
                            ),
        
                          // https://stackoverflow.com/questions/69164559/how-to-bring-widgets-to-next-line-in-listviewbuilder-flutter
                          Container(
                              // color: Colors.yellow[100],
                              // height: 48,
                              width: MediaQuery.of(context).size.width * .8,
                              constraints: BoxConstraints(minHeight: 48, maxHeight: 48),
                              padding: EdgeInsets.all(8),
                              child: SingleChildScrollView(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  children: al[index]['recp_json']['shopping_list']['purchase'].map<Widget>((item) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: CircleAvatar(
                                              radius: 05, backgroundColor: Color(0xffC4C4C4)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 4.0),
                                          child: Text(
                                            item['item'],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
        
                            
                            
                            SizedBox(height: 6),
                            Container(
                              // color: Colors.orange[100],
                              height: 100,
                              width: MediaQuery.of(context).size.width * .8,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color:  Color(0xFFfce0b6),
                                  borderRadius: BorderRadius.all(Radius.circular(8))
                                ),
                              child: ListView.builder(
                                itemCount: al[index]['recp_json']['recipe']['instructions'].length,
                                itemBuilder: (context, idx) {
        
                                  return Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('${idx+1}. ${al[index]['recp_json']['recipe']['instructions'][idx]}'),
                                  );
                                }
                              )
                            ),
        
                              
                            SizedBox(height: 14.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(fx.toLowerCaseButFirst(al[index]['recp_json']['complexity'])),
                                Text(" Prep: ${al[index]['recp_json']['time']['prep']}  |  Cook: ${al[index]['recp_json']['time']['cook']}"),
                            ],),
        
        
        
                            // SizedBox(height: 12),
                            (widget.listTab == 'menu')
                              ?  Padding(
                                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("(\$ ${(al[index]['recipe_serv_price']['serv_save'] * -1 * al[index]['serv_size']).toStringAsFixed(2)})", 
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),),
                                      Text("\$ ${(al[index]['recipe_serv_price']['serv_price'] * al[index]['serv_size']).toStringAsFixed(2)}", 
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                                    
                                  ],),
                                )
                              : Container(),
        
        
        
                            (widget.listTab == 'menu')
                              ?
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 40, right: 20),
                                          child: Icon(
                                            Icons.arrow_downward,
                                            color: Colors.green,
                                            size: 22.0,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (widget.serveSize > 1) al[index]['serv_size'] -=1;
                                            widget.servingChanged(al[index]['recp_dates_id']);
                                          });
                                        }
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left:0.0, right: 0.0),
                                        child: Text('servings: ${al[index]['serv_size']}'),
                                      ),
                                      InkWell(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 20, right: 40),
                                          child: Icon(
                                            Icons.arrow_upward,
                                            color: Colors.green,
                                            size: 22.0,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (widget.serveSize > 1) al[index]['serv_size'] +=1;
                                            widget.servingChanged(al[index]['recp_dates_id']);
                                          });
                                        }
                                      ),
        
                                  ],),
                                )
                              : Container(),
        
                        ],
                      ),
                    ),
                          
                  ),
                ),
              );
            }
          ),
        ),


        // so screen wont be block if No Deals or All Accepted/Rejected
        (widget.listTab == 'swipe') 
          ? (widget.activeList.isNotEmpty) 
            ? Container()
            : // nothing to see in Swipe tab - 2 options, 
                  Padding(
                    padding: EdgeInsets.only(bottom: my_screenHeight / 3),
                    child: 
                      (globals.menuAll.isNotEmpty)
                        ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Click Menu Tab ', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: Color(0xFF3CBC6D))),
                                Icon(Icons.arrow_upward, size: 28, color: Color(0xFF3CBC6D),),                           
                              ],
                            ),
                            Text('to view your selections', style: TextStyle(fontSize: 22.0, height: 1.5)),
                          ],
                        )
                        : Column(
                            children: const [
                              Text('No Deals Found', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: Color(0xFF3CBC6D))),
                              Text('check back soon', style: TextStyle(fontSize: 22.0, height: 1.5)),
                            ],
                          )
                  )
      
            

          : Container()
      ],
    );
    
  }
}

