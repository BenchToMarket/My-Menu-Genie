

import 'package:flutter/material.dart';
import 'package:menu_genie/main.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
// import 'dart:async';

import '../admin/global_classes.dart';
import '../admin/savory_api.dart';


///
/// some saving at exit thoughts
/// https://www.dhiwise.com/post/flutter-exit-app-strategies-and-handling-unsaved-data
/// https://pub.dev/packages/flutter_exit_app/example
/// using WillPopScope - https://www.youtube.com/watch?v=B8gEF1COFVg
/// 

class ShopCreate extends StatefulWidget {
  const ShopCreate({Key? key}) : super(key: key);

  @override
  State<ShopCreate> createState() => _ShopCreateState();
}

class _ShopCreateState extends State<ShopCreate> {

  bool _isLoading = false;  
  bool _isDateSelected = true;

  late GlobalVar globals;
  final HttpService httpSavory = HttpService();
  final GlobalFunctions fx = GlobalFunctions();  

  // int initialCommitStatus = 0;    // 0-no shop list, 1-list setup, 2-list commit, 4-list-purchased

  final double _sliderMargin = 160.0;
  bool _sliderLeft = false;

  int commitCount = 0;
  double commitSavings = 0.0;
  double commitTotal = 0.0;
  
  @override
  void initState() { 

    globals = Provider.of<GlobalVar>(context, listen: false);

    super.initState();
    getActiveMenu();
    startFetching();
    // startChangeTimer();
  }

  @override
  void dispose() {
    checkForChanges(globals.activeMenu['commit_status']);
    // if (timer != null) {
    //   timer.cancel();
    // }
    super.dispose();
  } 

  
  // *** should be more global 
  getActiveMenu() {
    
    print('33333333333333333333333333333333333');
    // print(globals.menuCommit);
    // print(globals.shopDate);

    globals.activeMenu = {};
    if (globals.menuCommit.isNotEmpty) {
      for (var mc in globals.menuCommit) {
        // print(mc['date_end_shop']);
        // print(mc['date_end_shop'].runtimeType);
        if (mc['store_id'] == currStore.storeID && mc['commit_status'] >=0 && DateTime.parse(mc['date_end_shop']).compareTo(DateTime.parse(globals.shopDate)) >= 0) {
          globals.activeMenu = mc;
        }
      }
    }
    print(globals.activeMenu);

    if (globals.activeMenu['commit_status'] == 2) {
      globals.shopThreshMet = true;
    }

  }

  startFetching() async {

    if (globals.shopDate == 'Select') {
      _isDateSelected = false;
      return;
    }

    _isLoading = true;

    // print('0000000000000000000000000000000000000000000000000');
    // print(globals.shopDate);
    // print(globals.activeMenu['id']);

    globals.popShoppingList(await httpSavory.getShoppingList(globals.shopDate, globals.activeMenu['id']));

    popStoresShoppingList(currStore.storeID);
  

    // print('111111111111111111111111111111111111');

    // testing -- globals.shopBuy = globals.shopBuy + globals.shopBuy + globals.shopBuy;

    // // print('--------------------------------');
    // // for (var l in globals.shoppingList) {
    // //   print(l);
    // // }

    // // print(globals.shoppingList);
    // print('-------------------  shop buy  -------------');
    // for (var p in globals.shopBuy) {
    //   print(p);
    // }
    // print('-------------   dont buy  -------------------');
    // for (var p in globals.shopDontBuy) {
    //   print(p);
    // }
    // print('--------------------------------');
    // // globals.shopVerify += globals.shopVerify;
    // for (var v in globals.shopVerify) {
    //   print(v);
    // }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

  }

