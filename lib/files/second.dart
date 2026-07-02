import 'package:flutter/material.dart';
import 'package:gps/files/thired.dart';

class Second extends StatefulWidget {
  const Second({super.key});

  @override
  State<Second> createState() => _SecondState();
}

class _SecondState extends State<Second> {
  int selectedIndex = -1;

  final List<Map<String, String>> languages = [
    {"name": "English", "flag": "🇺🇸"},
    {"name": "Bahasa Indonesia", "flag": "🇮🇩"},
    {"name": "हिन्दी", "flag": "🇮🇳"},
    {"name": "Español", "flag": "🇪🇸"},
    {"name": "ไทย (Thai)", "flag": "🇹🇭"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffEAF6FF),
              Color(0xffD6EFFF),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(.25),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.language,
                  color: Colors.blue,
                  size: 50,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Choose Your Language",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0F3057),
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "Select your preferred language.\nYou can change it later from Settings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.08),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              languages[index]["flag"]!,
                              style: const TextStyle(fontSize: 35),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                languages[index]["name"]!,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration:
                              const Duration(milliseconds: 300),
                              child: isSelected
                                  ? const Icon(
                                Icons.check_circle,
                                key: ValueKey(1),
                                color: Colors.blue,
                                size: 30,
                              )
                                  : const Icon(
                                Icons.radio_button_unchecked,
                                key: ValueKey(2),
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      if (selectedIndex == -1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please select a language",
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Thired(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "NEXT",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}