import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import '../../models/dumyData.dart';
import 'components/course_card.dart';
import 'components/secondary_course_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _message = "Waiting for messages...";
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
              _message = "Received message: ${String.fromCharCodes(datagram.data)}";
              print(_message);
            });
          }
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }
    @override
  void initState() {
    super.initState();
    _startListening();
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
