import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import '../../models/dumyData.dart';
import '../popupcards/emergency.dart';
import '../popupcards/accident.dart';
import 'components/course_card.dart';
import 'components/secondary_course_card.dart';
import '../../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _message = "Waiting for messages...";
  String _recmsg ="";
  String emgon="";
  String accion="";
  bool showEmergency = false;
  bool showAccident = false;
  bool isUpdating = false;
  int count = 0;
  List<String> _data=[];
  List<String> _mydataToList = [];
  List<String> _myprevdataToList = [];
  List<String> _emgdataToList = [];
  List<String>_emgprevdataToList = [];
  List<String> currentState =[];
  double relativeDistance = 0;
  int miliseconds = 0;
  int emggcount =0;
  int noemggcount=0;

  File file = File(outputdir.path);

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
  
  RawDatagramSocket? _socket;
  Future<void> _startListening() async {
    try {
          _socket = await RawDatagramSocket.bind("169.254.129.201", 5005);
          Directory document = await getApplicationDocumentsDirectory();
          file = File(document.path);
          _socket!.listen((event) {
          if (event == RawSocketEvent.read) {
            final datagram = _socket!.receive();
            print("looking for packets");
            if (datagram != null) {
              setState(() {
                DateTime now = DateTime.now();
                _message = "${String.fromCharCodes(datagram.data)},${DateTime.now().millisecondsSinceEpoch}";
                _data = splitString(_message);

                if(_data[0]=="my"){             //detecting my packets
                  mydata.put("my",_message);    //adding to a box
                  count= count +1;              //increase counter
                  _mydataToList = mydata.get("my")?.split(',').toList() ?? [];
                }

                if(count == PREVIUOS_POSITION_COUNT){
                  isUpdating = true;
                  _myprevdataToList = mydata.get('my')?.split(',').toList() ?? [];
                  _emgprevdataToList = nearby.get(EMERGENCY_VEHICLE_ID)?.split(',').toList() ?? [];
                  prevmydata.put('my', _myprevdataToList.join(','));
                  prevnearbydata.put(EMERGENCY_VEHICLE_ID, _emgprevdataToList.join(','));
                  count =0;
                }
                if(_data[0]!='my' && !isUpdating){      //When emmergency data comes and not updating loop
                  nearby.put(_data[0],_message);
                  _mydataToList = mydata.get("my")?.split(',').toList() ?? [];
                  _emgdataToList = nearby.get(_data[0])?.split(',').toList() ?? [];
                  _myprevdataToList = prevmydata.get('my')?.split(',').toList() ?? [];
                  _emgprevdataToList = prevnearbydata.get(_data[0])?.split(',').toList() ?? [];
                  relativeDistance = distance(double.parse(_mydataToList[1]), double.parse(_mydataToList[2]), double.parse(_emgdataToList[1]), double.parse(_emgdataToList[2]));
                  print("distance , ${relativeDistance.toString()}");

                  if(_emgprevdataToList.isNotEmpty && _myprevdataToList.isNotEmpty){
                    print(_mydataToList);
                    print(_myprevdataToList);
                    print(_emgdataToList);
                    print(_emgprevdataToList);
                    if(relativeDistance>10){
                      emgon = emergencyAlert(
                      double.parse(_mydataToList[3]), double.parse(_emgdataToList[4]),
                      double.parse(_myprevdataToList[1]), double.parse(_myprevdataToList[2]),
                      double.parse(_emgprevdataToList[1]), double.parse(_emgprevdataToList[2]),
                      double.parse(_mydataToList[1]), double.parse(_mydataToList[2]),
                      double.parse(_emgdataToList[1]), double.parse(_emgdataToList[2])
                      );
                      accion = accidentAheadAlert(
                      double.parse(_mydataToList[3]), double.parse(_emgdataToList[4]),
                      double.parse(_myprevdataToList[1]), double.parse(_myprevdataToList[2]),
                      double.parse(_emgprevdataToList[1]), double.parse(_emgprevdataToList[2]),
                      double.parse(_mydataToList[1]), double.parse(_mydataToList[2]),
                      double.parse(_emgdataToList[1]), double.parse(_emgdataToList[2]),
                      double.parse(_emgdataToList[4])
                      );
                      currentState.add(emgon);
                      if(currentState.length == BUFFER_SIZE+1){
                        currentState.clear();
                      }
                      print(currentState);
                      emggcount = currentState.where((item) => item == "emergency").length;
                      noemggcount = currentState.where((item) => item == "no emergency").length;

                      if(currentState.length == BUFFER_SIZE && emggcount >= noemggcount){
                        print("Emergency");

                        showEmergency =true;
                      }
                      else if(currentState.length == BUFFER_SIZE && emggcount < noemggcount){
                        showEmergency = false;
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
        
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                    
                    onPressed: () {},
                    // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 12.0,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          )),
                        
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child:  Text(_message),
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
                    Text("65",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 80.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(width:30),
                    Text("limit",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                
                  child: Text("Kmph",
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                      ),
                    ),
                ),
              
                showEmergency ? emergencyAlertShow() : Text(''),

              
             
              
              
            ],
          ),
        ),
      );
    
  }
}
