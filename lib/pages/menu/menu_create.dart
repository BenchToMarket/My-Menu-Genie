// ignore_for_file: prefer_const_constructors


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:swipe_to/swipe_to.dart';

import '../admin/global_classes.dart';
import '../admin/savory_api.dart';


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

  bool _changesWereMade = false;


  /// menuMaster - list of list to update changes
  /// [recp_dates_id, recp_accept, servings, changed]

  @override
  void initState() { 
    super.initState();
   startFetching();
  }

  startFetching() async {
     // *** move to splash screen
    // my_screenWidth = MediaQuery.of(context).size.width;
    // my_screenheight = MediaQuery.of(context).size.height;

    _noInternetConnection = await fetchMenu();

    if (_noInternetConnection == true) {
      if (!mounted) return;
      setState(() { });
    }
  }



  fetchMenu() async {
    
    globals = Provider.of<GlobalVar>(context, listen: false);
    bool noConnection = false;
    int servSize = currUser.userServeSize;

    int minsSinceUpdate = DateTime.now().difference(globals.dateUpdatedMenu).inMinutes;
    // ********************* for testing
    // _minsSinceUpdate = 99999999999999;

    print('mins since updated MENU _--- $minsSinceUpdate');
    if (minsSinceUpdate > globals.MINS_UPDATE_MENU) {
      _isLoading = true;

      List<dynamic> menu = await httpSavory.getMenuMap();

      if (menu[0]["error"] == 'noconnection') {
        noConnection = true;
        return noConnection;
      } else {

        globals.popMenuAll(menu);

        if (globals.menuAll.isNotEmpty) {
          globals.updatedMenuAll(DateTime.now());
        }

        print('111111111111111111111111111111');
        for (var m in globals.menuAll) {
          // print(m['recp_json']['title']);
          // print(m);
          if (m['recp_accept'] == 0) {
            globals.menuSwipe.add(m);
          } else if (m['recp_accept'] == 1) {
            globals.menuAccept.add(m); 
          } else if (m['recp_accept'] == -1) {
            globals.menuReject.add(m);
          }
          if (m['serv_size'] == -1) {
            servSize = currUser.userServeSize; 
          } else {
            servSize = m['serv_size'];
          }
          // [recp_dates_id, recp_accept, servings, changed]
          globals.menuMaster.add([m['recp_dates_id'], m['recp_accept'], servSize, 0]);

          print(m['recp_dates_id'].runtimeType);
          print(m['recp_accept'].runtimeType);
          print(m['recp_dates_id']);
          print(m['recp_accept']);
        }


        // globals.menuSwipe = globals.menuAll;

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


  fetchMenuCosts() async {

    List recpAccept = [];
    /// 1. we have to fetch all accepted Menu and costs
    /// 2. adjust changes to accepted, rejected or back to swipe in menu_user_recp_join
    /// can retrieve by recp_dates_id (this is how user acceptance is recorded)
    /// on server, then we fetch recp_id
    /// then by item, option_id and price, deal_price (if any) & calc savings - all by single serving 
    /// menu_user_recp_join - should remember # of servings for accepted menu

    print('1111111111111111111111111111111');
    for (var a in globals.menuAccept) {
      print(a);
      recpAccept.add(a['recp_id']);
    }

    print(recpAccept);



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

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 3,
      initialIndex:1,
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
                      if (index == 0) {
                      } else if (index == 1) {
                      } else if (index == 2) {
                        fetchMenuCosts();
                      } 
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
    
                Center(child: MenuList(
                  listTab: 'reject',
                  activeList: globals.menuReject,
                  serveSize: currUser.userServeSize,
                  recipeSwiped: swipeMethod,
                  )
                ),


                Center(child: MenuList(
                  listTab: 'swipe',
                  activeList: globals.menuSwipe,
                  serveSize: currUser.userServeSize,
                  recipeSwiped: swipeMethod,
                  )
                ),

                Center(child: MenuList(
                  listTab: 'menu',
                  activeList: globals.menuAccept,
                  serveSize: currUser.userServeSize,
                  recipeSwiped: swipeMethod,
                  )
                ),

    
              ],
            ),
      ),
    );
    
  }

  swipeMethod(String fromTab, String direction, int idx) {
    _changesWereMade = true;

    if (fromTab == 'swipe') {
        if (direction == 'right') {
          setState(() {
            globals.menuAccept.add( globals.menuSwipe[idx]);
            updateMasterAccept(globals.menuSwipe[idx]['recp_dates_id'], 1);
            globals.menuSwipe.removeWhere((item) => item['recp_dates_id'] == globals.menuSwipe[idx]['recp_dates_id']);
          });
        } else {
          setState(() {
            globals.menuReject.add(globals.menuSwipe[idx]);
            updateMasterAccept(globals.menuSwipe[idx]['recp_dates_id'], -1);
            globals.menuSwipe.removeWhere((item) => item['recp_dates_id'] == globals.menuSwipe[idx]['recp_dates_id']);
          });
        }

    } else if (fromTab == 'reject') {
        // will only be right, left is rejected
        setState(() {
          globals.menuSwipe.add( globals.menuReject[idx]);
          globals.menuReject.removeWhere((item) => item['recp_dates_id'] == globals.menuReject[idx]['recp_dates_id']);
        });
    } else {
      // will only be left, right is rejected
      setState(() {
        globals.menuSwipe.add( globals.menuAccept[idx]);
        globals.menuAccept.removeWhere((item) => item['recp_dates_id'] == globals.menuAccept[idx]['recp_dates_id']);
      });
    }

    print('menu swipe --- ${globals.menuSwipe.length}');
    print('menu accept --- ${globals.menuAccept.length}');
    print('menu reject --- ${globals.menuReject.length}');

  }

  updateMasterAccept(int id, int acct) {
    // [recp_dates_id, recp_accept, servings, changed]
    print('33333333333333333333333333333');

    for (var m in globals.menuMaster) {
      print(m);
      // print(m['recp_dates_id'].runtimeType);
      // print(m['recp_accept'].runtimeType);
      if (m[0] == id) {
        m[1] = acct;
        m[3] = 1;
        break;
      }
    }
    
  print('2222222222222222222222222222222222');
  print(globals.menuMaster);
  }




}




