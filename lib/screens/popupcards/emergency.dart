import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class emergencyAlertShow extends StatelessWidget {
  const emergencyAlertShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
            child: AlertDialog(
                            title: const Text('Emergency Alert'),
                            content: const Text('Emergency situation detected.'),
                            backgroundColor: Colors.red,
                            
                          
              
            ),
    );
  }
}
