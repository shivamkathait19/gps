import 'package:flutter/material.dart';

class Thired extends StatelessWidget {
  const Thired({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(child: Column(
        children: [

          Text("We need some access!" ,textAlign: TextAlign.center,style: TextStyle(
            color: Colors.amber, fontSize: 32,
          ),),
          Text("You need to grant access to the device camera."
              " Photo Library and Location to take photos ore record video", textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18,color: Colors.black, fontWeight: FontWeight.bold ),
          ),

          
        ],
      )),
    );
  }
}
