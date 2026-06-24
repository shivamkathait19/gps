import 'package:flutter/material.dart';
import 'package:gps/Loginscreen.dart';
import 'package:gps/Mainpages.dart';
import 'package:gps/files/second.dart';
import 'package:gps/files/thired.dart';
import 'package:gps/mainform.dart';
import 'package:gps/files/splash%20Screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
        ),
      ),
      home: Thired(),
    );
  }
}