



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../admin/global_classes.dart';
import '../admin/savory_api.dart';




class SaveMonthly extends StatefulWidget {
  const SaveMonthly({Key? key}) : super(key: key);

  @override
  State<SaveMonthly> createState() => _SaveMonthlyState();
}

class _SaveMonthlyState extends State<SaveMonthly> {

  bool _isLoading = false;  

  late GlobalVar globals;
  final HttpService httpSavory = HttpService();
  final GlobalFunctions fx = GlobalFunctions();  

  final double _sliderMargin = 90.0;
  bool _sliderLeft = false;

  String timeSpan = 'monthly';
  List<dynamic> saveBySpan = [];
  int _selectedSpan = -1;

  @override
    void initState() { 

      globals = Provider.of<GlobalVar>(context, listen: false);
      super.initState();
      startFetching();
      // testForOpeningDirection();
  }

  @override
  void dispose() {
    // checkForChanges(globals.activeMenu['commit_status']);
    super.dispose();
  } 

  startFetching() async {

    _isLoading = true;

    saveBySpan = await httpSavory.getSavingsSpan(timeSpan, "-1");   // -1 for all stores


    // saveBySpan = [
    //     {
    //         "span": "January",
    //         "items": "6",
    //         "savings": "22.35",
    //         "total": "30.15",
    //         "bydate": [
    //             {
    //                 "date": "Jan 20",
    //                 "store": "Publix",
    //                 "savings": "10.35"
    //             },
    //             {
    //                 "date": "Jan 27",
    //                 "store": "Fresh Market",
    //                 "savings": "12.35"
    //             }
    //         ]
    //     },
    //     {
    //         "span": "February",  
    //         "items": "10",
    //         "savings": "31.00",
    //         "total": "50.88",
    //         "bydate": [
    //             {
    //                 "date": "Jan 20",
    //                 "store": "Publix",
    //                 "savings": "10.35"
    //             },
    //             {
    //                 "date": "Jan 27",
    //                 "store": "Fresh Market",
    //                 "savings": "12.35"
    //             }
    //         ]
    //     }
    // ];


    // saveBySpan = [];


    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    testForOpeningDirection();

  }

  testForOpeningDirection() {

    if (saveBySpan.isEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() { _sliderLeft = true; });
      });
    } 
  }



  spanSelected(int index) {

    _selectedSpan = index;

    setState(() {});

  }


  @override
  Widget build(BuildContext context) {

    if (_isLoading) {return const Center(child: CircularProgressIndicator());}

    return Scaffold(
      appBar: AppBar(       
        // title: Center(child: Text("Monthly Savings", style: TextStyle(color: Colors.white),)),
        title: Center(child: Text(fx.toLowerCaseButFirst(timeSpan) + " Savings", style: TextStyle(color: Colors.white),)),
       
      ),

      body: Stack(
        children: [


              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       SizedBox(width: 30.0,),
                  //       Text(timeSpan.toUpperCase()),
                  //       Text('Savings')
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: 30.0),
            
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 0.0, bottom: 18.0),
                    child: Container(
                      // width: my_screenWidth - 50,
                      height: my_screenHeight * .6,
                      child: ListView.builder(
                        // scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        // separatorBuilder: (_, __) => Divider(height: 12),
                        itemCount: saveBySpan.length,
                        itemBuilder: (context, index) {
                          return SavePanel(
                            saveSpan: saveBySpan[index],
                            index: index,
                            isSelected: _selectedSpan == index ? true : false,
                            spanChanged: spanSelected,
                          );
                        }
                        ),
                    )
                  ),
                ],
              ),



              AnimatedPositioned(
                top:  (my_screenHeight - my_screenDisplay) / 2,
                left: _sliderLeft ? (_sliderMargin / 2) : (my_screenWidth + 80.0),
                duration: const Duration(milliseconds: 500),
                child: Container(
                  height: my_screenDisplay * .75,
                  width: my_screenWidth - _sliderMargin,  
                  decoration: BoxDecoration(
                    color: Colors.white,    
                    borderRadius: const BorderRadius.all(Radius.circular(10)) ,
                    border: Border.all(
                      width: 4,
                      color: blueColor,
                    ),
                  ),                 
                  // color: Colors.blue,
                
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('How it Works?', style: TextStyle(fontSize: 22.0,color: blueColor),),
                      ),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('1. Create your', style: TextStyle(fontSize: 20.0),),
                                Text(' Menu', style: TextStyle(fontFamily: 'Roboto', fontSize: 26.0,fontWeight: FontWeight.w600, color: blueColor),)
                              ],
                            ),
                            const SizedBox(height: 16.0),


                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('2.', style: TextStyle(fontSize: 20.0),),
                                Text(' Shop', style: TextStyle(fontFamily: 'Roboto', fontSize: 26.0,fontWeight: FontWeight.w600, color: blueColor),),
                                Text(' for Deals', style: TextStyle(fontSize: 20.0),),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('3.', style: TextStyle(fontSize: 20.0),),
                                Text(' Save', style: TextStyle(fontFamily: 'Roboto', fontSize: 26.0,fontWeight: FontWeight.w600, color: blueColor),),
                                Text(" \$100's", style: TextStyle(fontSize: 20.0),),
                              ],
                            ),
                            // SizedBox(height: 16.0),
                            


                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          
                          children: const [
                            Icon(Icons.shopping_cart, color: goldColor,),
                            SizedBox(width: 16.0,),
                            Text('Confirm Shopping\nto View Savings', style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w600, color:goldColor), textAlign: TextAlign.center,),
                          ],
                        ), // Color(0xFFe9813f)),),
                        // child: Text('Start Saving from Menu Tab', style: TextStyle(fontSize: 16.0,color: Color(0xFFe9813f)),),
                      ),

                      // InkWell(child: Padding(
                      //   padding: const EdgeInsets.only(bottom: 8.0, right: 12.0),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       Text('Got it', style: const TextStyle(fontSize: 16.0,color: Color(0xFFe9813f)),),
                      //     ],
                      //   ),
                      // ),
                      //   onTap: () {
                      //     setState(() {
                      //       _sliderLeft = false;
                      //     });
                      //     },
                      // )
                    ],
                  )

                ),
              ),

        ] 
              )
    
    );


  }
}




