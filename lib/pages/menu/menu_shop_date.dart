import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../admin/global_classes.dart';
import '../admin/savory_api.dart';
// import 'menu_create.dart';


class ShopDatePicker extends StatefulWidget {

  final String startShopDate;                     // if not Select - we are trying to change
  final int startStore;
  final Function (String sd, bool sameStore) menuCreatedSelect; 
  const ShopDatePicker({required this.startShopDate, required this.startStore, required this.menuCreatedSelect, Key? key}) : super(key: key);

  @override
  State<ShopDatePicker> createState() => _ShopDatePickerState();
}

class _ShopDatePickerState extends State<ShopDatePicker> {

  bool _isLoading = false;
  bool _createActive = false;

  // late GlobalVar globals;
  final HttpService httpSavory = HttpService();
  final GlobalFunctions fx = GlobalFunctions();  
  late GlobalVar globals;

  DateTime todayDate = DateTime.now();
  DateTime selectDate = DateTime.now();
  String dateTodayStr = '';
  String selectDateString = '';
  List<String> dowChoices = [];  
  int dowToday = 1;
  int dowSelected = -1;
  Map<int, String> dowMap = {1:'M',2:'T',3:'W',4:'T',5:'F',6:'S',7:'Su'};

  String selectedDate = 'Select';   
  int storeSelected = 0;

  @override
  void initState() { 
    super.initState();

    popDOWfromToday();
    startFetching();
    globals = Provider.of<GlobalVar>(context, listen: false); 
  }



  startFetching() async {

    _isLoading = true;

    // TODO -  
    // should set to current store - change storeSelected as well 
    // something like this
    // for (var s in globals.userStores) {
    //                         if (s.storeID == widget.startStore) {

    currStore.ChangeStore(1, 'Publix');

    _isLoading = false;

  }


  popDOWfromToday() {

    dowToday = todayDate.weekday;
    int dowIndex = dowToday;
    String?  dowString = 'M';
    dateTodayStr = fx.FormatDateDow(todayDate.toString()); 

    for(int i = 1; i < 8; i++){
      dowString = dowMap[dowIndex];
      dowChoices.add(dowString!);
      if (dowIndex < 7) {
        dowIndex+=1;
      } else {
        dowIndex = 1;
      }
    }
  }

  selectedDOWFunction(index) {

    print('------   selected dow -- ' + index.toString());
    // print(dowChoices[index]);

    dowSelected = index;

    setState(() {
      selectDate = todayDate.add(Duration(days: dowSelected));
      _createActive = true;
    });

    selectDateString = fx.FormatDateDow(selectDate.toString());
    selectedDate = fx.FormatDate(selectDate.toString());
    
    // print(selectDateString);
    // print(selectedDate);
  }

  
  selectedStore(index) {

    print('------   selected store  -- $index');

    currStore.ChangeStore(globals.userStores[index].storeID, globals.userStores[index].storeName);
    setState(() {
      storeSelected = index;
    });
  }



  @override
  Widget build(BuildContext context) {

    if (_isLoading) {return Center(child: CircularProgressIndicator());}

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          
          Column(
            children: [
              // InkWell(
              //   child: Text('******   boxes to pick day *****'),
              //   onTap: () {
              //     Navigator.push( context, MaterialPageRoute( builder: (context) => MenuCreate()));
              //   },
              //   ),

                Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 18.0, bottom: 6.0),
                  child: Container(
                    width: my_screenWidth - 50,
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      // separatorBuilder: (_, __) => Divider(height: 12),
                      itemCount: globals.userStores.length,
                      itemBuilder: (context, index) {
                        return StoreSelector(
                          storeOption: globals.userStores[index],
                          index: index,
                          isSelected: storeSelected == index ? true : false,
                          storeChanged: selectedStore,
                        );
                      }
                      ),
                  )
                ),

