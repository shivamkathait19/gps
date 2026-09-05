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
import 'package:gps/files/saved.dart';



class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> with WidgetsBindingObserver {
  final ScreenshotController screenshotController = ScreenshotController();
  final MapController _miniMapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _clockTimer;

  bool isCapturing = false;
  bool isFlashOn = false;
  bool isGridOn = false;
  CameraController? _controller;
  File? _image;
  String savedImagePath = "";

  // GPS & Location Data
  double? lat, lng;
  double altitude = 0.0;
  double speed = 0.0;
  double accuracy = 0.0;
  double heading = 0.0;

  String placeTitle = "Locating GPS...";
  String fullAddress = "Fetching full street address...";
  DateTime currentDateTime = DateTime.now();

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

    // Clock timer for live seconds
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          currentDateTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer?.cancel();
    _positionStreamSubscription?.cancel();
    _controller?.dispose();
    _miniMapController.dispose();
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
      ResolutionPreset.max,
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

  void toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      if (isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
        setState(() => isFlashOn = false);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
        setState(() => isFlashOn = true);
      }
    } catch (e) {
      debugPrint("Flash error: $e");
    }
  }

  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email") ?? "No Email";
      username = prefs.getString("username") ?? "User";
    });
  }

  /// Live continuous GPS tracking
  Future<void> startLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          placeTitle = "GPS Service is OFF";
          fullAddress = "Tap here or enable GPS in device settings";
        });
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          placeTitle = "Location Permission Denied";
          fullAddress = "Please allow location access to tag photos";
        });
        return;
      }

      // 1. Try instant cached location first (0ms delay)
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        _onPositionUpdated(lastPosition);
      }

      // 2. Fetch high accuracy current position
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _onPositionUpdated(currentPosition);

      // 3. Start continuous stream tracking
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // update every 1 meter
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
      debugPrint("GPS error: $e");
      setState(() {
        placeTitle = "Searching GPS...";
        fullAddress = "Acquiring satellite signal...";
      });
    }
  }

  void _onPositionUpdated(Position position) {
    if (!mounted) return;

    setState(() {
      lat = position.latitude;
      lng = position.longitude;
      altitude = position.altitude;
      speed = (position.speed * 3.6); // m/s to km/h
      if (speed < 0) speed = 0;
      accuracy = position.accuracy;
      heading = position.heading;
    });

    try {
      _miniMapController.move(LatLng(position.latitude, position.longitude), 16.0);
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
        String locality = place.locality ?? place.subLocality ?? "";
        String area = place.subAdministrativeArea ?? "";
        String street = place.street ?? "";
        String state = place.administrativeArea ?? "";
        String country = place.country ?? "";
        String pincode = place.postalCode ?? "";

        // Build Title
        String title = [
          if (locality.isNotEmpty) locality,
          if (area.isNotEmpty && area != locality) area,
          if (state.isNotEmpty) state,
          if (country.isNotEmpty) country,
        ].join(", ");

        // Build Full Address
        String addr = [
          if (street.isNotEmpty && street != locality) street,
          if (locality.isNotEmpty) locality,
          if (area.isNotEmpty) area,
          if (pincode.isNotEmpty) pincode,
          if (state.isNotEmpty) state,
          if (country.isNotEmpty) country,
        ].join(", ");

        setState(() {
          placeTitle = title.isNotEmpty ? title : "GPS Tagged Location";
          fullAddress = addr.isNotEmpty ? addr : "Lat: $latitude, Lng: $longitude";
        });
      }
    } catch (e) {
      debugPrint("Address lookup error: $e");
    }
  }

  String _formatDMS(double coordinate, bool isLat) {
    String direction = isLat
        ? (coordinate >= 0 ? 'N' : 'S')
        : (coordinate >= 0 ? 'E' : 'W');
    double absolute = coordinate.abs();
    int degrees = absolute.floor();
    double minutesNotTruncated = (absolute - degrees) * 60;
    int minutes = minutesNotTruncated.floor();
    double seconds = (minutesNotTruncated - minutes) * 60;

    return "$degrees° $minutes' ${seconds.toStringAsFixed(3)}\" $direction";
  }

  String _getHeadingDirection(double h) {
    if (h >= 337.5 || h < 22.5) return "N";
    if (h >= 22.5 && h < 67.5) return "NE";
    if (h >= 67.5 && h < 112.5) return "E";
    if (h >= 112.5 && h < 157.5) return "SE";
    if (h >= 157.5 && h < 202.5) return "S";
    if (h >= 202.5 && h < 247.5) return "SW";
    if (h >= 247.5 && h < 292.5) return "W";
    return "NW";
  }

  String _formatDate(DateTime dt) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    String dayName = days[dt.weekday - 1];
    String monthName = months[dt.month - 1];
    String timeStr =
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";

    return "$dayName, ${dt.day} $monthName ${dt.year} $timeStr";
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
            content: Text("GPS Photo Saved to Gallery!"),
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
    ], text: "Shared from GPS Map Camera");
  }

  Future<void> takePhoto() async {
    if (isCapturing) return;

    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera is not ready yet")),
      );
      return;
    }

    setState(() {
      isCapturing = true;
    });

    try {
      // Capture only the clean camera preview and GPS stamp
      final Uint8List? bytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 50),
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
      ).showSnackBar(SnackBar(content: Text("Capture error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image != null) {
      return _buildCapturedPhotoScreen();
    }

    return _buildCameraScreen();
  }

  /// ─────────────────────────────────────────────────────────────
  /// MAIN CAMERA SCREEN with Live GPS Map & Data Overlay
  /// ─────────────────────────────────────────────────────────────
  Widget _buildCameraScreen() {
    final bool cameraReady =
        _controller != null && _controller!.value.isInitialized;

    return Scaffold(
      drawer: const Saved(),
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            /// ─── Top Control Bar ───
            Container(
              color: Colors.black,
              padding: const EdgeInsets.only(
                top: 40,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Live GPS Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                        SizedBox(width: 6),
                        Text(
                          "GPS ACTIVE",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: isFlashOn ? Colors.yellowAccent : Colors.white,
                          size: 24,
                        ),
                        onPressed: toggleFlash,
                        tooltip: "Flash",
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.flip_camera_android,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: switchCamera,
                        tooltip: "Switch Camera",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ─── Viewfinder Area ───
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      /// ─── LAYER 1: PURE CAPTURE LAYER (Only Camera + GPS Stamp) ───
                      Screenshot(
                        controller: screenshotController,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            /// Full Live Camera Preview
                            if (cameraReady)
                              ClipRect(
                                child: OverflowBox(
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _controller!.value.previewSize?.height ?? constraints.maxWidth,
                                      height: _controller!.value.previewSize?.width ?? constraints.maxHeight,
                                      child: CameraPreview(_controller!),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                color: const Color(0xff18181b),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                              ),

                            /// GPS Map & Location Data Card (Exact design)
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 12,
                              child: _buildGpsStampCard(),
                            ),
                          ],
                        ),
                      ),

                      /// ─── LAYER 2: UI-ONLY OVERLAYS (NEVER CAPTURED IN PHOTO) ───
                      /// Focus Grid Lines (Visual only)
                      if (isGridOn)
                        IgnorePointer(
                          child: CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: GridPainter(),
                          ),
                        ),

                      /// Center Green Focus Box (Visual only - NOT in photo)
                      IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.greenAccent.withValues(alpha: 0.8),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),

                      /// Capture Progress Loading Overlay (Visual only - NOT in photo)
                      if (isCapturing)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            /// ─── Bottom Action Bar (Clean Shutter Button) ───
            Container(
              color: Colors.black,
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Center(
                child: GestureDetector(
                  onTap: takePhoto,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.15),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ─────────────────────────────────────────────────────────────
  /// GPS STAMP CARD (Mini Map + Place Name + Address + Chips)
  /// ─────────────────────────────────────────────────────────────
  Widget _buildGpsStampCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// ─── Left Side: Mini Map with Live Marker ───
          Container(
            width: 82,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white30, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: FlutterMap(
                mapController: _miniMapController,
                options: MapOptions(
                  initialCenter: LatLng(lat ?? 28.6139, lng ?? 77.2090),
                  initialZoom: 15.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.gps',
                  ),
                  if (lat != null && lng != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(lat!, lng!),
                          width: 32,
                          height: 32,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.redAccent,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// ─── Right Side: Location Info & Chips ───
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title: Place Name & Logo
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        placeTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.greenAccent, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.eco, color: Colors.greenAccent, size: 10),
                          SizedBox(width: 2),
                          Text(
                            "GPS",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                /// Full Address
                Text(
                  fullAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 2),

                /// Lat & Long (DMS / Decimal formatted)
                if (lat != null && lng != null)
                  Text(
                    "Lat ${_formatDMS(lat!, true)}  Long ${_formatDMS(lng!, false)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                const SizedBox(height: 2),

                /// Date & Time
                Text(
                  _formatDate(currentDateTime),
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 8,
                  ),
                ),

                const SizedBox(height: 2),

                /// Note line
                const Text(
                  "Note: GPS Map Camera Photo",
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 7.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                /// Bottom Chips Row (Speed, Accuracy, Altitude, Compass)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip("🚗", "${speed.toStringAsFixed(0)} km/h"),
                      const SizedBox(width: 5),
                      _buildChip("🎯", "±${accuracy.toStringAsFixed(0)}m"),
                      const SizedBox(width: 5),
                      _buildChip("⛰️", "${altitude.toStringAsFixed(0)} m"),
                      const SizedBox(width: 5),
                      _buildChip("🧭", "${heading.toStringAsFixed(0)}° ${_getHeadingDirection(heading)}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 8)),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 7.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }



  /// ─────────────────────────────────────────────────────────────
  /// CAPTURED PHOTO PREVIEW SCREEN (Save / Share / Delete)
  /// ─────────────────────────────────────────────────────────────
  Widget _buildCapturedPhotoScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
          onPressed: () {
            setState(() {
              _image = null;
            });
          },
        ),
        title: const Text(
          "Captured GPS Photo",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
            onPressed: () {
              setState(() {
                _image = null;
              });
            },
            tooltip: "Discard",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// Photo Preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            /// Bottom Action Controls
            Container(
              color: const Color(0xff18181b),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _image = null;
                        });
                      },
                      icon: const Icon(Icons.camera_alt_outlined, size: 20),
                      label: const Text(
                        "Retake",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: saveImageToFolder,
                      icon: const Icon(Icons.save_alt, size: 20),
                      label: const Text(
                        "Save Photo",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white12,
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: shareImage,
                    icon: const Icon(Icons.share, color: Colors.greenAccent, size: 22),
                    tooltip: "Share",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple Grid Painter for Camera Viewfinder
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // Vertical lines
    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);

    // Horizontal lines
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
