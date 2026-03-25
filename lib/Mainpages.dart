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
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    initLocation();
  }

  /// 🔥 INIT LOCATION (IMPORTANT)
  Future<void> initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 📍 Check GPS ON hai ya nahi
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("GPS OFF hai");
      return;
    }

    // 🔐 Permission check
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permission permanently denied");
      return;
    }

    /// 📍 FIRST LOCATION (IMPORTANT 🔥)
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    /// 🔄 LIVE TRACKING
    startTracking();
  }

  /// 📍 LIVE TRACKING
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

          /// 🗺️ MAP
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation!,
              initialZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),

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

          /// 📍 BUTTON
          Positioned(
            bottom: 200,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                if (currentLocation != null) {
                  mapController.move(currentLocation!, 17);
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}