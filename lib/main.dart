import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:v2v_Com/components/side_menu.dart';
import 'package:v2v_Com/screens/home/home_screen.dart';
import 'package:v2v_Com/entry_point.dart';
import 'package:v2v_Com/screens/onboding/onboding_screen.dart';
import 'package:hive/hive.dart';
import "package:hive_flutter/hive_flutter.dart";

import 'constants.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<String>('my-data');
  await Hive.openBox<String>('prev-my-data');
  await Hive.openBox<String>('dummy');
  await Hive.openBox<String>('nearby');
  await Hive.openBox<String>('prev-nearby-data');
  await Hive.openBox<String>('login');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V2V Communication',
      theme: ThemeData(
        scaffoldBackgroundColor:  Colors.white,
        primarySwatch: Colors.blue,
        fontFamily: "Intel",
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          errorStyle: TextStyle(height: 0),
          border: defaultInputBorder,
          enabledBorder: defaultInputBorder,
          focusedBorder: defaultInputBorder,
          errorBorder: defaultInputBorder,
        ),
      ),
      home:  HomeScreen(),
    );
  }
}

const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(
    color: Color(0xFFDEE3F2),
    width: 1,
  ),
);
