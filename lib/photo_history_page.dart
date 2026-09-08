import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoHistoryPage extends StatelessWidget {
  const PhotoHistoryPage({Key? key}) : super(key: key);

  Future<List<String>> _loadSavedPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('saved_photos') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('फ़ोटो इतिहास')),
      body: FutureBuilder<List<String>>(
        future: _loadSavedPhotos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final photos = snapshot.data!;
          if (photos.isEmpty) {
            return const Center(child: Text('कोई फ़ोटो नहीं सहेजी गई।'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final path = photos[index];
              return GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: Image.file(File(path), fit: BoxFit.contain),
                  ),
                ),
                child: Image.file(File(path), fit: BoxFit.cover),
              );
            },
          );
        },
      ),
    );
  }
}
