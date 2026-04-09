/*import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class mainPages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Free Map")),
      body:

      FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(28.6139, 77.2090), // Delhi
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(28.6139, 77.2090),
                width: 80,
                height: 80,
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),

        ],
      ),
      backgroundColor: Colors.white54,

    );
  }
}*/
import 'package:flutter/material.dart';
class Mainpages extends StatelessWidget {
  const Mainpages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Center(child: Text("GoGps ",style: TextStyle(
         fontSize: 20, backgroundColor: Colors.brown.withOpacity(0.5000), fontStyle: FontStyle.italic
        ),)),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child:
            Icon(Icons.location_on,color: Colors.red, size: 50,)),
          ],
        ),

      ),

       bottomSheet:(
           Text("shivam", style: TextStyle(
         color: Colors.black
       ),))
    );
  }
}
