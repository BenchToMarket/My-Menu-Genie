import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:menu_genie/pages/admin/phoenix.dart';

import '../admin/global_classes.dart';

class Admin_Text extends StatefulWidget {

  final String title;
  final String purpose;
  Admin_Text({required  this.title, required this.purpose});

  @override
  _Admin_TextState createState() => _Admin_TextState();
}

class _Admin_TextState extends State<Admin_Text> {

  bool _isLoading = false;
  String mainText = '';


  @override
  void initState() {
    super.initState(); 
    fetchPageText();
  }

  void fetchPageText() async {

      _isLoading = true;

      List<dynamic> textList = await getPageText();

      if (textList.length > 0) {
         mainText = textList[0]['message'];
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
  }

  Future<List<dynamic>> getPageText() async {
    
    final PhoenixFunctions fx = PhoenixFunctions();
    String sh = fx.determinephoenix();

    try {

      print('************ fetch Page Text  ' + widget.purpose);
      final response = 
        await http.get(Uri.parse(API + '/admin-text/' + widget.purpose.toString() + '/' + sh + '/'));

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        return result;

      } else {
        throw "Can't get page text .";
      }

    } catch(err) {
      print('WTF');
      print(err);
      return [];
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading == true) {
      return Center(child: CircularProgressIndicator(),);
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Center(child: Padding(
          padding: const EdgeInsets.only(right: 40.0),
          child: Text(widget.title, style: TextStyle(color: Colors.white)),
        )),
       
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(child: Text(mainText, style: TextStyle(fontSize: 16.0))),
      ),
    );
  }
}