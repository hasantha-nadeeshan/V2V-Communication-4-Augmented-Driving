import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:v2v_Com/constants.dart';

class showTurnNow extends StatelessWidget {
  const showTurnNow({super.key});

   @override
  Widget build(BuildContext context) {
    return  Center(  
              child: 
                AlertDialog(
                  title: const Text('Turn Now'),
                  content: const Text('You can make a turn now'),
                  backgroundColor: Colors.green,
                ),
              
     
    );
  }
}