class MenuList extends StatefulWidget {

  final String listTab;
  final List activeList;
  int serveSize;
  final Function(String, String, int) recipeSwiped;
  // ** function to change serving size

  MenuList({required this.listTab, required this.activeList, required this.serveSize, required this.recipeSwiped,
    Key? key}) : super(key: key);

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {

  late List al;
  final GlobalFunctions fx = GlobalFunctions();  

  @override
  void initState() {
    super.initState();
    al = widget.activeList;
  }
  @override
  Widget build(BuildContext context) {

    return ListView.separated(
      separatorBuilder: (_, __) => Divider(height: 0),
      itemCount: al.length,
      itemBuilder: (context, index) {
        // GestureDetector - 2 methods: https://stackoverflow.com/questions/55050463/how-to-detect-swipe-in-flutter
        return Container(              
              height: (widget.listTab == 'menu') ? 400 : 370,
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
              margin: EdgeInsets.only(top:30, right:30, left: 30),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),)
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
                              child: Text('${idx+1}. ' + al[index]['recp_json']['recipe']['instructions'][idx], ),
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
                          // Text("Cook: " + al[index]['recp_json']['time']['cook'].toString()),
                      ],),



                      // SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('(\$ 8.45)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),),
                            Text('\$ 20.10', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                        ],),
                      ),



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
                                  onTap: () {setState(() {if (widget.serveSize > 0) widget.serveSize -=1;});},
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:0.0, right: 0.0),
                                  child: Text('servings: ${widget.serveSize}'),
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
                                  onTap: () {setState(() {if (widget.serveSize < 12) widget.serveSize +=1;});},
                                ),

                            ],),
                          )
                        : Container(),

                      // (widget.listTab == 'menu')
                      //   ?
                      //     Padding(
                      //       padding: const EdgeInsets.only(top: 8.0),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Text('servings: ${widget.serveSize}    '),
                      //           Container(
                      //               height: 12.0,
                      //               width: 140.0,
                      //               decoration: BoxDecoration(
                      //                 borderRadius: BorderRadius.all(Radius.circular(2)),
                      //                 border: Border.all(
                      //                   width: 1,
                      //                   color: Colors.black,
                      //                 ),
                      //               ),
                      //             ),

                      //       ],),
                      //     )
                      //   : Container(),


                  ],
                ),
              ),
                    
            ),
          ),
        );
      }
    );
    
  }
}




// class MenuList extends StatefulWidget {

//   String listType;
//   List activeList;
//   Function(String, int) recipeSwiped;

//   MenuList({required this.listType, required this.activeList, required this.recipeSwiped,
//     Key? key}) : super(key: key);

//   @override
//   State<MenuList> createState() => _MenuListState();
// }

// class _MenuListState extends State<MenuList> {
//   @override
//   Widget build(BuildContext context) {

//     return ListView.separated(
//       separatorBuilder: (_, __) => Divider(height: 2, color: Colors.teal[300]),
//       itemCount: widget.activeList.length,
//       itemBuilder: (context, index) {
//         // GestureDetector - 2 methods: https://stackoverflow.com/questions/55050463/how-to-detect-swipe-in-flutter
//         return SwipeTo(
//           child: Container(
//             padding: EdgeInsets.all(12),
//             margin: EdgeInsets.all(20),
//             color: Colors.grey,
//             child: Text(widget.activeList[index]['recp_json']['title']),
        
//           ),
//           onRightSwipe: (details) { 
//             print('333333333333333333333333333');
//              widget.recipeSwiped('right', index);
//           }
          
//           // onHorizontalDragEnd: (DragEndDetails details) {
//             // // Note: Sensitivity is integer used when you don't want to mess up vertical drag
//             // // int sensitivity = 8;
//             // if (details.primaryVelocity!  > sensitivity) {
//             //     // Right Swipe
//             //     widget.recipeSwiped('right', index);
//             //     // print('2222222222222222222222222');
//             //     // print(widget.activeList.length);

//             //     // setState(() {
//             //     //   widget.activeList.removeWhere((item) => item['recp_dates_id'] == widget.activeList[index]['recp_dates_id']);
//             //     // });

//             //     // print(widget.activeList.length);
//             // } else if(details.primaryVelocity! < -sensitivity){
//             //     //Left Swipe
//             // }
//           // },
//         );
//       }
//     );
    
//   }
// }