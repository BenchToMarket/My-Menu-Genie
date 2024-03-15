import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:menu_genie/pages/admin/phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:slider_captcha/slider_capchar.dart';


import '../admin/global_classes.dart';
import '../admin/admin_textpage.dart';
import 'user_login.dart';

import '../admin/navigation_bar.dart';
import '../admin/savory_api.dart';
// import '../admin/more_help.dart';

// validation:
// https://fluttertutorial.in/flutter-sign-up-with-validation/
// https://stackoverflow.com/questions/56253787/how-to-handle-textfield-validation-in-password-in-flutter

class UserSignup extends StatefulWidget {


  UserSignup({Key? key}) : super(key: key);

  @override
  _UserSignupState createState() => _UserSignupState();
}

class _UserSignupState extends State<UserSignup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyRef = GlobalKey<FormState>();
  final GlobalFunctions fx = GlobalFunctions();
  final PhoenixFunctions px = PhoenixFunctions();
  final HttpService httpSavory = HttpService();

  // final SliderController _authController = SliderController();
  bool authVisible = false;
  int authFailed = 0;
  bool failedVisible = false;
  String failedNotice = 'Failed to Authenticate\ntry again later';

  late String _email;
  late String _password;
  // String _username;
  late String _postcode;
  late String _city;
  late String _state;

  String? _referredBy;

  late Map<String, dynamic> _cityAndState;
  bool _gotCityState = false;
  // bool _updatedPic = false;
  bool _updatedZip = false;


  Widget _buildEmailField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'email',
        icon: Icon(FontAwesomeIcons.envelope),
        errorStyle: TextStyle(
          color: orangeColor,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          wordSpacing: 1.0,
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      maxLength: 40,
      validator: (String? value) {
        String pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regExp = RegExp(pattern);
        if (value!.isEmpty) {
          return 'Email is required';
        } else if (!regExp.hasMatch(value)) {
          return 'Invalid email - check for spaces';
        } else {
          return null;
        }
      },
      onSaved: (String? value) {
        _email = value!;
      },
    );
  }

  // late String _passwordError;
  bool visible = true;

  Widget _buildPasswordField() {
    return TextFormField(
      obscureText: visible,
      decoration: InputDecoration(
          labelText: 'password',
          // hintText: "minimum 6 characters", errorText: _passwordError,
          icon: const Icon(FontAwesomeIcons.unlockKeyhole),
          errorStyle: const TextStyle(
          color: orangeColor,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          wordSpacing: 1.0,
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
      maxLength: 40,
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

  // Widget _buildUsernameField() {
  //   return TextFormField(
  //     decoration: InputDecoration(
  //       labelText: 'username',
  //       icon: Icon(FontAwesomeIcons.user),
  //       errorStyle: TextStyle(
  //         color: Colors.yellow[700],
  //         fontSize: 16.0,
  //         wordSpacing: 5.0,
  //       ),
  //     ),
  //     keyboardType: TextInputType.name,

  //     maxLength: 20,

  //     /// https://stackoverflow.com/questions/12018245/regular-expression-to-validate-username
  //     /// username is 6-20 characters long  (?=.{8,20}$)
  //     /// no _ or . at the beginning        (?![_.])
  //     /// no __ or _. or ._ or .. inside    (?!.*[_.]{2})
  //     /// allowed characters                [a-zA-Z0-9._]
  //     /// no _ or . at the end              (?<![_.])$)
  //     validator: (String value) {
  //       String pattern =
  //           r'(^(?=.{6,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$)';
  //       RegExp regExp = new RegExp(pattern);
  //       if (value.isEmpty) {
  //         return 'Username is required';
  //       } else if (!regExp.hasMatch(value)) {
  //         return 'min 6: a-z . A-Z _ 0-9';
  //       }
  //       return null;
  //     },
  //     onSaved: (String value) {
  //       _username = value;
  //     },
  //   );
  // }



  Widget _buildPostalField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'zip code',
        icon: Icon(FontAwesomeIcons.envelope),
        errorStyle: TextStyle(
          color: orangeColor,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          wordSpacing: 1.0,
        ),),
      keyboardType: TextInputType.number,     // using just number, can't input international, but not target now 
      maxLength: 8,
      // initialValue: widget.originalZip,

      /// https://stackoverflow.com/questions/12018245/regular-expression-to-validate-username
      /// username is 6-20 characters long  (?=.{8,20}$)
      /// allowed characters                [a-zA-Z0-9]
     
      validator: (String? value) {

        String pattern = r'(^[a-zA-Z0-9 ]*$)';
        RegExp regExp = RegExp(pattern);
        if (value!.isEmpty) {
          return 'Zip code to find local deals';
        }  else if (value.length != 5) {
          return 'Must be 5 digits';
        } else if (!regExp.hasMatch(value)) {
          return 'allowed: a-z A-Z 0-9';
        }

        if (_gotCityState == false) {
          return 'Zip code must match a US city';
        }

        return null;
       
      },
      onChanged:  (String value) {
        _postcode = value;
      },
      onSaved: (String? value) {
        _postcode = value!;
      },
    );
  }


  Widget _buildReferralField() {
    return Container(
      height: 60,
      width: 220,
      child: TextFormField(
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          // labelText: 'Enter Code',
          // hintText: 'Promo or Referral Code',
          hintText: 'Enter Code here',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 8.0),
          // icon: Icon(FontAwesomeIcons.user),
          errorStyle: TextStyle(
          color: orangeColor,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          wordSpacing: 1.0,
          ),
        ),
        keyboardType: TextInputType.name,
        // maxLength: 6,

        validator: (String? value) {
          String pattern = r'(^(?=.{6,6}$)[a-zA-Z0-9]+(?<![_.])$)';
          RegExp regExp = RegExp(pattern);
          if (value!.isEmpty) {
            // - should ask user if they forgot to enter a promo code
            return null;
          } else if (!regExp.hasMatch(value)) {
            return 'code provided to you';
          }
          return null;
        },
        onChanged: (String? value) {
          _referredBy = value!;
        },        
        onSaved: (String? value) {
          _referredBy = value!;
        },
      ),
    );
  }

  Icon termsUse = Icon(Icons.check_box_outline_blank);
  bool _acceptTerms = false;

  bool _isButtonDisabled = true;
  void _buttonPressed() {
    setState(() {
      _isButtonDisabled = true;
    });
  }

  // void authenticatoinFailer() async {
  //   final HttpService httpService = HttpService();
  //   curr_user = CurrentUser(user_id:0, user_id_string: '0');
  //   await httpService.sendAppError(context,' -- NEW USER -- -- SECURITY -- authetication failed, new user: ' +  _email);
  // }

  void joinMenuGenie() async {

    // for testing 
    // curr_user = CurrentUser(user_id:1, user_id_string: '1');
    // Navigator.push( context, MaterialPageRoute( builder: (context) => ContestPage(false)));  //  => ContestPage(true)));
    // return;
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day); 
  
    int _newUserID = await createNewUser();
    // int _newUserID = 0;
    if (_newUserID > 0) {
      // final CurrentUser userService = CurrentUser();
      // curr_user = await userService.PopulateCurrentUser();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      int _serv_size = 4;   // TODO - user should select

      currUser = CurrentUser(
        userID: _newUserID,
        userIDString: _newUserID.toString(),
        userServeSize: _serv_size,
      );

      prefs.setBool("isLoggedIn", true); // set to false to test Login
      prefs.setInt("currentUserID",currUser.userID);  
      prefs.setInt("userServeSize",_serv_size);  
      prefs.setInt('appVersion', cpAppVersion);


      // **** can send user to another App Info page before we beign
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement( context, MaterialPageRoute( builder: (context) => const MyBottomNavigationBar()));

      // Navigator.push( context, MaterialPageRoute( builder: (context) => GetStartedPage('start')));

      // Navigator.push( context, MaterialPageRoute( builder: (context) => ContestPage('start')));

      // Navigator.push( context, MaterialPageRoute( builder: (context) => GamifiedPage('start')));

    }
  }


  @override
  Widget build(BuildContext context) {

    // _postcode = widget.sentPostal;
    // _city = widget.city;
    // _state = widget.state;

    // print('----- in signup -----');
    // print(_selectedGoal);
    // print(_selectedLevel);

    return Scaffold(
        appBar: AppBar(
          title: const Center(
              // child: (Text('Sign Up', style: TextStyle(color: Colors.white)))),
              // child: (Text("Save \$100's with Menu Genie AI", style: TextStyle(color: Colors.white)))),
              child: Text("Menu Genie AI - Sign Up", style: TextStyle(color: Colors.white))),
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   // ignore: prefer_const_literals_to_create_immutables
              //   children: [
              //     const Text("Menu Genie ", style: TextStyle(color: Colors.white)),
              //     const Text("AI", style: TextStyle(color:goldColor)),
              //     const Text(" - Sign Up", style: TextStyle(color: Colors.white)),
              //   ],
              // )),
          automaticallyImplyLeading: false,
          // leading: IconButton(
          //     icon: const Icon(FontAwesomeIcons.anglesLeft),
          //     tooltip: 'Back',
          //     onPressed: () {
          //       Navigator.pop(context);
          //     }),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 30, right: 40, top: 30),
          child: Form(
              key: _formKey,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: _buildEmailField(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: _buildPasswordField(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: _buildPostalField(),
                  ),

                  // ***** keep  
                  // slider autheticator - Capthcha 
                  // (authVisible == true)
                  //   ? 
                  //     SafeArea(
                  //       child: Padding(
                  //         // padding: const EdgeInsets.symmetric(horizontal: 20),
                  //         padding: const EdgeInsets.all(20),
                  //         child: SliderCaptcha(
                  //           controller: _authController,
                  //           image: Image.asset(
                  //             'images/run_variety_sm.jpg',
                  //             fit: BoxFit.fitWidth,
                  //           ),
                  //           colorBar: Colors.blue[700],
                  //           colorCaptChar: Colors.blue[700],
                  //           space: 10,
                  //           fixHeightParent: false,
                  //           onConfirm: (value) async {
                  //             // debugPrint(value.toString());
                  //             if (value == false) {
                  //               authFailed +=1;
                  //             } else {
                  //                 joinMenuGenie();
                  //                 return;
                  //             }
                  //             return await Future.delayed(const Duration(seconds: 1)).then(
                  //               (value) {
                  //                 if (authFailed > 4) {
                  //                   setState(() {
                  //                     authVisible = false;
                  //                     failedVisible = true;
                  //                   });
                  //                   authenticatoinFailer();
                  //                 }
                  //                 _authController.create.call();
                                  
                  //               },
                  //             );
                  //           },
                  //         ),
                  //       ),
                  //     )
                  //   : Container(),

                  // (failedVisible == true)
                  //   ? Text(failedNotice, style: TextStyle(fontSize: 18.0, height: 1.5, color: Colors.yellow[700]),textAlign: TextAlign.center,)
                  //   : Container(),



                  SizedBox(height: 40),

                  Row(
                    children: [
                      IconButton(
                      icon: termsUse,
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        DateTime now = DateTime.now();
                        DateTime onlyDate = DateTime(now.year, now.month, now.day); prefs.setString('contestDate', onlyDate.toString());
                        _acceptTerms = !_acceptTerms;
                        setState(() {
                          if (_acceptTerms == true) {
                            termsUse = Icon(Icons.check_box);
                            _isButtonDisabled = false;
                          } else {
                            termsUse = Icon(Icons.check_box_outline_blank);
                            _isButtonDisabled = true;
                          }
                        });
                      }),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
          
                          // Text("I accept Cardiac Peak's "),
                          // SizedBox(height: 2.0),
                          Row(
                            children: [
                              Text("I accept Menu Genie AI's "),
                              InkWell(
                                child: Text("Terms of Use", style: TextStyle(color: blueColor)),
                                onTap: () {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Admin_Text(
                                        title: "Terms of Use",
                                        purpose: 'service',
                                    )));
                                }
                              ),
                             
                            ],
                          ),
                        ],
                      )
                    ],),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 30, right: 20),
                    child: RaisedButton(
                        color: blueColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Join Menu Genie AI',
                            style: TextStyle(fontSize: 18, color: Colors.white)),
                        // onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => UserSignup())),
                        onPressed: _isButtonDisabled
                            ? null
                            : () async {
                                _buttonPressed();
                                // print(' -- Join button pressed --');

                                _gotCityState = await getCityState(); 

                                if (!_formKey.currentState!.validate()) {
                                  print('wait a minute!!!');
                                  setState(() {
                                    _acceptTerms = false;
                                    termsUse = Icon(Icons.check_box_outline_blank);
                                    _isButtonDisabled = true;
                                  });
                                  return;
                                }
                                _formKey.currentState!.save();

                                joinMenuGenie();

                                // setState(() {
                                //   authVisible = true;
                                // });

                                // final HttpService httpService = HttpService();
                                // curr_user = CurrentUser(user_id:0, user_id_string: '0');
                                // await httpService.sendAppError(context,' -- NEW USER -- join button click, new user: ' +  _email);      

                              }

                        // String savedRecord = await SaveWeight();
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => UserSignup()));
                        //Navigator.pop(context,true);
                        // },

                        ),
                  ),

                  // // **ToDo - trying to align this at bottom of screen, Align does not work
                  // Align(
                  //   alignment: Alignment.bottomCenter,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(
                  //         left: 30, right: 20, top: 6, bottom: 12),
                  //     child: Text(
                  //       "By joining, I accept Cardiac Peak’s\nPrivacy Policy & Terms of Service",
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ),
                  // ),

                  SizedBox(height: 26.0,),

                  const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text("Enter your Promo or Referral Code", style: TextStyle(color: blueColor,)),
                  ),
                  Form(
                    key: _formKeyRef,
                    child: _buildReferralField(),
                  ),
                ],
              )),
        ));
  }

  Future<int> createNewUser() async {
    bool userExists = await testifUserExists();

    if (userExists == true) {
      return -1;
    }

    // print('******* create new user  ******');
    // print(userExists);
    if (userExists == false) {
      print(' -- NO user exists');
    }

    // user does not exist (no email or username match), now create new user

    int _newUserID = await SaveNewUser(); // testing groups

    // print('-- new user id  -- ' + _newUserID.toString());
    // return false;
    // int _newUserID = 40;  for testing, so we don't need to save user

    if (_newUserID < 0) {
      print('issue creating new user');
      // // _newUser (-1 sgtatusCode not 201, -2 is error in SaveNewUser) 
      // final HttpService httpService = HttpService();
      // await httpService.sendAppError(context,'issue creating new user:  $_newUserID');
      // // await httpService.sendAppError(context, 'canLaunchURL_os:  ' + Platform.operatingSystemVersion.toString());
      return 0;
    }

    return _newUserID;

    // Navigator.pop(context);
  }



  Future<int> SaveNewUser() async {
    // print(' -- Dio saving test -- ');
    int _newUserID;
    String _passcodeHash;
    String _ref_code;
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day); 

    // hash passcode
    var bytes1 = utf8.encode(_password); // data being hashed
    _passcodeHash = sha256.convert(bytes1).toString(); // Hashing Process

    // generate ref_code
    final GlobalFunctions fx = GlobalFunctions();
    final PhoenixFunctions px = PhoenixFunctions();
    String sh = px.determinephoenix();
    _ref_code = fx.RandomString(6);
    
    Map<String, dynamic> newUser = {
        "email": _email,
        "password": _passcodeHash,
        "post_code": _postcode,
        "ref_by": _referredBy,
        "ref_code": _ref_code,
        "city": _city,
        "state": _state,
        // "user_type": "user",
        "app_version": cpAppVersion,
      };

    final jsonUser = json.encode(newUser);
    _newUserID = await httpSavory.createNewUser(jsonUser);

    return _newUserID;
  }


  Future<bool> testifUserExists() async {

    String sh = px.determinephoenix();

    bool _emailMatch = false;
    // bool _usernameMatch = false;

    print('-------- fetch Verified User------');
    // print('test email -------' + _email);
    // print('test user_name ---' + _username);

    _email = _email.toLowerCase();


    final response = await http.get(Uri.parse('$API/user-exists/$_email/$sh/'));

    // print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> verified = jsonDecode(response.body);
      if (verified.length == 0) {
        _emailMatch = false;
        // _usernameMatch = false;
      } else {
        for (var user in verified) {
          if (user['email'] == _email) {
            _emailMatch = true;
          }
          // if (user['user_name'] == _username) {
          //   _usernameMatch = true;
          // }
        }
      }
    }

    if (_emailMatch == true) {
      showDialog(
              context: context,
              builder: (BuildContext context) => DupAccountDialog(
                  context: context,
                  emailMatch: _emailMatch,
                ),);
      // showSignupAlert(context, _emailMatch);
      return true;
    } else {
      return false; // no match, can create a new user
    }
  }

  

