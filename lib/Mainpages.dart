import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



class Mainpages extends StatefulWidget {
  const Mainpages({super.key});

  @override
  State<Mainpages> createState() => _MainpagesState();
}

class _MainpagesState extends State<Mainpages> {

  final ImagePicker _picker = ImagePicker();

  /// 📷 OPEN CAMERA
  Future<void> openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Photo Captured: ${photo.name}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: const Center(
          child: Text(
            "Drawer Menu",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [

          /// 🔥 BACKGROUND (MAP की जगह)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🔍 SEARCH BAR
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
              ),
              height: 50,
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(Icons.menu, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),

                  const Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search here...",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const Icon(Icons.mic, color: Colors.white),
                ],
              ),
            ),
          ),

          /// 📍 CENTER ICON (optional)
          const Center(
            child: Icon(Icons.place, color: Colors.red, size: 40),
          ),

          /// 🎯 FLOATING BUTTONS
          Positioned(
            right: 20,
            bottom: 120,
            child: Column(
              children: [

                /// 📷 CAMERA BUTTON
              FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.black,
                  onPressed: openCamera,
                  child: const Icon(Icons.camera_alt, color: Colors.white, size:50),
                ),

                const SizedBox(height: 10),

                /// 🔄 REFRESH BUTTON (map हट गया इसलिए replace)
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Refreshed")),
                    );
                  },
                  child: const Icon(Icons.refresh),
                ),

                const SizedBox(height: 10),

                /// ➕ ADD
                FloatingActionButton(
                  mini: true,
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),

                const SizedBox(height: 10),

                /// ➖ REMOVE
                FloatingActionButton(
                  mini: true,
                  onPressed: () {},
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          /// 📍 BOTTOM BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bottom Clicked")),
                  );
                },
                icon: const Icon(Icons.location_on, color: Colors.red),
                label: const Text(
                  "Your Location",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}