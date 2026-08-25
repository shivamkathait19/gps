import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';

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

class _MainpageState extends State<Mainpage> with WidgetsBindingObserver {
  final ScreenshotController screenshotController = ScreenshotController();
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;

  bool isCapturing = false;
  bool locationLoaded = false;
  CameraController? _controller;
  File? _image;
  String savedImagePath = "";

  String locationText = "📍 Fetching live GPS location...";
  double? lat, lng;
  double _currentZoom = 16.0;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  String email = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadUserData();
    initCamera();
    startLocationTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStreamSubscription?.cancel();
    _controller?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameras.isNotEmpty) {
        _startCamera(_selectedCameraIndex);
      }
    }
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
      debugPrint("Camera init error: $e");
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
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Camera start error: $e");
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

  /// Live GPS Location Stream - continuous tracking in the background
  Future<void> startLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationLoaded = true;
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
          locationLoaded = true;
          locationText = "🚫 Location Permission Denied";
        });
        return;
      }

      // Initial fast location fetch
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _onPositionUpdated(initialPosition);

      // Start continuous background GPS stream
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3, // Update every 3 meters movement
      );

      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _onPositionUpdated(position);
        },
        onError: (error) {
          debugPrint("Location stream error: $error");
        },
      );
    } catch (e) {
      setState(() {
        locationLoaded = true;
        locationText = "Error: $e";
      });
    }
  }

  void _onPositionUpdated(Position position) {
    if (!mounted) return;

    setState(() {
      lat = position.latitude;
      lng = position.longitude;
      locationLoaded = true;
    });

    try {
      _mapController.move(LatLng(position.latitude, position.longitude), _currentZoom);
    } catch (_) {}

    _updateAddress(position.latitude, position.longitude);
  }

  Future<void> _updateAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks.first;
        String village = place.locality ?? place.subLocality ?? "";
        String district = place.subAdministrativeArea ?? "";
        String street = place.street ?? "";
        String state = place.administrativeArea ?? "";
        String country = place.country ?? "";
        String pincode = place.postalCode ?? "";

        String formattedAddress = [
          if (street.isNotEmpty) "🛣️ $street",
          if (village.isNotEmpty) "🏡 $village",
          if (district.isNotEmpty) "🏢 $district",
          if (state.isNotEmpty) "🌍 $state",
          if (pincode.isNotEmpty) "📮 $pincode",
          if (country.isNotEmpty) "🌏 $country",
        ].join("  ");

        setState(() {
          locationText = formattedAddress.isNotEmpty
              ? formattedAddress
              : "Lat: ${latitude.toStringAsFixed(5)}, Lng: ${longitude.toStringAsFixed(5)}";
        });
      }
    } catch (e) {
      debugPrint("Address lookup error: $e");
    }
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("GPS Photo Saved Successfully!"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Save image error: $e");
    }
  }

  Future<void> shareImage() async {
    if (_image == null) return;
    await Share.shareXFiles([
      XFile(_image!.path),
    ], text: "Shared from GPS Photo App");
  }

  Future<void> takePhoto() async {
    if (isCapturing) return;

    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera not ready")),
      );
      return;
    }

    setState(() {
      isCapturing = true;
    });

    try {
      final Uint8List? bytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 150),
      );

      if (bytes == null) {
        throw Exception("Photo capture failed");
      }

      final dir = await getTemporaryDirectory();
      final file = File(
        "${dir.path}/GPS_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      await file.writeAsBytes(bytes);

      if (!mounted) return;

      setState(() {
        _image = file;
        isCapturing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isCapturing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Photo capture failed: $e")));
    }
  }

  void _recenterMap() {
    if (lat != null && lng != null) {
      _mapController.move(LatLng(lat!, lng!), 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool cameraReady =
        _controller != null && _controller!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        backgroundColor: const Color(0xff1f2937),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.location_on, color: Colors.orangeAccent, size: 22),
            SizedBox(width: 8),
            Text(
              "GPS Camera & Live Map",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: _image == null
          ? Screenshot(
              controller: screenshotController,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalHeight = constraints.maxHeight;
                  // Camera takes top 62%, Live Map takes bottom 38%
                  final cameraHeight = totalHeight * 0.62;
                  final mapHeight = totalHeight * 0.38;

                  return Stack(
                    children: [
                      /// ─── 1. CAMERA PREVIEW (Top 62%) ───
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: cameraHeight,
                        child: Container(
                          color: Colors.black,
                          child: cameraReady
                              ? ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.center,
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: _controller!.value.previewSize?.height ?? constraints.maxWidth,
                                        height: _controller!.value.previewSize?.width ?? cameraHeight,
                                        child: CameraPreview(_controller!),
                                      ),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                        ),
                      ),

                      /// ─── 2. LIVE GPS MAP (Bottom 38%) ───
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: mapHeight,
                        child: Container(
                          color: const Color(0xff111827),
                          child: lat != null && lng != null
                              ? FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: LatLng(lat!, lng!),
                                    initialZoom: _currentZoom,
                                    onPositionChanged: (pos, hasGesture) {
                                      if (pos.zoom != null) {
                                        _currentZoom = pos.zoom!;
                                      }
                                    },
                                    interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.all,
                                    ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName:
                                          'com.example.gpsapp',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: LatLng(lat!, lng!),
                                          width: 50,
                                          height: 50,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue.withValues(alpha: 0.28),
                                                  border: Border.all(
                                                    color: Colors.blueAccent,
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.my_location,
                                                color: Colors.redAccent,
                                                size: 26,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.orangeAccent,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Acquiring GPS Signal...",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),

                      /// ─── 3. DIVIDER BAR BETWEEN CAMERA & MAP ───
                      Positioned(
                        top: cameraHeight - 3,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepOrangeAccent,
                                Colors.orangeAccent,
                                Colors.amberAccent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// ─── 4. GRADIENT OVERLAY ON MAP FOR TEXT READABILITY ───
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: mapHeight,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// ─── 5. LIVE ADDRESS & TIMESTAMP OVERLAY ───
                      Positioned(
                        bottom: 8,
                        left: 10,
                        right: 75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "LIVE GPS TRACKING",
                                  style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
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
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "📅 ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}  ⏰ ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ─── 6. LAT/LNG CHIP & RECENTER BUTTON (Bottom Right) ───
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _recenterMap,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.orangeAccent,
                                    width: 1.2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.gps_fixed,
                                  color: Colors.orangeAccent,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (lat != null && lng != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.orangeAccent,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "${lat!.toStringAsFixed(4)}\n${lng!.toStringAsFixed(4)}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      /// ─── 7. CAMERA SWITCH BUTTON (Top Right) ───
                      if (!isCapturing)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: switchCamera,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white38),
                              ),
                              child: const Icon(
                                Icons.switch_camera,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),

                      /// ─── 8. CAPTURE BUTTON (Floating over divider) ───
                      if (!isCapturing)
                        Positioned(
                          top: cameraHeight - 38,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: takePhoto,
                              child: Container(
                                height: 72,
                                width: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3.5,
                                  ),
                                  color: Colors.black45,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orangeAccent.withValues(alpha: 0.6),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
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

                      /// ─── 9. CAPTURING LOADING OVERLAY ───
                      if (isCapturing)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black54,
                            child: const Center(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      /// Action Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                              onPressed: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                            ),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                  onPressed: saveImageToFolder,
                                  icon: const Icon(Icons.save, color: Colors.white),
                                  label: const Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: shareImage,
                                  icon: const Icon(Icons.share, color: Colors.white),
                                  label: const Text(
                                    "Share",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// Captured Image Preview (Has Camera + Map combined!)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _image!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
