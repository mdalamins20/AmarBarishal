import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // নোটিফিকেশন সিস্টেম চালু করার ফাংশন
  Future<void> initNotifications() async {
    // শুধুমাত্র সমর্থিত প্ল্যাটফর্মের জন্য কাজ করবে
    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    // ব্যবহারকারীর কাছে অনুমতি চাওয়া হচ্ছে
    await _firebaseMessaging.requestPermission();

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
    await _localNotifications.initialize(initializationSettings);

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

  // ডেটাবেসে নোটিফিকেশন সেভ করার ফাংশন
  Future<void> saveNotification(RemoteMessage message) async {
    if (message.notification == null) return;

    final notificationData = {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'sentTime': message.sentTime ?? DateTime.now(),
      'isRead': false,
    };

    try {
      await FirebaseFirestore.instance.collection('notifications').add(notificationData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasNewNotification', true);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notification: $e');
      }
    }
  }
}

