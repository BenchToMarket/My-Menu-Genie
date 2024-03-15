import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'global_classes.dart';
import 'webview.dart';
import 'savory_api.dart';
import 'admin_textpage.dart';



class MoreHelp extends StatefulWidget {

  const MoreHelp({Key? key}) : super(key: key);

  @override
  _MoreHelpState createState() => _MoreHelpState();
}

class _MoreHelpState extends State<MoreHelp> {
  final GlobalFunctions fx = GlobalFunctions();
  Icon contestReset = Icon(Icons.check_box_outline_blank);
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
          title: Center(
            child: Text('Help Center', style: TextStyle(color: Colors.white),),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 0.0, left: 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                ListTile(
                  // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                  title: const Text('Tech Support'),
                  subtitle: const Text('version & upgrade here'),
                  trailing: IconButton(
                    icon: const Icon(Icons.double_arrow),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => InformationDialog(     // InformationDialog_Link(
                          context: context,
                          title: 'Support & Upgrade',
                          text1: "For Tech Support email us at support@MenuGenie.ai",
                          text2: 'To Upgrade go to MenuGenie.AI or directly on Google Play or Apple Store',
                          // can check for OS with  print(Platform.operatingSystem); (need - import 'dart:io' show Platform; )
                          text3: 'current version - 1.0.$cpAppVersion',
                          // textLink: 'Upgrade on Google Play',
                          // link: 'https://play.google.com/store/apps/details?id=com.cardiac_peak_app'
                        ),
                    ),
                  ),
                  // dense: true,
                ),
                const Divider(height: 4, color: blueColor),



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
                          textLink: 'cardiacpeak.com/privacy',
                          link: 'https://cardiacpeak.com/privacy.html'),
                    ),
                  ),
                  // dense: true,
                ),
                const Divider(height: 4, color: blueColor),


                ListTile(
                  // leading: healthTypes[index].healthIcon, // Icon(Icons.directions_bike), //
                  title: Text('Terms of Use'),
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
                Divider(height: 4, color:blueColor),


                


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
                          text1:  "Send an email with subject 'Delete Account' to support@MenuGenie.ai",
                          text2:  "Include your username or email used with Menu Genie AI",
                          text3:  "(optional) Please let us know anything else you want us to know. Deletion is NOT reversible.",
                    ),
                  ),)
                ),
                
                Divider(height: 4, color:blueColor),



                SizedBox(height: 10.0),

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


                SizedBox(height: 30.0),

    
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
          style: TextStyle(color: goldColor, fontSize: 22.0)),
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
              SizedBox(height: 18),
              Text(text1),
              (text2 != null) ? SizedBox(height: 30) : Container(),
              (text2 != null) ? Text(text2) : Container(),
              (text3 != null) ? SizedBox(height: 30) : Container(),
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
          style: TextStyle(color:blueColor, fontSize: 26)),
    ),
    content: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 18),
            Text(text1),
            (text2 != '') ? SizedBox(height: 30) : Container(),
            (text2 != '') ? Text(text2) : Container(),
            (textLink != '') ? SizedBox(height: 30) : Container(),
            (textLink != '')
                ? InkWell(
                    child: Text(textLink,
                        style: TextStyle(color: Colors.blue[300])),
                    // onTap: () => launchUrl(Uri.parse(link)))
                    onTap: () {    
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MyWebView(
                                      title: textLink,  //  'your webpage', 
                                      selectedUrl:link, 
                                      // isGarmin: false,
                                    ))
                                );        
                              })
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
            color:blueColor,
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
