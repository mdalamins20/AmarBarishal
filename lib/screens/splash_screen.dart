import 'dart:async';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import '../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  const SplashScreen({super.key, required this.onThemeChanged});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // প্রথম ফ্রেম build হওয়ার পর Navigator চালানো হবে
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request permission and subscribe here
      NotificationService().requestPermissionAndSubscribe();
      
      Timer(
        const Duration(seconds: 3),
            () {
          if (!mounted) return; // Widget dispose হলে Navigator না চালায়
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MainScreen(onThemeChanged: widget.onThemeChanged),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ডার্ক/লাইট মোড অনুযায়ী ব্যাকগ্রাউন্ড রঙ পরিবর্তন হবে
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // স্প্ল্যাশ স্ক্রিনের লোগো
            Image.asset(
              'assets/icon/splash_logo.png',
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 24),
            // প্রথম লেখা
            const Text(
              'আমার বরিশাল',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // দ্বিতীয় লেখা
            const Text(
              'বরিশালের সব কিছু এখন আপনার হাতের মুঠোয়',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
