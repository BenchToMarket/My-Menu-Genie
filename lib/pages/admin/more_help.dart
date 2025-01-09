import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

import 'global_classes.dart';
import 'webview.dart';
import 'savory_api.dart';
import 'admin_textpage.dart';

import 'help_defaults.dart';
import 'help_sub_plan.dart';



class MoreHelp extends StatefulWidget {

  const MoreHelp({Key? key}) : super(key: key);

  @override
  _MoreHelpState createState() => _MoreHelpState();
}

class _MoreHelpState extends State<MoreHelp> {
  final GlobalFunctions fx = GlobalFunctions();
  Icon contestReset = const Icon(Icons.check_box_outline_blank);
  final HttpService httpService = HttpService();

  @override
  void initState() {
    super.initState();
    // httpService.engageRecord('4', '0');     // NavBar  -  More
  }


  @override
  Widget build(BuildContext context) {

    String sh;
    return Scaffold(
        appBar: AppBar(
          // leading: null,
          automaticallyImplyLeading: false,
          title: const Center(
            child: Text('Help Center', style: const TextStyle(color: Colors.white),),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 0.0, left: 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                // ListTile(
                //   // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                //   title: const Text('Tech Support'),
                //   subtitle: const Text('version & upgrade here'),
                //   trailing: IconButton(
                //     icon: const Icon(Icons.double_arrow),
                //     onPressed: () => showDialog(
                //       context: context,
                //       builder: (BuildContext context) => InformationDialog(     // InformationDialog_Link(
                //           context: context,
                //           title: 'Support & Upgrade',
                //           text1: "For Tech Support email us at support@MenuGenie.ai",
                //           text2: 'To Upgrade go to MenuGenie.AI or directly on Google Play or Apple Store',
                //           // can check for OS with  print(Platform.operatingSystem); (need - import 'dart:io' show Platform; )
                //           text3: 'current version - 1.0.$cpAppVersion',
                //           // textLink: 'Upgrade on Google Play',
                //           // // link: 'https://play.google.com/store/apps/'
                //           // // link: 'https://play.google.com/store/apps/details?id=com.cardiac_peak_app'
                //           // link: 'https://play.google.com/store/apps/details?id=com.cardiac_peak_app'
                //         ),
                //     ),
                //   ),
                //   // dense: true,
                // ),
                // const Divider(height: 4, color: blueColor),

                
                ListTile(
                  // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                  title: const Text('Tech Support'),
                  subtitle: const Text('version & upgrade here'),
                  trailing: IconButton(
                    icon: const Icon(Icons.double_arrow),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => InformationDialog_Link(
                          context: context,
                          title: 'Support',
                          text1:
                              'If you need assistance or have an issue with the App, please email with full details to: support@MenuGenie.AI',
                          // can check for OS with  print(Platform.operatingSystem); (need - import 'dart:io' show Platform; )
                          text2: 'version - 1.0.' + cpAppVersion.toString(),
                          textLink: 'Upgrade on Google Play',
                          link: 'https://play.google.com/store/apps/details?id=ai.menu_genie'),  // giving unknown url scheme error
                          // link: 'https://play.google.com/store/apps/'),
                    ),
                  ),
                  // dense: true,
                ),
                Divider(height: 4, color: Colors.teal[300]),



                ListTile(
                  // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                  title: const Text('My Plan & Costs'),
                  subtitle: const Text('how to get a free for life'),
                  trailing: IconButton(
                    icon: const Icon(Icons.double_arrow),
      
                    onPressed: () {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SubscriptionPlan(

                                    )));
                                }
                  ),
                ),
                
                const Divider(height: 4, color:blueColor),




                ListTile(
                  // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                  title: const Text('My Defaults'),
                  subtitle: const Text('serving size & store'),
                  trailing: IconButton(
                    icon: const Icon(Icons.double_arrow),
      
                    onPressed: () {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const UserDefaults(
                                    )));
                                }
                  ),
                ),
                
                const Divider(height: 4, color:blueColor),


                // ListTile(
                //   // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                //   title: Text('Connect to Garmin or fitbit', style: TextStyle(color: Colors. yellow[700])),
                //   subtitle: Text('private & secure connection'),
                //   trailing: IconButton(
                //     icon: Icon(Icons.double_arrow,color: Colors. yellow[700]),
                //     onPressed: () => Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => GarminConnect())),
                //   ),
                //   // dense: true,
                // ),
                // Divider(height: 4, color: Colors.teal[300]),

                
                // ListTile(
                //   // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                //   title: Text('Contests - Win Cash!'),
                //   subtitle: Text('active & upcoming'),
                //   trailing: IconButton(
                //     icon: Icon(Icons.double_arrow),
                //     onPressed: () {
                //       Navigator.push( context, MaterialPageRoute( builder: (context) => ContestPage('help')));
                //     },
                //   ),
                //   // dense: true,
                // ),
                // Divider(height: 4, color: Colors.teal[300]),






  
                
                
                // ListTile(
                //   // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                //   title: Text('Profile'),
                //   subtitle: Text('your referral code is here'),
                //   trailing: IconButton(
                //     icon: Icon(Icons.double_arrow),
                //     onPressed: () {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => UserProfilePage(
                //                   userID: curr_user.user_id,
                //                   userName: curr_user.user_name)));
                //     },
                //   ),
                //   // dense: true,
                // ),
                // Divider(height: 4, color: Colors.teal[300]),




                ListTile(
                  // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                  title: const Text('Privacy Policy'),
                  // subtitle: Text('contact us'),
                  trailing: IconButton(
                    icon: const Icon(Icons.double_arrow),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => InformationDialog_Link(
                          context: context,
                          title: 'Privacy Policy',
                          text1:
                              'Menu Genie AI strongly believes in your privacy. Please read our policy here:',
                          text2: '',
                          textLink: 'menugenie.ai/privacy',
                          link: 'https://menugenie.ai/privacy.html'),
                    ),
                  ),
                  // dense: true,
                ),
                const Divider(height: 4, color: blueColor),


                ListTile(
                  // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                  title: const Text('Terms of Use'),
                  // subtitle: Text('contact us'),
                  trailing: IconButton(
                    icon: const Icon(Icons.double_arrow),

                    onPressed: () {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Admin_Text(
                                        title: "Terms of Use",
                                        purpose: 'service',
                                    )));
                                }
   
                  ),
                  // dense: true,
                ),
                const Divider(height: 4, color:blueColor),


                


                ListTile(
                  // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                  title: const Text('Delete Account'),
                  // subtitle: Text('contact us'),
                  trailing: IconButton(
                    icon: const Icon(Icons.double_arrow),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => InformationDialog(
                          context: context,
                          title: 'How to Delete Your Account',
                          text1:  "Send an email with subject 'Delete Account' to support@MenuGenie.AI",
                          text2:  "Include your username or email used with Menu Genie AI",
                          text3:  "(optional) Please let us know anything else you want us to know. Deletion is NOT reversible.",
                    ),
                  ),)
                ),
                
                const Divider(height: 4, color:blueColor),




                ListTile(
                  // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                  title: const Text('Suggestions & Feedback'),
                  subtitle: const Text('contribute to our Beta'),
                  trailing: IconButton(
                    icon: const Icon(Icons.double_arrow),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => InformationDialog(
                          context: context,
                          title: 'Have Suggestions?',
                          text1:  "We're in Beta. Please be pateint.",
                          text2:  "We wecome any and all Suggestions or tell us any issues you are experiencing. Contributions that we use, will be rewarded by free stuff or rewards, possibly even a free lifetime premium membership.",
                          text3:  "email us at contribute@MenuGenie.AI",
                          // text3:  "email us a contribute@MenuGenie.AI",
                    ),
                  ),)
                ),
                
                const Divider(height: 4, color:blueColor),




                const SizedBox(height: 10.0),

                // // isAdmin is determined at login for user_id = 1
                // // (Provider.of<GlobalVar>(context, listen: false).isAdmin == true 
                // //   && (curr_user.user_id <= 62 || curr_user.user_id == 106 || curr_user.user_id == 533))

                //   (Provider.of<GlobalVar>(context, listen: false).isAdmin == true)
                //     ? Container(
                //         width: double.infinity,
                //         padding: EdgeInsets.only(
                //             right: 60.0, left: 60.0, bottom: 10.0),
                //         child: RaisedButton(
                //           child: Text('Go to Dashbooard',
                //               style: TextStyle(fontSize: 20)),
                //           shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(10)),
                //           onPressed: () => Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) => DashBoard())),
                //         ),
                //       )
                //     : Container(),


                const SizedBox(height: 30.0),

    
              ],
            ),
          ),
        ));
  }
}


