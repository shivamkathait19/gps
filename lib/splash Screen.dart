import 'package:flutter/material.dart';
 class splasgScreen extends StatelessWidget {
   const splasgScreen({super.key});
 
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text("Gogo Gps ",style: TextStyle(fontStyle: FontStyle.italic),),
         centerTitle: true,

       ),
       body: Container(
         child: Column(
           children: [
           SafeArea(child: Column(
             children: [
               Text("GOGO GPS")
             ],
           ))
           ],
         ),
       )
     );
   }
 }
 