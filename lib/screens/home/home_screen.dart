import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:v2v_Com/screens/popupcards/gonnaturn.dart';
import 'package:v2v_Com/screens/popupcards/overtakewarning.dart';
import 'dart:async';
import 'dart:io';
import '../../models/dumyData.dart';
import '../popupcards/donotturnnow.dart';
import '../popupcards/emergency.dart';
import '../popupcards/accident.dart';
import '../popupcards/turnnow.dart';
import 'components/course_card.dart';
import 'components/secondary_course_card.dart';
import '../../constants.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  double heading = 0;
  String _message = "Waiting for messages...";
  bool isUpdating = false;
  int count = 0;
  int turntrig =0;
  double heading_right_turn = 0;
  String emgon="";
  String accion="";
  String mySpeed = '0';
  bool showEmergency = false;
  bool showAccident = false;
  

  List<String> _data=[];
  List<String> _mydataToList = [];
  List<String> _myprevdataToList = [];
  List<String> _neardataToList = [];
  List<String>_nearprevdataToList = [];
  List<String> currentState =[];
  List<String> nearVehicles =[];

  List<String> _emgdataToList = [];
  List<String>_emgprevdataToList = [];
  List<String> currentEmgState =[];
  List<String> currentAcciState = [];

  double relativeDistance = 0;
  int miliseconds = 0;
  int emggcount =0;
  int noemggcount=0;


  int accicount =0;
  int noaccicount =0;
  

  bool isPossibleToTurn = false;

  bool isRightTurnOn = false;

  bool isSomeOneGonnaTurn = false;

  

  late Box<String> mydata;
  late Box<String> prevmydata;
  late Box<String> dummydata;
  late Box<String> nearby;
  late Box<String> prevnearbydata;

  @override
  void initState() {
    super.initState();
    _startListening();
    mydata = Hive.box<String>('my-data');
    nearby = Hive.box<String>('nearby');
    prevmydata = Hive.box<String>('prev-my-data');
    prevnearbydata = Hive.box<String>('prev-nearby-data');
  }
  void wantToRightTurn(){
    setState(() {
    isRightTurnOn = true;
    turntrig =1;
  });
    print("turn state"+isRightTurnOn.toString());
  }

  
  RawDatagramSocket? _socket;
  Future<void> _startListening() async {
    try {
          _socket = await RawDatagramSocket.bind("169.254.129.201", 5005);
    
          _socket!.listen((event) {
          if (event == RawSocketEvent.read) {
            final datagram = _socket!.receive();
            print("looking for packets");
            if (datagram != null) {
              setState(() {
                _message = "${String.fromCharCodes(datagram.data)},${DateTime.now().millisecondsSinceEpoch}";
                _data = splitString(_message);

                if(_data[0]=="my"){             //detecting my packets
                  mydata.put("my",_message);    //adding to a box
                  count= count +1;              //increase counter
                  _mydataToList = mydata.get("my")?.split(',').toList() ?? [];
                }
                if(_data[0]!="my"){
                  print('updating nearby data');
                  nearby.put(_data[0],_message);
                  if(!nearVehicles.contains(_data[0])){
                    nearVehicles.add(_data[0]);
                  }
                  
                }

                
                List<String> itemsToRemove = [];

                if(nearVehicles.isEmpty){
                  isSomeOneGonnaTurn = false;
                  

                }
                if(nearVehicles.isNotEmpty ){
                  for (var key in nearVehicles) {
                  List<String> _templist = nearby.get(key)?.split(',').toList() ?? [];
                  int? millisecondsSinceEpoch = int.tryParse(_templist[5]);

                    if (millisecondsSinceEpoch != null) {
                      DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
                      Duration diff = timestamp.difference(DateTime.now());
                      
                      if (-1*diff.inMinutes > 1) {
                        
                        itemsToRemove.add(key);
                      }
                    }
                  }
                  // Remove the items after the iteration is complete
                  nearVehicles.removeWhere((item) => itemsToRemove.contains(item));
                  print(nearVehicles.join(','));
                

                
                  
                }
                

                if(count == PREVIUOS_POSITION_COUNT){
                  isUpdating = true;
                  _myprevdataToList = mydata.get('my')?.split(',').toList() ?? [];
                  prevmydata.put('my', _myprevdataToList.join(','));
                  _emgprevdataToList = nearby.get(EMERGENCY_VEHICLE_ID)?.split(',').toList() ?? [];
                  prevnearbydata.put(EMERGENCY_VEHICLE_ID, _emgprevdataToList.join(','));
                  for(var key in nearby.keys){
                    
                    _nearprevdataToList = nearby.get(key)?.split(',').toList() ?? [];
                    prevnearbydata.put(key, _nearprevdataToList.join(',') );
                  }
                  count =0;
                }

                
                
                if(isRightTurnOn){   //now going to take a turn
                  if(turntrig == 1){
                    heading_right_turn =double.parse( _myprevdataToList[4]);
                    turntrig = 0;
                  }
                  if(_myprevdataToList.isNotEmpty && separateLanes(double.parse(_mydataToList[4]), heading_right_turn)=="same"){
                    if(nearVehicles.isEmpty){
                      print("No near by vehicales can turn");
                      isPossibleToTurn = true;
                    }
                    else{
                      print("we have near by vehicalse");
                      String nearKey ='';
                      double minDistance= double.infinity;
                      double tempDistance = 0;
                      List<String> _tempneardatalist=[];
                      for(var key in nearby.keys){
                        print("now checking "+key);
                        _mydataToList = mydata.get("my")?.split(',').toList() ?? [];
                        _myprevdataToList = prevmydata.get("my")?.split(',').toList() ?? [];
                        _tempneardatalist = nearby.get(key)?.split(',').toList() ?? [];
                        if(separateLanes(double.parse(_mydataToList[4]), double.parse(_tempneardatalist[3]))=="same"){     ///checking different lanes
                          print("heading is different, different lanes discard");
                          print(_mydataToList.join(','));
                          print(_tempneardatalist.join(','));
                          
                        }
                        else{
                          print('heading is ok');
                          List<String> _tempnearprevdatalist = prevnearbydata.get(key)?.split(',').toList()??[];
                          print(_tempnearprevdatalist.join(','));
                          if(_tempnearprevdatalist.isNotEmpty){
                            print("going to check infront or behind");

                            print(_mydataToList.join(','));
                            print(_myprevdataToList.join(','));
                            print(_tempneardatalist.join(','));
                            print(_tempnearprevdatalist.join(','));
                            if(inFrontBehindDifferent(double.parse(_myprevdataToList[1]), double.parse(_myprevdataToList[2]), double.parse(_tempnearprevdatalist[1]),double.parse( _tempnearprevdatalist[2]), double.parse(_mydataToList[1]), double.parse(_mydataToList[2]), double.parse(_tempneardatalist[1]),double.parse( _tempneardatalist[2]))=='infront'){
                              tempDistance = distance(double.parse(_mydataToList[1]), double.parse(_mydataToList[2]), double.parse(_tempneardatalist[1]), double.parse(_tempneardatalist[2]));
                              print("distance to near vehicle "+tempDistance.toString());
                              if(tempDistance< minDistance){
                                minDistance = tempDistance;
                                nearKey = key;
                              }
                            }
                          }
                          
                        }
                      
                        print("nearby key "+nearKey);
                        
                        
                        
                      }

                      if(nearKey == ""){
                        isPossibleToTurn = true;
                        print("You can turn now no obstcale vehicles");
                      }
                      else{
                        _neardataToList = nearby.get(nearKey)?.split(',').toList() ?? [];
                        _nearprevdataToList = prevnearbydata.get(nearKey)?.split(',').toList() ?? [];

                        isPossibleToTurn = possibleToRightTurn(double.parse(_myprevdataToList[1]), double.parse(_myprevdataToList[2]), 
                        double.parse(_nearprevdataToList[1]),double.parse( _nearprevdataToList[2]), 
                        double.parse(_mydataToList[1]), double.parse(_mydataToList[2]), double.parse( _mydataToList[3]),
                        double.parse(_neardataToList[1]),double.parse( _neardataToList[2]), double.parse( _neardataToList[4]));
                        if(isPossibleToTurn){
                          print("You can turn now incoming vehicle is gonna stop");
                        }
                        else{
                          print("can not turn");
                        }
                      }
                      print("*****************************************");

                      
                    }
                  }
                  else{
                    isRightTurnOn = false;
                  }
                
                }
               
                if(_data[0]==EMERGENCY_VEHICLE_ID && !isUpdating && !isRightTurnOn){      //When emmergency data comes and not updating loop
                  nearby.put(_data[0],_message);
                  _mydataToList = mydata.get("my")?.split(',').toList() ?? [];
                  _emgdataToList = nearby.get(EMERGENCY_VEHICLE_ID)?.split(',').toList() ?? [];
                  _myprevdataToList = prevmydata.get('my')?.split(',').toList() ?? [];
                  _emgprevdataToList = prevnearbydata.get(EMERGENCY_VEHICLE_ID)?.split(',').toList() ?? [];
                  relativeDistance = distance(double.parse(_mydataToList[1]), double.parse(_mydataToList[2]), double.parse(_emgdataToList[1]), double.parse(_emgdataToList[2]));
                  print("distance , ${relativeDistance.toString()}");

                  if(_emgprevdataToList.isNotEmpty && _myprevdataToList.isNotEmpty){
                    // String inter ="";
                    // inter = intersection(double.parse(_mydataToList[4]), double.parse(_emgdataToList[3]),
                    //    double.parse(_myprevdataToList[1]), double.parse(_myprevdataToList[2]),
                    //    double.parse(_emgprevdataToList[1]), double.parse(_emgprevdataToList[2]),
                    //  double.parse(_mydataToList[1]), double.parse(_mydataToList[2]),
                    //    double.parse(_emgdataToList[1]), double.parse(_emgdataToList[2]));
                    // print(inter);
                     print(_mydataToList);
                     print(_myprevdataToList);
                     print(_emgdataToList);
                     print(_emgprevdataToList);
                    if(relativeDistance>6){
                      emgon = emergencyAlert(
                      double.parse(_mydataToList[4]), double.parse(_emgdataToList[3]),
                      double.parse(_myprevdataToList[1]), double.parse(_myprevdataToList[2]),
                      double.parse(_emgprevdataToList[1]), double.parse(_emgprevdataToList[2]),
                      double.parse(_mydataToList[1]), double.parse(_mydataToList[2]),
                      double.parse(_emgdataToList[1]), double.parse(_emgdataToList[2])
                      );
                      accion = accidentAheadAlert(
                      double.parse(_mydataToList[4]), double.parse(_emgdataToList[3]),
                      double.parse(_myprevdataToList[1]), double.parse(_myprevdataToList[2]),
                      double.parse(_emgprevdataToList[1]), double.parse(_emgprevdataToList[2]),
                      double.parse(_mydataToList[1]), double.parse(_mydataToList[2]),
                      double.parse(_emgdataToList[1]), double.parse(_emgdataToList[2]),
                      double.parse(_emgdataToList[4])
                      );
                      currentEmgState.add(emgon);
                      currentAcciState.add(accion);
                      if(currentEmgState.length == BUFFER_SIZE+1){
                        currentEmgState.clear();
                      }
                      if(currentAcciState.length == BUFFER_SIZE+1){
                        currentAcciState.clear();
                      }
                      print(currentEmgState);
                      print(currentAcciState);
                      emggcount = currentEmgState.where((item) => item == "emergency").length;
                      noemggcount = currentEmgState.where((item) => item == "no emergency").length;
                      accicount = currentAcciState.where((item) => item == "accident").length;
                      noaccicount = currentAcciState.where((item) => item == "no accident").length;

                      if(currentEmgState.length == BUFFER_SIZE && emggcount >= noemggcount){
                        print("Emergency");

                        showEmergency =true;
                        showAccident = false;
                      }
                      if(currentAcciState.length == BUFFER_SIZE && accicount >= noaccicount){
                        print('accident');
                        showAccident =true;
                        showEmergency = false;
                      }
                    
                      if(currentEmgState.length == BUFFER_SIZE && emggcount < noemggcount){
                        showEmergency = false;
                        currentEmgState.clear();
                      }

                      if(currentAcciState.length == BUFFER_SIZE && accicount < noaccicount){
                        print('no accident');
                        showAccident = false;
                        currentAcciState.clear();
                      }
                    }
                    
                    
                    print("************Done**********");  
                  }
                
                }
                
                isUpdating = false;
            
              });
            }
          }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _socket?.close();
  }
  @override
Widget build(BuildContext context) {
 

  return Scaffold(
    backgroundColor: ThemeClass.darkTheme.scaffoldBackgroundColor,
    body: SafeArea(
      bottom: false,
      child: Container(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 12.0,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(_message),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.speed_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 30),
                      Text(
                        _mydataToList.isNotEmpty
                            ? (double.parse(_mydataToList[3]) * 0.1).toInt().toString()
                            : '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 80.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Text(
                        "limit",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    "Kmph",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
              //  isRightTurnOn && isPossibleToTurn ? showTurnNow() : isRightTurnOn && !isPossibleToTurn ? showDoNotTurn() : Text(''),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: ElevatedButton(
                            child: Text('<---'),
                            onPressed: () {},
                          ),
                        ),
                      ),

                     
                      
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: Image.asset(
                            
                              "assets/newimg/car.png",
                              scale:0.8,
                            ),
                          ),
                        ),
                      
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: ElevatedButton(
                            child: Text('--->'),
                            onPressed: wantToRightTurn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                          padding: const EdgeInsets.all(45),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/newimg/cadrant.png',
                                scale: 1.5,  
                              ),
                              Transform.rotate(
                                angle: ((_mydataToList.isNotEmpty
                            ? (double.parse(_mydataToList[4]) * 0.1).toInt()
                            : 0)*(pi/180)*-1),
                                child: Image.asset(
                                  'assets/newimg/compass.png',
                                  scale: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
            Positioned.fill(

              child: Align(
                alignment: Alignment.center,
                child: isRightTurnOn && isPossibleToTurn ? showTurnNow() : 
                      isRightTurnOn && !isPossibleToTurn ? showDoNotTurn() : 
                  //    isSomeOneGonnaTurn ? showSomeOneGonnaTurn() : 
                      showEmergency ? emergencyAlertShow() : 
                      showAccident ? accidentAlertShow()
                      : Text(''),
               
              )
               
            ),
          ],
        ),
      ),
    ),
  );
}
}