Widget InformationDialog(
    {required BuildContext context,
    required String title,
    required String text1,
    String? text2,
    String? text3}) {
  return AlertDialog(
    // backgroundColor: Colors.black26,
    title: Center(
      child: Text(title,
          style: const TextStyle(color: goldColor, fontSize: 22.0)),
    ),
    content: SingleChildScrollView(
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 16.0, color: blueColor),
        child: Padding(
          padding: const EdgeInsets.only(top:16.0, bottom: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 18),
              Text(text1),
              (text2 != null) ? const SizedBox(height: 30) : Container(),
              (text2 != null) ? Text(text2) : Container(),
              (text3 != null) ? const SizedBox(height: 30) : Container(),
              (text3 != null) ? Text(text3) : Container()
            ],
          ),
        ),
      ),
    ),
    actions: <Widget>[
      FlatButton(
        // color: Colors.teal[400],
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text(
          'Okay, got it!',
          style: TextStyle(
            fontSize: 16,
            color: goldColor,
          ),
        ),
      ),
    ],
  );
}



Widget InformationDialog_Link(
    {required BuildContext context,
    required String title,
    required String text1,
    required String text2,
    required String textLink,
    required String link}) {
  return AlertDialog(
    title: Center(
      child: Text(title,
          style: const TextStyle(color:goldColor, fontSize: 26)),
    ),
    content: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 18),
            Text(text1),
            (text2 != '') ? const SizedBox(height: 30) : Container(),
            (text2 != '') ? Text(text2) : Container(),
            (textLink != '') ? const SizedBox(height: 30) : Container(),
            (textLink != '')
                ? InkWell(
                    child: Text(textLink,
                        style: const TextStyle(color: blueColor, height: 1.5)),
                    // onTap: () => launchUrl(Uri.parse(link)))
                    
                    onTap: () { 
                      try {
                        launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
                      } catch (err) {
                        if (kDebugMode) { print('WTF - $err'); }
                      }
                    }   
                  )


                        // if (!await launchUrl(url), mode: LaunchMode.externalApplication)) {
                        // if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
                        //       throw Exception('Could not launch $link');
                        //   }
                          
                    //    } 
                    // )
                  
                    // onTap: () {    
                    //             Navigator.push(context, MaterialPageRoute(builder: (context) => MyWebView(
                    //                   title: textLink,  //  'your webpage', 
                    //                   selectedUrl:link, 
                    //                   // isGarmin: false,
                    //                 ))
                    //             );        
                    //           })
                : Container(),
          ],
        ),
      ),
    ),
    actions: <Widget>[
      FlatButton(
        // color: Colors.teal[400],
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text(
          'Okay, got it!',
          style: TextStyle(
            fontSize: 16,
            color:goldColor,
          ),
        ),
      ),
    ],
  );
}


