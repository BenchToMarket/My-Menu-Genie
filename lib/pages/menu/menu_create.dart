// ignore_for_file: prefer_const_constructors


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../admin/global_classes.dart';
import '../admin/savory_api.dart';
import 'menu_shop_date.dart';
import '../admin/more_help.dart';
import '../cook/cook_recipe.dart';



class MenuCreate extends StatefulWidget {

  bool noInternetConnection; 
  MenuCreate({required this.noInternetConnection, Key? key}) : super(key: key);

  @override
  State<MenuCreate> createState() => _MenuCreateState();
}

class _MenuCreateState extends State<MenuCreate> {

  bool _isLoading = false;  
  bool _noInternetConnection = false;
  bool _hasConnect = true;

  late GlobalVar globals;
  final HttpService httpSavory = HttpService();

  // late double my_screenWidth;
  // late double my_screenheight;
  // bool changesWereMade = false;

  Map<String, dynamic> recipe = {};

  bool _isDateSelected = true;
  // bool shoppingStarted = false;

  final double _sliderMargin = 90.0;
  bool _sliderLeftHowTo = false;
  bool _sliderBadConnect = false;
  // bool _sliderLeftShopLock = false;
  // DateTime todayDate = DateTime.now();

  // this is to close out Shopping cart
  final double _sliderMarginBuy = 60.0;
  bool _sliderLeftCompleteBuy = false;

  // after shopping list completed - we will create new menu - we need to hold selected values
  // bool flagToCreateNewMenu = false;
  bool delayCreateMenuFlag = false;
  String delaySelectedDate = 'Select';
  bool delaySameStore = false;


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
    globals.menuDate = 'Select';

    super.initState();

    checkConnectionInBackground();

