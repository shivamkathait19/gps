import 'package:flutter/material.dart';
 class splasgScreen extends StatelessWidget {
   const splasgScreen({super.key});
 
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         //title: Text("Gogo Gps ",style: TextStyle(fontStyle: FontStyle.italic),),
         centerTitle: true,

       ),
       body: Container(
         child: SafeArea(child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           //crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Padding(
               padding: EdgeInsets.all(0.0),
               child: Text("GOGO GPS CAMERA",style: TextStyle(color: Colors.black,fontSize: 30,fontWeight: FontWeight.bold),),
             ),
             Padding(
               padding: EdgeInsets.only(bottom:10),
               child: Text("Capture proof,not just photos",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w800),),
             ),
             Text("Trusted."),
             Text("Accrurate."),
             Text("Authentic.")

           ],
         )),
       )
     );
   }
 }
 