// Widget confirmDialog(
//     {required BuildContext context,
//     required String title,
//     required String text1,
//     String text2,
//     VoidCallback confirmCallback,
//     bool isContest = false}) {
//   return new AlertDialog(
//     title: Center(
//       child: Text(title,
//           style: TextStyle(color: Colors.tealAccent[300], fontSize: 26)),
//     ),
//     content: SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             SizedBox(height: 18),
//             Text(text1),
//             (text2 != null) ? SizedBox(height: 30) : Container(),
//             (text2 != null) ? Text(text2) : Container(),
//           ],
//         ),
//       ),
//     ),
//     actions: <Widget>[
//       new FlatButton(
//         onPressed: () {
//           Navigator.of(context).pop();
//         },
//         child: new Text(
//           'Cancel',
//           style: new TextStyle(
//             fontSize: 16,
//             color: Colors.grey[400],
//           ),
//         ),
//       ),
//       new FlatButton(
//         // onPressed:  () {print('-- go to result');},
//         onPressed: () {
//           confirmCallback();
//           Navigator.of(context).pop();
//         },
//         child: new Text(
//           'Yes, Confirm',
//           style: new TextStyle(
//             fontSize: 16,
//             color: blueColor,
//           ),
//         ),
//       ),
//     ],
//   );
// }



