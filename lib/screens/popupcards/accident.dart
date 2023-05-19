import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class accidentShow extends StatelessWidget {
  const accidentShow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
            child: AlertDialog(
                            title: const Text('Accident Ahead'),
                            content: const Text('Accident Ahead, Please avoid.'),
                            backgroundColor: Colors.yellow,
                            
                          
              
            ),
    );
  }
}