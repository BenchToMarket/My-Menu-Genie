

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/global_classes.dart';
import '../admin/navigation_bar.dart';
import '../admin/more_help.dart';
import '../admin/phoenix.dart';



class UserLogin extends StatefulWidget {

  final bool fromSignup;
  const UserLogin({required this.fromSignup, Key? key}) : super(key: key);

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  // final CurrentUser userService = CurrentUser();

  Widget _buildEmailField() {

    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'email',
        icon: Icon(FontAwesomeIcons.envelope),
        errorStyle: TextStyle(
          color: orangeColor,
          wordSpacing: 5.0,
        ),),
      keyboardType: TextInputType.emailAddress,
      maxLength: 40,

      validator: (String? value) {
        String pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regExp = RegExp(pattern);
        if (value!.isEmpty) {
          return 'Email is required';
        } else if (!regExp.hasMatch(value)) {
          return 'Invalid email - verify no spaces at end';
        } else {
          return null;
        }
       
      },
      onSaved: (String? value) {
        _email = value!;
      },
    );
  }

  late String _passwordError;
  bool visible = true;
 
  Widget _buildPasswordField() {
    return TextFormField(
      obscureText: visible,
      decoration: InputDecoration(
        labelText: 'password',
        // hintText: "minimum 6 characters", errorText: _passwordError,
        icon: const Icon(FontAwesomeIcons.unlock),     // unlockKeyhole
        errorStyle: const TextStyle(
          color: Colors.orange,
          wordSpacing: 5.0,
        ),
        suffix: InkWell(
          child: visible
              ? const Icon(
                  Icons.visibility_off,
                  size: 18,
                  color: Colors.orange,
                )
              : const Icon(
                  Icons.visibility,
                  size: 18,
                  color: Colors.orange,
                ),
          onTap: () {
            setState(() {
              visible = !visible;
            });
          },
        )),

      keyboardType: TextInputType.visiblePassword,
      maxLength: 200,
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Password is required';
        } else if (value.length < 6) {
          return 'At least 6 characters';
        }
        return null;
      },
      onSaved: (String? value) {
        _password = value!;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    
   return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.fromSignup == true ? true: false,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        title: Center(child: Padding(
          padding: EdgeInsets.only(right: widget.fromSignup == true  ? 60.0 : 0.0),
          child: (Text('Log In', style: TextStyle(color: Colors.white))),
        )),
      ),

      
      body: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 30, right: 40, top: 40),
              child: Form(
              key: _formKey,

                child:Column( 
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
      
                    // SizedBox(height: 24),
                    
                    _buildEmailField(),
                
                    _buildPasswordField(),
                  
                    const SizedBox(height: 60),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left:50, right:50),
                      child: RaisedButton(
                        color: blueColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: const Text('Log In',
                            style: TextStyle(fontSize: 18, color: Colors.white)),
                        // onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => UserSignup())),   
                        onPressed:() async {
                          // print(' -- Join button pressed --');
                          
                          if(!_formKey.currentState!.validate()) {
                            // print('wait a minute!!!');
                            return;
                            }
                          _formKey.currentState!.save();

                          bool credMatch = await testifUserExists(context);

                          if (credMatch == true) {
                            // print('loging in user ---- '+ curr_user.user_name);
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyBottomNavigationBar(noInternetConnection: false,)));
                          }
                        
                        },

                      ),
                    ),

                    FlatButton(
                    
                      child: const Text('Forgot Password?',
                        style: TextStyle(
                          fontSize: 16,
                          color: goldColor,
                        ),
                      ),
                      
                      onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => InformationDialog(
                        context: context,   
                        title: 'Password Reset',
                        text1: 'Send us an email to reset your password: support@MenuGenie.ai',
                        text2: 'You can provide a specific password in the email or we will generate a random password. \nThis may take 24 hours.'),),
                    ),


                    TextButton(
                      onPressed: () {
                            Navigator.of(context).pop();
                          },
                      child: const Text(
                          "No Account? Join for Free",
                          style: TextStyle(
                            fontSize: 16,
                            color: blueColor,
                          ),
                        ),
                    ),


                  
                  ],
                )   
              ),

            )
      
      
    );
  }

  Future<bool> testifUserExists(BuildContext context) async {

    // print('111111111111111111111111111111111');

    final PhoenixFunctions px = PhoenixFunctions();
    final GlobalFunctions fx = GlobalFunctions();  
    String sh = px.determinephoenix(); 

    bool _emailMatch = false;
    bool _passwordMatch = false;
    String _passcodeHash;
    int _user_id = -1;      // return -1 if no match
    List<dynamic> verified;

    _email = _email.toLowerCase();
    // hash passcode
    var bytes1 = utf8.encode(_password);                 // data being hashed
    _passcodeHash = sha256.convert(bytes1).toString();    // Hashing Process

    loginUser(var user) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String memberSince = fx.FormatDate(user['created_on']);

      // print('222222222222222222222222222222222222');
      // print(user);

      // list of store prefs
      // https://stackoverflow.com/questions/60220216/flutter-how-to-store-list-of-int-in-shared-preference

      prefs.setBool("isLoggedIn", true); // set to false to test Login
      prefs.setInt("currentUserID", user['id']); 
      prefs.setInt("userServeSize", user['json_prefs']['serv_size']);                 // ** TODO - need to pull from user preferneces
      prefs.setInt('appVersion', user['app_version']);
      prefs.setInt('userPlan', user['plan_id']);
      // prefs.setStringList('store_list', ["1"]);
      prefs.setString('seenInfo', '2222222222');

      currUser = CurrentUser(
        userID: prefs.getInt("currentUserID")!,
        userIDString: prefs.getInt("currentUserID").toString(),
        userServeSize: prefs.getInt("userServeSize")!,
        userPlan: prefs.getInt("userPlan")!,
        seenInfo: prefs.getString("seenInfo")!,
      );

      print(currUser);

      if (user['id'] <= 30) {   // == 1 || user['id'] == 34 || user['id'] == 41 || user['id'] == 53) {
        Provider.of<GlobalVar>(context, listen: false).setIsAdmin(true);
      }
      
    }

    print('*********  fetch Verified User ******');
    final response = await http.get(Uri.parse('$API/user-login/$_email/$_passcodeHash/$sh/'));

    if (response.statusCode == 200) {
      verified = jsonDecode(response.body);

      if (verified.length == 0) {
        _emailMatch = false;
        _passwordMatch = false;
      } else {
        // ** need to test for duplicate accoiunt, and do something (merge or have them pick??)

        for (var user in verified) {

          if (user['email'].toLowerCase() == _email) {
            _emailMatch = true;
            
            // if email does not match, password stays false
            if (user['password'] == _passcodeHash) {
              _passwordMatch = true;
            }
          }

          if (_emailMatch == true && _passwordMatch == true) {
            _user_id = user['id'];
            await loginUser(user);
            break;
          } 
        }
      
      }
    }

    // print('1111111111111111111111111111');
    // print(_emailMatch);
    // print(_passwordMatch);

    if (_emailMatch != true || _passwordMatch != true) {
      // either email or password does not match, tell user which one
      showDialog(
        context: context,
        builder: (BuildContext context) => InformationDialog(
        context: context,   
        title: 'Incorrect Login',
        text1: (_emailMatch == false) ? 'email $_email \nmay not match our records' : '',
        text2: (_passwordMatch == false) ? 'password $_password \ndoes not match our records' : '',
        text3: "Verify entry is correct.\nIf still having trouble:\nsupport@menugenie.ai"
        ),);
       

      return false; 
    } else {
      return true;  // match, can login user
    }

  }


  // void resetPassword(int _user_id) async {
  //   // generate random string or two words using - https://pub.dev/packages/random_words/install
  //   // hash & insert into db
  //   // verify valid email in textBox
  //   // send email to user w/ new password - maybe - https://pub.dev/packages/flutter_email_sender/example
  //   // if we do this, we must have reset password method as well ???
  // }

}