class SliderCompleteShopping extends StatefulWidget {

  final double sliderMargin;
  final String fromPage;
  final Function() confirmComplete;
  final Function() cancelComplete;

  const SliderCompleteShopping({required this.sliderMargin, required this.fromPage, required this.confirmComplete, required this.cancelComplete, Key? key}) : super(key: key);

  @override
  State<SliderCompleteShopping> createState() => _SliderCompleteShoppingState();
}

class _SliderCompleteShoppingState extends State<SliderCompleteShopping> {
  
  late GlobalVar globals;
  final HttpService httpSavory = HttpService();
  final GlobalFunctions fx = GlobalFunctions();  

  int commitCount = 0;
  double commitSavings = 0.0;
  double commitTotal = 0.0;


  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    globals = Provider.of<GlobalVar>(context, listen: false);

    getCommitNumbers();
  }

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

  @override
  Widget build(BuildContext context) {

    return Container(
              height: my_screenHeight * .55,
              width: my_screenWidth - widget.sliderMargin,  
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
                    children: [
                          (globals.activeShop['commit_status']) < 4
                            ?
                              (widget.fromPage == 'shop')
                                ? const Text('Complete Purchase', style: TextStyle(fontSize: 18.0, color: Color(0xFFe9813f)),)
                                // : Container(
                                //     padding: EdgeInsets.all(16.0),
                                //     child: Text('Your have an Active Shopping Cart from ' + currStore!.storeName + '.  You MUST Finalize your Cart before creating a new Menu.', style: TextStyle(fontSize: 18.0, color: Color(0xFFe9813f)),))
                                : Container(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text('Active Shopping Cart from ' + currStore!.storeName, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Color(0xFFe9813f)),),
                                            SizedBox(height: 16.0),
                                            // Text(' - Finalize your Cart OR', style: TextStyle(fontSize: 18.0, color: blueColor)),
                                            // Text(' - Cancel to continue Shopping', style: TextStyle(fontSize: 18.0, color: blueColor))
                                            Text('"Complete" Shopping', style: TextStyle(fontSize: 18.0, color: blueColor)),
                                            Text('or', style: TextStyle(fontSize: 18.0, color: blueColor)),
                                            Text('"Cancel" to continue Shopping', style: TextStyle(fontSize: 18.0, color: blueColor))
                                          ],
                                        ))
      
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
                          Text(commitCount.toString(), style: const TextStyle(fontSize: 18.0, color: blueColor),),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Savings'),
                          const SizedBox(height: 2.0),
                          Text('\$ ${commitSavings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18.0, color: blueColor),),
                        ],
                      ),

                          (globals.activeShop['commit_status']) < 4
                            ? 
                              Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: blueColor, // background
                                      onPrimary: Colors.white, // foreground
                                      padding: const EdgeInsets.all(8.0),    
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),) 
                                    ),
                                    onPressed: () {
                                      
                                      DateTime dateToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                                      globals.activeShop['commit_status_new'] = 4;
                                      globals.activeShop['date_shopped'] = fx.FormatDate(dateToday.toString());
                                      globals.activeShop['shopped_count'] = commitCount;
                                      globals.activeShop['shopped_total'] = commitTotal;
                                      globals.activeShop['shopped_savings'] = commitSavings;

                                      widget.confirmComplete();
                                      
                                      // checkForChanges(4);  // this also saves 

                                      // Future.delayed(const Duration(milliseconds: 300), () {
                                      //   setState(() { _sliderLeftCompleteBuy = false; });
                                      // });
                                    },
                                    child: const Text('Complete')),
                                ),
                              )

                            : const SizedBox(height: 30.0,),                       
                
                
                    ],
                  ),
                ),

                InkWell(child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text((globals.activeShop['commit_status'] < 4) ? 'Cancel' : 'Got it', style: const TextStyle(fontSize: 16.0,color: Color(0xFFe9813f)),)
                    ],
                  ),
                ),
                  onTap: () {
                    widget.cancelComplete();
                    // setState(() {
                    //   _sliderLeftCompleteBuy = false;
                    // });
                    },
                )
              ],
            ),
    );


    
  }
}


  // keeping for completing purcahse - menu_commit = 4
  checkForChanges(int newStatus, BuildContext context) async {

    // print('111111111111111111');
    // print(globals.shopThreshMet);

    final GlobalVar globals = Provider.of<GlobalVar>(context, listen: false);
    final HttpService httpSavory = HttpService();
    
    if (globals.shopThreshMet == false) {return;}
    print('----    checking for changes on shopping list---- new status:  ' + newStatus.toString());

    // print(globals.changesMadeBuy);
    // print(globals.activeShop['commit_status']);
    for (var mc in globals.menuCommit) {
      // print(mc);
      if (mc['id'] == globals.activeShop['id']) {
        if (mc['commit_status_new'] < newStatus) {
          mc['commit_status_new'] = newStatus;
        }
      }
    }
    // print('-------------------  shop buy  ALL -------------');
    // for (var p in globals.shopBuyAll) {
    //   print(p);
    // }

    Map<String, dynamic> shopMap = {'menu': globals.activeShop, 'buy': globals.shopBuyAll, 'verify': globals.shopVerifyAll};

    final jsonChanged = json.encode(shopMap);

    // print(jsonChanged);

    bool success = await httpSavory.sendShopUpdates(jsonChanged);

    // *** do we need to change in global menu list - or just active
    if (globals.activeShop['commit_status'] < newStatus) {
        // *** we only do like this IF we are creating a shopping list, if we have do something else
        if (success == true) {
          globals.activeShop['commit_status'] = newStatus;
          // for (var mc in globals.menuCommit) {
          //   if (mc['id'] == globals.activeShop['id']) {
          //     if (mc['commit_status'] < 2) {
          //       mc['commit_status_new'] = 2;
          //     }
          //     print('  -----     our active menu commit  ------');
          //   }
          // }
        }
    }

  }


