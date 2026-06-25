import 'package:flutter/material.dart';

class Thired extends StatefulWidget {
  const Thired({super.key});

  @override
  State<Thired> createState() => _ThiredState();
}

class _ThiredState extends State<Thired> {
  bool cemeraAccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(child: Padding(
        padding:  EdgeInsets.all(20.0),
        child: Column(
          children: [
             SizedBox(height: 19,),
            Text("We need some access!" ,textAlign: TextAlign.center,style: TextStyle(
              color: Colors.amber, fontSize: 28,
            ),),
            Text("You need to grant access to the device camera."
                " Photo Library and Location to take photos ore record video", textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18,color: Colors.black, fontWeight: FontWeight.w400 ),
            ),
             Container(
               decoration: BoxDecoration(
                 color: Colors.grey,
                 borderRadius: BorderRadius.circular(16),
                 border: Border.all(
                   color: Colors.grey.shade100

                 ),
               ),
               child: Row(
                 children: [
                   CircleAvatar(
                     radius: 28,
                     backgroundColor: Colors.amber,
                     child: Icon(Icons.camera_alt,
                       color: Colors.orange,size: 32,),
                   ),
                   Expanded(child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text("Cemera Access",style: TextStyle(
                         fontSize: 22,
                         fontWeight: FontWeight.bold,

                       ),),
                       Text("App needs access to your cemera for capture photo & videos",style: TextStyle(
                         color: Colors.grey.shade600,
                         fontSize: 15,
                       ),
                       ),
                       Switch(value: cemeraAccess,
                         activeColor: Colors.amber,
                         onChanged: (value){
                         setState((){
                           cemeraAccess = value;
                         });
                         },
                       )
                     ],
                   )),

                 ],
               ),
             ),
            SizedBox(
              height: 50,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.shade600
                )
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.amber,
                    child: Icon(Icons.location_city,size: 50,),
                  ),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("Location Access,",style: TextStyle(
                          fontWeight: FontWeight.bold,fontSize: 20,
                      ),)

                    ],
                  ))

                ],
              ),
            )
           ],


      )),
    ),
    );
  }
}
