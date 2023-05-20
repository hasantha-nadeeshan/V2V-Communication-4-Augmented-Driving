import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:v2v_Com/constants.dart';

class emergencyAlertShow extends StatelessWidget {
  const emergencyAlertShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
            color: backgroundColorDark,
            child: Center(  
              child: 
                AlertDialog(
                  title: const Text('Emergency Alert'),
                  content: const Text('Emergency situation detected.'),
                  backgroundColor: Colors.red,
                ),
              
      ),
    );
  }
}
