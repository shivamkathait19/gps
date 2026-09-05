import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gps/files/Mainpages.dart';
import 'package:permission_handler/permission_handler.dart';

class Thired extends StatefulWidget {
  const Thired({super.key});

  @override
  State<Thired> createState() => _ThiredState();
}

class _ThiredState extends State<Thired> {
  bool cameraAccess = false;
  bool locationAccess = false;

  Future<void> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    setState(() {
      cameraAccess = status.isGranted;
    });
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    setState(() {
      locationAccess = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withOpacity(.25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(.12),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.security, color: Colors.blue, size: 20),
                    SizedBox(height: 10),
                    Text(
                      "Permissions Required",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Please allow Camera and Location permissions to capture GPS-enabled photos.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffEAF6FF),
                      Color(0xffD6EFFF),
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                        size: 35,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Camera Access",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "App needs access to your camera for capture photo & videos",
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          Switch(
                            value: cameraAccess,
                            activeColor: Colors.blue.shade200,
                            onChanged: (value) async {
                              await requestCameraPermission();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffEAF6FF),
                      Color(0xffD6EFFF),
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    //color: Colors.grey.shade600
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.location_on,
                        size: 50,
                        color: Colors.red.shade200,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Location Access,",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            "App needs access to your location for display current location.",
                          ),
                          Switch(
                            value: locationAccess,
                            activeColor: Colors.amber,
                            onChanged: (value) async {
                              await requestLocationPermission();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Text.rich(
                TextSpan(
                  text: "By tapping Next, you agree to our ",
                  style: TextStyle(fontSize: 15),
                  children: [
                    TextSpan(
                      text: "Terms of Service ",
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextSpan(
                      text: "And ",
                      style: TextStyle(color: Colors.amber),
                    ),
                    TextSpan(
                      text: "Privacy Policy ",
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                // textDirection: TextDirection.ltr,
              ),
              SizedBox(width: double.infinity, height: 20),
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
                    if (cameraAccess && locationAccess) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Mainpage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Please allow Camera & Location permission",
                          ),
                        ),
                      );
                    } // Next Screen
                  },
                  child: const Text(
                    "NEXT",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
