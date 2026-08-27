import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gps/files/second.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scaleAnimation;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.08,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

   timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Second(),
        ),
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                      const Color(0xff0F2027),
                      const Color(0xff2C5364),
                      _controller.value)!,
                  Color.lerp(
                      const Color(0xff203A43),
                      const Color(0xff4CA1AF),
                      _controller.value)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [

                    const Spacer(),

                    ScaleTransition(
                      scale: scaleAnimation,
                      child: Container(
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 80,
                          color: Colors.red,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "GOGO GPS CAMERA",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Capture Proof, Not Just Photos",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "Trusted.\nAccurate.\nAuthentic.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      height: 35,
                      width: 35,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      "Version 1.23.5",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.85),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}