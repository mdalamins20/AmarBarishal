import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_barishal_new/screens/about_me_screen.dart';
import 'package:my_barishal_new/screens/admin/manage_categories_screen.dart';
import 'package:my_barishal_new/screens/admin/manage_news_links_screen.dart';
import 'package:my_barishal_new/screens/login_screen.dart';
import 'package:my_barishal_new/screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          // 🔴 জরুরি: এখানে আপনার নিজের আসল অ্যাডমিন User ID (UID) দিন
          // এই পদ্ধতিটি নিরাপদ নয়। নিচের পরামর্শ দেখুন।
          final bool isAdmin = user != null && user.uid == 'YOUR_ADMIN_UID_HERE';

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Text('আমার বরিশাল', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),

              // --- শুধুমাত্র অ্যাডমিনদের জন্য বিশেষ মেন্যু ---
              if (isAdmin) ...[
                ListTile(
                  leading: const Icon(Icons.dashboard_customize),
                  title: const Text('ক্যাটাগরি পরিচালনা'),
                  onTap: () {
                    Navigator.pop(context); // Drawer বন্ধ করার জন্য
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('নিউজ লিংক পরিচালনা'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ManageNewsLinksScreen()));
                  },
                ),
                const Divider(), // অ্যাডমিন মেন্যুর পর একটি দাগ
              ],

              // --- সকল ব্যবহারকারীর জন্য কমন মেন্যু এখানে যোগ করা হয়েছে ---
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('সেটিংস'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('আমাদের সম্পর্কে'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutMeScreen()));
                },
              ),
              const Divider(),

              // --- ব্যবহারকারীর লগইন অবস্থার উপর ভিত্তি করে বাটন যোগ করা হয়েছে ---
              if (user != null)
              // যদি ব্যবহারকারী লগইন করা থাকে
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('লগআউট'),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                )
              else
              // যদি ব্যবহারকারী লগইন করা না থাকে
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('লগইন'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}