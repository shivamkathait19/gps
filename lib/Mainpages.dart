
import 'package:flutter/material.dart';

class Mainpages extends StatelessWidget {
  const Mainpages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     drawer: Drawer(
       backgroundColor: Colors.black,
     ),
      body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShFjcpjTmNukIRjEMU1ltR-NAHXvqTXgTlrA&s"),
             fit: BoxFit.cover
              ),
            )
            ),
           Positioned(
             top: 50,
               left: 15,
               right: 15,
               child: Container(
                 margin: EdgeInsets.all(10),
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
             color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(30),),
                 height: 50,
                 child: Row(
                   children: [
                     Builder(builder: (context)=> IconButton(onPressed: (){
                       Scaffold.of(context).openDrawer();
                     },
                         icon: Icon(Icons.menu,color: Colors.black,))),
                    SizedBox(width: 100,),
                    Expanded(
                        child: Center(
                          child: TextField(
                            decoration: InputDecoration(
                           labelText: "Search here  ",labelStyle: TextStyle(
                              color: Colors.white
                            ),
                           border: InputBorder.none, enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                            ) ),),)),
                      Icon(Icons.mic,color: Colors.black,),

                   ],

                 ),
           ),

           ),
              Center(
                child: Icon(Icons.location_on,color: Colors.red,size: 50,),
              ),
            Positioned(
              right: 20,
              bottom: 90,
              child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () {},
                  child: Icon(Icons.my_location,size: 40,),
                ),
                 FloatingActionButton(
                   mini: true,
                   onPressed: (){},
                 child: Icon(Icons.add,size: 40,),
                 ),
                FloatingActionButton(
                  mini:  true,
                  onPressed: (){},
                child: Icon(Icons.remove,blendMode: BlendMode.modulate
                  ,),
                )
              ],
            ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
               height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical( top: Radius.circular(20)
                    ),
                    //backgroundBlendMode: BlendMode.colorDodge
                  ),
                      child: TextButton.icon(onPressed: (){},
                          icon: Icon(Icons.location_on,color: Colors.red,),
                          label: Text("your location ",style: TextStyle(
                            color: Colors.red.shade800
                          ),),),

            ))
          ],
      ),


    );
  }
}