  popStoresShoppingList(int storeID) {

    globals.shopBuyAll.clear();
    globals.shopBuy.clear();
    globals.shopDontBuy.clear();
    globals.shopVerifyAll.clear();
    globals.shopVerify.clear();
    globals.shopDontVerify.clear();
    globals.shopCategory.clear();

    for (var l in globals.shoppingList) {
      if (l['store_id'] == storeID) {
          globals.shopBuyAll = l['shopping_list']['purchase'];
          globals.shopVerifyAll = l['shopping_list']['verify'];
          globals.shopBuy = l['shopping_list']['purchase'].where((item) => item['shop_accept'] == 1).toList();
          globals.shopDontBuy = l['shopping_list']['purchase'].where((item) => item['shop_accept'] == -1).toList();
          globals.shopVerify = l['shopping_list']['verify'].where((item) => item['dont'] == false).toList();
          globals.shopDontVerify = l['shopping_list']['verify'].where((item) => item['dont'] == true).toList();
          globals.shopCategory = l['shopping_list']['shop_cat'];
      }
    }
    globals.shopCategory.insert(0, "Verify");
    globals.shopCategory.insert(0, "All");

  }


  checkForChanges(int newStatus) async {
    
    if (globals.shopThreshMet == false) {return;}
    print('----    checking for changes on shopping list---- ');

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

  }

  // commitShopping() {
  //   // need to update in 3 places:
  //   // activeMenu, menuCommitList and maybe db (can do later when saving other changes)
  //   globals.activeMenu['commit_status_new'] = 2;
  //   for (var mc in globals.menuCommit) {
  //     // print(mc);
  //     if (mc['id'] == globals.activeMenu['id']) {
  //       mc['commit_status'] = 2;
  //     }
  //   }
  // }

  getCommitNumbers() {
    commitCount = 0;
    commitSavings = 0.0;
    commitTotal = 0.0;
    for (var row in globals.shopBuy) {
      if (row['shop_check'] == true) {
        commitCount += 1;
        commitSavings += (row['shop_sug'] * (row['option_price'] - row['deal_price']));
        commitTotal += (row['shop_sug'] * row['option_price']);
      }
    }
  }

