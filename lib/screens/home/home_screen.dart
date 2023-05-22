import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
  bool showAccident = true;
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
                if(_data[0]==EMERGENCY_VEHICLE_ID && !isUpdating){      //When emmergency data comes ans not updating loop
                  nearby.put(EMERGENCY_VEHICLE_ID,_message);
                  _mydataToList = mydata.get("my")?.split(',').toList() ?? [];
                  _emgdataToList = nearby.get(EMERGENCY_VEHICLE_ID)?.split(',').toList() ?? [];
                  _myprevdataToList = prevmydata.get('my')?.split(',').toList() ?? [];
                  _emgprevdataToList = prevnearbydata.get(EMERGENCY_VEHICLE_ID)?.split(',').toList() ?? [];
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
                      if(currentState.length >BUFFER_SIZE){
                        currentState.removeAt(0);
                      }
                      print(currentState);
                    }
                    
                    emggcount = currentState.where((item) => item == "emergency").length;
                    noemggcount = currentState.where((item) => item == "no emergency").length;

                    if(currentState.length == BUFFER_SIZE && emggcount > noemggcount){
                      showEmergency =true;
                    }
                    else{
                      showEmergency = false;
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
      body: SafeArea(
        bottom: false,
        child: showEmergency? emergencyAlertShow() : showAccident? accidentAlertShow(): SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 0, 15),
                child: Text(
                  _message,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...courses
                        .map((course) => Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: CourseCard(course: course),
                            ))
                        .toList(),
                  ],
                ),
              ),
             
               SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 child: DemoPage(),
             ),
              
              
            ],
          ),
        ),
      ),
    );
  }
}
