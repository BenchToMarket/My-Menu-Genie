

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_genie/pages/admin/global_classes.dart';

// import 'more_help.dart';
// import 'webview.dart';


class ForceAction extends StatefulWidget {

  final String appVersion;
  final Map<String, dynamic> userVerify;
  ForceAction({required this.appVersion, required this.userVerify, Key? key}) : super(key: key);

  @override
  State<ForceAction> createState() => _ForceActionState();
}

class _ForceActionState extends State<ForceAction> {
  @override
  Widget build(BuildContext context) {

    return Container(
      // color: Color(0xFFe9813f),

      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/genie_female.jpg"),
              fit: BoxFit.fitHeight),
        ),
      
        child:  Container(
          color: Colors.black.withOpacity(0.4),
          child: ForceDialog_No_Link(
                            context: context,
                            title: widget.userVerify['force_action'] == 'upgrade' ? 'Upgrade Required' : 'Account Upgrade',
                            text1: widget.userVerify['message'],
                              
                            // 'If you need assistance or have an issue with the App, please email with full details to: support@CardiacPeak.com',
                            // can check for OS with  print(Platform.operatingSystem); (need - import 'dart:io' show Platform; )
                            text2: 'current version: 1.0.${widget.appVersion}',
                            // textLink: 'Upgrade on Google Play',
                            // link: 'https://play.google.com/store/apps/details?id=com.cardiac_peak_app'),
                            // link: 'https://cardiacpeak.com/'),
    ),
        ));



    // return Column(
    //   children: [

    // ],);
    
  }
}



Widget ForceDialog_No_Link(
    {required BuildContext context,
    required String title,
    required String text1,
    String? text2,
    String? text3,
    // required String textLink,
    // required String link
    }) {
  return AlertDialog(
    title: Center(
      child: Text(title,
          style: TextStyle(color: blueColor, fontSize: 22.0)),
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 18),
          Text(text1),
          (text2 != null) ? const SizedBox(height: 30) : Container(),
          (text2 != null) ? Text(text2) : Container(),
          // (textLink != '') ? SizedBox(height: 30) : Container(),
          // (textLink != '')
          //     ? InkWell(
          //         child: new Text(textLink,
          //             style: TextStyle(color: Colors.blue[300])),
          //         // onTap: () => launchUrl(Uri.parse(link)))
          //         onTap: () {    
          //                     Navigator.push(context, MaterialPageRoute(builder: (context) => MyWebView(
          //                           title: textLink,  //  'your webpage', 
          //                           selectedUrl:link, 
          //                           // isGarmin: false,
          //                         ))
          //                     );        
          //                   })
          //     : Container(),
        ],
      ),
    ),
    actions: <Widget>[
      FlatButton(
        // color: Colors.teal[400],
        onPressed: () {
          // Navigator.of(context).pop();
          SystemNavigator.pop();
          // SystemChannels.platform.invokeMethod('SystemNavigator.pop'); 
          // 
          // if (Platform.isIOS) {
          //   SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          // }
        },
        child: const Text(
          'Okay, got it!',
          style: TextStyle(
            fontSize: 16,
            color: blueColor,
          ),
        ),
      ),
    ],
  );
}