  activateSlider() {
    setState(() { _sliderLeft = true; });
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {return const Center(child: CircularProgressIndicator());}

    return DefaultTabController(
      length: 2,
      initialIndex:globals.shopActiveTab, //    1,
      child: Scaffold(
        appBar: AppBar(
              bottom: PreferredSize(
                preferredSize: const Size(10.0, 0.0),
                child: TabBar(
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 4.0, color: Colors.white),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.w800
                  ),
                  onTap: (index) async {
                    globals.shopActiveTab = index;
                      if (index == 0) {
                      } else if (index == 1) {
                      } else if (index == 2) {
                      } 
                      
                  },
                  tabs: [
                    const Tab(child: Text("Don't Buy")),
                    Tab(child: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.shopping_cart, color:  Color(0xFF3CBC6D),),   
                          const Text("My List"),
                          InkWell(
                            child: const Icon(Icons.shopping_cart),
                            onTap: () {
                              getCommitNumbers();
                              setState(() {
                                _sliderLeft = true;
                              });
                            },
  
                            ),                 
                        ],
                      )
                    ),

                  ],
                ),
              ),

            ),
            body: Stack(
              children: [
                  TabBarView(
                    children: [
                
                      // const Center(child: const Text('dont')),
                
                      Center(child: ShopList(listTab: 'dont', activeList: globals.shopDontBuy, shopSwiped: swipedBuy, verifySwiped: swipedVerify, inactiveTry: activateSlider,)),
                
                      Center(child: ShopList(listTab: 'list', activeList: globals.shopBuy, shopSwiped: swipedBuy, verifySwiped: swipedVerify, inactiveTry: activateSlider,))
                
                    
                    ],
                  ),



                  AnimatedPositioned(
                    top: 100.0,
                    left: _sliderLeft ? (_sliderMargin / 2) : (my_screenWidth + 80.0),
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      height: my_screenHeight * .55,
                      width: my_screenWidth - _sliderMargin,  
                      decoration: BoxDecoration(
                        color: Colors.white,    
                        borderRadius: const BorderRadius.all(Radius.circular(10)) ,
                        border: Border.all(
                          width: 4,
                          color: const Color(0xFF3CBC6D),
                        ),
                      ),                 
                      // color: Colors.blue,
                    
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                (globals.activeMenu['commit_status']) < 4
                                  ? const Text('Confirm Purchase', style: TextStyle(fontSize: 18.0, color: Color(0xFFe9813f)),)
                                  : Column(
                                    children: const [
                                      Text('Completed Purchase', style: TextStyle(fontSize: 18.0, color: Colors.black),),
                                      Text("No changes allowed", style: TextStyle(fontSize: 14.0, color: Color(0xFFe9813f)),),
                                    ],
                                  ),
                                Column(
                                  children: [
                                    const Text('Items'),
                                    const SizedBox(height: 2.0),
                                    Text(commitCount.toString(), style: const TextStyle(fontSize: 18.0, color: Color(0xFF3CBC6D)),),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Savings'),
                                    const SizedBox(height: 2.0),
                                    Text('\$ ${commitSavings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18.0, color: Color(0xFF3CBC6D)),),
                                  ],
                                ),

                                (globals.activeMenu['commit_status']) < 4
                                  ? 
                                    Container(
                                      width: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: const Color(0xFF3CBC6D), // background
                                            onPrimary: Colors.white, // foreground
                                            padding: const EdgeInsets.all(8.0),    
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),) 
                                          ),
                                          onPressed: () {
                                            
                                            DateTime dateToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                                            globals.activeMenu['commit_status_new'] = 4;
                                            globals.activeMenu['date_shopped'] = fx.FormatDate(dateToday.toString());
                                            globals.activeMenu['shopped_count'] = commitCount;
                                            globals.activeMenu['shopped_total'] = commitTotal;
                                            globals.activeMenu['shopped_savings'] = commitSavings;
                                            
                                            checkForChanges(4);  // this also saves 

                                            Future.delayed(const Duration(milliseconds: 300), () {
                                              setState(() { _sliderLeft = false; });
                                            });
                                          },
                                          child: const Text('Confirm')),
                                      ),
                                    )

                                  : const SizedBox(height: 30.0,)

                                  
                          
                          
                              ],
                            ),
                          ),

                          InkWell(child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, right: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text((globals.activeMenu['commit_status'] < 4) ? 'Cancel' : 'Got it', style: const TextStyle(fontSize: 16.0,color: Color(0xFFe9813f)),),
                              ],
                            ),
                          ),
                            onTap: () {
                              setState(() {
                                _sliderLeft = false;
                              });
                              },
                          )
                        ],
                      )

                    ),
                  ),


              ],

            ),
      ),
    );
    
  }

  
  // *****************************************************
  // the difference with shop vs menu - we have not saved the shopping list until we commit
  // so we dont have an PK id for each item on the list until we save it
  swipedBuy(String fromTab, String direction, Map move) { // int idx) {    // 
    if (globals.changesMadeBuy == false) {globals.changesMadeBuy = true;};
    int insertHere = 0;

    if (fromTab == 'list') {
        if (direction == 'left') {
          for (var l in globals.shopDontBuy) {
            if (l['index'] < move['index']) {
              insertHere +=1;
            }
          }
          setState(() {
            globals.shopDontBuy.insert(insertHere, move);
            updateSwipe(move['index'], -1);
            globals.shopBuy.removeWhere((item) => item['index'] == move['index']);
          });
        }

    } else if (fromTab == 'dont') {
        if (direction == 'right') {
          for (var l in globals.shopBuy) {
            if (l['index'] < move['index']) {
              insertHere +=1;
            }
          }
          setState(() {
            
            // globals.shopBuy.add(move);
            globals.shopBuy.insert(insertHere, move);
            updateSwipe(move['index'], 1);
            globals.shopDontBuy.removeWhere((item) => item['index'] == move['index']);

            // // // globals.shopBuy.insert(insertHere, globals.shopDontBuy[idx]);
            // globals.shopBuy.add(globals.shopDontBuy[idx]);
            // updateSwipe(globals.shopDontBuy[idx]['index'], 1);
            // globals.shopDontBuy.removeWhere((item) => item['index'] == globals.shopDontBuy[idx]['index']);
          });
        }
    }
  }

  updateSwipe(int id, int pos) {

    for (var all in globals.shopBuyAll) {
      if (all['index'] == id) {
        all['shop_accept'] = pos;
        all['changed'] = true;
      }
    }
  }

  swipedVerify(String fromTab, String direction, Map move) {
    // globals.changesMadeVerify = true;
    // if (globals.changesMadeBuy == false) {globals.changesMadeBuy = true;}; - right now we save verfiy only if buy has changes

    if (fromTab == 'list') {
        if (direction == 'left') {
          
          setState(() {
            globals.shopDontVerify.add(move);
            updateVerify(move['index'], -1);
            globals.shopVerify.removeWhere((item) => item['index'] == move['index']);
          });
        }

    } else if (fromTab == 'dont') {
          setState(() {
            globals.shopVerify.add(move);
            updateVerify(move['index'], 1);
            globals.shopDontVerify.removeWhere((item) => item['index'] == move['index']);
          });
    }
  }

  updateVerify(int id, int pos) {
    for (var all in globals.shopVerifyAll) {
      if (all['index'] == id) {
        all['dont'] = (pos == 1) ? false : true;
        // all['shop_accept'] = pos;
        all['changed'] = true;
      }
    } 
  }

}




