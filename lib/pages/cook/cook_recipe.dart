


import 'package:flutter/material.dart';
import 'dart:math';

import '../admin/global_classes.dart';




class CookRecipe extends StatefulWidget {

  final String recp_name;
  Map<String, dynamic> recipe = {};
  final int servingsCooking;
  final String sentFrom;
  CookRecipe({required this.recp_name, required this.recipe, required this.servingsCooking, required this.sentFrom,
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

  // recipe is what is in the database, cooking is what user selected
  int servingRecipe = 1;
  int servingCooking = 1;
  double servingAdjust = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    populateLocals();
  }

  populateLocals() {

    recipe = widget.recipe;
    servingCooking = widget.servingsCooking;

    
    ingredients = (recipe['recp_json']['recipe']['ingredients']);
    instructions = (recipe['recp_json']['recipe']['instructions']);
    servingRecipe = (recipe['recp_json']['recipe']['servings']);

    servingAdjust = (servingCooking / servingRecipe);
    // servingAdjust = double.parse((servingCooking / servingRecipe).toStringAsFixed(0));

    // print('recipe:  $servingRecipe');
    // print('cooking: $servingCooking');
    // print('adjust:  $servingAdjust');
    // // print(recipe);

    if (widget.sentFrom == 'menu') {
      ingredDetailShow = true;
      ingredHeightAll  = my_screenHeight * .55;
      ingredHeightDetail = ingredHeightAll - 40.0;
    }
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
                                      // child: Text(ingredients[idx]),
                                      child: Text((servingAdjust == 1.0) ? ingredients[idx] : convertToCookingServing(ingredients[idx], servingAdjust)),
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
                                    // print('Step ' + (idx + 1).toString());
                                    // print(instructions[idx]);
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

  convertToCookingServing(String ingredient, double adjust) {

    // Regular expression to match numbers including fractions
    // final regExp = RegExp(r'^(\d+(\s*\d+/\d+)?|\d+/\d+|\d+)');       // sometimes separated 2 1/2 to '2 1' & '/2' - seeing a space
    // final regExp = RegExp(r'^\s*(\d+(\s*\d+/\d+)?|\d+/\d+|\d+)\s*');
    final regExp = RegExp(r'^(\d+/\d+|\d+)');


    // Find the numeric part
    final match = regExp.firstMatch(ingredient);

    if (match != null) {
      String numberPart = match.group(0)!.trim();
      String restOfDescription = ingredient.substring(match.end).trim();

      // Convert the numeric part (handles fractions)
      double numericValue = _convertToDouble(numberPart);

      // Multiply by the factor
      double newNumericValue = numericValue * adjust;

      // Convert the new numeric value back to a string (handling fractions)
      String newNumberPart = _convertToFractionOrWhole(newNumericValue);

      // Rebuild the string with the new number
      return '$newNumberPart $restOfDescription';
    }

    // If no number is found, return the original string
    return ingredient;
  }


  double _convertToDouble(String numberPart) {
    if (numberPart.contains('/')) {
      // Handle fractions like "1/2"
      List<String> fractionParts = numberPart.split('/');
      double numerator = double.parse(fractionParts[0].trim());
      double denominator = double.parse(fractionParts[1].trim());
      return numerator / denominator;
    } else {
      // Handle whole numbers
      return double.parse(numberPart);
    }
  }

  String _convertToFractionOrWhole(double value) {

    // If the number is a whole number, return it without decimal places
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    } else {
      // Otherwise, convert to a fraction (or leave as a decimal if desired)
      String fractionResult = value.toStringAsFixed(2);   // default 

      // current doing both to 1/4 - which is good for now
      if (value < 1.0) {
        // want to the 1/8th fraction
        fractionResult = convertToFraction(value, 'high');
      } else {
        // only want by 1/2
        fractionResult = convertToFraction(value, 'med');
        // print(fractionResult); // Output: "1 1/4"
      }

      return fractionResult;
    }
  }


  // Function to convert a double to a fraction string rounded to the nearest 1/2
  String convertToFraction(double value, String precision) {

    // Split the number into its integer and fractional parts
    int wholePart = value.floor();
    double fractionalPart = value - wholePart;

    // Find the nearest fraction to the fractional part
    String fraction = _getNearestFraction(fractionalPart, precision);

    // If the fraction is "0", return only the whole part
    if (fraction == "0") {
      return wholePart.toString();
    } else if (wholePart == 0) {
      // If the whole part is 0, return only the fraction
      return fraction;
    } else {
      // Combine the whole part with the fraction
      if (fraction == "1") {
        wholePart +=1;
        return wholePart.toString();
      }
      return "$wholePart $fraction";
    }
  }

  // Helper function to round the fractional part to the nearest 1/2
  String _getNearestFraction(double fractionalPart, String precision) {

    // Define possible fractions (denominators of 2)
    List<double> fractionValues;
    List<String> fractionStrings;

    if (precision == 'high') {
        fractionValues = [0, 0.25, 0.5, 0.75, 1.0];
        fractionStrings = ["0", "1/4", "1/2", "3/4", "1"];
    } else {
      // right now just medium - so going to nearest 1/2  - low will be to full
        fractionValues = [0, 0.5, 1.0];
        fractionStrings = ["0", "1/2", "1"];
    }

    // Find the closest match
    double closestFraction = fractionValues.reduce((a, b) =>
        (fractionalPart - a).abs() < (fractionalPart - b).abs() ? a : b);

    // Return the corresponding fraction string
    return fractionStrings[fractionValues.indexOf(closestFraction)];
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