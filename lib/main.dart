import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/admin/navigation_bar.dart';
import 'pages/admin/global_classes.dart';
// import 'pages/admin/savory_api.dart';
// import 'pages/menu/menu_create.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
          providers: [
            Provider<GlobalVar>(create: (_) => GlobalVar()),
            // ChangeNotifierProvider<Connect>(create: (context) => Connect()),
          ],
        child:  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.

        // https://stackoverflow.com/questions/74621686/how-to-use-colorscheme-in-flutter-themedata
        // colorScheme: const ColorScheme(brightness: brightness, primary: primary, onPrimary: onPrimary, secondary: secondary, onSecondary: onSecondary, error: error, onError: onError, background: background, onBackground: onBackground, surface: surface, onSurface: onSurface),
        colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF3CBC6D),
            onPrimary: Color(0xFF3CBC6D),
            secondary:  Color(0xFFe9813f),  // Color(0xFFF8B249),  
            onSecondary: Color(0xFFfce0b6),
            error: Color(0xFFF32424),
            onError: Color(0xFFF32424),
            background: Color(0xFFFEFEFE),          // background: Color(0xFFF1F2F3),
            onBackground: Color(0xFFFFFFFF),
            surface: Color(0xFF54B435),     // can change 
            onSurface: Color(0xFF54B435),
          ),

          // from Cardiac Peak - custom for Savory
          // textTheme: const TextTheme(
          //   headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          //   headline6: TextStyle(fontSize: 18.0, fontStyle: FontStyle.italic),
          //   bodyText1: TextStyle(fontSize: 16.0, fontFamily: 'Hind'),
          //   bodyText2: TextStyle(fontSize: 12.0, fontFamily: 'Hind'),
          // ),

          // textTheme: TextTheme(
          //   headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          //   headline6: TextStyle(fontSize: 18.0, fontStyle: FontStyle.italic),
          //   bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          //   // bodyText2: TextStyle(fontFamily: 'Hind'),
          // ),

        // primarySwatch: Colors.blue,
        // primarySwatch: Colors.red,

        // primaryColor: const Color(0xFF21BE5D),    // FF means full opacity
        // backgroundColor: const Color(0xFFFEFEFE),
        // accentColor: Colors.cyan[600],

        // other colors:
        // light slate grey -    Color(0xFF676161),  
        // hot red              color:Color(0xFFE40014)

      ),

      home: const MyBottomNavigationBar(),
    ),
    );
  }
}