class ShopList extends StatefulWidget {

  final String listTab;
  final List<dynamic> activeList;                    // ** not sure if we tell what list - these are global list - but be careful with tab (dont)
  final Function(String, String, Map) shopSwiped;
  final Function(String, String, Map) verifySwiped;
  final VoidCallback inactiveTry;

  const ShopList({required this.listTab, required this.activeList,
    required this.shopSwiped, required this.verifySwiped, required this.inactiveTry,
    Key? key}) : super(key: key);

  @override
  State<ShopList> createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {

  // late List<dynamic> al;
  late List<dynamic> filteredList;
  final GlobalFunctions fx = GlobalFunctions();  
  late GlobalVar globals;

  // int storeSelected = 0;
  // int catSelected = 0;
  String catName = '';
  
  // bool _isCommited = false;   // or do by status number
  int commitThresh = 5;
  int commitCount = 0;
  int inactiveCount = 0;


  @override
  void initState() {
    super.initState();

    // print('00000000000000000000000000000000000000000');
    // print(catSelected);

    // al = widget.activeList;
    // filteredList = widget.activeList;
    filteredList = List.from(widget.activeList);
    globals = Provider.of<GlobalVar>(context, listen: false);  

    selectedCategory(globals.shopSubCat); 
    selectedStore(globals.shopSubStore);
    
    if (filteredList.length < (commitThresh+2)) {commitThresh = 3;}   // 6 or less, commit at 3

  }


  selectedStore(index) {

    print('------   selected store  -- $index');

    currStore.ChangeStore(globals.userStores[index].storeID, globals.userStores[index].storeName);
    setState(() {
      // storeSelected = index;
      globals.shopSubStore = index;
    });

    // testing only - printing our checked list
    // print('--- items checked ----');
    // itemChecked.forEach((key, value) {
    //   print(value);
    // });
    // print('-----  items in   main list -----');
    // widget.activeList.forEach((element) {
    //   if (element['shop_check'] == true) {
    //     print(element['item']);
    //   }
    // });
    
  }


  selectedCategory(index) {

    filteredList.clear();
    // catSelected = index;
    globals.shopSubCat = index;
    catName = globals.shopCategory[index];

    if (catName == "All") {
      if (widget.listTab == 'list') {
          filteredList = List.from(globals.shopBuy);
          // filteredList = globals.shopBuy;
      } else {
          filteredList = List.from(globals.shopDontBuy);
      }

    } else if (catName == 'Verify') {
      if (widget.listTab == 'list') {
          filteredList = List.from(globals.shopVerify);
      } else {
          filteredList = List.from(globals.shopDontVerify);
      }
      
    } else {
      for (var item in widget.activeList) {
        if (item['cat_main'] == catName) {
          filteredList.add(item);
        } 
      }
    }

    setState(() {});
  }

  Map<int, String> itemChecked = {};
  void selectedShopItem(bool selected, int itemID, String itemName) {
    if (selected == true) {
      setState(() {
        // userChecked.add(dataName);
        itemChecked[itemID] = itemName;
      });
    } else {
      setState(() {
        // userChecked.remove(dataName);
        itemChecked.removeWhere((key, value) => key == itemID);
      });
    }
  }

  bool sameCat = false;

  doWeAddS(int count, String type) {
    String addS = '';

    if (count > 1) {
      if (type != 'ct') {
        addS = 's';
      }
    }
    return addS;
  }


  countChange(bool val) {

    if (globals.changesMadeBuy == false) {globals.changesMadeBuy = true;};
    if (globals.activeMenu['commit_status_new'] > 2) {return;}
    // we only need to count committed - if 0, 1 or 2 (nothing, setup, commit-not purchase)
    // >2 we bought items on list

    if (val == true) {
      addCommit();
    } else {
      commitCount -= 1;
    }
  }

  addCommit() {
    commitCount +=1;
    
    if (globals.activeMenu['commit_status'] < 2) {     // 1-setup but not committed (not using yet)
      // only for uncommitted shopping
        if (commitCount == commitThresh) {
            globals.shopThreshMet = true;
        }
    }

  }

  testInactiveCount() {
    inactiveCount +=1;
    if (inactiveCount > 2) {
      widget.inactiveTry();
      inactiveCount = 0;
    }
  }

  // commitShopping() {
  //   // need to update in 3 places:
  //   // activeMenu, menuCommitList and maybe db (can do later when saving other changes)
  //   globals.activeMenu['commit_status'] = 2;
  //   for (var mc in globals.menuCommit) {
  //     print(mc);
  //     if (mc['id'] == globals.activeMenu['id']) {
  //       mc['commit_status'] = 2;
  //     }
  //   }
  // }


  @override
  Widget build(BuildContext context) {

    return Container(

      color: (globals.activeMenu['commit_status'] < 3) ? null : Colors.grey[300],   
      
      padding: (globals.activeMenu['commit_status'] < 3)
        ? null
        : const EdgeInsets.only(left: 16, right: 16),
      
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 18.0, bottom: 6.0),
            child: Container(
              width: my_screenWidth - 50,
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                // separatorBuilder: (_, __) => Divider(height: 12),
                itemCount: globals.userStores.length,
                itemBuilder: (context, index) {
                  return StoreSelector(
                    storeOption: globals.userStores[index],
                    index: index,
                    isSelected: globals.shopSubStore == index ? true : false,
                    storeChanged: selectedStore,
                  );
                }
                ),
            )
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              width: my_screenWidth - 20,
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                // separatorBuilder: (_, __) => Divider(height: 12),
                itemCount: globals.shopCategory.length,
                itemBuilder: (context, index) {
                  return CatSelector(
                    catName: globals.shopCategory[index],
                    index: index,
                    isSelected: globals.shopSubCat == index ? true : false,
                    categoryChanged: selectedCategory,
                  );
                }
                ),
            )
          ),

          (catName != 'Verify')
            ?
              Expanded(
                child: ListView.builder(
                  // separatorBuilder: (_, index) => Divider(height: 6, color: Colors.red),
                  itemCount: filteredList.length,
                  
                  itemBuilder: (context, index) {
                    // GestureDetector - 2 methods: https://stackoverflow.com/questions/55050463/how-to-detect-swipe-in-flutter
                    // DIsmissable - something with the swipping - if swipe not accepted or something
                    sameCat = (index == 0 || catName == 'Verify') ? false : filteredList[index]['cat_main'] == filteredList[index-1]['cat_main'];
                    return Container(              
                          // height: (widget.listTab == 'list') ? (sameCat == false ? 80 : 55) : 40,
                          height: (sameCat == false ? 80 : 55),
                          // width: 70,
                          // color: Colors.red,
                          
                          margin: EdgeInsets.only(top: (sameCat) ? 0.0 : 4.0),

                      child: Dismissible(
                        // key: Key(filteredList[index]),
                        key: Key(filteredList[index]['index'].toString()),
                        // key: Key(filteredList[index]['item']),
                        // key:  UniqueKey(),
              
                        confirmDismiss: (direction) async {
                          if (globals.activeMenu['commit_status'] < 3) {
                              if (direction == DismissDirection.startToEnd) {    // this is a right-swipe
                                    if (widget.listTab == 'list') {
                                      return false;
                                    } else {
                                        widget.shopSwiped(widget.listTab, 'right', filteredList[index]);
                                        filteredList.removeAt(index);     // filtered list is a copy of the activeList - so we must remove from here as well
                                        // widget.shopSwiped(widget.listTab, 'right', index);
                                        countChange(false);
                                        return true;     
                                    }
                  
                              } else {
                                    if (widget.listTab == 'dont') {
                                      return false;
                                    } else {
                                      if (filteredList[index]['shop_check'] == false) {
                                          widget.shopSwiped(widget.listTab, 'left', filteredList[index]);
                                          filteredList.removeAt(index);
                                          // widget.shopSwiped(widget.listTab, 'left', index);
                                          countChange(true);
                                          return true;     
                                      } else {
                                        return false;
                                      }

                                    }            
                              }   
                          } else {
                            testInactiveCount();   
                          }

                        },

                        child: Column(
                              children: [
                        
                                (sameCat == false) 
                                  ? Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Text((filteredList[index]['cat_main'] != 0) ? filteredList[index]['cat_main'].toString() : 'Other', style: const TextStyle(fontSize: 18.0),),
                                  )
                                  : Container(),

                                    Card(
                                      // shape: RoundedRectangleBorder(
                                      //   side: BorderSide(color: Color(0xFF3CBC6D), width: 2.0),
                                      //   borderRadius: BorderRadius.circular(10),
                                      //   ),
                                      margin: const EdgeInsets.only(right:10, left: 10),
                                      // color: Colors.grey,
                                      elevation: 10,
                                      // shadowColor:Color(0xFFe9813f), // Colors.black,
                                      child: Container(
                                        // color: Colors.red,
                                        padding: const EdgeInsets.only(top: 6.0, left: 10.0, right: 10.0, bottom: 6.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                      
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                            
                                                        Checkbox(
                                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                          value: filteredList[index]['shop_check'],
                                                          activeColor: const Color(0xFFe9813f),
                                                          onChanged: (val) {
                                                            // selectedShopItem(val!, filteredList[index]['id'], filteredList[index]['item']);
                                                            if (globals.activeMenu['commit_status'] < 3) {
                                                                if (widget.listTab == 'list') {
                                                                  setState(() {
                                                                    filteredList[index]['shop_check'] = val; 
                                                                    filteredList[index]['changed'] = true; 
                                                                    countChange(val!);
                                                                  });
                                                                }
                                                            } else {
                                                              testInactiveCount();  
                                                            }

                                                            
                                                          },
                                                        ),
                                                            
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(filteredList[index]['item'],
                                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),),

                                                            (filteredList[index]['cat_main'] != 0)
                                                              ? 
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 16.0),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(filteredList[index]['shop_sug'].toString()),
                                                                      const SizedBox(width: 4,),
                                                                      Text(filteredList[index]['units_sell'].toString()),
                                                                      // (filteredList[index]['shop_sug'] > 1) ? Text('s') : Container()
                                                                      Text(doWeAddS(filteredList[index]['shop_sug'], filteredList[index]['units_sell']))
                                                                    ],
                                                                  ),
                                                                )              
                                                              :                           
                                                              Padding(
                                                                  padding: const EdgeInsets.only(left: 16.0),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(filteredList[index]['total_serv'].toString()),
                                                                      const SizedBox(width: 4,),
                                                                      Text(filteredList[index]['cook'].toString()),
                                                                      Text(doWeAddS(filteredList[index]['total_serv'], filteredList[index]['cook']))
                                                                    ],
                                                                  ),
                                                                )           

                                                          ],
                                                        ),
                                                      ],
                                                    ),

                                                  ],
                                                ),

                                              ],
                                            ),


                                            (filteredList[index]['cat_main'] != 0)
                                              ?
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                        Text("\$  ${(filteredList[index]['shop_sug'] * filteredList[index]['option_price']).toStringAsFixed(2)}",
                                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                                        const SizedBox(height: 4,),
                                                        Padding(
                                                          padding: const EdgeInsets.only(right: 60.0),
                                                          child: Text("(${(filteredList[index]['shop_sug'] * (filteredList[index]['option_price'] - filteredList[index]['deal_price'])).toStringAsFixed(2)})",
                                                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),),
                                                        ),
                                                ],)
                                              : const SizedBox(width: 30)
                                          ],
                                        ),
                                      ),
                                            
                                    ),

                              ],
                            ),

                      ),
                    );
                  }
                ),
              )

            :
                  Expanded(
                    child: 
                        ListView.builder(
                              itemCount: filteredList.length,
                            
                              itemBuilder: (context, index) {
                                return Container(

                                  child: Dismissible(
                                        key: Key(filteredList[index]['index'].toString()),
                              
                                        confirmDismiss: (direction) async {
                                          if (globals.activeMenu['commit_status'] < 3) {
                                              if (direction == DismissDirection.startToEnd) {    // this is a right-swipe
                                                    if (widget.listTab == 'list') {
                                                      return false;
                                                    } else {
                                                        widget.verifySwiped(widget.listTab, 'right', filteredList[index]);
                                                        filteredList.removeAt(index);     // filtered list is a copy of the activeList - so we must remove from here as well
                                                        // widget.shopSwiped(widget.listTab, 'right', index);
                                                        return true;     
                                                    }
                                  
                                              } else {
                                                    if (widget.listTab == 'dont') {
                                                      return false;
                                                    } else {
                                                      widget.verifySwiped(widget.listTab, 'left', filteredList[index]);
                                                      filteredList.removeAt(index);
                                                      // widget.shopSwiped(widget.listTab, 'left', index);
                                                      return true;     
                                                    }            
                                              }
                                          } else {
                                            testInactiveCount();  
                                          }

                                        },

                                  child: Column(
                                    children: [
                                      
                                      (index == 0)
                                        ?
                                          const Padding(
                                              padding: EdgeInsets.only(top: 10.0, bottom: 14.0),
                                              child: Text('Items you may have at Home', style: TextStyle(fontSize: 18.0),),
                                              // child: Text('Select when you Have?', style: TextStyle(fontSize: 18.0),),
                                            )

                                        : Container(),


                                      // VerifyCard(verifyName: filteredList[index], isSelected: false),
                            
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: InkWell(
                                          child: Card(
                                              shape: RoundedRectangleBorder(
                                                // side: BorderSide(color: Color(0xFF3CBC6D), width: 2.0),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              elevation: 10,
                                              // shadowColor:Color(0xFFe9813f), // Colors.black,
                                              // color: Colors.white,
                                              color: (filteredList[index]['shop_check']) ? Colors.orange[100] : Colors.white,
                                              // color: (filteredList[index]['dont']) ? Colors.grey[300] : Colors.orange[100],
                                            margin: const EdgeInsets.only(right:30, left: 30),
                                            child: Container(
                                              height: 50.0,
                                              width: my_screenWidth,
                                               padding: const EdgeInsets.only(top: 6.0, left: 10.0, right: 10.0, bottom: 6.0),
                                              child: Center(child: Text(filteredList[index]['name'], style: const TextStyle(fontSize: 16.0)))),      // filteredList[index]['item'])
                                          ),
                                          onTap: () {
                                            // removed for swipe function - keeping in case i want back
                                            // if we want to check off that it is in our cart - might do by shop accept
                                            if (globals.activeMenu['commit_status'] < 3) {
                                                setState(() {
                                                    filteredList[index]['shop_check'] = !filteredList[index]['shop_check'];
                                                });
                                            } else {
                                                testInactiveCount();  
                                            }

                                          },
                                        ),
                                      )


                                    ],),
                                )
                                );
                                    
                                
         
                              }
                            )
                  ),


          // so screen wont be block if No Deals or All Accepted/Rejected
          (widget.listTab == 'list') 
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
                                  Icon(Icons.arrow_left, size: 28, color: Color(0xFF3CBC6D),),                           
                                  Text(' Select your Menu', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: Color(0xFF3CBC6D))),
                                   ],
                              ),
                              const Text('start with your menu', style: TextStyle(fontSize: 22.0, height: 1.5)),
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
      ),
    );
    
  }

}


