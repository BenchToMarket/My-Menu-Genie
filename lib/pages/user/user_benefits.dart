
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;


// import 'user_goal.dart';
// import 'user_login.dart';
// import '../../utils/global_classes.dart';
// import '../../pages/connect/connect_api.dart';
// import '../admin/admin_more_help.dart';

import 'user_signup.dart';
import 'user_login.dart';
import '../admin/savory_api.dart';
import '../admin/global_classes.dart';


class UserBenefits extends StatefulWidget {
  @override
  _UserBenefitsState createState() => _UserBenefitsState();
}

class _UserBenefitsState extends State<UserBenefits> {

  bool _isLoading = false;
  final HttpService httpSavory = HttpService();

  int _index = 0;   // to size the box in view to be larger
  // List<String> _imageUrl = [API + '/media/promo_pic/cardiac_pic.jpg',API + '/media/promo_pic/cardiac_pic.jpg',API + '/media/promo_pic/cardiac_pic.jpg',API + '/media/promo_pic/cardiac_pic.jpg'];
  List<String> _imageUrl =  ['save_on_groceries.jpg','amazing_recipes.jpg','cook_like_pro.jpg'];
  List<String> _imageCopy = ["Save \$100's on Groceries", 'Amazing Recipes', 'Cook like a Pro'];
  List<String> _imageSubtext = ['AI Chef-inspired Recipes\nfrom your local grocery deals', 'Discover Dishes\nyou never thought of making', 'Impress friends, family,\nand even first dates...'];
  bool _hasImages = false;

  // List<dynamic> goalChoices = [{"id": 4, "group_name": "Weight Loss"}, {"id": 14, "group_name": "My First 5k"}, {"id": 10, "group_name": "Racing 5k to Marathon"}, {"id": 9, "group_name": "Get off the Couch"}, {"id": 16, "group_name": "Peak Fitness"}, {"id": 5, "group_name": "Overall Fitness & Health"}, {"id": 17, "group_name": "Fitness Networking"}];

  // other options: Athletic Performace, Establish a Consistent Regimin

  @override
  void initState() {
    super.initState(); 
    fetchPromoPics();
  }

  fetchPromoPics() async {

    _isLoading = true;

    bool hasConnect = await httpSavory.checkConnection();

    if (hasConnect == true) {
      await getPromoPics();
      // goalChoices = await getGoalChoices();
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

  }


  // Future<bool> checkConnection() async {
  //   // final url = 'http://<your_django_server_url>/api/'; // Replace with your Django API endpoint

  //   try {
  //     final response = await http.get(Uri.parse(API)).timeout(
  //       Duration(seconds: 3), // Set a 2-second timeout
  //       onTimeout: () {
  //         // Handle timeout
  //         if (kDebugMode) { print('Connection timed out'); }
  //         return http.Response('Error: Timeout', 408);
  //         // return false; 
  //       },     
  //     );

  //     if (response.statusCode == 200) {
  //       if (kDebugMode) { print('Connected to Django API!'); }
  //       return true;
  //     } else {
  //       if (kDebugMode) { print('Failed to connect: ${response.statusCode}'); }
  //       return false;
  //     }
  //   } catch (e) {
  //     if (kDebugMode) { print('Error: $e'); }
  //     return false;
  //   }
  // }


  Future<bool> getPromoPics() async {

    try {
      print('********** fetching promo pics ******* Program ID--- ');
      final response = await http.get(Uri.parse('$API/menu-promopics/'));

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        // print(result);
        _hasImages = true; 
        _imageUrl.clear();   // this way we have default images
        _imageCopy.clear();
        _imageSubtext.clear();

        for (var r in result) {
          _imageUrl.add(API + r['promo_pic']);
          _imageCopy.add(r['promo_copy']);
          _imageSubtext.add(r['promo_subtext']);
        }

        return true;

        // print(_imageUrl);
        // print(_imageCopy);
        // print(_imageSubtext);

      } else {
        throw {'result': 'falied'};
      }

    } catch(err) {
      print('WTF');
      print(err);
      return false;
    }
  }

  
  // Future<List<dynamic>> getGoalChoices() async {

  //   try {
  //     print('********** fetching goal choices --- ');
  //     final response = await http.get(Uri.parse(API + '/goal-signup/'));

  //     if (response.statusCode == 200) {
  //       goalChoices.clear();   // clear defaults if success
  //       List<dynamic> result = jsonDecode(response.body);
  //       return result;
  //     } else {
  //       throw "Can't get goals at startup.";
  //     }

  //   } catch(err) {
  //     print('WTF');
  //     print(err);
  //     return goalChoices;
  //   }
  // }
  
  

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
          onWillPop: () async => false,
            child: Scaffold(

              body: Center(
                child: Container(
                  color: Colors.black87,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[

                      
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Container(
                          // height: 100,
                          child: Center(
                            child: Text('MenuGenie.ai',
                              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, 
                              color: blueColor)),
                          ),
                        ),
                      ), //, fontFamily: 'Hind')),

                      // SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Text('swipe for benefits -->',
                          style: TextStyle(fontSize: 16, color: goldColor)),
                      ),


