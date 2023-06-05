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
                Card(
          elevation: 50,
          shadowColor: Colors.black,
          color: backgroundColorDark,
          child: SizedBox(
            width: 1050,
            height: 550,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 208,
                    child: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Center(
                        child: Icon(
                          Icons.front_hand_outlined,
                          size: 200.0,),
                      ),
                           radius: 200,
                    ), //CircleAvatar
                  ), //CircleAvatar
                  const SizedBox(
                    height: 10,
                  ), //SizedBox
                   //Text
                  const SizedBox(
                    height: 10,
                  ), //SizedBox
                   //Text
                  const SizedBox(
                    height: 10,
                  ), //SizedBox
                  SizedBox(
                    width: 300,
 
                    child: ElevatedButton(
                                  onPressed: (){},
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.red),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.warning),
                                          SizedBox(width: 20.0),
                                          Text(
                                            'Don\'t Turn',
                                            style: TextStyle(
                                              fontSize: 30.0,
                                              fontWeight: FontWeight.bold,
                                            )
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                    
                  ) //SizedBox
                ],
              ), //Column
            ), //Padding
          ), //SizedBox
        ),
              
     
    );
  }
}