class SliderDontShowAgain extends StatefulWidget {    // probably can be stateless

  final double myMargin;
  final int ShowIdx;
  final Function(bool, int)? removeSlider;   //bool = true - dont show again 
  final Function(bool, int)? acceptTerms;   //bool = true - dont show again  - terms are whatever we are asking, lock shopping?
  const SliderDontShowAgain({required this.myMargin,required this.ShowIdx, required this.removeSlider, required this.acceptTerms, Key? key}) : super(key: key);

  @override
  State<SliderDontShowAgain> createState() => _SliderDontShowAgainState();
}

class _SliderDontShowAgainState extends State<SliderDontShowAgain> {

  bool dontShowCheck = false;

  @override
  Widget build(BuildContext context) {

    return InkWell(
              child: Container(
                height: my_screenHeight * .55,
                width: my_screenWidth - widget.myMargin,  
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
                      child: Text('Warning', style: TextStyle(fontSize: 22.0,color: blueColor),),
                    ),
                          
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Do you want to Start your Shopping?', style: TextStyle(fontFamily: 'Roboto', fontSize: 22.0,fontWeight: FontWeight.w600, color: blueColor), textAlign: TextAlign.center,),
                                // Padding(
                                //   padding: EdgeInsets.all(2.0),
                                //   child: Text('swipe right to Menu', style: TextStyle(fontSize: 20.0),),
                                // ),
                                ],
                            ),
                          ),
                          const SizedBox(height: 24.0),                     
                                
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              // Text('Dislike', style: TextStyle(fontFamily: 'Roboto', fontSize: 26.0,fontWeight: FontWeight.w600, color: blueColor),),
                              Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Text('This will lock your Menu', style: TextStyle(fontSize: 18.0), textAlign: TextAlign.center,),
                              ),
                              Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Text('This is not reversible', style: TextStyle(fontSize: 18.0), textAlign: TextAlign.center,),
                              ),
                              ],
                          ),
                          const SizedBox(height: 24.0),
                                                          
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: const [
                          //     Text('Maybe Later', style: TextStyle(fontFamily: 'Roboto', fontSize: 26.0,fontWeight: FontWeight.w600, color: blueColor),),
                          //     Padding(
                          //       padding: EdgeInsets.all(2.0),
                          //       child: Text('keep in Swipe', style: TextStyle(fontSize: 20.0),),
                          //     ),
                          //     ],
                          // ),
                          // const SizedBox(height: 24.0), 
                          
                        ],
                      ),
                    ),

                                
                    
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0, left: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text("cancel", style: TextStyle(fontSize: 16.0),),
                                  ],
                                ),
                              ),
                              onTap: () {
                                widget.removeSlider!(dontShowCheck, widget.ShowIdx);
                              },
                            ),

                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0, right: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    // Text("Lock Menu", style: TextStyle(fontSize: 20.0,color: Color(0xFFe9813f),fontWeight: FontWeight.w600,),),
                                    Text("Start Shopping", style: TextStyle(fontSize: 20.0,color: Color(0xFFe9813f),fontWeight: FontWeight.w600,),),
                                  ],
                                ),
                              ),
                              onTap: () {
                                widget.acceptTerms!(dontShowCheck, widget.ShowIdx);
                              },
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              value: dontShowCheck,
                              activeColor: const Color(0xFFe9813f),
                              onChanged: (val) {
                                print(dontShowCheck);
                                setState(() {
                                  dontShowCheck = !dontShowCheck; 
                                });
                                 
                              },
                            ),
                            Text("Don't show again")
                          ],
                        ),
                      ],
                    ),

                    

                                    
                          
                  
                  ],
                )
                          
              ),
                  onTap: () {
                    null;
                    // if (dontShowCheck == false) {
                    //   widget.removeSlider!(dontShowCheck, widget.ShowIdx);
                    // }
                  },
            );
    
  }
}