class SavePanel extends StatefulWidget {

  final Map<String, dynamic> saveSpan;
  final int index;
  final bool isSelected;
  final Function(int) spanChanged;

  SavePanel({required this.saveSpan,required this.index, required this.isSelected, required this.spanChanged,
    Key? key}) : super(key: key);

  @override
  State<SavePanel> createState() => _SavePanelState();
}

class _SavePanelState extends State<SavePanel> {
  bool hideBydate = true;

  List<dynamic> bydate = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    populateBydate();
  }

  populateBydate() {
    // print(widget.saveSpan['bydate']);
    // print(widget.saveSpan['bydate'][0]);
    // print(widget.saveSpan['bydate'][0]['store']);
    bydate = widget.saveSpan['bydate'];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: InkWell(
        child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: blueColor, width: 4.0),
                        borderRadius: BorderRadius.circular(10),
                        ),
                      margin: EdgeInsets.only(top: (widget.index == 0 ) ? 10 : 30, right:30, left: 30),
                      
                      // onPressed: () {
                      //   // storeChanged(index);
                      // },
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        child:  Column(
                          children: [
                            Text(widget.saveSpan['span'], style: TextStyle(color: Colors.black, fontSize: 20.0)),

                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // SizedBox(width: 50.0,),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child:  Row(
                                  children: [
                                    Text(bydate.length.toString(), style: TextStyle(color: Colors.black, fontSize: 16.0)),
                                    Text(' trip', style: TextStyle(color: Colors.black, fontSize: 16.0)),
                                    Text((bydate.length > 1) ?'s' :'', style: TextStyle(color: Colors.black, fontSize: 16.0)),
                                  ],
                                ),
                                ),
                                Row(
                                  children: [
                                    Text(widget.saveSpan['items'].toString(), style: TextStyle(color: Colors.black, fontSize: 16.0)),
                                    Text(' items', style: TextStyle(color: Colors.black, fontSize: 16.0)),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Row(
                                    children: [
                                      Text('\$ ', style: TextStyle(fontWeight: FontWeight.w600, color: blueColor, fontSize: 20.0)),
                                      Text(widget.saveSpan['savings'].toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, color: blueColor, fontSize: 20.0)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.0),
                          
               
                          (hideBydate == true)
                            ? Container()
                            : 
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 18.0, bottom: 6.0),
                                child: Container(
                                  // width: my_screenWidth - 50,
                                  height: bydate.length * 20,
                                  child: ListView.builder(
                                    // scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    // separatorBuilder: (_, __) => Divider(height: 12),
                                    itemCount: bydate.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 2.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(bydate[index]['date']),
                                            Text(bydate[index]['store']),
                                            Text(bydate[index]['savings'].toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0,color: blueColor),),
                                          ],
                                        ),
                                      );
                                      // return SavePanel(
                                      //   saveSpan: saveBySpan[index],
                                      //   index: index,
                                      //   isSelected: _selectedSpan == index ? true : false,
                                      //   spanChanged: spanSelected,
                                      // );
                                    }
                                    ),
                                )
                              ),           
                          
                          ],

                        ),
                        
                      )

                
                      
                  ),
                  onTap: () {
                    // widget.spanChanged(widget.index);

                    setState(() {
                      hideBydate = !hideBydate;
                    });
                    
                  },
      ),
    );
  }
}
