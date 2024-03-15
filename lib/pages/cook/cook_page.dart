

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'dart:async';

import '../admin/global_classes.dart';
import '../admin/savory_api.dart';
import '../menu/menu_create.dart';
import 'cook_recipe.dart';



class CookPage extends StatefulWidget {
  const CookPage({Key? key}) : super(key: key);

  @override
  State<CookPage> createState() => _CookPageState();
}

class _CookPageState extends State<CookPage> {

  bool _isLoading = false;  
  // bool _isDateSelected = true;

  List<dynamic> cookingList = [];
  List<dynamic> cookingActive = [];
  List<dynamic> cookingComplete = [];
  Map<String, dynamic> recipe = {};

  late GlobalVar globals;
  final HttpService httpSavory = HttpService();
  final GlobalFunctions fx = GlobalFunctions();  

  final double _sliderMargin = 160.0;
  bool _sliderLeft = false;

  @override
  void initState() { 

    print('11111111111111111111111111111');
    print(currUser.userID);

    globals = Provider.of<GlobalVar>(context, listen: false);
    super.initState();
    startFetching();
  }

  @override
  void dispose() {
    // checkForChanges(globals.activeMenu['commit_status']);
    // if (timer != null) {
    //   timer.cancel();
    // }
    super.dispose();
  } 

  
  startFetching() async {

    _isLoading = true;


    // globals.menuCommit = await httpSavory.getMenuCommit();

    // List<dynamic> menu = await httpSavory.getMenuMap(globals.shopDate);
  
    cookingList = await httpSavory.getCookPageList('active');   // active or saved, but can be anything

    for (var cl in cookingList) {
      if (cl['recp_cook_status'] < 4) {
        cookingActive.add(cl);
      } else {
        cookingComplete.add(cl);
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

  }

  // changedServingCount(int id) {
  //   print('--   in change serving count - doing nothing ------------');
  //   // right now do nothing - do we want to save or just change recipe ?????
  // }

  recipeSelected(int id) {

    for (var a in cookingActive) {
      // print(a);
      if (a['recp_dates_id'] == id) {
        recipe = a;
      }
    }

    Navigator.push( context, MaterialPageRoute( builder: (context) => CookRecipe(
        recp_name: recipe['recp_json']['title'],
        recipe: recipe,
      )));
  }



  @override
  Widget build(BuildContext context) {

    if (_isLoading) {return const Center(child: CircularProgressIndicator());}

    return DefaultTabController(
      length: 2,
      // initialIndex:globals.shopActiveTab, 
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
                    const Tab(child: Text("Active")),
                    Tab(child: 
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          // const Icon(Icons.shopping_cart, color:  blueColor,),   
                          Text("Complete"),
                          // InkWell(
                          //   child: const Icon(Icons.favorite),
                          //   onTap: () {
                          //     // getCommitNumbers();
                          //     setState(() {
                          //       _sliderLeft = true;
                          //     });
                          //   },
                          // ),                 
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
                
                      // const Center(child: const Text('Active')),



                         
                      (cookingActive.isNotEmpty)
                        ?
                          Center(child: CookList(
                            listTab: 'cook_active',
                            activeList: cookingActive,
                            recipeSelect: recipeSelected,
                            )
                          )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                  // Icon(Icons.arrow_downward, size: 28, color: blueColor,),                           
                                  Text('Create Menu First ', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: blueColor)),
                                ],
                            ),
                            Text('Menu, Shop, Save then Cook...', style: TextStyle(fontSize: 22.0, height: 1.5)),
                          ],
                        ),
 
                                           
                      (cookingComplete.length > 0)
                        ?
                          Center(child: CookList(
                            listTab: 'cook_complete',
                            activeList: cookingComplete,
                            recipeSelect: recipeSelected,
                            )
                          )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                  // Icon(Icons.arrow_downward, size: 28, color: blueColor,),                           
                                  Text('Save Favorites Here ', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500, color: blueColor)),
                                ],
                            ),
                            Text('rate recipes after you cook', style: TextStyle(fontSize: 22.0, height: 1.5)),
                          ],
                        ),
 
 
                
                   
                   
                    
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
                          color: blueColor,
                        ),
                      ),                 
                      // color: Colors.blue,
                    
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [

                                Text('Confirm Purchase', style: TextStyle(fontSize: 18.0, color: Color(0xFFe9813f)),),


               
                                // Column(
                                //   children: [
                                //     const Text('Items'),
                                //     const SizedBox(height: 2.0),
                                //     Text(commitCount.toString(), style: const TextStyle(fontSize: 18.0, color: blueColor),),
                                //   ],
                                // ),
                                // Column(
                                //   children: [
                                //     const Text('Savings'),
                                //     const SizedBox(height: 2.0),
                                //     Text('\$ ${commitSavings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18.0, color: blueColor),),
                                //   ],
                                // ),

                                // (globals.activeMenu['commit_status']) < 4
                                //   ? 
                                //     Container(
                                //       width: double.infinity,
                                //       child: Padding(
                                //         padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                                //         child: ElevatedButton(
                                //           style: ElevatedButton.styleFrom(
                                //             primary: blueColor, // background
                                //             onPrimary: Colors.white, // foreground
                                //             padding: const EdgeInsets.all(8.0),    
                                //             shape: RoundedRectangleBorder(
                                //                 borderRadius: BorderRadius.circular(6),) 
                                //           ),
                                //           onPressed: () {
                                            
                                //             DateTime dateToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                                //             globals.activeMenu['commit_status_new'] = 4;
                                //             globals.activeMenu['date_shopped'] = fx.FormatDate(dateToday.toString());
                                //             globals.activeMenu['shopped_count'] = commitCount;
                                //             globals.activeMenu['shopped_total'] = commitTotal;
                                //             globals.activeMenu['shopped_savings'] = commitSavings;
                                            
                                //             checkForChanges(4);  // this also saves 

                                //             Future.delayed(const Duration(milliseconds: 300), () {
                                //               setState(() { _sliderLeft = false; });
                                //             });
                                //           },
                                //           child: const Text('Confirm')),
                                //       ),
                                //     )

                                //   : const SizedBox(height: 30.0,)

                                  
                          
                          
                              ],
                            ),
                          ),

                          InkWell(child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, right: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                // Text((globals.activeMenu['commit_status'] < 4) ? 'Cancel' : 'Got it', style: const TextStyle(fontSize: 16.0,color: Color(0xFFe9813f)),),
                                Text('Got it', style: TextStyle(fontSize: 16.0,color: Color(0xFFe9813f)),),
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
}