    startFetching();
    // startChangeTimer();
  }

  @override
  void dispose() {
    if (kDebugMode) { print('---   disposing   menu ---'); }
    // globals.isSaving = true;
    // checkForChanges();   // moved to Nav Bar
    // if (timer != null) {
    //   timer.cancel();
    // }
    super.dispose();
  } 

  void checkConnectionInBackground() {
    // Run the connection check in the background
    Future.microtask(() async {
      _hasConnect = await httpSavory.checkConnection();

      if (!_hasConnect) {
        // Handle the connection failure (e.g., show a message)
        setState(() {
          _hasConnect = false;
          _isLoading = false;  
        });
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
              _sliderBadConnect = true; 
          });
        });
      }
    });
  }


  startFetching() async {

    _isLoading = true;

    print('444444444444444444444444444444444');
    // print(_hasConnect);
    // // _hasConnect = await httpSavory.checkConnection();

    // print(_hasConnect);

    // if (_hasConnect == false) {
    //   print('22222222222222222222222222222');
    //   setState(() {
    //     _isLoading = false;  
    //   });
    //     Future.delayed(const Duration(seconds: 2), () {
    //       print('3333333333333333333333333333333333');
    //       setState(() {
    //          _sliderBadConnect = true; 
    //       });
    //     });
    //   return;
    // }
    
    // sent from slash screen - so no need to test again
    if (widget.noInternetConnection == true) {
      _noInternetConnection = true;
      return;
    }

    // int minsSinceStoreUpdate = DateTime.now().difference(globals.dateUpdatedStore).inMinutes;
    // // minsSinceStoreUpdate = 1; // 99999999999999;    // ********************* for testing
    // if (kDebugMode) { print('mins since update Store _--- $minsSinceStoreUpdate'); }
    // if (minsSinceStoreUpdate > globals.MINS_UPDATE_STORE) {
    //   _noInternetConnection = await fetchStores();
    //   globals.updatedStore(DateTime.now());
    // }
    if (globals.updatedStores == true) {
      _noInternetConnection = await fetchStores();
    }

    if (_noInternetConnection == true) {
      if (!mounted) return;
      setState(() { });
    }

    await fetchMenu();

    testForOpeningDirections();

    if (kDebugMode) { print('----------     done loading menu       -------------------------'); } 
    if (kDebugMode) { print(currUser.seenInfo); }

  }

  fetchStores() async {

    // ** TODO - this is probably wrong, checking internet in splash screen
    // also no need to reset _isLoading - since we do with menu loading
    bool noConnection = false;

    _isLoading = true;

    List<dynamic> menuStores = await httpSavory.getStores('no date');

    if (menuStores[0]["error"] == 'noconnection') {
      noConnection = true;
      return noConnection;
    } else {

      globals.userStores.clear();

      for (var m in menuStores) {
        globals.userStores.add(Store( storeID: m['store_id'], storeName: m['store_name']));
      }

      // ?? checks to see if currStore == null
      currStore ??= Store(
            storeID: globals.userStores[0].storeID,
            storeName: globals.userStores[0].storeName,
          );
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    return noConnection;
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
  /// 
  
  
  clearAllMenus() {

      globals.menuAll.clear();
      globals.menuSwipe.clear();
      globals.menuAccept.clear();
      globals.menuReject.clear();

      // globals.menuDate = 'Select';
      // globals.activeMenu = {};

      // globals.menuAll.isNotEmpty
  }

  
  // fetchMenuCommit() async {
  //     globals.menuCommit = await httpSavory.getMenuCommit();
  //     print(globals.menuCommit);

  // }


  fetchMenu() async {
    
    _isLoading = true;    // redundant from startfetching ?

    // ** testing - to force committed menu to show & to force fetching
    // globals.updatedShopCommit(DateTime(2976, 1, 1));
    // globals.menuAll.clear();

    int menuWeShow = 4;

    int minsSinceCommit = DateTime.now().difference(globals.dateShopCommit).inMinutes;
    // minsSinceCommit = 1;  // 99999999999999;    // ********************* for testing   // 1 forces us to pull committed menu
    if (kDebugMode) { print('mins since SHOP Commit _--- $minsSinceCommit'); }

    if (minsSinceCommit > globals.MINS_SHOP_COMMIT) {

      print('11111111111111111111111');

      menuWeShow = 2;   // commit 60 mins ago, dont show until we reset the clock by creating new menu
      if (globals.lastMenuWeShow == 4) {
        globals.changedMenuCommit = true;  // only the first time through
        globals.lastMenuWeShow = 2;
      } else {
        globals.changedMenuCommit = false;
      }
    } else {
      // globals.changedMenuCommit = false;
    }

    // if menuWeShow is 2 or menu.isEmpty - we need to pull again

    if (globals.menuCommit.isEmpty) {
      globals.menuCommit = await httpSavory.getMenuCommit();
    }

    print('33333333333333333333333333333333333');
    // print(globals.menuAll.isEmpty);
    // print(globals.changedMenuCommit);
    // menuWeShow = 0;


    if (globals.menuAll.isEmpty || globals.changedMenuCommit == true) {

      clearAllMenus();

      // 2 is committed ---- 4 is purchased --- so we do < 
      // this is the first menu without commited (in last 60 mins) shopping
      for (var mc in globals.menuCommit) {
        print('------------------------------------------------');
        print(mc);
        if (mc['commit_status'] < 4) {
            globals.activeShop = mc;
            globals.shopDate = mc['date_shop'];
        }
        if (mc['commit_status'] < menuWeShow) {     // 2 - dont show committed menu  // 4) {
            globals.activeMenu = mc;
            globals.menuDate = mc['date_shop'];
          break;
        }
      }

      // this would be a user with commited shopping logs back in, but menu would show anyway (bc we show menu for 1 hour only if remain active)
      // but keep for now - for testing and if we change how long we show menu
      if (globals.activeMenu.isNotEmpty) {
        if (globals.activeMenu['commit_status'] > 1) {
          globals.shopThreshMet = true;
        }
      }

      if (globals.menuDate == "Select") {
        if (!mounted) return;
        setState(() {
          _isDateSelected = false;
          _isLoading = false;
        });
        return;
      }

      List<dynamic> menu = await httpSavory.getMenuMap(globals.menuDate);   // fetches by current store ID

      globals.popMenuAll(menu);

      if (globals.menuAll.isNotEmpty) {
        globals.updatedMenuAll(DateTime.now());
        // test if we have a new menu commit_id - if so, fetch menu Commit again  (probably better way to do this)
        if (globals.menuAll[0]['commit_id'] != null) {
          globals.menuCommit = await httpSavory.getMenuCommit();
        }
      }

      // as of June 2, we are now getting  recipe serve price with return of the menu in GetMenuMap
      // so no fetch Menu costs - keeping in case we need for something else

      for (var m in globals.menuAll) {
        // print(m);
        // print(m['recp_dates_id']);
        // recpDatesList.add(m['recp_dates_id']);
        // m['recipe_serv_price'] = {'serv_price': 0.00, 'serv_deal': 0.00, 'serv_save': -0.00};

        if (m['recp_accept'] == 0) {
          globals.menuSwipe.add(m);
        } else if (m['recp_accept'] == 1) {
          globals.menuAccept.add(m); 
        } else if (m['recp_accept'] == -1) {
          globals.menuReject.add(m);
        }
      }

    }


    if (globals.menuAccept.isNotEmpty) {
      globals.menuActiveTab = 2;
    } 

    // fetchMenuCosts();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // for servings defaults - might move to menu_shop_date - so comes up before we create menu
    // Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => const UserDefaults(
    //             )));
    
  
  }


  fetchMenu_old() async {
    
    _isLoading = true;    // redundant from startfetching ?
    
    int minsSinceUpdate = DateTime.now().difference(globals.dateUpdatedMenu).inMinutes;
    // ********************* for testing
    // minsSinceUpdate = 99999999999999;
    if (kDebugMode) { print('mins since updated MENU _--- $minsSinceUpdate'); }

    // we only pull a new menu at start & if we change store/date
    if (minsSinceUpdate > globals.MINS_UPDATE_MENU) {
      
      globals.menuCommit = await httpSavory.getMenuCommit();

      clearAllMenus();
      int menuWeShow = 2;
      

      // print('4444444444444444444444444444');
      // print(globals.menuCommit);
      // print(globals.menuCommit.length);

      // show committed Menu if we just committed shopping list in last 60 mins (or time of MINS_SHOP_COMMIT)
      // only gets here if we updated the Menu in span above (but if we didn't updated the menu, ok to show the last)
      int minsSinceCommit = DateTime.now().difference(globals.dateShopCommit).inMinutes;
      // minsSinceCommit = 1;  // 99999999999999;    // ********************* for testing   // 1 forces us to pull committed menu
      if (kDebugMode) { print('mins since SHOP Commit _--- $minsSinceCommit'); }

      if (minsSinceCommit < globals.MINS_SHOP_COMMIT) {
        menuWeShow = 4;
      }


      // this is the first menu without commited (in last 60 mins) shopping
      for (var mc in globals.menuCommit) {
        if (mc['commit_status'] < 4) {
            globals.activeShop = mc;
            globals.shopDate = mc['date_shop'];
        }
        if (mc['commit_status'] < menuWeShow) {     // 2 - dont show committed menu  // 4) {
            globals.activeMenu = mc;
            globals.menuDate = mc['date_shop'];
          break;
        }
      }

      // print('---------222222222222222222----------');
      // print(globals.menuDate);

      if (globals.menuDate == "Select") {
        if (!mounted) return;
        setState(() {
          _isDateSelected = false;
          _isLoading = false;
        });
        return;
      }

      // print(globals.menuDate);
      // globals.menuDate = '2024-04-15';

      List<dynamic> menu = await httpSavory.getMenuMap(globals.menuDate);   // fetches by current store ID

      globals.popMenuAll(menu);

      // print('3333333333333333333333333333333333');
      // print(globals.menuAll);
      // print(globals.menuAll.length);

      if (globals.menuAll.isNotEmpty) {
        globals.updatedMenuAll(DateTime.now());
        // test if we have a new menu commit_id - if so, fetch menu Commit again  (probably better way to do this)
        if (globals.menuAll[0]['commit_id'] != null) {
          globals.menuCommit = await httpSavory.getMenuCommit();
        }
      }

      // as of June 2, we are now getting  recipe serve price with return of the menu in GetMenuMap
      // so no fetch Menu costs - keeping in case we need for something else

      for (var m in globals.menuAll) {
        // print(m);
        // print(m['recp_dates_id']);
        // recpDatesList.add(m['recp_dates_id']);
        // m['recipe_serv_price'] = {'serv_price': 0.00, 'serv_deal': 0.00, 'serv_save': -0.00};

        if (m['recp_accept'] == 0) {
          globals.menuSwipe.add(m);
        } else if (m['recp_accept'] == 1) {
          globals.menuAccept.add(m); 
        } else if (m['recp_accept'] == -1) {
          globals.menuReject.add(m);
        }
      }
    }

    if (globals.menuAccept.isNotEmpty) {
      globals.menuActiveTab = 2;
    } 

    // fetchMenuCosts();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // for servings defaults - might move to menu_shop_date - so comes up before we create menu
    // Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => const UserDefaults(
    //             )));
    
  
  }


  createMenuSelected(String selectedDate, bool sameStore) async {
    if (kDebugMode) { print('------    create menu selected  -------'); }
    // print(selectedDate);
    // print(globals.menuDate);
    
    globals.menuActiveTab = 1;

    Future.delayed(const Duration(milliseconds: 100), () {
      // Navigator.of(context).pop();
      setState(() {
        // this resets that menuDate - thus changes display
        if (!mounted) return;
        _isDateSelected = true;
      });
    });
    
    if (selectedDate != globals.menuDate || sameStore == false) {
        globals.menuDate = selectedDate;
        // globals.menuDate = '2024-01-05';          // *** testing only
        globals.creatingMenu = true;
        globals.changedMenuCommit = false;    // new menu - so we have not changed we committed
        globals.updatedMenuAll(DateTime(1976, 1, 1));         // reset so we pull another menu 
        
        setState(() {
          globals.creatingMenu = false;
        });
        
        if (delayCreateMenuFlag == true) {
          // came from completing shopping, so reset and re-fetch
          globals.menuCommit.clear();
          globals.menuAll.clear();
          delayCreateMenuFlag = false;
          globals.updatedShopCommit(DateTime(1976, 1, 1));
        } else {
          globals.updatedShopCommit(DateTime.now());
        }
        
        await fetchMenu();

    }

    testForOpeningDirections();

  }

  chooseNewDate() {
    setState(() {
      _isDateSelected = false;
    });
  }

  
  testForOpeningDirections() {

    if (currUser.seenInfo[0] != '2') {return;}
    
    if (!globals.menuAll.isEmpty) {
      Future.delayed(const Duration(seconds: 4), () {
        if (!mounted) return;
        setState(() { _sliderLeftHowTo = true; });
      });
    } 
  }


  // checkForChanges_old() async {
  //   // we are updating menu_user_recp_join table by user_id & recp_dates_id - did user
  //   // - recp_accept or reject
  //   // - recp_cook (not here) but same api
  //   // - serv_size
  //   // return;

  //   if (kDebugMode) { print('-----------------        checking for changes    ----------------'); }
  //   if (kDebugMode) { print(globals.changesMadeMenu); }

  //   if (globals.changesMadeMenu == false) {
  //     // globals.isSaving = false;
  //     return;
  //   }
  //   globals.changesMadeMenu = false;             // do here so we dont try to change the same changes twice
  //   // globals.isSaving = true;

  //   print('1111111111111111111111111111');

  //   List<dynamic> onlyChanged = [];

  //   for (var m in globals.menuAll) {        
  //       if (m['changed'] == true) {
  //         onlyChanged.add({
  //           'user_join_id': m['user_join_id'],
  //           'recp_dates_id': m['recp_dates_id'],
  //           'recp_accept': m['recp_accept'],
  //           'recp_cook': m['recp_cook'],
  //           'serv_size': m['serv_size'],
  //           'changed': m['changed'],
  //           });
  //           m['changed'] = false;
  //     }
  //   }

  //   final jsonChanged = json.encode(onlyChanged);

  //   await httpSavory.sendMenuUpdates(jsonChanged);
  //   // setState(() {
  //   //   globals.isSaving = false;
  //   // });

  //   print('2222222222222222222222222222222');
  //   print(globals.isSaving);

  // }

  recipeSelected(int id, int servingCooking) {

    if (globals.menuActiveTab == 2) {
      for (var ma in globals.menuAccept) {
        if (ma['recp_dates_id'] == id) {
          recipe = ma;
        }
      }
    } else if (globals.menuActiveTab == 1) {
      for (var ma in globals.menuSwipe) {
        if (ma['recp_dates_id'] == id) {
          recipe = ma;
        }
      }
    } else {
      for (var ma in globals.menuReject) {
        if (ma['recp_dates_id'] == id) {
          recipe = ma;
        }
      }
    }


    Navigator.push( context, MaterialPageRoute( builder: (context) => CookRecipe(
        recp_name: recipe['recp_json']['title'],
        recipe: recipe,
        servingsCooking: servingCooking,
        sentFrom: 'menu',
      )));
  }
  


  // // as of June 2, we are now getting  recipe serve price with return of the menu in GetMenuMap
  // // so no fetch Menu costs - keeping in case we need for something else
  // fetchMenuCosts() async {

  //   globals.recpAccept.clear();
  //   ///  [recp_dates_id, recp_accept, servings, changed]
  //   /// 1. we have to fetch all accepted Menu and costs
  //   /// 2. adjust changes to accepted, rejected or back to swipe in menu_user_recp_join
  //   /// can retrieve by recp_dates_id (this is how user acceptance is recorded)
  //   /// on server, then we fetch recp_id
  //   /// then by item, option_id and price, deal_price (if any) & calc savings - all by single serving 
  //   /// menu_user_recp_join - should remember # of servings for accepted menu

  //   // // [recp_dates_id, recp_accept, servings, changed]
  //   // for (var mm in globals.menuMaster) {
  //   //   if(mm[1] == 1) {
  //   //     globals.recpAccept.add(mm[0]);
  //   //   }
  //   // }

  //   // ** I want to get for all menu items - we should have prices before we accept a recipe

  //   for (var mm in globals.menuAccept) {
  //     globals.recpAccept.add(mm['recp_dates_id']);
  //   }

  //   final jsonAccepted = json.encode(globals.recpAccept);   // ([1,2]);  // globals.recpAccept);

  //   globals.recpIngred = await httpSavory.getRecipeIngred('recp-ingred', jsonAccepted, globals.menuDate);

  //   // there is a much better way to map
  //   for (var ri in globals.recpIngred) {
  //     for (var ma in globals.menuAccept) {
  //       if (ri['recp_dates_id'] == ma['recp_dates_id']) {
  //         ma['recipe_serv_price'] = ri['recipe_serv_price'];
  //       }
  //     }
  //   }

  //   setState(() {});      // this is set price and savings by just fetched price data
  // } 

  askToCompleteShopping(String selectedDate, bool sameStore) async {

    if (globals.shoppingListPopulated == false) {
      globals.popShoppingList(await httpSavory.getShoppingList(globals.shopDate, globals.activeShop['id']));
      await popStoresShoppingList(currStore!.storeID);
    }

    setState(() {
      if (globals.shoppingListPopulated == false) {
        globals.shoppingListPopulated = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() { _sliderLeftCompleteBuy = true; });
        });
      } else {
        // we dont want to delay if we did not need to populate 
        setState(() { _sliderLeftCompleteBuy = true; });
      }
    });

    // hold values for if the user completes shopping
    delayCreateMenuFlag = true;
    delaySelectedDate = selectedDate;
    delaySameStore = sameStore;

  }

  // these 2 are for shopping commit or cancel
  shopConfirmComplete() {

      globals.shopThreshMet = true;
      checkForChanges(4, context);  // this also saves 
      createMenuSelected(delaySelectedDate, delaySameStore);
      
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() { _sliderLeftCompleteBuy = false; });  
      });
  }

  shopCancelComplete() {
    delayCreateMenuFlag = false;
    setState(() {
      _sliderLeftCompleteBuy = false;
    });
  }

  shopCancelConnect() {
    setState(() {
      _sliderBadConnect = false;
    });
  }

  // want to move to help - but it does not like using context - duplicated in Menu & Shop
  popStoresShoppingList(int storeID) {

    globals.shopBuyAll.clear();
    globals.shopBuy.clear();
    globals.shopDontBuy.clear();
    globals.shopVerifyAll.clear();
    globals.shopVerify.clear();
    globals.shopDontVerify.clear();
    globals.shopCategory.clear();

    // print('*****************************************');

    for (var l in globals.shoppingList) {
      if (l['store_id'] == storeID) {
          // print(l['shopping_list']);
          // print('-------------------------------------------');
          globals.shopBuyAll = l['shopping_list']['purchase'];
          globals.shopVerifyAll = l['shopping_list']['verify'];
          globals.shopBuy = l['shopping_list']['purchase'].where((item) => item['shop_accept'] == 1).toList();
          globals.shopDontBuy = l['shopping_list']['purchase'].where((item) => item['shop_accept'] == -1).toList();
          globals.shopVerify = l['shopping_list']['verify'].where((item) => (item['dont'] == 'keep' || item['dont'] == 'want')).toList();
          globals.shopDontVerify = l['shopping_list']['verify'].where((item) => item['dont'] == 'dont').toList();
          // globals.shopVerify = l['shopping_list']['verify'].where((item) => item['dont'] == false).toList();
          // globals.shopDontVerify = l['shopping_list']['verify'].where((item) => item['dont'] == true).toList();
          globals.shopCategory = l['shopping_list']['shop_cat'];
      }
    }
    globals.shopCategory.insert(0, "Verify");
    globals.shopCategory.insert(0, "All");

    // print('44444444444444444444444444444444');
    // print(globals.shopVerifyAll);
    // print('-------------------------------------------');
    // print(globals.shopVerify);

  }



  @override
  Widget build(BuildContext context) {

    if (_noInternetConnection == true) {
      return Center(
        child: Text(
          'Server Connection Error',
          style: TextStyle(color: blueColor, fontSize: 24),
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
                        // fetchMenuCosts();
                      }
                      // checkForChanges();      // i think we can do after, fetching above pulls based on changed in app
                  },
                  tabs: const [
                    Tab(child: Text('Reject')),
                    Tab(child: Text('Swipe')),
                    Tab(child: Text('Menu')),
                  ],
                ),
              ),

            ),
            body: Stack(
              children: [
                  TabBarView(
                    children: [
                    
                      (_isDateSelected == false)
                        ?
                          MenuDatePicker(startMenuDate: globals.menuDate,startStore: currStore!.storeID, menuCreatedSelect: createMenuSelected, hasConflictingShopping: askToCompleteShopping,)
                        : 
                          Center(child: MenuList(
                            listTab: 'reject',
                            activeList: globals.menuReject,
                            serveSize: currUser.userServeSize,
                            servingChanged: updateServing,      // only required in Accept
                            recipeSwiped: swipeMethod,
                            newDateSelected: chooseNewDate,
                            recipeSelect: recipeSelected,
                            )
                          ),
                
                
                      (_isDateSelected == false)
                        ?
                          MenuDatePicker(startMenuDate: globals.menuDate,startStore: currStore!.storeID,  menuCreatedSelect: createMenuSelected,hasConflictingShopping: askToCompleteShopping)
                        : 
                          Center(child: MenuList(
                            listTab: 'swipe',
                            activeList: globals.menuSwipe,
                            serveSize: currUser.userServeSize,
                            servingChanged: updateServing,
                            recipeSwiped: swipeMethod,
                            newDateSelected: chooseNewDate,
                            recipeSelect: recipeSelected,
                            )
                          ),
                
                      (_isDateSelected == false)
                        ?
                          MenuDatePicker(startMenuDate: globals.menuDate,startStore: currStore!.storeID,  menuCreatedSelect: createMenuSelected,hasConflictingShopping: askToCompleteShopping)
                        : 
                          Center(child: MenuList(
                            listTab: 'menu',
                            activeList: globals.menuAccept,
                            serveSize: currUser.userServeSize,
                            servingChanged: updateServing,
                            recipeSwiped: swipeMethod,
                            newDateSelected: chooseNewDate,
                            recipeSelect: recipeSelected,
                            )
                          ),
                
                    
                    ],
                  ),


                  
              (currUser.seenInfo[0] == '2')
                ? 
                  AnimatedPositioned(
                    top: (my_screenHeight - my_screenDisplay) / 2,  //, 100.0,
                    left: _sliderLeftHowTo ? (_sliderMargin / 2) : (my_screenWidth + 80.0),
                    duration: const Duration(milliseconds: 500),
                    child: InkWell(
                      child: Container(
                        height: my_screenDisplay * .75,
                        width: my_screenWidth - _sliderMargin,  
                        decoration: BoxDecoration(
                          color: Colors.white,    
                          borderRadius: const BorderRadius.all(Radius.circular(10)) ,
                          border: Border.all(
                            width: 4,
                            color: blueColor,
                          ),
                        ),                 
                        // color: Colors.blue,
                      
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                                  
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('How it Works?', style: TextStyle(fontSize: 22.0,color: blueColor),),
                            ),
                                  
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text('Like a Recipe', style: TextStyle(fontFamily: 'Roboto', fontSize: 26.0,fontWeight: FontWeight.w600, color: blueColor),),
                                      Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Text('swipe right to Menu', style: TextStyle(fontSize: 20.0),),
                                      ),
                                      ],
                                  ),
                                  const SizedBox(height: 24.0),                     
                                        
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text('Dislike', style: TextStyle(fontFamily: 'Roboto', fontSize: 26.0,fontWeight: FontWeight.w600, color: blueColor),),
                                      Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Text('swipe left to Reject', style: TextStyle(fontSize: 20.0),),
                                      ),
                                      ],
                                  ),
                                  const SizedBox(height: 24.0),
                                                                  
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text('Maybe Later', style: TextStyle(fontFamily: 'Roboto', fontSize: 26.0,fontWeight: FontWeight.w600, color: blueColor),),
                                      Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Text('keep in Swipe', style: TextStyle(fontSize: 20.0),),
                                      ),
                                      ],
                                  ),
                                  const SizedBox(height: 24.0), 
                                  
                                ],
                              ),
                            ),
                            
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0, right: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    // Text((globals.activeMenu['commit_status'] < 4) ? 'Cancel' : 'Got it', style: const TextStyle(fontSize: 16.0,color: Color(0xFFe9813f)),),
                                    Text("Don't show again", style: TextStyle(fontSize: 20.0,color: Color(0xFFe9813f)),),
                                  ],
                                ),
                              ),
                              onTap: () {
                                final GlobalFunctions fx = GlobalFunctions();
                                fx.seenInfoSet(0, '0');
                                setState(() {
                                  _sliderLeftHowTo = false;
                                });
                              },
                            )
                                  
                          
                          ],
                        )
                                  
                      ),
                          onTap: () {
                            setState(() {
                              _sliderLeftHowTo = false;
                            });
                          },
                    ),
                  )
                : Container(),

                (globals.shoppingListPopulated == true)
                  ?             
                    AnimatedPositioned(
                      top:  (my_screenHeight - my_screenDisplay) / 2,
                      left: _sliderLeftCompleteBuy ? (_sliderMarginBuy / 2) : (my_screenWidth + 80.0),
                      duration: const Duration(milliseconds: 500),
                      child: SliderCompleteShopping( 
                        sliderMargin: _sliderMarginBuy,
                        fromPage: 'menu',
                        confirmComplete: shopConfirmComplete,
                        cancelComplete: shopCancelComplete,
                      ),
                    )
                  : Container(),


                  // Bad Connection
                  AnimatedPositioned(
                    top: (my_screenHeight - my_screenDisplay) / 2,  //, 100.0,
                    left: _sliderBadConnect ? (_sliderMargin / 2) : (my_screenWidth + 80.0),
                    duration: const Duration(milliseconds: 500),
                    child: SliderBadConnection(
                      sliderMargin: _sliderMargin,
                      fromPage: 'menu',
                      cancelConnect: shopCancelConnect,
                    )
                  )

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
      // print(all['recp_dates_id']);
      if (all['recp_dates_id'] == id) {
        all['recp_accept'] = pos;
        all['changed'] = true;
      }
    }
    // globals.changesMadeMenu = true;  in above method
  }

  updateServing(int id) {     // }, int servChg) {

    print('33333333333333333333333333333');
    print(globals.shopThreshMet);

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
  final Function(int)? servingChanged;
  final Function(String, String, int)? recipeSwiped;
  final VoidCallback? newDateSelected;
  // ** function to change serving size
  final Function(int, int) recipeSelect;

  MenuList({required this.listTab, required this.activeList, required this.serveSize, required this.servingChanged, required this.recipeSwiped,required this.newDateSelected, required this.recipeSelect, 
    Key? key}) : super(key: key);

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {

  late List al;
  final GlobalFunctions fx = GlobalFunctions();  
  late GlobalVar globals;

  DateTime todayDate = DateTime.now();
  int dowToday = 0; 
  bool shoppingStart = false;
  int attemptToChangeMenu = 0;
  int attemptChangeThreshold = 3;
  
  // Deals not Posted yet - messages
  // these will be generated more dynamically with more stores
  String publixNotYet = 'Publix Deals\nbegin every Thursday\nend on Wednesday.\n\nCheck back soon \nor shop earlier in the week by clicking the date above.';
  // String publixWereLate = 'We have not yet posted the Publix Menu. We are running late. Check back in 24 hours.';
  String freshNotYet = 'The Fresh Market Deals\nbegin every Wednesday\nend on Tuesday.\n\nCheck back soon \nor shop earlier in the week by clicking the date above.';
  String wereLate = 'We are in Beta.\nSometimes we are late in posting Menus.\nThank you for your patients';


  @override
  void initState() {
    super.initState();

    globals = Provider.of<GlobalVar>(context, listen: false);              
    setVariables();
  }

  setVariables() {
    
    al = widget.activeList;
    dowToday  = todayDate.weekday;
    
    // if started shopping dutring this session, we might not fetch new menu_commit
    // kind of a waste - we could just use the global now that we have it
    if (globals.shopThreshMet == true) {
      shoppingStart = true;
      return;
    }
    
    // moed to fetch menu from parent widget 
    // // not using yet - we need some way to prevent user from changing the menu after they started to shop
    // // but then we also need to reset a started shopping - lots to consider here
    // plus gets null error when 1st loading app
    // if (globals.activeMenu.isNotEmpty) {
    //   if (globals.activeMenu['commit_status'] > 1) {
    //     shoppingStart = true;
    //   }
    // }

  }

  addOneAttemptedMenuChange() {
    attemptToChangeMenu +=1;
    if (attemptToChangeMenu == attemptChangeThreshold) {
      if (kDebugMode) { print('---  Menu is fixed - Complete or Reset Shopping ---- '); }
      attemptToChangeMenu = 0; // reset
      showDialog(
                  context: context,
                  builder: (BuildContext context) => InformationDialog(
                  context: context,   
                  title: 'Menu Fixed',
                  text1: "You can't make changes to a Menu after you start Shopping.",
                  text2: 'Complete Shopping to Start a new Menu. Click Cart icon in Shop.'),);
                  // text3: 'We will be adding more flexibility soon.'),);
    }
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
              Text("Shop ${currStore!.storeName}:", style: TextStyle(fontSize: 18.0)),

              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary:  blueColor, // background
                    onPrimary: Colors.black, // foreground
                    padding: EdgeInsets.all(8.0),    
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),) 
                  ),
                  onPressed: () {
                      if (shoppingStart == true) {
                          addOneAttemptedMenuChange();
                      } else {
                        widget.newDateSelected!();
                      }
                  },
                  child:  Text((globals.menuDate == 'Select') ? globals.menuDate : fx.FormatDateDow(globals.menuDate.toString()), style: TextStyle(fontSize: 18.0)),
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
                    // height: ((widget.listTab == 'menu') ? 430.0 : 400.0) + ((index == 0 ) ? 0.0 : 20.0),    // adding 20 for +20 top-margin after 1st
                    // height: ((widget.listTab == 'menu') ? 380.0 : 330.0) + ((index == 0 ) ? 0.0 : 20.0),    // adding 20 for +20 top-margin after 1st
                    // width: 70,
                    // color: Colors.red,
                child: Dismissible(
                  key: Key(al[index]['recp_json']['title']),
        
                  confirmDismiss: 
                        (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                                if (widget.listTab == 'menu') {
                                  return false;
                                } else {

                                    if (widget.listTab == 'swipe' && shoppingStart == true) {
                                      addOneAttemptedMenuChange();
                                      return false;
                                    }
                                    widget.recipeSwiped!(widget.listTab, 'right', index);
                                    return true;     
                                }
              
                          } else {
                                if (widget.listTab == 'reject') {
                                  return false;
                                } else {
                                  if (widget.listTab == 'menu' && shoppingStart == true) {
                                    addOneAttemptedMenuChange();
                                    return false;
                                  }
                                  widget.recipeSwiped!(widget.listTab, 'left', index);
                                  return true;     
                                }            
                          }
                        },
              

                  child: InkWell(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: blueColor, width: 4.0),
                        borderRadius: BorderRadius.circular(10),
                        ),
                      margin: EdgeInsets.only(top: (index == 0 ) ? 10 : 30, right:30, left: 30),
                      // color: Colors.grey,
                      child: Container(
                        padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 0.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                child: Text(al[index]['recp_json']['title'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: blueColor),),
                              onTap: () {
                                // print('------    NEED TO ADD A SLIDER ------');
                                // print(al[index]['recp_json']['recipe']['ingredients']);
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
                                    color: goldColorLight,   // Color(0xFFfce0b6),
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
                          
                          
                          
                              // // SizedBox(height: 12),
                              // (widget.listTab == 'menu')
                              //   ?  Padding(
                              //       padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                              //       child: Row(
                              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //         children: [
                              //           Text("(\$ ${(al[index]['recipe_serv_price']['serv_save'] * -1 * al[index]['serv_size']).toStringAsFixed(2)})", 
                              //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: blueColor),),
                              //           Text("\$ ${(al[index]['recipe_serv_price']['serv_price'] * al[index]['serv_size']).toStringAsFixed(2)}", 
                              //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                                      
                              //       ],),
                              //     )
                              //   : Container(),
                          
                              Padding(
                                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("(\$ ${(al[index]['recipe_serv_price']['serv_save'] * -1 * al[index]['serv_size']).toStringAsFixed(2)})", 
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: blueColor),),
                                        Text("\$ ${(al[index]['recipe_serv_price']['serv_deal'] * al[index]['serv_size']).toStringAsFixed(2)}", 
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                                      
                                    ],),
                                  ),
                          
             
                                Padding(
                                  padding: const EdgeInsets.only(top: 0.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      (widget.listTab == 'menu')
                                      ? 
                                        InkWell(
                                          child: Container(
                                            // padding: EdgeInsets.only(left: 40, right: 20),
                                            padding: EdgeInsets.only(left: 40, right: 20, top: 10, bottom: 20),
                                            child: Icon(
                                              Icons.arrow_downward,
                                              color: Colors.green,
                                              size: 22.0,
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              if (shoppingStart == true) {addOneAttemptedMenuChange(); return;}
                                              // if (widget.serveSize > 1) al[index]['serv_size'] -=1;
                                              if (al[index]['serv_size'] > 1) al[index]['serv_size'] -=1;
                                              widget.servingChanged!(al[index]['recp_dates_id']);
                                            });
                                          }
                                        )
                                      : Container(),

                                      Padding(
                                        padding: const EdgeInsets.only(left:0.0, right: 0.0, top: 10, bottom: 20),
                                        child: Text('servings: ${al[index]['serv_size']}'),
                                      ),

                                      (widget.listTab == 'menu')
                                        ? 
                                          InkWell(
                                            child: Container(
                                              // padding: EdgeInsets.only(left: 20, right: 40),
                                              padding: EdgeInsets.only(left: 40, right: 20, top: 10, bottom: 20),
                                              child: Icon(
                                                Icons.arrow_upward,
                                                color: Colors.green,
                                                size: 22.0,
                                              ),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                if (shoppingStart == true) {addOneAttemptedMenuChange(); return;}
                                                if (al[index]['serv_size'] < 20) al[index]['serv_size'] +=1;
                                                widget.servingChanged!(al[index]['recp_dates_id']);
                                              });
                                            }
                                          )
                                        : Container(),
                                                          
                                  ],),
                                )

                  
                          ],
                        ),
                      ),
                            
                    ),
                    onTap: () {
                          widget.recipeSelect(al[index]['recp_dates_id'], al[index]['serv_size']);
                    }
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
                    padding: EdgeInsets.only(bottom: my_screenHeight / 4),
                    child: 
                      (globals.menuAll.isNotEmpty)
                        ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Click Menu Tab ', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: blueColor)),
                                Icon(Icons.arrow_upward, size: 28, color: blueColor,),                           
                              ],
                            ),
                            Text('to view your selections', style: TextStyle(fontSize: 22.0, height: 1.5)),
                          ],
                        )
                        : Column(
                            children: [
                              Text('No Deals Found', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: blueColor)),
                              // Text('check back soon', style: TextStyle(fontSize: 22.0, height: 1.5)),
                              Container(
                                // color: blueColor,
                                margin: EdgeInsets.only(left: 50.0, right: 50.0, top: 30.0), // , bottom: 20.0),
                                // padding: EdgeInsets.all(20.0),
                                child: Text((currStore!.storeID == 1 ? publixNotYet : freshNotYet), style: TextStyle(fontSize: 20.0),)
                                ),

                              (dowToday == 4 || dowToday == 5)
                                ? Container(
                                  margin: EdgeInsets.only(left: 50.0, right: 50.0, top: 30.0),
                                  child: (Text(wereLate, style: TextStyle(fontSize: 14.0)))
                                  )
                                : Container()
                            ],
                          )
                  )  

          : (widget.listTab == 'menu') 
            ? (widget.activeList.isNotEmpty) 
              ? Container()
              : // nothing to see in Swipe tab - 2 options, 
                    Padding(
                      padding: EdgeInsets.only(bottom: my_screenHeight / 4),
                      child: 
                        (globals.menuAll.isNotEmpty)
                          ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('No Recipes to Cook', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: blueColor)),
                                  // Icon(Icons.arrow_upward, size: 28, color: blueColor,),                           
                                ],
                              ),
                              Text('swipe your recipes here', style: TextStyle(fontSize: 22.0, height: 1.5)),
                            ],
                          )
                          : Column(
                              children: [
                                Text('No Deals Found', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: blueColor)),
                                // Text('check back soon', style: TextStyle(fontSize: 22.0, height: 1.5)),
                                Container(
                                  // color: blueColor,
                                  margin: EdgeInsets.only(left: 50.0, right: 50.0, top: 30.0), // , bottom: 20.0),
                                  // padding: EdgeInsets.all(20.0),
                                  child: Text((currStore!.storeID == 1 ? publixNotYet : freshNotYet), style: TextStyle(fontSize: 20.0),)
                                  ),

                                (dowToday == 4 || dowToday == 5)
                                  ? Container(
                                    margin: EdgeInsets.only(left: 50.0, right: 50.0, top: 30.0),
                                    child: (Text(wereLate, style: TextStyle(fontSize: 14.0)))
                                    )
                                  : Container()
                              ],
                            )
                    )

                  :
                    (widget.listTab == 'reject') 
                        ? (widget.activeList.isNotEmpty) 
                          ? Container()
                          : // nothing to see in Swipe tab - 2 options, 
                                Padding(
                                  padding: EdgeInsets.only(bottom: my_screenHeight / 4),
                                  child: 
                                    (globals.menuAll.isNotEmpty)
                                      ? Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Text('Rejected Recipes', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: blueColor)),
                                              // Icon(Icons.arrow_upward, size: 28, color: blueColor,),                           
                                            ],
                                          ),
                                          Text('swipe ONLY if you dislike', style: TextStyle(fontSize: 22.0, height: 1.5)),
                                        ],
                                      )
                                      : Column(
                                          children: [
                                            Text('No Deals Found', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: blueColor)),
                                            // Text('check back soon', style: TextStyle(fontSize: 22.0, height: 1.5)),
                                            Container(
                                              // color: blueColor,
                                              margin: EdgeInsets.only(left: 50.0, right: 50.0, top: 30.0), // , bottom: 20.0),
                                              // padding: EdgeInsets.all(20.0),
                                              child: Text((currStore!.storeID == 1 ? publixNotYet : freshNotYet), style: TextStyle(fontSize: 20.0),)
                                              ),

                                          (dowToday == 4 || dowToday == 5)
                                            ? Container(
                                              margin: EdgeInsets.only(left: 50.0, right: 50.0, top: 30.0),
                                              child: (Text(wereLate, style: TextStyle(fontSize: 14.0)))
                                              )
                                            : Container()

                                          ],
                                        )
                                )

              : Container()
      ],
    );
    
  }
}



