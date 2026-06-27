import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gps/Mainpages.dart';
import 'package:permission_handler/permission_handler.dart';

class Thired extends StatefulWidget {
  const Thired({super.key});

  @override
  State<Thired> createState() => _ThiredState();
}

class _ThiredState extends State<Thired> {
  bool cemeraAccess = false;
  bool LocationAccess = false;

  Future<void> requsetCemeraPermi()async{
   PermissionStatus status = await Permission.camera.request();
    setState(() {
      cemeraAccess = status.isGranted;
    });
  }

  Future<void> requsetLocationpermi()async{
    PermissionStatus status= await Permission.location.request();
  setState(() {
    LocationAccess = status.isGranted;
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: Padding(
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
             SizedBox(height: 20,),
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
                     backgroundColor: Colors.transparent,
                     child: Icon(Icons.camera_alt,
                       color: Colors.black,size: 35,),
                   ),
                   Expanded(child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         "Cemera Access",style: TextStyle(
                         fontSize: 22,
                         fontWeight: FontWeight.bold,

                       ),),
                       Text("App needs access to your cemera for capture photo & videos",style: TextStyle(
                         color: Colors.black,
                         fontSize: 15,
                       ),
                       ),
                       Switch(value: cemeraAccess,
                         activeColor: Colors.amber,
                         onChanged: (value)async{
                         await requsetCemeraPermi();
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
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.location_on,size: 50,),
                  ),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                 Text("Location Access,",style: TextStyle(
                          fontWeight: FontWeight.bold,fontSize: 20,
                      ),),
                       Text(    "App needs access to your location for display current location.",),
                      Switch(value: LocationAccess,
                          activeColor: Colors.amber,
                          onChanged: (value)async{
                       await requsetLocationpermi();
                          })
                    ],
                  )),

                ],

              ),
            ),
            Spacer(),
            Text.rich(
              TextSpan (
                  text: "By tapping Next, you agree to our ",style: TextStyle(
                  fontSize: 15
              ),
                children: [
                  TextSpan(
                    text: "Terms end Service " ,style: TextStyle(
                    color: Colors.blue
                  ),

                  ),
                  TextSpan(
                    text: "And ",style: TextStyle(
                    color: Colors.amber
                  ),
                  ),
                  TextSpan(text: "Privacy Policy ",style: TextStyle(
                    color: Colors.blue,fontSize: 15
                  ))
                ]
              ),
              textAlign: TextAlign.center,
             // textDirection: TextDirection.ltr,
            ),
           SizedBox(
             width: double.infinity,
             height:20,
           ),
            SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                      if(cemeraAccess && LocationAccess){
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>Mainpage()));
                      } else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please allow Cemera & Location permission")),
                        );
                      }// Next Screen
                  },
                  child: const Text(
                    "NEXT",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ), ),
]
      )),
    ),
    );
  }
}
