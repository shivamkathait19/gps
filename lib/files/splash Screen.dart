import 'package:flutter/material.dart';
 class splasgScreen extends StatelessWidget {
   const splasgScreen({super.key});
 
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.grey,
       appBar: AppBar(
         //title: Text("Gogo Gps ",style: TextStyle(fontStyle: FontStyle.italic),),
         centerTitle: true,

       ),
       body: Container(

         child: SafeArea(
             child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           //crossAxisAlignment: CrossAxisAlignment.start,
           children: [

             Padding(
               padding: EdgeInsets.all(0.0),
               child: Padding(
                 padding:  EdgeInsets.only(left: 30),
                 child: Row(
                   children: [

                     Container(
                       height: 50,
                       width: 90,
                       color: Colors.black,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle
                       ),

                     ),
                     SizedBox(width: 10,),
                     Column(
                       children: [
                         Text("GOGO GPS CAMERA",style: TextStyle(color: Colors.black,fontSize: 26,fontWeight: FontWeight.bold,),),
                           SizedBox(height: 2,),
                         Text("CAPTURE PROOF, NOT JUST PHOTOS",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,),),

                       ],
                     ),

                   ],
                 ),
               ),
             ),
               SizedBox(height: 20,),
             Padding(
               padding:  EdgeInsets.only(right:200),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text("TRUSTED.",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                     Text("ACCUURATE.",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                     Text("AUTHENTIC.",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)) ]
                  ),
             ),
                  Text("Version 12.1")

           ],
         )),
       )
         
     );
   }
 }
 