                      // https://stackoverflow.com/questions/51607440/horizontally-scrollable-cards-with-snap-effect-in-flutter
                      Container(
                        child: Column(
                          children: [
                            SizedBox(
                              height: my_screenHeight * .65, // .55 //300,
                              child: PageView.builder(
                                itemCount: _imageUrl.length,
                                controller: PageController(viewportFraction: 0.80), // 0.65
                                onPageChanged: (int index) => setState(() => _index = index),
                                itemBuilder: (_, i) {
                                  return Transform.scale(
                                    scale: i == _index ? 1 : 0.8,
                                    child: Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

                                      child: Center(

                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          
                                          child:  (_isLoading)
                                                ? Container()
                                                : Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: [

                                                    (_hasImages == true)
                                                    ? 
                                                      Image.network(
                                                            _imageUrl[i],
                                                            fit: BoxFit.contain,
                                                          )
                                                    : 
                                                      Image.asset(
                                                        'images/' + _imageUrl[i],
                                                        fit: BoxFit.fitWidth,
                                                      ),

     
                                                      Padding(
                                                        padding: const EdgeInsets.all(2.0),
                                                        child: Column(
                                                          children: [
                                                            Text(_imageCopy[i],
                                                              style: TextStyle(fontSize: 22.0, color: Colors.red,
                                                              fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                                                              textAlign: TextAlign.center),

                                                            // SizedBox(height: 12.0),
                                                            SizedBox(height: 2.0),
                                                            (_imageSubtext[i] == null)
                                                            ? Container()
                                                            : Text(_imageSubtext[i],
                                                                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: blueColor,height: 1.3),
                                                                    textAlign: TextAlign.center),

                                                          ],
                                                        ),
                                                      ),

                                                     
                                                      // SizedBox(height: 6.0),

                                                  ],),

                                    

                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // SizedBox(height: 6),
                            // Text('swipe for benefits -->',
                            //   style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),


                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(left:50.0, right:50.0, top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          
                          children: <Widget>[
                            Container(
                              width: 100.0,
                              child: RaisedButton(
                              child: Text("Log In", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: goldColor),),
                                color: blueColor,   
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.all(10.0),
                                onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => UserLogin(fromSignup: true,))), 
                              ),
                            ), 
                            SizedBox(width: 20.0),
                            Expanded(
                              child: RaisedButton(
                                child: Text("Sign Up",style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: goldColor),),
                                color: blueColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.all(10.0),

                                onPressed: () async {
                                  final HttpService httpService = HttpService();
                                  // curr_user = CurrentUser(user_id:0, user_id_string: '0');
                                  currUser = CurrentUser(userID: 0, userIDString: '0',userServeSize: 4, userPlan: 2, seenInfo: '2222222222');
                                  
                                  // TODO - can remove 1st AppError - if we never get Platform errors
                                  // await httpService.sendAppError(context,' -- NEW USER -- Sign Up button hit --- Start ----');
                                  try {
                                      if (Platform.version.isNotEmpty)
                                      await httpService.sendAppError(' -- MENU GENIE  -- NEW USER -- Sign Up button hit --- Platform: ' + Platform.version.toString() + ' -- OS: ' + Platform.operatingSystemVersion.toString());
                                    } catch(err) {
                                      await httpService.sendAppError(' -- MENU GENIE  -- NEW USER -- Sign Up button hit --- Error: ' + err.toString());
                                    }
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => UserGoal(goalChoices: goalChoices,)));  
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserSignup()));  

                                }  
                            ),)
                        ],)    
                      ),



                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: Container(
                          
                      //     child: Column(
                      //       // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //       // mainAxisSize: MainAxisSize.min,
                      //       children: <Widget>[
                      //         Container(
                      //           width: double.infinity,
                      //           padding: EdgeInsets.only(left:50, right:50),
                      //           child: RaisedButton(
                      //             color: Colors.teal[700],
                      //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //             child: Text('Sign Up',
                      //                 style: TextStyle(fontSize: 18)),
                      //             onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => UserGoal())),             
                      //           ),
                      //         ),
                      //         // SizedBox(height: 6),
                      //         Row(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Text('Already have an account?',
                      //                 style: TextStyle(fontSize: 12)),
                      //             FlatButton(
                      //               onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => UserLogin())), 
                      //               // color: Colors.amberAccent,
                      //               child: Text('Log In',
                      //                 style: TextStyle(fontSize: 16),), 
                                      
                      //               textColor: Colors.blueAccent[300],  // not working ?
                      //             ),
                      //           ],
                      //         )
                      //       ],
                      //     )
                      //   ),
                      // ),
                    
                    
                      ],
                    ),
                  ),
                )
              ),
          ),
        );
    

  }
}