                const Padding(
                  padding: EdgeInsets.only(top: 18.0, bottom: 20.0),
                  child: Text("What Day are you Shopping?",style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                ),

                Container(
                  height:  40,
                  margin: EdgeInsets.all(8.0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: (dowChoices.length),
                      itemBuilder: (context, index) {
                        return SelectDOW(
                          selectedDOWFunction, // callback function, setstate for parent
                          index: index,
                          isSelected: dowSelected == index ? true : false,
                          title: dowChoices[index],   //index.toString(),
                          width: my_screenWidth / 10.5,
                        );
                      },
                    ),          
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(currStore.storeName + ": ", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400)),
                      Text((dateTodayStr == selectDateString) ? 'Today' : selectDateString, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800, color: Color(0xFF3CBC6D))),
                    ],
                  ),
                ),
              
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 100.0, right: 100.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // primary: (selectedDate == 'Select') ? Colors.grey : Color(0xFF3CBC6D), // background
                        primary: (selectedDate == 'Select') ? Colors.grey : Color(0xFF3CBC6D), // background
                        onPrimary: (selectedDate == 'Select') ? Colors.black : Colors.white, // foreground
                        padding: EdgeInsets.all(8.0),    
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),) 
                      ),
                      onPressed: () {
                        (_createActive == true) 
                          ? widget.menuCreatedSelect(selectedDate, widget.startStore == currStore.storeID)
                          : null;
                        _createActive = false;
                        
                      },
                      child: Text((selectedDate == widget.startShopDate && currStore.storeID == widget.startStore) ? 'Keep Menu' : 'Create Menu')),
                  ),
                ),

            ],
          ),



          // const Text("Menu Genie", style: TextStyle(fontFamily: 'Roboto', fontSize: 36.0,fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text("MenuGenie", style: TextStyle(fontFamily: 'Roboto', fontSize: 36.0,fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),),
          //     Text(".ai", style: TextStyle(fontFamily: 'Roboto', fontSize: 36.0,fontWeight: FontWeight.w600, color: Color(0xFFe9813f)),),
          //   ],
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Menu", style: TextStyle(fontFamily: 'Roboto', fontSize: 36.0,fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),),
              Text(" ", style: TextStyle(fontFamily: 'Roboto', fontSize: 8.0,fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),),
              Text("Genie", style: TextStyle(fontFamily: 'Roboto', fontSize: 36.0,fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),),
              Text(" AI", style: TextStyle(fontFamily: 'Roboto', fontSize: 36.0,fontWeight: FontWeight.w600, color: Color(0xFFe9813f)),),
            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text("MenuGenie", style: TextStyle(fontFamily: 'Roboto', fontSize: 36.0,fontWeight: FontWeight.w600, color: Color(0xFFe9813f)),),
          //     Text(".ai", style: TextStyle(fontFamily: 'Roboto', fontSize: 36.0,fontWeight: FontWeight.w600, color: Color(0xFF3CBC6D)),),
          //   ],
          // ),


          Column(
            children: [
              DefaultTextStyle(
                style: TextStyle(fontSize: 16.0, height: 1.8),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 38.0),
                  child: Column(
                    children: [
                      Text('1. Select Store & Shopping Day', 
                            style: (selectedDate != 'Select') ? TextStyle(color: Colors.black, fontWeight: FontWeight.normal) : TextStyle(color: Color(0xFF3CBC6D), fontWeight: FontWeight.bold)),
                      Text('2. Create Menu Options', 
                            style: (selectedDate == 'Select') ? TextStyle(color: Colors.black, fontWeight: FontWeight.normal) : TextStyle(color: Color(0xFF3CBC6D), fontWeight: FontWeight.bold)),
                      Text('3. Swipe your Selections', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),

              
              (widget.startShopDate == 'Select') 
                ? Container()
                : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 12.0, right: 22.0),
                        child: Text('Cancel', style: TextStyle(fontSize: 18.0, color: Colors.red),),
                      ),
                      onTap: () {
                        if (widget.startStore != currStore.storeID) {
                          // reset store to initial 
                          for (var s in globals.userStores) {
                            if (s.storeID == widget.startStore) {
                              currStore.ChangeStore(s.storeID, s.storeName);
                            }
                          }
                        }
                        widget.menuCreatedSelect(widget.startShopDate, true);
                      },
                      ),
                  ],
                )

            ],
          ),


        ],
      );


    
  }
}



// duplicate - in chop_create - should make just one of these
class StoreSelector extends StatelessWidget {

  final Store storeOption;
  final int index;
  final bool isSelected;
  final Function(int) storeChanged;

  StoreSelector({required this.storeOption,required this.index, required this.isSelected, required this.storeChanged,
    Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero, // Set this
                      // padding: EdgeInsets.zero, // and this
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),    
                      primary:  (isSelected ?  const Color(0xFF3CBC6D) : Colors.white), // background
                      onPrimary: Colors.black, // foreground  
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),) 
                    ),
                    onPressed: () {
                      storeChanged(index);
                    },
                    child:  Text(storeOption.storeName, style: TextStyle(color: isSelected ?  Colors.white : Colors.black, fontSize: 18.0)),
                ),
    );
  }
}




class SelectDOW extends StatelessWidget {
  final String title;
  final int index;
  final bool isSelected;
  final double width;
  Function(int) selectedDOWFunction;         // ** this is the callback

  SelectDOW(
    this.selectedDOWFunction, {
    Key? key,
    required this.title,
    required this.index,
    required this.isSelected,
    required this.width,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(2.0),

        child: InkWell(
          child: Container(
            width: width,
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.circular(5.0),
              color: (isSelected ?  Color(0xFF3CBC6D) : Colors.white),
            ),
            child: Center(
              child: Text("${title}",
                  style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
          ),
          onTap: () => selectedDOWFunction(index),
        )

    );
 
  }
}
