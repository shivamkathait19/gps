import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // `cameras` is defined in main.dart as a global list
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.high);
    await _controller.initialize();
    if (!mounted) return;
    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Save image to app's documents directory and persist its path
  Future<String> _saveAndPersist(XFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = "${dir.path}/photo_$timestamp.jpg";
    await file.saveTo(path);

    // Store path in SharedPreferences for history
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList('saved_photos') ?? [];
    saved.add(path);
    await prefs.setStringList('saved_photos', saved);
    return path;
  }

  Future<void> _capture() async {
    try {
      final XFile raw = await _controller.takePicture();
      final savedPath = await _saveAndPersist(raw);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('फ़ोटो सहेजी गई: $savedPath')),
      );
    } catch (e) {
      debugPrint('कैप्चर त्रुटि: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('कैमरा')),
      body: _isInitialized
          ? CameraPreview(_controller)
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: _capture,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