class StoreSelector extends StatelessWidget {

  final Store storeOption;
  final int index;
  final bool isSelected;
  final Function(int) storeChanged;

  StoreSelector({required this.storeOption,required this.index, required this.isSelected, required this.storeChanged,
    Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero, // Set this
                      // padding: EdgeInsets.zero, // and this
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),    
                      primary:  (isSelected ?  const Color(0xFF3CBC6D) : Colors.white), // background
                      onPrimary: Colors.black, // foreground  
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),) 
                    ),
                    onPressed: () {
                      storeChanged(index);
                    },
                    child:  Text(storeOption.storeName, style: TextStyle(color: isSelected ?  Colors.white : Colors.black, fontSize: 18.0)),
                ),
    );
  }
}



class CatSelector extends StatelessWidget {

  final String catName;
  final int index;
  final bool isSelected;
  final Function(int) categoryChanged;

  CatSelector({required this.catName,required this.index, required this.isSelected, required this.categoryChanged,
    Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14.0),
      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero, // Set this
                      // padding: EdgeInsets.zero, // and this
                      padding: const EdgeInsets.only(left: 14.0, right: 14.0),    
                      primary:  (isSelected ?  const Color(0xFFe9813f) : Colors.white), // background
                      onPrimary: Colors.black, // foreground  
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),) 
                    ),
                    onPressed: () {
                      categoryChanged(index);
                    },
                    child:  Text(catName, style: TextStyle(color: isSelected ?  Colors.white : Colors.black, fontSize: 16.0)),
                ),
    );
  }
}





