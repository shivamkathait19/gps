import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';

// यहाँ अपनी Google Maps API Key डालें
const String googleMapsApiKey = "YOUR_GOOGLE_MAPS_API_KEY";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Mainpage(),
      theme: ThemeData.dark(),
    );
  }
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
  String savedImagePath = "";

  String locationText = "No location";
  double? lat, lng;
  String? staticMapUrl; // मैप इमेज का URL रखने के लिए

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0; // 0 = Back, 1 = Front (आमतौर पर)

  String email = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
    initCamera();
    initFrontCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void>initFrontCamera()async{
    final camera = await availableCameras();
    CameraDescription?  frontCamera;
    for(var camera in camera){
      if(camera.lensDirection== CameraLensDirection.front){
        frontCamera = camera;
        break;
      }
    }
    frontCamera ??= camera.first;

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
    );

    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _startCamera(_selectedCameraIndex);
    }
  }

  Future<void> _startCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
    );

    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  // फ्रंट और बैक कैमरा स्विच करने का फंक्शन
  void switchCamera() {
    if (_cameras.length < 2) return; // अगर फोन में एक ही कैमरा है तो कुछ न करें
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _startCamera(_selectedCameraIndex);
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
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = "${directory.path}/GPSPhotos";
      final folder = Directory(folderPath);

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      String fileName = "GPS_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final newImage = await _image!.copy('$folderPath/$fileName');
      savedImagePath = newImage.path;

      await GallerySaver.saveImage(newImage.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Image Saved Successfully"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error : $e")),
      );
    }
  }

  Future<void> shareImage() async {
    if (_image == null) return;
    await Share.shareXFiles(
      [XFile(_image!.path)],
      text: "Shared from GPS photo App",
    );
  }

  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationText = "Location Service OFF";
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
          locationText = "Permission Denied";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      lat = position.latitude;
      lng = position.longitude;

      // Google Static Maps API URL जनरेट करना (लाल मार्कर के साथ)
      staticMapUrl =
      "https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=15&size=400x200&markers=color:red%7C$lat,$lng&key=$googleMapsApiKey";

      List<Placemark> placemarks = await placemarkFromCoordinates(lat!, lng!);
      Placemark place = placemarks.first;

      String village = place.locality ?? "";
      String district = place.subAdministrativeArea ?? "";
      String street = place.street ?? "";
      String state = place.administrativeArea ?? "";
      String country = place.country ?? "";
      String pincode = place.postalCode ?? "";

      String currentTime = "${DateTime.now().hour}:${DateTime.now().minute}";

      setState(() {
        locationText = "🏡 Village : $village  🏢 District : $district\n\n"
            "🛣️ Street : $street  🌍 State : $state  📮 PinCode : $pincode\n\n"
            "🌏 Country : $country  📅 Date : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}  ⏰ Time : $currentTime";
      });
    } catch (e) {
      setState(() {
        locationText = "Error : $e";
      });
    }
  }

  Future<void> takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final XFile file = await _controller!.takePicture();

    setState(() {
      _image = File(file.path);
      locationText = "Getting GPS Location...";
      staticMapUrl = null; // पुराना मैप हटाना
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(30),
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(),
                accountName: Padding(
                  padding: const EdgeInsets.only(top: 25),
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
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text("Profile", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text("Settings", style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.white),
                title: const Text("About", style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text("Logout", style: TextStyle(color: Colors.white)),
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _image == null
          ? Stack(
        children: [
          /// Live Camera
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          /// Camera Switch Button (Top Right)
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black54,
              onPressed: switchCamera,
              child: const Icon(Icons.switch_camera, color: Colors.white),
            ),
          ),

          /// Capture Button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: takePhoto,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.transparent,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 30),
                      onPressed: () {
                        setState(() {
                          _image = null;
                          locationText = "No location";
                          staticMapUrl = null;
                        });
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: saveImageToFolder,
                          icon: const Icon(Icons.save, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: shareImage,
                          icon: const Icon(Icons.share, color: Colors.green),
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
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 15),

              /// Google Map Photo Box (नया फीचर)
              if (staticMapUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      staticMapUrl!,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          color: Colors.black26,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink(); // API key न होने पर खाली छोड़ेगा
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              /// GPS Location Info Box
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
                    const Icon(Icons.location_on, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        locationText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          height: 1.3,
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
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      username = prefs.getString("username") ?? "";
      fullname = prefs.getString("fullname") ?? "";
      phone = prefs.getString("phone") ?? "";
      email = prefs.getString("email") ?? "";
      dob = prefs.getString("dob") ?? "";
      gender = prefs.getString("gender") ?? "";
    });
  }

  Widget profileTile(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(
                    value.isEmpty ? "-" : value,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget profileTileFull(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white54)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
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
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey.shade900],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, size: 55, color: Colors.white),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      profileTile(Icons.person, "Username", username),
                      const SizedBox(width: 10),
                      profileTile(Icons.badge, "Full Name", fullname),
                    ],
                  ),
                  profileTileFull(Icons.phone, "Phone", phone),
                  profileTileFull(Icons.email, "Email", email),
                  profileTileFull(Icons.calendar_month, "DOB", dob),
                  profileTileFull(Icons.wc, "Gender", gender),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}