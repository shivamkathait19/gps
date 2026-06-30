import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gps/files/second.dart';
 class splasgScreen extends StatefulWidget {
   const splasgScreen({super.key});

  @override
  State<splasgScreen> createState() => _splasgScreenState();
}

class _splasgScreenState extends State<splasgScreen>
 with TickerProviderStateMixin{
   late AnimationController _controller;

      @override
  void initState() {
    // TODO: implement initState
    super.initState();
            _controller = AnimationController(vsync: this, duration: Duration(seconds:1))..repeat(reverse: true);

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>  second(),
        ),
      );
    });

  }



   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.grey,


       body: Container(
         decoration: BoxDecoration(
           gradient: LinearGradient(
             colors: [
               Color.lerp(Colors.blueAccent, Colors.blue.shade300, _controller.value)!,
               Color.lerp(Colors.amber, Colors.yellow.shade900, _controller.value)!,
             ],
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
           ),
         ),
         child: SafeArea(
             child: Column(
           //mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Padding(
               padding: EdgeInsets.all(0.0),
               child: Padding(
                 padding:  EdgeInsets.only(left:5),
                 child: Row(
                   children: [
                     SizedBox(height: 200,),
                     Container(
                       height: 50,
                       width: 90,
                       decoration: BoxDecoration(
                         gradient: LinearGradient(
                         colors: [
                             Color.lerp(Colors.lightGreenAccent, Colors.pink, _controller.value)!,
                         Color.lerp(Colors.white, Colors.white, _controller.value)!,

                         ],
                           begin: Alignment.topLeft,
                           end: Alignment.bottomRight,
                         ),
                         color: Colors.white24,
                         borderRadius: BorderRadius.circular(50),
                         border: Border.all(
                           color: Colors.black,
                           width: 3
                         ),
                       ),
                       child: Icon(Icons.location_on,shadows: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.3),
                           blurRadius: 20,
                           spreadRadius: 3,
                           offset: Offset(0, 15),
                         ),

                       ],
                       size: 70, color: Colors.blueAccent.shade400,
                       ),
                     ),
                     Column(
                       children: [

                         Text("GOGO GPS CAMERA",style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.bold,),),
                           SizedBox(height: 3, width: 2),
                         Padding(
                           padding:EdgeInsets.only(left:5),
                           child: Text("CAPTURE PROOF, NOT JUST PHOTOS",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600,),),
                         ),

                       ],
                     ),

                   ],
                 ),

               ),
             ),

             Padding(
               padding:  EdgeInsets.only(bottom: 50),
               child: Align(
                 alignment: Alignment.centerLeft,
                 child: Text(
                   "Trusted.\nAccurate.\nAuthentic.",
                   style: TextStyle(
                     fontSize: 40,
                     fontWeight: FontWeight.bold,
                     color: Color(0xff11184D),
                     height: 1.5,
                   ),
                 ),
               ),
             ),




             Spacer(),

              Container(
                width: 40,height: 20,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle
                ),
              ),
                 SizedBox(height: 20,),
             Text("Version 1.23.5",style: TextStyle(
                fontSize: 20,
               color: Color(0xff11184D),
             ),),
 SizedBox(height: 40,)
           ],
         )),
       )

     );
   }
}