// Cook List is similar to MenuList except:
// less detail, not dismissable, does not have store & date title, is clickable to see full recipe

class CookList extends StatefulWidget {

  final String listTab;
  final List activeList;
  final Function(int, int) recipeSelect;
  final Function(int, String) markAsDone;

  CookList({required this.listTab, required this.activeList, required this.recipeSelect, required this.markAsDone,
    
    Key? key}) : super(key: key);

  @override
  State<CookList> createState() => _CookListState();
}

class _CookListState extends State<CookList> {

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

        Expanded(
          child: ListView.separated(
            separatorBuilder: (_, __) => Divider(height: 0),
            itemCount: al.length,
            
            itemBuilder: (context, index) {
              // GestureDetector - 2 methods: https://stackoverflow.com/questions/55050463/how-to-detect-swipe-in-flutter
              // DIsmissable - something with the swipping - if swipe not accepted or something
              return InkWell(
                child: Container(              
                      // height: (index == 0 ) ? 190 : 210,    // account for increased top marign after first
                      // width: 70,
                      // color: Colors.yellow,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: blueColor, width: 4.0),
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
                            child: Text(al[index]['recp_json']['title'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: blueColor),)
                          ),
                      
                          Text(al[index]['recp_json']['description']), //, style: TextStyle(fontSize: 15.0)),
                    
                      
                                            
                            // SizedBox(height: 6),
                            // Container(
                            //   // color: Colors.orange[100],
                            //   height: 22,
                            //   width: MediaQuery.of(context).size.width * .8,
                            //   padding: EdgeInsets.all(4),
                            //   // decoration: BoxDecoration(
                            //   //     color:  Color(0xFFfce0b6),
                            //   //     borderRadius: BorderRadius.all(Radius.circular(8))
                            //   //   ),
                            //   child: Center(
                            //     child: ListView.builder(
                            //       shrinkWrap: true,
                            //       scrollDirection: Axis.horizontal,
                            //       itemCount: al[index]['recp_json']['tags']['descriptors'].length,
                            //       itemBuilder: (context, idx) {
                      
                            //         return (idx == 0)
                            //           ? Text(al[index]['recp_json']['tags']['descriptors'][idx], )
                            //           : Text(' | ' + al[index]['recp_json']['tags']['descriptors'][idx], );         
                            //       }
                            //     ),
                            //   )
                            // ),
                      
                          // https://stackoverflow.com/questions/69164559/how-to-bring-widgets-to-next-line-in-listviewbuilder-flutter
                          SizedBox(height: 6),
                          Container(
                              // color: Colors.yellow[100],
                              // height: 48,
                              width: MediaQuery.of(context).size.width * .8,
                              constraints: BoxConstraints(minHeight: 48, maxHeight: 48),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color:  goldColorLight,
                                  borderRadius: BorderRadius.all(Radius.circular(8))
                                ),
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
                      
                            
                            
                            // SizedBox(height: 6),
                            // Container(
                            //   // color: Colors.orange[100],
                            //   height: 100,
                            //   width: MediaQuery.of(context).size.width * .8,
                            //   padding: EdgeInsets.all(4),
                            //   decoration: BoxDecoration(
                            //       color:  Color(0xFFfce0b6),
                            //       borderRadius: BorderRadius.all(Radius.circular(8))
                            //     ),
                            //   child: ListView.builder(
                            //     itemCount: al[index]['recp_json']['recipe']['instructions'].length,
                            //     itemBuilder: (context, idx) {
                      
                            //       return Padding(
                            //         padding: const EdgeInsets.all(2.0),
                            //         child: Text('${idx+1}. ${al[index]['recp_json']['recipe']['instructions'][idx]}'),
                            //       );
                            //     }
                            //   )
                            // ),
                      
                              
                            SizedBox(height: 6.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(fx.toLowerCaseButFirst(al[index]['recp_json']['complexity'])),
                                Text(" Prep: ${al[index]['recp_json']['time']['prep']}  |  Cook: ${al[index]['recp_json']['time']['cook']}"),
                                Text('Serve: ${al[index]['serv_size']}'),
                            ],),


                            (widget.listTab == 'cook_active')
                              ?
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0, right: 10.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary:  blueColor, // background
                                          onPrimary: goldColor, // foreground
                                          padding: EdgeInsets.only(top:8.0, bottom: 8.0, left: 16.0, right: 16.0),    
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),) 
                                        ),
                                        onPressed: () {
                                          print('-- mark as done---  go to rating ----');
                                          widget.markAsDone(al[index]['recp_dates_id'], al[index]['recp_json']['title']);
                                        },
                                        child:  Text('Mark as Done', style: TextStyle(fontSize: 18.0)),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),    // cook_done - where we show rating

                            // Container(
                            //   height: 10.0,
                            //   color: Colors.red,
                            //   )
                      
                            // // SizedBox(height: 12),
                            // (widget.listTab == 'menu')
                            //   ?  Padding(
                            //       padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Text("(\$ ${(al[index]['recipe_serv_price']['serv_save'] * -1 * al[index]['serv_size']).toStringAsFixed(2)})", 
                            //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: blueColor),),
                            //           Text("\$ ${(al[index]['recipe_serv_price']['serv_price'] * al[index]['serv_size']).toStringAsFixed(2)}", 
                            //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                                    
                            //       ],),
                            //     )
                            //   : Container(),
                      
                      
                      
                            // (widget.listTab == 'menu')
                            //   ?
                            //     Padding(
                            //       padding: const EdgeInsets.only(top: 8.0),
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           InkWell(
                            //             child: Container(
                            //               padding: EdgeInsets.only(left: 40, right: 20),
                            //               child: Icon(
                            //                 Icons.arrow_downward,
                            //                 color: Colors.green,
                            //                 size: 22.0,
                            //               ),
                            //             ),
                            //             onTap: () {
                            //               setState(() {
                            //                 if (widget.serveSize > 1) al[index]['serv_size'] -=1;
                            //                 widget.servingChanged!(al[index]['recp_dates_id']);
                            //               });
                            //             }
                            //           ),
                            //           Padding(
                            //             padding: const EdgeInsets.only(left:0.0, right: 0.0),
                            //             child: Text('servings: ${al[index]['serv_size']}'),
                            //           ),
                            //           InkWell(
                            //             child: Container(
                            //               padding: EdgeInsets.only(left: 20, right: 40),
                            //               child: Icon(
                            //                 Icons.arrow_upward,
                            //                 color: Colors.green,
                            //                 size: 22.0,
                            //               ),
                            //             ),
                            //             onTap: () {
                            //               setState(() {
                            //                 if (widget.serveSize > 1) al[index]['serv_size'] +=1;
                            //                 widget.servingChanged!(al[index]['recp_dates_id']);
                            //               });
                            //             }
                            //           ),
                      
                            //       ],),
                            //     )
                            //   : Container(),
              
                            // // if we want serving - that we cant change - we may want to add above
                            // - allow user to change serving here - but we would have to adjust the entire recipe 
                          
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     Padding(
                                //       padding: const EdgeInsets.only(top:8.0),
                                //       child: Text('servings: ${al[index]['serv_size']}'),
                                //     ),
                                //   ],
                                // )      
                        ],
                      ),
                    ),
                          
                  ),
                ),

                 onTap: () {
                      widget.recipeSelect(al[index]['recp_dates_id'], al[index]['serv_size']);
                  }
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
                                Text('Click Menu Tab ', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: blueColor)),
                                Icon(Icons.arrow_upward, size: 28, color: blueColor,),                           
                              ],
                            ),
                            Text('to view your selections', style: TextStyle(fontSize: 22.0, height: 1.5)),
                          ],
                        )
                        : Column(
                            children: const [
                              Text('No Deals Found', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: blueColor)),
                              Text('check back soon', style: TextStyle(fontSize: 22.0, height: 1.5)),
                            ],
                          )
                  )
      
            

          : Container()
      ],
    );
    
  }
}

