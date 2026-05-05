import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gps/Loginscreen.dart';
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
        title: const Text("GPS Photo App",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white10,
      drawer: Drawer(
        surfaceTintColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.blueGrey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // 🔥 HEADER
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                accountName: Text(
                  "Shivam Singh",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                accountEmail: Text("shivam@email.com"),
                currentAccountPicture: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, size: 35, color: Colors.white),
                ),
              ),

              // 📷 Camera
              ListTile(
                leading: Icon(Icons.person,color: Colors.white,),
                title: Text("Profile",style: TextStyle(color: Colors.white),),
             onTap: (){
                  Navigator.pop(context);
             },
              )

              /*ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.white),
                title: Text("Camera", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  takePhoto();
                },
              ),*/

              // 🖼️ Gallery


              // 🗺️ Map
              ListTile(
                leading: Icon(Icons.map, color: Colors.white),
                title: Text("Map View", style: TextStyle(color: Colors.white)),
                onTap: () {
                  // yaha map screen open kar sakte ho
                },
              ),

              Divider(color: Colors.white54),

              // ⚙️ Settings
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text("Settings", style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),

              // ℹ️ About
              ListTile(
                leading: Icon(Icons.info, color: Colors.white),
                title: Text("About", style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("logout"),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                }
              )
            ],
          ),
        ),
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
                padding:  EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  locationText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        onPressed: takePhoto,
        backgroundColor: Colors.black ,
        child:  Icon(Icons.camera_alt),
      ),
    );
  }
}


class Profile extends StatelessWidget {
  final String username;
  final String fullname;
  final String phone;
  final String email ;
  final String dob;
  final String gender;



   Profile({super.key,
   required this.username,
     required this.fullname,
     required this.phone,
     required this.email,
     required this.dob,
     required this.gender,
   });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("profile"),
      ),
      backgroundColor: Colors.black,
 body: Column(
  crossAxisAlignment: CrossAxisAlignment.center,
   children: [

     Text("Usernaem: $username"),
     Text("fullnaem: $fullname"),
     Text("phone : $phone"),
     Text("email : $email"),
     Text("Dob: $dob"),
     Text("Gender: $gender"),
   ],
 ),
    );
  }
}
