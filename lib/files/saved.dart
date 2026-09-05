import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  List<File> _photos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory('${directory.path}/GPSPhotos');

      if (await folder.exists()) {
        final files = folder
            .listSync()
            .whereType<File>()
            .where((f) =>
                f.path.toLowerCase().endsWith('.jpg') ||
                f.path.toLowerCase().endsWith('.jpeg') ||
                f.path.toLowerCase().endsWith('.png'))
            .toList();

        // Sabse nayi pehle dikhao
        files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

        setState(() {
          _photos = files;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('Error loading photos: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _deletePhoto(File file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Photo?',
            style: TextStyle(color: Colors.white)),
        content: const Text('Kya aap yeh photo delete karna chahte hain?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await file.delete();
      _loadPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0D0D0D),
      child: Column(
        children: [
          // ─── Drawer Header ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.photo_library_rounded,
                        color: Colors.greenAccent,
                        size: 32,
                      ),
                    ),
                    // Refresh button
                    IconButton(
                      onPressed: () {
                        setState(() => _loading = true);
                        _loadPhotos();
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Saved Photos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _loading
                      ? 'Loading...'
                      : _photos.isEmpty
                          ? 'No photos yet'
                          : '${_photos.length} Photos',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ─── Photo Grid ───
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.greenAccent,
                    ),
                  )
                : _photos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: Colors.white.withOpacity(0.3),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Koi photo nahi mili',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pehle ek GPS photo click karein',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(4),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          final photo = _photos[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => _FullScreenPhoto(
                                    file: photo,
                                    onDelete: () {
                                      Navigator.pop(context);
                                      _loadPhotos();
                                    },
                                  ),
                                ),
                              );
                            },
                            onLongPress: () => _deletePhoto(photo),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  photo,
                                  fit: BoxFit.cover,
                                  cacheWidth: 200,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Full Screen Photo Viewer ───
class _FullScreenPhoto extends StatelessWidget {
  final File file;
  final VoidCallback onDelete;

  const _FullScreenPhoto({required this.file, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          file.path.split('/').last,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A2E),
                  title: const Text('Delete Photo?',
                      style: TextStyle(color: Colors.white)),
                  content: const Text(
                      'Kya aap yeh photo delete karna chahte hain?',
                      style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white54)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await file.delete();
                onDelete();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(file, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