Widget DupAccountDialog(
    {required BuildContext context,
    required bool emailMatch}) {

  return AlertDialog(
    // backgroundColor: Colors.black26,
    title: Center(
      child: Text('Duplicate Account',
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
              const Text("Duplicate email",
                            style: TextStyle(color: goldColor, fontSize: 18)),
                    SizedBox(height: 16.0),
                    Text( 'An account with the same email exists. Please login with email: $_email'),
            ],
          ),
        ),
      ),
    ),

    actions: <Widget>[
      FlatButton(
        child: Text("Back", style: TextStyle(color: Colors.grey[700]),),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      FlatButton(
        // color: Colors.teal[400],
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserLogin(fromSignup: true,))),
        child: const Text(
          'Log In',
          style: TextStyle(
            fontSize: 16,
            color: goldColor,
          ),
        ),
      ),
    ],
  );
}



  


  
  
  Future<bool> getCityState() async {

    try {
      print('********** fetching city and state *********');

      final response = 
        // await http.get('http://api.zippopotam.us/us/90210');
        await http.get(Uri.parse('http://api.zippopotam.us/us/$_postcode'));

      if (response.statusCode == 200) {
       
        _cityAndState = jsonDecode(response.body);
        _city = _cityAndState['places'][0]['place name'];
        _state = _cityAndState['places'][0]['state abbreviation'];
        
        // print(response.body);
        // print(_cityAndState);
        // print(_cityAndState['places']);
        // print(_cityAndState['places'][0]['place name']);
        // print(_cityAndState['places'][0]['state abbreviation']);

        return true;

      } else {
        return false;
      }

    } catch(err) {
      print('WTF');
      print(err);
      return false;
    }
  }
}
