

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  // List<dynamic> cookingList = [];
  List<dynamic> cookingActive = [];
  List<dynamic> cookingComplete = [];
  Map<String, dynamic> recipe = {};
  int ratingThisRecipeID = 0;
  String ratingThisRecipeTitle = '';

  late GlobalVar globals;
  final HttpService httpSavory = HttpService();
  final GlobalFunctions fx = GlobalFunctions();  

  final double _topMargin = 30.0;
  final double _sliderMargin = 80.0;
  bool _sliderLeftMarkDone = false;

  @override
  void initState() { 

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

    globals.shopActiveTab = 0;

    int minsSinceLastCook = DateTime.now().difference(globals.dateUpdatedCook).inMinutes;
    // minsSinceLastCook = 1;  // 99999999999999;    // ********************* for testing   // 1 forces us to pull committed menu
    if (kDebugMode) { print('mins since Last COOK _--- $minsSinceLastCook'); }

    if (minsSinceLastCook > globals.MINS_UPDATE_COOK || globals.changesMadeMenuToCook == true) {

        globals.cookingList = await httpSavory.getCookPageList('active');   // active or saved, but can be anything
        globals.updatedCook(DateTime.now());
        globals.changesMadeMenuToCook = false;

    }

    for (var cl in globals.cookingList) {
      if (cl['recp_cook_status'] < 6) {
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

  recipeSelected(int id, int servingCooking) {

    print(globals.shopActiveTab);

    if (globals.shopActiveTab == 0) {
      for (var a in cookingActive) {
        if (a['recp_dates_id'] == id) {
          recipe = a;
        }
      }
    } else {
      for (var a in cookingComplete) {
        if (a['recp_dates_id'] == id) {
          recipe = a;
        }
      }
    }

    print('1111111111111111111111111111111');
    print(recipe);


    Navigator.push( context, MaterialPageRoute( builder: (context) => CookRecipe(
        recp_name: recipe['recp_json']['title'],
        recipe: recipe,
        servingsCooking: servingCooking,
        sentFrom: 'cook',
      )));
  }

  sliderMarkAsDoneAndRate(int recpDateID, String recpTitle) {

    setState(() {
      ratingThisRecipeID = recpDateID;
      ratingThisRecipeTitle = recpTitle;
      _sliderLeftMarkDone = true;
    });
  }

  cancelRating() {
    setState(() {
      _sliderLeftMarkDone = false;
    });
  }

  rateThisRecipe(int recpDateID, int rating) async {

  // Fetch updated cooking list after rating
  List<dynamic> cookingListTemp = await httpSavory.rateRecipeReturnNewCookList(recpDateID, rating, 'all');

  // If no error occurred (valid list returned)
  if (cookingListTemp.length > 0) {

    setState(() {
      // Clear and update the cooking lists
      cookingActive.clear();
      cookingComplete.clear();
      globals.cookingList = cookingListTemp;

      // Separate active and complete items
      for (var cl in globals.cookingList) {
        if (cl['recp_cook_status'] < 6) {
          cookingActive.add(cl);
        } else {
          cookingComplete.add(cl);
        }
      }
      
      _sliderLeftMarkDone = false; // Reset the slider or related UI elements
    });
  }
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
  
                  tabs: const [
                    Tab(child: Text("Active")),
                    // Tab(child: Text("Complete")),
                    Tab(child: Text("Done")),
                  ],
                ),
              ),

            ),
            body: Stack(
              children: [
                  TabBarView(
                    children: [

                      (cookingActive.isNotEmpty)
                        ?
                          Center(child: CookList(
                            listTab: 'cook_active',
                            activeList: cookingActive,
                            recipeSelect: recipeSelected,
                            markAsDone: sliderMarkAsDoneAndRate,
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
                            // Text('Menu, Shop, Save then Cook...', style: TextStyle(fontSize: 22.0, height: 1.5)),
                            const SizedBox(height: 16.0),
                            // Text('from Menu nav bar', style: TextStyle(fontSize: 22.0, height: 1.3)),
                            // Text('swipe recipes right to menu tab', style: TextStyle(fontSize: 22.0, height: 1.3)),
                            const Text('go to Menu', style: TextStyle(fontSize: 18.0, height: 1.3)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('swipe recipes right ', style: TextStyle(fontSize: 22.0, height: 1.3,fontWeight: FontWeight.w500, color: blueColor)),
                                Text('to menu tab', style: TextStyle(fontSize: 22.0, height: 1.3)),
                              ],
                            ),
                            //Text('(from Menu nav bar)', style: TextStyle(fontSize: 18.0, height: 1.3)),
                          ],
                        ),
 
                                           
                      (cookingComplete.isNotEmpty)
                        ?
                          Center(child: CookList(
                            listTab: 'cook_done',
                            activeList: cookingComplete,
                            recipeSelect: recipeSelected,
                            markAsDone: sliderMarkAsDoneAndRate,
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
                            const Text('rate recipes after you cook', style: TextStyle(fontSize: 22.0, height: 1.5)),
                          ],
                        ),
 
 
                
                   
                   
                    
                    ],
                  ),


                  AnimatedPositioned(
                    top: _topMargin,
                    left: _sliderLeftMarkDone ? (_sliderMargin / 2) : (my_screenWidth + 80.0),
                    duration: const Duration(milliseconds: 500),
                    child: MarkAndRate( 
                      sliderMargin: _sliderMargin,
                      topMargin: _topMargin,
                      recpDateID: ratingThisRecipeID,
                      recpTitle: ratingThisRecipeTitle,
                      ratingSelected: rateThisRecipe,
                      cancelRating: cancelRating,
                    ),
                  ),

 

              ],

            ),
      ),
    );
    
  }
}


