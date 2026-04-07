import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // তারিখ ফরম্যাট করার জন্য
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    _markNotificationsAsRead();
  }

  // নতুন নোটিফিকেশন আছে কিনা সেই স্ট্যাটাসটি false করে দেওয়া হচ্ছে
  Future<void> _markNotificationsAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasNewNotification', false);
    // প্রয়োজন হলে ডেটাবেসে থাকা প্রতিটি নোটিফিকেশনের 'isRead' স্ট্যাটাসও true করা যেতে পারে
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('নোটিফিকেশন'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore-এর 'notifications' কালেকশন থেকে ডেটা আনা হচ্ছে
        // sentTime অনুযায়ী নতুনগুলো আগে দেখানো হচ্ছে
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('sentTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // ডেটা লোড হওয়ার সময় লোডিং অ্যানিমেশন দেখানো হচ্ছে
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // কোনো এরর হলে এরর মেসেজ দেখানো হচ্ছে
          if (snapshot.hasError) {
            return const Center(child: Text('একটি সমস্যা হয়েছে'));
          }
          // যদি কোনো নোটিফিকেশন না থাকে
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('কোনো নোটিফিকেশন নেই'));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              final title = notification['title'] ?? 'No Title';
              final body = notification['body'] ?? 'No Body';
              final timestamp = notification['sentTime'] as Timestamp?;

              // তারিখ ফরম্যাট করা হচ্ছে
              final formattedDate = timestamp != null
                  ? DateFormat('dd MMM, yyyy hh:mm a').format(timestamp.toDate())
                  : 'No date';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$body\n$formattedDate'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}