import 'package:flutter/material.dart';
 class splasgScreen extends StatelessWidget {
   const splasgScreen({super.key});
 
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.grey,


       body: Container(
         child: SafeArea(
             child: Column(
           //mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Padding(
               padding: EdgeInsets.all(0.0),
               child: Padding(
                 padding:  EdgeInsets.only(left:10),
                 child: Row(
                   children: [
                     SizedBox(height: 200,),
                     Container(
                       height: 50,
                       width: 90,
                       decoration: BoxDecoration(
                         color: Colors.white24,
                         borderRadius: BorderRadius.circular(50),
                         border: Border.all(
                           color: Colors.amber,

                         ),
                       ),
                       child: Icon(Icons.location_on),
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
 