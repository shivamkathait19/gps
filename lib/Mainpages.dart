import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  File? _image;
  String locationText = "No location";
  double? lat, lng;

  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationText = "Location OFF hai";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          locationText = "Permission denied";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      lat = position.latitude;
      lng = position.longitude;

      // 🔥 Address + Pin Code
      List<Placemark> placemarks =
      await placemarkFromCoordinates(lat!, lng!);

      Placemark place = placemarks[0];

      String name = place.name ?? "";
      String street = place.street ?? "";
      String city = place.locality ?? "";
      String state = place.administrativeArea ?? "";
      String country = place.country ?? "";
      String pincode = place.postalCode ?? "";

      setState(() {
        locationText =
        "$name\n$street\n$city, $state\n$country - $pincode\n\nLat: $lat\nLng: $lng";
      });

    } catch (e) {
      setState(() {
        locationText = "Error: $e";
      });
    }
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();

    final XFile? picked =
    await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        locationText = "Getting location...";
      });

      // 🔥 location baad me lo (UI freeze nahi hoga)
      await getLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GPS Photo App"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.orange,
       drawer: Drawer(

       ),
      body: Center(
        child: _image == null
            ? const Text(
          "No Image Captured",
          style: TextStyle(color: Colors.white),
        )
            : Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(_image!),
            ),
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  locationText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: takePhoto,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}