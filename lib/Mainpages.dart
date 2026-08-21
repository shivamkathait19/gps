import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
// dart:ui removed — unused import
import 'package:image/image.dart' as img;

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
  final ScreenshotController screenshotController = ScreenshotController();
  bool showResult = false;
  bool isCapturing = false;
  bool locationLoaded = false;
  CameraController? _controller;
  File? _image;
  String savedImagePath = "";

  String locationText = "No location";
  double? lat, lng;
  String? staticMapUrl;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0; // 0 = Back, 1 = Front (आमतौर पर)

  String email = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
    initCamera();
    getLocation();
    //initFrontCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<File> createGpsPhoto(File imageFile) async {
    final bytes = await imageFile.readAsBytes();

    img.Image? image = img.decodeImage(bytes);

    if (image == null) return imageFile;

    String text =
        '''

$locationText
Date : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
Time : ${DateTime.now().hour}:${DateTime.now().minute}
''';

    img.fillRect(
      image,
      x1: 0,
      y1: image.height - 220,
      x2: image.width,
      y2: image.height,
      color: img.ColorRgb8(0, 0, 0),
    );

    img.drawString(
      image,
      text,
      font: img.arial24,
      x: 20,
      y: image.height - 200,
      color: img.ColorRgb8(255, 255, 255),
    );

    final dir = await getTemporaryDirectory();

    final file = File(
      "${dir.path}/gps_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    await file.writeAsBytes(img.encodeJpg(image));

    return file;
  }

  Future<void> initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _selectedCameraIndex = 0;
        await _startCamera(_selectedCameraIndex);
      } else {
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (mounted) setState(() {});
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

  void switchCamera() {
    if (_cameras.length < 2) return;
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
      final folder = Directory("${directory.path}/GPSPhotos");

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      String fileName = "GPS_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final savedFile = await _image!.copy("${folder.path}/$fileName");

      await GallerySaver.saveImage(savedFile.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("GPS Photo Saved Successfully"),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> shareImage() async {
    if (_image == null) return;
    await Share.shareXFiles([
      XFile(_image!.path),
    ], text: "Shared from GPS photo App");
  }

  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationLoaded = true; // ✅ spinner band karo
          locationText = "📍 Location Service OFF — Please turn on GPS";
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
          locationLoaded = true; // ✅ spinner band karo
          locationText = "🚫 Location Permission Denied";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      lat = position.latitude;
      lng = position.longitude;

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
        locationLoaded = true;
        locationText =
            "🏡 Village : $village  🏢 District : $district"
            "🛣️ Street : $street  🌍 State : $state  📮 PinCode : $pincode"
            "🌏 Country : $country  📅 Date : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ⏰ Time : $currentTime";
      });
    } catch (e) {
      setState(() {
        locationLoaded = true;
        locationText = "Error : $e";
      });
    }
  }

  Future<void> takePhoto() async {
    setState(() {
      isCapturing = true;
    });
    await Future.delayed(Duration(milliseconds: 50));
    if (_controller == null || !_controller!.value.isInitialized) return;

    await getLocation();

    final Uint8List? bytes = await screenshotController.capture();

    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File(
      "${dir.path}/GPS_${DateTime.now().millisecondsSinceEpoch}logo.png",
    );

    await file.writeAsBytes(bytes);

    await GallerySaver.saveImage(file.path);

    setState(() {
      _image = file;
      isCapturing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sirf tab spinner dikhao jab dono (camera + location) load nahi hue
    final bool cameraReady = _controller != null && _controller!.value.isInitialized;
    if (!locationLoaded) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.blueAccent),
              SizedBox(height: 16),
              Text("Loading GPS...", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return Scaffold(
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
          ? Screenshot(
              controller: screenshotController,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalHeight = constraints.maxHeight;
                  // Camera takes top 65%, Map takes bottom 35%
                  final cameraHeight = totalHeight * 0.65;
                  final mapHeight = totalHeight * 0.35;

                  return Stack(
                    children: [
                      /// ─── FULL BACKGROUND: Map at bottom ───
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: mapHeight,
                        child: staticMapUrl != null
                            ? Image.network(
                                staticMapUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    Container(
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: Icon(
                                          Icons.map,
                                          color: Colors.white54,
                                          size: 60,
                                        ),
                                      ),
                                    ),
                              )
                            : Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),

                      /// ─── Dark gradient over map for text readability ───
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: mapHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.0),
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// ─── CAMERA PREVIEW (top portion) ───
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: cameraHeight,
                        child: CameraPreview(_controller!),
                      ),

                      /// ─── Thin divider / GPS watermark bar between camera & map ───
                      Positioned(
                        top: cameraHeight - 2,
                        left: 0,
                        right: 0,
                        child: Container(height: 4, color: Colors.orangeAccent),
                      ),

                      /// ─── Location text overlay on the map section ───
                      Positioned(
                        bottom: 8,
                        left: 12,
                        right: 50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "GPS Location",
                                  style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              locationText,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "📅 ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}  "
                              "⏰ ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ─── Lat/Lng chip (bottom right of map) ───
                      if (lat != null && lng != null)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orangeAccent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              "${lat!.toStringAsFixed(5)}, ${lng!.toStringAsFixed(5)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      /// ─── Camera Switch Button (Top Right) ───
                      if (!isCapturing)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: Colors.black54,
                            onPressed: switchCamera,
                            child: const Icon(
                              Icons.switch_camera,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      /// ─── Capture Button (center, just above map area) ───
                      if (!isCapturing)
                        Positioned(
                          top: cameraHeight - 55,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: takePhoto,
                              child: Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  color: Colors.black26,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orangeAccent.withValues(
                                        alpha: 0.6,
                                      ),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      /// ─── Loading spinner while capturing ───
                      if (isCapturing)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black38,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.black,
                  child: Column(
                    children: [
                      /// Top Buttons
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  // locationText = "No location";
                                  //staticMapUrl = null;
                                });
                              },
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: saveImageToFolder,
                                  icon: Icon(Icons.save, color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: shareImage,
                                  icon: const Icon(
                                    Icons.share,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// Captured Photo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _image!,
                          width: double.infinity,
                          //height: 500,
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
                              height: 200,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 150,
                                      color: Colors.black26,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox.shrink();
                              },
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
