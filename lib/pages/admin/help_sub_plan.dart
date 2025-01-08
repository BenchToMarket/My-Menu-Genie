
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'global_classes.dart';
import 'savory_api.dart';


class SubscriptionPlan extends StatefulWidget {
  const SubscriptionPlan({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlan> createState() => _SubscriptionPlanState();
}

class _SubscriptionPlanState extends State<SubscriptionPlan> {


  bool _isLoading = false;  

  late GlobalVar globals;
  final HttpService httpSavory = HttpService();
  final GlobalFunctions fx = GlobalFunctions();  

  Map<String, dynamic> userPlanAndUpgrade = {};
  List currentReferrals = [];
  int referalMenuCount = 0;


  @override
  void initState() { 

    globals = Provider.of<GlobalVar>(context, listen: false);
    super.initState();
    startFetching();
  }

  
  
  startFetching() async {

    _isLoading = true;

  
    userPlanAndUpgrade = await httpSavory.getUserPlan();   // active or saved, but can be anything
    // print(userPlanAndUpgrade);
    currentReferrals = userPlanAndUpgrade['status'];  // + userPlanAndUpgrade['status'] + userPlanAndUpgrade['status'];
    for (var r in currentReferrals) {
      if (r['count'] > 0) {
        referalMenuCount +=1;
      }
    }

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
          child: (Text('Subscription Plan', style: TextStyle(color: Colors.white))),
        )),
      ),

      body: Center(child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          
              const Text('Current Plan:', style: TextStyle(fontSize: 20.0,)),
              const SizedBox(height: 8.0,),
              Text(userPlanAndUpgrade['plan']['plan_name'], style: const TextStyle(fontSize: 24.0, color: blueColor),),
              const SizedBox(height: 8.0,),
              Text(userPlanAndUpgrade['plan']['plan_desc'], style: const TextStyle(fontSize: 16.0),),
        
              const SizedBox(height: 30.0),
              // ignore: prefer_interpolation_to_compose_strings
              Text('Earn: ' + userPlanAndUpgrade['upgrade']['new_plan_name'], style: const TextStyle(fontSize: 24.0, color: blueColor),),
              const SizedBox(height: 8.0,),
              Text(userPlanAndUpgrade['upgrade']['new_plan_desc'], style: const TextStyle(fontSize: 16.0),),
              // SizedBox(height: 2.0,),
              // Text(userPlanAndUpgrade['upgrade']['new_plan_details'], style: TextStyle(fontSize: 14.0),),
        
              
              const SizedBox(height: 30.0),
              Text('Current Referrals: $referalMenuCount', style: const TextStyle(fontSize: 24.0, color: blueColor),),
              // Text('Current Referrals: ' + currentReferrals.length.toString(), style: TextStyle(fontSize: 24.0, color: blueColor),),
              const SizedBox(height: 8.0,),
              // ignore: prefer_interpolation_to_compose_strings
              Text('Give your referral code : ' + userPlanAndUpgrade['plan']['ref_code'], style: const TextStyle(fontSize: 16.0),),
              const SizedBox(height: 2.0,),
              (referalMenuCount >= userPlanAndUpgrade['upgrade']['criteria'])
                ? Padding(
                  padding: const EdgeInsets.only(top:6.0, bottom: 4.0),
                  child: Row(
                    children: const [
                      Text('Claim your upgrade: ', style: TextStyle(fontSize: 16.0, color: blueColor)),
                      Text('support@menugenie.ai', style: TextStyle(fontSize: 16.0)),
                    ],
                  ),
                )
                : 
                  Row(
                    children: [
                      const Checkbox(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          value: (true), onChanged: null, activeColor: Color(0xFFe9813f),),
                      Text(userPlanAndUpgrade['upgrade']['new_plan_details'], style: const TextStyle(fontSize: 14.0, color: blueColor),),
                    ],
                  ),
              const SizedBox(height: 8.0,),

              
              (currentReferrals.isEmpty)
                ? const Text('You currently have NO referrals\nGive your friends the above code\nHave them enter when they signup', style: TextStyle(height: 1.3),)
                : Container(
                  height: 200.0,
                   child: Card(
                          // margin: EdgeInsets.only(left: mrg, right: mrg),
                          
                          elevation: 10,
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0, top: 4.0),
                             child: ListView.builder(
                                  shrinkWrap: true,
                                  // scrollDirection: Axis.horizontal,
                                  itemCount: currentReferrals.length,
                                  itemBuilder: (context, idx) {
                               
                                    return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            value: (currentReferrals[idx]['count'] > 0 ? true : false), onChanged: null, activeColor: const Color(0xFFe9813f),),
                                          Text(currentReferrals[idx]['email']),
                                          // ignore: prefer_interpolation_to_compose_strings
                                          Text('    of   ' + currentReferrals[idx]['city']),
                                          // Text(currentReferrals[idx]['state']),
                                        ],
                                      ),
                                    );
                                  }
                                ),
                           ),
                         ),
                  ),

              
              // const SizedBox(height: 30.0),
              // const Text('If you reach 3 referrals that have created at least one menu, contact support@menugenie.ai for upgrade', style: TextStyle(fontSize: 16.0),),
        
        
            ],
          ),
        ),
      ))

    
    );
    
    

    
  }
}