import 'package:flutter/material.dart';
import 'mainscreen.dart';

void main ()=> runApp(recognition());

class recognition extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.blue,
      ),
      home: mainScreen(),
    );
  }

}