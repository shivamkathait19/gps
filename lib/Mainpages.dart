import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gps/files/forth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';


@override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Mainpage(),
      theme: ThemeData.dark(),
    );
  }


class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();

}

class _MainpageState extends State<Mainpage> {
  bool showResult = false;
  CameraController? _controller;
  File? _image;
 String savedImagePath ="";

  String locationText = "No location";
  double? lat, lng;

  String email = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
    initCamera();
  }
  @override
  void dispose(){
    _controller?.dispose();
  }

   Future<void> initCamera()async{
    final cameras = await availableCameras();
    _controller = CameraController(
        cameras.first,
        ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted){
      setState(() {

      });
    }
   }

  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      email = prefs.getString("email") ?? "No Email";
      username = prefs.getString("username") ?? "User";
    });
  }

  Future<void> saveImageToFolder() async {
    if (_image == null) return;

    try {
      final directory =
      await getApplicationDocumentsDirectory();

  final folderPath = "${directory.path}/GPSPhotos";

  final folder = Directory(folderPath);

  if (!await folder.exists()) {
  await folder.create(recursive: true);
  }

  String fileName =
  "GPS_${DateTime.now().millisecondsSinceEpoch}.jpg";

  final newImage =
  await _image!.copy('$folderPath/$fileName');

  savedImagePath = newImage.path;

  await GallerySaver.saveImage(newImage.path);

  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  backgroundColor: Colors.green,
  content: Text(
  "Image Saved Successfully",
  ),
  ),
  );
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("Error : $e"),),);}}

Future<void> shareImage()async{
    if(_image == null) return;
    await Share.shareXFiles(
      [XFile(_image!.path)],
      text: "Shared from GPS photo App"
    );
}

  Future<void> getLocation() async {
    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          locationText = "Location Service OFF";
        });
        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        setState(() {
          locationText = "Permission Denied";
        });
        return;
      }

      Position position =
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      lat = position.latitude;
      lng = position.longitude;

      List<Placemark> placemarks =
      await placemarkFromCoordinates(
        lat!,
        lng!,
      );

      Placemark place = placemarks.first;

      String village = place.locality ?? "";
      //String area = place.subLocality ?? "";
      String district = place.subAdministrativeArea ?? "";
      String street = place.street ?? "";
      String state = place.administrativeArea ?? "";
      String country = place.country ?? "";
      String pincode = place.postalCode ?? "";


      String currentTime =
          "${DateTime.now().hour}:${DateTime.now().minute}";

      setState(() {
        locationText = "🏡 Village : $village 🏢 District : $district\n\n,"
            " 🛣️ Street : $street 🌍 State : $state 📮 PinCode : $pincode"
            "🌏 Country : $country 📅 Date : $currentTime ⏰ Time : $currentTime";
        //"📍 Area : $area\n\n"
      });
    } catch (e) {
      setState(() {
        locationText = "Error : $e";
      });
    }
  }

  Future<void> takePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized) return;

    final XFile file = await _controller!.takePicture();

    setState(() {
      _image = File(file.path);
      locationText = "Getting GPS Location...";
    });

    await getLocation();
  }



  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(

      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(30),
            children: [
              UserAccountsDrawerHeader(
                decoration:  BoxDecoration(

                ),

                accountName: Padding(
                  padding:  EdgeInsets.only(top: 25),
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                accountEmail: Text(email),
                 currentAccountPicture: Padding(
                   padding: const EdgeInsets.only(right: 20),
                   child: Container(
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                         border: Border.all(
                         color: Colors.white,
                           width: 1,

                       )
                     ),
                   ),
                 ),
              ),

              /// PROFILE
              ListTile(
                leading: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                title: const Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const ProfileScreen(),
                    ),
                  );
                },
              ),

              /// SETTINGS
              ListTile(
                leading: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                title: const Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),

              /// ABOUT
              ListTile(
                leading: const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                title: const Text(
                  "About",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),

              /// LOGOUT
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        title: const Text(
          "GPS Photo App",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),

      body: _image == null
          ? Stack(
        children: [

          /// Live Camera
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          /// Capture Button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: takePhoto,
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      )
          : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// Top Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _image = null;
                          locationText = "No location";
                        });
                      },
                    ),

                    Row(
                      children: [

                        IconButton(
                          onPressed: saveImageToFolder,
                          icon: const Icon(
                            Icons.save,
                            color: Colors.blue,
                          ),
                        ),

                        IconButton(
                          onPressed: shareImage,
                          icon: const Icon(
                            Icons.share,
                            color: Colors.green,
                          ),
                        ),

                      ],
                    )
                  ],
                ),
              ),

              /// Captured Photo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  _image!,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 20),

              /// GPS Location
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on,color: Colors.amber,),
                    SizedBox(width: 10,),
                    Expanded(child:
                    Text(
                      locationText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        height: 1.0,
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),


     /* floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Colors.orange,
              Colors.deepOrange,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color:
              Colors.orange.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 5,
          backgroundColor: Colors.transparent,
          onPressed: takePhoto,
          child: const Icon(
            Icons.camera_alt,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),*/


    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  String username = "";
  String fullname = "";
  String phone = "";
  String email = "";
  String dob = "";
  String gender = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username =
          prefs.getString("username") ?? "";
      fullname =
          prefs.getString("fullname") ?? "";
      phone = prefs.getString("phone") ?? "";
      email = prefs.getString("email") ?? "";
      dob = prefs.getString("dob") ?? "";
      gender = prefs.getString("gender") ?? "";
    });
  }

  Widget profileTile(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.orange,
          ),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                ),
              ),

              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Profile",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.blueGrey.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundColor:
                  Colors.orange,
                  child: Icon(
                    Icons.person,
                    size: 55,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 25),
               Row(
                 children: [
                profileTile(

                  Icons.person,
                  "Username",
                  username,
                ),
                SizedBox(width: 60,),

                profileTile(
                  Icons.badge,
                  "Full Name",
                  fullname,
                ),]
               ),
                profileTile(
                  Icons.phone,
                  "Phone",
                  phone,
                ),

                profileTile(
                  Icons.email,
                  "Email",
                  email,
                ),

                profileTile(
                  Icons.calendar_month,
                  "DOB",
                  dob,
                ),

                profileTile(
                  Icons.wc,
                  "Gender",
                  gender,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}