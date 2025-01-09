
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global_classes.dart';
import 'savory_api.dart';


class UserDefaults extends StatefulWidget {
  const UserDefaults({Key? key}) : super(key: key);

  @override
  State<UserDefaults> createState() => _UserDefaultsState();
}

class _UserDefaultsState extends State<UserDefaults> {


  bool _isLoading = false;  

  late GlobalVar globals;
  final HttpService httpSavory = HttpService();
  final GlobalFunctions fx = GlobalFunctions();  

  Map<String, dynamic> userDefaults = {};
  List<dynamic> storePref = [];
  int prefServe = 4;

  // List currentReferrals = [];
  // int referalMenuCount = 0;


  @override
  void initState() { 

    globals = Provider.of<GlobalVar>(context, listen: false);
    super.initState();
    startFetching();
  }

  
  
  startFetching() async {

    _isLoading = true;

    userDefaults = await httpSavory.getUserDefaults();   // active or saved, but can be anything

    storePref = userDefaults['store'].toList();


    if (currUser.userServeSize.isNaN) {
      if (userDefaults['serving_size']['json_prefs']['serv_size'] != null) {
        prefServe = userDefaults['serving_size']['json_prefs']['serv_size'];
      }
      currUser.userServeSize = prefServe;
    }

    // currUser.userServeSize = 8;

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

  }



  @override
  Widget build(BuildContext context) {

    if (_isLoading) {return const Center(child: CircularProgressIndicator());}

    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: widget.fromSignup == true ? true: false,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        title: const Center(child: Padding(
          padding: EdgeInsets.only(right: 50.0),
          child: (Text('My Defaults', style: TextStyle(color: Colors.white))),
        )),
      ),

      body: Center(child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
          
              const Text('Store Preferences:', style: TextStyle(fontSize: 20.0, color: blueColor)),
              const SizedBox(height: 8.0,),

              Text('Currently only ' + storePref.length.toString() + ' stores available\nAdding more soon', style: const TextStyle(fontSize: 16.0, height: 1.3),),
        
              const SizedBox(height: 12.0),
              
              Container(
                  height: 200.0,
                   child: Card(
                          // margin: EdgeInsets.only(left: mrg, right: mrg),
                          
                          // TODO - when we can change or add stores we need to reset this:
                          // globals.updatedStorel(DateTime.now());
                          elevation: 10,
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0, top: 4.0),
                             child: ListView.builder(
                                  shrinkWrap: true,
                                  // scrollDirection: Axis.horizontal,
                                  itemCount: storePref.length,
                                  itemBuilder: (context, idx) {
                               
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 12.0),

                                      // ignore: todo
                                      // TODO - when give ability to change stores - need to make updatedStores = true
                                      child: Text(storePref[idx]['store_name'], style: const TextStyle(fontSize: 24.0, color: blueColor)),

                                      // child: Row(
                                      //   children: [
                                      //     Checkbox(
                                      //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      //       value: (storePref[idx]['count'] > 0 ? true : false), onChanged: null, activeColor: const Color(0xFFe9813f),),
                                      //     Text(currentReferrals[idx]['email']),
                                      //     // ignore: prefer_interpolation_to_compose_strings
                                      //     Text('    of   ' + currentReferrals[idx]['city']),
                                      //     // Text(currentReferrals[idx]['state']),
                                      //   ],
                                      // ),
                                    );
                                  }
                                ),
                           ),
                         ),
                  ),
              


              const SizedBox(height: 60.0),
              Text('Preferred Serving Size: ${currUser.userServeSize}', style: const TextStyle(fontSize: 20.0, color: blueColor)),
              const SizedBox(height: 8.0,),

              Text('You can adjust for every recipe', style: const TextStyle(fontSize: 16.0, height: 1.3),),
        
              const SizedBox(height: 12.0),

              
              Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary:  blueColor, // background
                    onPrimary: Colors.white, // foreground
                    padding: EdgeInsets.all(8.0),    
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),) 
                  ),

                  onPressed: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) =>
                          ServingSizeAdjust(
                            serveStart: currUser.userServeSize,
                            confirmServeChange: changingServingSize,
                            )));
                  },
        
                  child:  const Text('Change Serving Size', style: TextStyle(fontSize: 18.0)),
              ),
              ),

              // SizedBox(height:30.0)

    
        
            ],
          ),
        ),
      ))

    
    );
    
  }

  changingServingSize(int newServing) async {

    // print('******   updating serivng size to   --    ' + newServing.toString());
    // print('33333333333333333333333');
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // print(prefs.getInt("userServeSize")!,);

    bool didUpdate = await httpSavory.sendDefaultUpdates('serving', currUser.userServeSize, newServing, 'none', 'none');

    if (didUpdate == true) {
      setState(() {    
        // currUser.userServeSize = newServing;
        currUser.changeCurrentUser('serving', currUser.userID, newServing, context);
      });
    };

  }

  


}