class SliderBadConnection extends StatefulWidget {

  final double sliderMargin;
  final String fromPage;
  final Function() cancelConnect;

  const SliderBadConnection({required this.sliderMargin, required this.fromPage, required this.cancelConnect, Key? key}) : super(key: key);

  @override
  State<SliderBadConnection> createState() => _SliderBadConnectionState();
}

class _SliderBadConnectionState extends State<SliderBadConnection> {
  @override
  Widget build(BuildContext context) {

    return InkWell(
                      child: Container(
                        height: (widget.fromPage == 'splash') ? my_screenDisplay : my_screenDisplay * .75,
                        width: my_screenWidth - widget.sliderMargin,  
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
                              child: Text('Poor Internet Connection', style: TextStyle(fontSize: 22.0,color: blueColor),),
                            ),
                                  
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text('Connect to WiFi', style: TextStyle(fontFamily: 'Roboto', fontSize: 26.0,fontWeight: FontWeight.w600, color: blueColor),),
                                      Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Text('Go to: Settings/Connections', style: TextStyle(fontSize: 20.0),),
                                      ),
                                      ],
                                  ),
                                  const SizedBox(height: 24.0),                     
                                        
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text('Why?', style: TextStyle(fontFamily: 'Roboto', fontSize: 26.0,fontWeight: FontWeight.w600, color: blueColor),),
                                      Padding(
                                        padding: EdgeInsets.only(top:2.0),
                                        child: Text("store construction", style: TextStyle(fontSize: 20.0),),
                                      ),
                                      Text("can weaken cell signal", style: TextStyle(fontSize: 20.0),),
                                      ],
                                  ),
                                  const SizedBox(height: 24.0),                 

                                  (widget.fromPage == 'splash')
                                    ?
                                      Padding(
                                        padding: const EdgeInsets.only(top:24.0, bottom: 24.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Text('Then Restart App', style: TextStyle(fontFamily: 'Roboto', fontSize: 26.0,fontWeight: FontWeight.w600, color: blueColor),),
                                            Padding(
                                              padding: EdgeInsets.only(top:2.0),
                                              child: Text("after you connect to WiFi", style: TextStyle(fontSize: 20.0),),
                                            ),
                                            ],
                                        ),
                                      )
                                    : Container(),
                                                    
                                  
                                ],
                              ),
                            ),
                            
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0, right: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text("Got it!", style: TextStyle(fontSize: 20.0,color: Color(0xFFe9813f)),),
                                  ],
                                ),
                              ),
                              onTap: () {
                                widget.cancelConnect();
                              },
                            )
                                  
                          
                          ],
                        )
                                  
                      ),
                          onTap: () {
                             widget.cancelConnect();
                          },
                    );
    
  }
}

