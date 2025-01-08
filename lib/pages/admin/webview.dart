// import 'dart:async';
// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

class MyWebView extends StatelessWidget {
  final String title;
  final String selectedUrl;
  // final bool isGarmin;

 
  MyWebView({Key? key, 
    required this.title,
    required this.selectedUrl,
    // this.isGarmin = false,
  }) : super(key: key);


  // final Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Center(child: Padding(
          padding: const EdgeInsets.only(right:40.0),
          child: Text(title, style: TextStyle(color: Colors.white)),
        )),
      ),

      //body: WebViewWidget(controller: _controller),

      body: WebView(
        initialUrl: selectedUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController controller) {
          _controller = controller;
        },
        

        onPageFinished: null,

        // onPageFinished: 
        // (isGarmin == true)
        //   ? 
        //     (finish) async {
        //       //reading response on finish
        //       final response = await _controller.runJavascriptReturningResult("document.documentElement.innerText");
        //       // print(jsonDecode(response)); //don't forget to decode into json

        //       if (jsonDecode(response).contains('201 Created')) {    // 'Cardiac Peak Privacy Policy')) { //  
        //         Future.delayed(const Duration(milliseconds: 100), () {
        //           Navigator.pop(context, true);
        //         });
        //       }
        //     }
        //   : null
    
      )
    );
  }

}


