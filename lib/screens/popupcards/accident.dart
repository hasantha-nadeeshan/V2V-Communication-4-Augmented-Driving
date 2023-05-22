import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:v2v_Com/constants.dart';

class accidentAlertShow extends StatelessWidget {
  const accidentAlertShow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
            color: backgroundColorDark,
            child: Center(  
              child: 
                AlertDialog(
                  title: const Text('Accident Ahed Alert'),
                  content: const Text('Please avoid this road'),
                  backgroundColor: Colors.yellow,
                ),
              
      ),
    );
  }
}