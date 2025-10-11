import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay 3 detik lalu pindah ke halaman detector
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/detector');
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEEF2F7),
              Color(0xFFD8E0E8),
              Color(0xFFBFCBD6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 80),
              Container(
                width: w * 0.35,
                height: w * 0.35,
                decoration: const BoxDecoration(
                  color: Color(0xFF064E3B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                "Melon Leaf Disease Detector",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: w > 360 ? 22 : 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "AI-powered plant health monitoring",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: w > 360 ? 14 : 13,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              const Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Version 1.0.0",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
