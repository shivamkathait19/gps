import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mainpages extends StatefulWidget {
  const Mainpages({super.key});

  @override
  State<Mainpages> createState() => _MainpagesState();
}

class _MainpagesState extends State<Mainpages> {

  late GoogleMapController mapController;

  final LatLng _initialPosition = const LatLng(28.6139, 77.2090); // Delhi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [

          /// 🔥 GOOGLE MAP
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          /// 🔍 SEARCH BAR
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
              ),
              height: 50,
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(Icons.menu, color: Colors.white),
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search here...",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const Icon(Icons.mic, color: Colors.white),
                ],
              ),
            ),
          ),

          /// 📍 CENTER PIN
          const Center(
            child: Icon(Icons.location_on, color: Colors.red, size: 40),
          ),

          /// 🎯 FLOATING BUTTONS
          Positioned(
            right: 20,
            bottom: 120,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    mapController.animateCamera(
                      CameraUpdate.newLatLng(_initialPosition),
                    );
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 10),

                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    mapController.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),

                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    mapController.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          /// 📍 BOTTOM LOCATION BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.location_on, color: Colors.red),
                label: Text(
                  "Your Location",
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}