import 'package:flutter/material.dart';
import 'package:gps/Loginscreen.dart';
import 'package:gps/Mainpages.dart';
import 'package:gps/mainform.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: loginScreen(),
    );
  }
}