class MarkAndRate extends StatefulWidget {

  final double sliderMargin;
  final double topMargin;
  final int recpDateID;
  final String recpTitle;
  final Function(int, int) ratingSelected;
  final Function() cancelRating;
  const MarkAndRate({required this.sliderMargin, required this.topMargin, required this.recpDateID, required this.recpTitle, 
    required this.ratingSelected, required this.cancelRating,
    Key? key}) : super(key: key);

  @override
  State<MarkAndRate> createState() => _MarkAndRateState();
}

class _MarkAndRateState extends State<MarkAndRate> {

  double iconSize = 50.0;
  bool _ratingActive = true;

  @override
  Widget build(BuildContext context) {

        return Container(
              height: my_screenDisplay- (widget.topMargin * 2),
              width: my_screenWidth - widget.sliderMargin,  
              // padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,    
                borderRadius: const BorderRadius.all(Radius.circular(10)) ,
                border: Border.all(
                  width: 4,
                  // color: blueColor,
                  color: goldColor,
                ),
              ),                 
              // color: Colors.blue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text(widget.recpDateID.toString()),

                Column(
                  children: [
                    const SizedBox(height: 30.0),
                    const Text('What do you think about', style: TextStyle(fontSize: 18.0, color: Colors.black)),
                    // SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Text(widget.recpTitle, style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500, color: blueColor), textAlign: TextAlign.center,),
                    ),
                  ],
                ),
                

                Container(
                  // width: my_screenWidth - (widget.sliderMargin * 2), 
                  margin: const EdgeInsets.all(24.0),
                  padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,    
                    borderRadius: const BorderRadius.all(Radius.circular(10)) ,
                    border: Border.all(
                      width: 2,
                      // color: blueColor,
                      color: Colors.black45,
                    ),
                  ),        
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        child: FaIcon(
                          FontAwesomeIcons.thumbsDown,
                          color: Colors.black45,
                          size: iconSize,
                        ),
                        onTap: () {
                          if (_ratingActive == true) {
                            widget.ratingSelected(widget.recpDateID, 1);
                            _ratingActive = false;
                          }
                        },
                      ),
                      InkWell(
                        child: FaIcon(
                          FontAwesomeIcons.thumbsUp,
                          color: blueColor,
                          size: iconSize,
                        ),
                        onTap: () {
                          if (_ratingActive == true) {
                            widget.ratingSelected(widget.recpDateID, 4);
                            _ratingActive = false;
                          }
                        },
                      ),
                      InkWell(
                        child: FaIcon(
                          FontAwesomeIcons.solidHeart,
                          color: Colors.red,
                          size: iconSize,
                        ),
                        onTap: () {
                          if (_ratingActive == true) {
                            widget.ratingSelected(widget.recpDateID, 5);
                            _ratingActive = false;
                          }
                          
                        },
                      ),
                    ],
                  ),
                ),

                // SizedBox(height: 30.0),
                const Text('Rate after you taste', style: TextStyle(fontSize: 18.0, color: Colors.black)),



                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      TextButton(
                        onPressed: () {
                          print(_ratingActive);
                          if (_ratingActive == true) {
                            widget.ratingSelected(widget.recpDateID, 9999);   // django has a hard time interpreting a negative in an API
                            _ratingActive = false;
                          }
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero, // Set this
                          padding: EdgeInsets.zero, // and this
                        ),
                        child: const Text(
                            // "Don't\nCook",
                            "Remove\nfrom\nMenu",
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Color(0xFFe9813f), //Colors.red, //  Color(0xFFe9813f),
                            ), textAlign: TextAlign.center,
                          ),
                      ),

                      TextButton(
                        onPressed: () {
                          widget.cancelRating();
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero, // Set this
                          padding: EdgeInsets.zero, // and this
                        ),
                        child: const Text(
                            'Cancel\nRating',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black45, // Color(0xFFe9813f), // goldColor,
                            ),textAlign: TextAlign.center,
                          ),
                      ),
                    ],
                  ),
                ),

                // InkWell(child: Padding(
                //   padding: const EdgeInsets.all(20.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: const [
                //       Text('Cancel', style: TextStyle(fontSize: 20.0,color: Color(0xFFe9813f)),)
                //     ],
                //   ),
                // ),
                //   onTap: () {
                //     widget.cancelRating();
                //     },
                // )
                

              ]
            )
        );
    
  }
}