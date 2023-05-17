import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'dart:io';
import '../../models/dumyData.dart';
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
  int count = 0;
  int emgcount = 0;
  List<String> _data=[];
  List<String> _mydataToList = [];
  List<String> _myprevdataToList = [];
  List<String> _emgdataToList = [];
  List<String>_emgprevdataToList = [];
  double relativeDistance = 0;
  int miliseconds = 0;
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
     // final address = InternetAddress("192.168.1.35");
    //  final port = 65154;
      _socket = await RawDatagramSocket.bind("169.254.129.201", 5005);

      _socket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          print("looking for packets");
          if (datagram != null) {
            setState(() {
            //  _message = "Receiving messages...";
              DateTime now = DateTime.now();
              _message = "${String.fromCharCodes(datagram.data)},${DateTime.now().millisecondsSinceEpoch}";
              _data = splitString(_message);
            //  print(_message);
            //  print(_data);
              if(_data[0]=="my"){
                mydata.put("my",_message);
                count= count +1;
              //  print("box ekata danwa");
                _mydataToList = mydata.get("my")?.split(',').toList() ?? [];
              }
              if(count == PREVIUOS_POSITION_COUNT){
                _myprevdataToList = mydata.get('my')?.split(',').toList() ?? [];
                _emgprevdataToList = nearby.get(EMERGENCY_VEHICLE_ID)?.split(',').toList() ?? [];
                prevmydata.put('my', _myprevdataToList.join(','));
                prevnearbydata.put(EMERGENCY_VEHICLE_ID, _emgprevdataToList.join(','));
                count =0;
              }
              if(_data[0]==EMERGENCY_VEHICLE_ID){
              //  print("pita data");
                nearby.put(_data[0],_message);
                emgcount = emgcount+1;
                relativeDistance = distance(double.parse(_mydataToList[1]), double.parse(_mydataToList[2]), double.parse(_data[1]), double.parse(_data[2]));
                _emgdataToList = nearby.get(_data[0])?.split(',').toList() ?? [];
              //  print(_data);
                print("distance");
                print(relativeDistance);
              //  print("awa");
                if(_emgprevdataToList.isNotEmpty && _myprevdataToList.isNotEmpty){
                  
                  _myprevdataToList = prevmydata.get('my')?.split(',').toList() ?? [];
                  _emgprevdataToList = prevnearbydata.get(EMERGENCY_VEHICLE_ID)?.split(',').toList() ?? [];
                  _emgdataToList = nearby.get(EMERGENCY_VEHICLE_ID)?.split(',').toList() ?? [];
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
                  }
                  print("Emmergency new algo||");
                  print(emgon);
                  print("************Done**********");

                  
                }

              }
              
             
           //   print("box eken out");
            //  print(mydata.get("my"));
            //  print("ok gatta");
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
        child: SingleChildScrollView(
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
             
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: DemoPage(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
