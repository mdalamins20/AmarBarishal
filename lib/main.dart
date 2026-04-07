import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

// Background message handler অবশ্যই টপ-লেভেল ফাংশন হতে হবে
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // background isolate-এর জন্য Firebase আবার initialize করতে হয়
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().saveNotification(message);
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

Future<void> main() async {
  // 1. Flutter engine-এর সাথে সব বাইন্ডিং নিশ্চিত করা
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase সার্ভিস শুরু করা
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Firestore-এর জন্য অফলাইন ডেটা চালু করা
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  // 4. শুধুমাত্র মোবাইল প্ল্যাটফর্মে নোটিফিকেশন সার্ভিস সেটআপ করা
  //    kIsWeb ব্যবহার করা defaultTargetPlatform চেক করার চেয়ে সহজ
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await NotificationService().initNotifications();
  }

  // 5. অ্যাপ রান করা
  runApp(const MyBarishalApp());
}

// থিমের ডেটা build মেথডের বাইরে রাখা হয়েছে পারফরম্যান্সের জন্য
final _lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5), // হালকা ধূসর রঙ
  textTheme: GoogleFonts.hindSiliguriTextTheme(ThemeData.light().textTheme),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 1,
    titleTextStyle: GoogleFonts.hindSiliguri(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    actionsIconTheme: const IconThemeData(color: Colors.black),
  ),
  useMaterial3: true,
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.dark,
  ),
  textTheme: GoogleFonts.hindSiliguriTextTheme(ThemeData.dark().textTheme),
  appBarTheme: AppBarTheme(
    titleTextStyle: GoogleFonts.hindSiliguri(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    actionsIconTheme: const IconThemeData(color: Colors.white),
  ),
  useMaterial3: true,
);


class MyBarishalApp extends StatefulWidget {
  const MyBarishalApp({super.key});
  @override
  State<MyBarishalApp> createState() => _MyBarishalAppState();
}

class _MyBarishalAppState extends State<MyBarishalApp> {
  // অ্যাপের থিম স্টেট ম্যানেজ করার জন্য ভেরিয়েবল
  ThemeMode _themeMode = ThemeMode.system; // সিস্টেম ডিফল্ট দিয়ে শুরু হবে
  bool _isLoadingTheme = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // SharedPreferences থেকে সেভ করা থিম লোড করা
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // উইজেট dispose হয়ে গেলে যেন setState কল না হয়, তার জন্য mounted চেক
    if (mounted) {
      final isDarkMode = prefs.getBool('isDarkMode');
      setState(() {
        if (isDarkMode == null) {
          _themeMode = ThemeMode.system; // কোনো সেটিং না থাকলে সিস্টেম থিম
        } else {
          _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
        }
        _isLoadingTheme = false;
      });
    }
  }

  // থিম পরিবর্তন করার ফাংশন
  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        final isCurrentlyDark = _themeMode == ThemeMode.dark ||
            (_themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        _themeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
        prefs.setBool('isDarkMode', !isCurrentlyDark);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // থিম লোড হওয়ার আগ পর্যন্ত লোডিং স্ক্রিন দেখানো
    if (_isLoadingTheme) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'আমার বরিশাল',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _themeMode,
      // SplashScreen-এ onThemeChanged ফাংশনটি পাস করা হয়েছে
      home: SplashScreen(onThemeChanged: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}