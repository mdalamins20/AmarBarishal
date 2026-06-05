import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/notification_screen.dart';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // নোটিফিকেশন সিস্টেম চালু করার ফাংশন
  Future<void> initNotifications() async {
    // শুধুমাত্র সমর্থিত প্ল্যাটফর্মের জন্য কাজ করবে
    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    // Request permission and subscribe AFTER app is rendered.
    // We will call requestPermission() from the UI.

    // FCM টোকেন প্রিন্ট করা হচ্ছে (টেস্টিং এর জন্য)
    final fcmToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $fcmToken');
    }

    // লোকাল নোটিফিকেশন প্লাগইন চালু করা হচ্ছে
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('notification_icon'); // আমাদের তৈরি করা আইকন
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _navigateToNotificationScreen();
      },
    );

    // Create high importance channel specifically for Android 8+
    if (defaultTargetPlatform == TargetPlatform.android) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // অ্যাপ যখন খোলা থাকবে (ফোরগ্রাউন্ড), তখন নোটিফিকেশন হ্যান্ডেল করার জন্য
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
      }
      // লোকাল নোটিফিকেশন দেখানো হচ্ছে
      _showLocalNotification(message);
      // ডেটাবেসে নোটিফিকেশন সেভ করা হচ্ছে
      saveNotification(message);
    });

    // অ্যাপ ব্যাকগ্রাউন্ডে থাকলে নোটিফিকেশনে ক্লিক করলে
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateToNotificationScreen();
    });

    // অ্যাপ পুরোপুরি বন্ধ (terminated) অবস্থায় নোটিফিকেশনে ক্লিক করলে
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // একটু সময় নিয়ে নেভিগেট করতে হবে, কারণ অ্যাপ সদ্য চালু হচ্ছে
      Future.delayed(const Duration(milliseconds: 1000), () {
        _navigateToNotificationScreen();
      });
    }
  }

  void _navigateToNotificationScreen() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (context) => const NotificationScreen()),
      );
    }
  }

  // লোকাল নোটিফিকেশন দেখানোর জন্য প্রাইভেট ফাংশন
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // চ্যানেল আইডি
            'High Importance Notifications', // চ্যানেল নাম
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  // ডেটাবেসে নোটিফিকেশন সেভ করার ফাংশন (আর প্রয়োজন নেই, কারণ এডমিন প্যানেল সরাসরি গ্লোবাল ডাটাবেসে সেভ করবে)
  // তবে আনরিড ব্যাজ দেখানোর জন্য SharedPreferences এ সেভ করে রাখছি।
  Future<void> saveNotification(RemoteMessage message) async {
    if (message.notification == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasNewNotification', true);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notification status: $e');
      }
    }
  }

  // Request notification permission and subscribe to topic
  // Call this from the UI (like splash screen) after the app is loaded
  Future<void> requestPermissionAndSubscribe() async {
    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }
      
      // Also subscribe to topic
      await _firebaseMessaging.subscribeToTopic('all_users');
      if (kDebugMode) {
        print('Subscribed to all_users topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting permission or subscribing: $e');
      }
    }
  }
}