// class VerifyCard extends StatefulWidget {

//   final String verifyName;
//   bool isSelected;
//   VerifyCard({required this.verifyName, required this.isSelected,
//       Key? key}) : super(key: key);

//   @override
//   State<VerifyCard> createState() => _VerifyCardState();
// }

// class _VerifyCardState extends State<VerifyCard> {
//   @override
//   Widget build(BuildContext context) {

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: InkWell(
//         child: Card(
//               shape: RoundedRectangleBorder(
//                 // side: BorderSide(color: Color(0xFF3CBC6D), width: 2.0),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               elevation: 10,
//               // shadowColor:Color(0xFFe9813f), // Colors.black,
//               color: (widget.isSelected) ? Colors.orange[100] : Colors.white,
//             margin: const EdgeInsets.only(right:30, left: 30),
//             child: Container(
//               height: 50.0,
//               width: my_screenWidth,
//                 padding: const EdgeInsets.only(top: 6.0, left: 10.0, right: 10.0, bottom: 6.0),
//               child: Center(child: Text(widget.verifyName, style: const TextStyle(fontSize: 16.0)))),      // filteredList[index]['item'])
//           ),
//         onTap: () {
//           setState(() {
//               widget.isSelected = !widget.isSelected;
//           });
//         },
        
//       ),
//     );
    
//   }
// }