// // TODO - notusing here - bc warning to use context in async - duplicating code in Menu & Shop - should be in one
// popStoresShoppingList(int storeID, BuildContext context) {

//     GlobalVar globals = Provider.of<GlobalVar>(context, listen: false);

//     globals.shopBuyAll.clear();
//     globals.shopBuy.clear();
//     globals.shopDontBuy.clear();
//     globals.shopVerifyAll.clear();
//     globals.shopVerify.clear();
//     globals.shopDontVerify.clear();
//     globals.shopCategory.clear();

//     print('*****************************************');

//     for (var l in globals.shoppingList) {
//       if (l['store_id'] == storeID) {
//           print(l['shopping_list']);
//           print('-------------------------------------------');
//           globals.shopBuyAll = l['shopping_list']['purchase'];
//           globals.shopVerifyAll = l['shopping_list']['verify'];
//           globals.shopBuy = l['shopping_list']['purchase'].where((item) => item['shop_accept'] == 1).toList();
//           globals.shopDontBuy = l['shopping_list']['purchase'].where((item) => item['shop_accept'] == -1).toList();
//           globals.shopVerify = l['shopping_list']['verify'].where((item) => (item['dont'] == 'keep' || item['dont'] == 'want')).toList();
//           globals.shopDontVerify = l['shopping_list']['verify'].where((item) => item['dont'] == 'dont').toList();
//           // globals.shopVerify = l['shopping_list']['verify'].where((item) => item['dont'] == false).toList();
//           // globals.shopDontVerify = l['shopping_list']['verify'].where((item) => item['dont'] == true).toList();
//           globals.shopCategory = l['shopping_list']['shop_cat'];
//       }
//     }
//     globals.shopCategory.insert(0, "Verify");
//     globals.shopCategory.insert(0, "All");

//   }

