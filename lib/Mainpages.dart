import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class mainPages extends StatefulWidget {
  const mainPages({super.key});

  @override
  State<mainPages> createState() => _mainPagesState();
}

class _mainPagesState extends State<mainPages> {

  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    startTracking();
  }

  /// 📍 LIVE LOCATION
  void startTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [

          /// 🗺️ REAL MAP BACKGROUND (FREE)
          FlutterMap(
            options: MapOption(
              initialCenter: currentLocation!,
              initialZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),

              /// 📍 MOVING MARKER
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation!,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.navigation,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// 🔍 SEARCH BAR
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 59,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 10),
                  Text("Search location...")
                ],
              ),
            ),
          ),

          /// 📍 CURRENT LOCATION BUTTON
          Positioned(
            bottom: 200,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () {
                // future: camera move karenge
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          /// 🚗 BOTTOM CARD (same tumhara)
          Positioned(
            bottom:1,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Center(
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          "Current Location",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Row(
                      children: [
                        Icon(Icons.flag, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          "Destination",
                          style: TextStyle(color: Colors.white70),
                        )
                      ],
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text("Start Navigation"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}