class ServingSizeAdjust extends StatefulWidget {

// final String upgradeNeeded;

final int serveStart;
Function(int) confirmServeChange;

ServingSizeAdjust({required this.serveStart, required this.confirmServeChange, Key? key}) : super(key: key);

  @override
  State<ServingSizeAdjust> createState() => _ServingSizeAdjustState();
}

class _ServingSizeAdjustState extends State<ServingSizeAdjust> {

  int newServeSize = 4; 
  bool serveChanged = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    newServeSize  = widget.serveStart;
  }

  changeServingSize(int chg) {
    setState(() {
      newServeSize += chg;
      if (widget.serveStart == newServeSize) {
        serveChanged = false;
      } else {
        serveChanged = true;
      }
    });

  }


  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white.withOpacity(0.85), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text('Serving Size', style: TextStyle(color: Colors.white))),
        ),
        body: Center(
          child: Container(
            color: blueColor,
            height: my_screenHeight * .7,
            width: my_screenWidth * .8,
            
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                      
                  const Text('Your Preferred Serving Size', style: TextStyle(fontSize: 22.0),),


                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.only(left: 40, right: 20),
                            child: const Icon(
                              Icons.arrow_downward,
                              color: goldColor,
                              size: 36.0,
                            ),
                          ),
                          onTap: () {
                            if (newServeSize >1) {
                              changeServingSize(-1);
                            }
                          }
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left:0.0, right: 0.0),
                          child: Row(
                            children: [
                              Text('Serving Size:  '),
                              Text('$newServeSize', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.only(left: 20, right: 40),
                            child: const Icon(
                              Icons.arrow_upward,
                              color: goldColor,
                              size: 36.0,
                            ),
                          ),
                          onTap: () {
                            if (newServeSize < 10) {
                              changeServingSize(1);
                            }
                          }
                        ),

                    ],),
                  ),

                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Do NOT select how many people'),
                      Text('select servings, for example:'),
                      Text(' -- grown man may eat 2 servings'),
                      Text(' -- two kids may share 1 serving'),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text('You will be able to adjust'),
                      Text('serving size for every recipe'),
                    ],
                  ),

                  // const Text('Assistance: support@CardiacPeak.com'),




                  SizedBox(height: 20.0),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FlatButton(
                        // color: Colors.teal[400],
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: goldColor,
                          ),
                        ),
                      ),


                      Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 0.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: (serveChanged == false) ? Colors.white54 : Colors.white, // background
                                onPrimary: blueColor, // foreground
                                padding: EdgeInsets.all(8.0),    
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),) 
                              ),
                              onPressed: () {
                                (serveChanged == false)
                                  ? null
                                  : {
                                      widget.confirmServeChange(newServeSize),
                                      Navigator.of(context).pop()
                                    };
                              },
                              child:  const Text('Update', style: TextStyle(fontSize: 18.0)),
                          ),
                          ),
                    ],
                  ),
            
                ],
                
              ),
            )
              
          ),
        ),
    );
  }
}



