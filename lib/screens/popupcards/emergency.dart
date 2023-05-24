import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:v2v_Com/constants.dart';

class emergencyAlertShow extends StatelessWidget {
  const emergencyAlertShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
            Container(
           
            child: Center(  
              child: 
                AlertDialog(
                  title: const Text('Emergency Vehicle'),
                  content: const Text('Notification'),
                  backgroundColor: Colors.red,
                ),
              
      ),
    );
  }
}
