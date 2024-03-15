
import 'dart:ffi';

import 'package:flutter/material.dart';

import '../admin/global_classes.dart';
import '../admin/savory_api.dart';



class CookRecipe extends StatefulWidget {

  final String recp_name;
  Map<String, dynamic> recipe = {};
  CookRecipe({required this.recp_name, required this.recipe,
    Key? key}) : super(key: key);

  @override
  State<CookRecipe> createState() => _CookRecipeState();
}

class _CookRecipeState extends State<CookRecipe> {

  Map<String, dynamic> recipe = {};
  List ingredients = [];
  List instructions = [];

  bool ingredDetailShow = false;
  double ingredHeightAll = 40.0;
  double ingredHeightDetail = 0.0;
  double mrg = 30.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    populateLocals();
  }

  populateLocals() {
    recipe = widget.recipe;

    ingredients = (recipe['recp_json']['recipe']['ingredients']);
    instructions = (recipe['recp_json']['recipe']['instructions']);

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18.0),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 44.0),
            child: Text(widget.recp_name),
            // child: Text(widget.recp_name, style: TextStyle(color: Colors.white),),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
           
            const SizedBox(height: 16.0,),
            Container(
              height: 54.0,
              padding: const EdgeInsets.all(8),
              margin: EdgeInsets.only(left: mrg + 10.0, right: mrg + 10.0),
              decoration: const BoxDecoration(
                  color: goldColorLight,   //  Color(0xFFfce0b6),
                  borderRadius: BorderRadius.all(Radius.circular(8))
                ),
              child:                             
                  DefaultTextStyle(
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Text(recipe['recp_json']['complexity']),
                        Text(" Prep: ${recipe['recp_json']['time']['prep']}  |  Cook: ${recipe['recp_json']['time']['cook']}"),
                        Text('Serve: ${recipe['serv_size']}'),
                    ],),
                  ),

            ),

            SizedBox(height: 16.0),
            Container(
              height: ingredHeightAll,
              // padding: const EdgeInsets.all(8),
              margin: EdgeInsets.only(left: mrg, right: mrg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    child: Container(
                      height: 40.0,
                      // width: my_screenWidth * .8,
                      padding: const EdgeInsets.all(8),
                      // margin: EdgeInsets.only(left: mrg, right: mrg),
                      decoration: const BoxDecoration(
                          color:  goldColor, //   Color(0xFFe9813f),
                          borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          (Text('Ingredients', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600))),
                        ],
                      )
                    ),
                    onTap: () {
                      setState(() {
                        ingredDetailShow = !ingredDetailShow;
                        // this is new visibility
                        if (ingredDetailShow == true) {
                          ingredHeightAll  = my_screenHeight * .55;
                          ingredHeightDetail = ingredHeightAll - 40.0;
                        } else {
                          ingredHeightAll  = 40.0;
                          ingredHeightDetail = 0.0;
                        }
                      });

                    },
                  ),

                  Container(
                    height: ingredHeightDetail,
                    // margin: EdgeInsets.only(left: mrg, right: mrg),
                    // color: Colors.red
                    child: 
                      (ingredDetailShow == true)
                        ?
                         Card(
                          // margin: EdgeInsets.only(left: mrg, right: mrg),
                          
                          elevation: 10,
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0, top: 4.0),
                             child: ListView.builder(
                                  shrinkWrap: true,
                                  // scrollDirection: Axis.horizontal,
                                  itemCount: ingredients.length,
                                  itemBuilder: (context, idx) {
                               
                                    return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(ingredients[idx]),
                                    );
                                  }
                                ),
                           ),
                         )

                        : Container()
                    ,
                  ),


              ],)
            ),


            
            SizedBox(height: 16.0),
            Container(
              height: my_screenHeight * .60,
              // padding: const EdgeInsets.all(8),
              margin: EdgeInsets.only(left: mrg, right: mrg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    child: Container(
                      height: 40.0,
                      // width: my_screenWidth * .8,
                      padding: const EdgeInsets.all(8),
                      // margin: EdgeInsets.only(left: mrg, right: mrg),
                      decoration: const BoxDecoration(
                          color: goldColor, //    Color(0xFFe9813f),
                          borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          (Text('Directions', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600))),
                        ],
                      )
                    ),
                    onTap: () {
                      setState(() {
                        ingredDetailShow = !ingredDetailShow;
                        // this is new visibility
                        if (ingredDetailShow == true) {
                          ingredHeightAll  = my_screenHeight * .55;
                          ingredHeightDetail = ingredHeightAll - 40.0;
                        } else {
                          ingredHeightAll  = 40.0;
                          ingredHeightDetail = 0.0;
                        }
                      });
                    },
                  ),
              
                  SingleChildScrollView(
                    child: Container(
                      height: (my_screenHeight * .60) - 40.0,
                      // margin: EdgeInsets.only(left: mrg, right: mrg),
                      // color: Colors.red
                      child: 
                          
                          Card(
                          // margin: EdgeInsets.only(left: mrg, right: mrg),
                          
                          elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.only(left:8.0, top: 4.0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  // scrollDirection: Axis.horizontal,
                                  itemCount: instructions.length,
                                  itemBuilder: (context, idx) {
                                    return InstructItem(stepCount: idx + 1, stepDirection: instructions[idx]);
                                  }
                                ),
                            ),
                          )
                                
                      ,
                    ),
                  ),
              
              
              ],)
            ),

        ],),
      )
      
    );     
    
  }
}



class InstructItem extends StatelessWidget {

  final int stepCount;
  final String stepDirection;

  const InstructItem({required this.stepCount, required this.stepDirection,
      Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Text('Step ' + stepCount.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.0, color: blueColor),),
        SizedBox(height: 4.0),
        Text(stepDirection),
        SizedBox(height: 12.0),

    ],);
    
  }
}