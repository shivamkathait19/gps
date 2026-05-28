import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

@override
  Widget build(BuildContext context) {
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
content: Text("Error : $e"),
),
);
}
}

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
      String area = place.subLocality ?? "";
      String district = place.subAdministrativeArea ?? "";
      String street = place.street ?? "";
      String state = place.administrativeArea ?? "";
      String country = place.country ?? "";
      String pincode = place.postalCode ?? "";

      String currentTime =
          "${DateTime.now().hour}:${DateTime.now().minute}";

      setState(() {
        locationText =
        "🏡 Village : $village\n\n"
            "📍 Area : $area\n\n"
            "🏢 District : $district\n\n"
            "🛣️ Street : $street\n\n"
            "🌍 State : $state\n\n"
            "📮 PinCode : $pincode\n\n"
            "🌏 Country : $country\n\n"
            "📅 Date : $currentTime\n\n"
            "⏰ Time : $currentTime\n\n"
            "📌 Latitude : $lat\n\n"
            "📌 Longitude : $lng";
      });
    } catch (e) {
      setState(() {
        locationText = "Error : $e";
      });
    }
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();

    final XFile? picked = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        locationText = "Getting GPS Location...";
      });

      await getLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Colors.blueGrey.shade900,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                accountName: Text(
                  username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(email),
                currentAccountPicture:
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
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
        backgroundColor: Colors.black,
        title: const Text(
          "GPS Photo App",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.blueGrey.shade900,
              Colors.black,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: _image == null
              ? Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.camera_alt,
                size: 120,
                color: Colors.white54,
              ),

              SizedBox(height: 20),

              Text(
                "Capture GPS Photo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          )
              : Stack(
            children: [
              ClipRRect(
                borderRadius:
                BorderRadius.circular(20),
                child: Image.file(
                  _image!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              /// GPS BADGE
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: const Text(
                    "GPS ON",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              /// LOCATION CARD
              Positioned(
                bottom: 20,
                left: 15,
                right: 15,
                child: Container(
                  padding:
                  const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(
                      25,
                    ),
                    color: Colors.black
                        .withOpacity(0.4),
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on,
                            color:
                            Colors.orange,
                          ),

                          SizedBox(width: 8),

                          Text(
                            "LIVE GPS",
                            style: TextStyle(
                              color:
                              Colors.orange,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 10),

                      Text(
                        locationText,
                        style:
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: saveImageToFolder,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    GestureDetector(
                      onTap: shareImage,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.share,
                          color: Colors.black,
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

      floatingActionButton: Container(
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
      ),
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
        title: const Text("Profile"),
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

                profileTile(
                  Icons.person,
                  "Username",
                  username,
                ),

                profileTile(
                  Icons.badge,
                  "Full Name",
                  fullname,
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