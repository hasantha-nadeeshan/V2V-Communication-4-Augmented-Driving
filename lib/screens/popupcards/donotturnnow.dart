import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:v2v_Com/constants.dart';

class showDoNotTurn extends StatelessWidget {
  const showDoNotTurn({super.key});
@override
  Widget build(BuildContext context) {
    return  Center(  
              child: 
                AlertDialog(
                  title: const Text('Don\'t turn now'),
                  content: const Text('Wait to turn'),
                  backgroundColor: Colors.red[900],
                ),
              
     
    );
  }
}