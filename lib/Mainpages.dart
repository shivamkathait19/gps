
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
             top: 15,
               left: 15,
               right: 15,
               child: Container(
                 padding: EdgeInsets.symmetric(horizontal: 15),
             height: 50,
             decoration: BoxDecoration(color: Colors.white,
               borderRadius: BorderRadius.circular(30),
               boxShadow:[
                 BoxShadow(
                   color: Colors.black
                 )
               ]
             ),
                 child: Row(
                   children: [
                    Builder(builder: (context)=> IconButton(onPressed: (){}, icon:Icon(Icons.menu)))
                     ]
                 ),
           ),

           )

          ],
      ),
    );
  }
}
/*import 'package:flutter/material.dart';

class Mainpages extends StatelessWidget {
  const Mainpages({super.keyDra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.black,
      ),

      body: Stack(
        children: [
 // 🗺️ Fake Map Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://www.mysanantonio.com/business/article/Internet-Makes-Fake-Google-Maps-Location-for-16555487.php", // map style image
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔍 Search Bar (Top)
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 5)
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.menu),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Search here...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Icon(Icons.mic),
                ],
              ),
            ),
          ),

          // 📍 Center Marker
          Center(
            child: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 50,
            ),
          ),

          // 🎯 Right Side Buttons
          Positioned(
            right: 15,
            bottom: 120,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () {},
                  child: Icon(Icons.my_location),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {},
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {},
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // 📦 Bottom Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 5)
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Your Location"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

 */