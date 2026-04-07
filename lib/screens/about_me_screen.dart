import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_about_me_screen.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  // URL (ফোন, হোয়াটসঅ্যাপ, ওয়েব) খোলার জন্য একটি হেল্পার ফাংশন
  Future<void> _launchURL(Uri uri, BuildContext context) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch ${uri.path}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const EditAboutMeScreen(),
                    ));
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('about_me')
            .doc('developer_info')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('কোনো তথ্য পাওয়া যায়নি'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'ডেভেলপার';
          final designation = data['designation'] ?? 'ডেভেলপার'; // নতুন ডেটা আনা হয়েছে
          final imageUrl = data['imageUrl'] ?? '';
          final mobile = data['mobile'] ?? '';
          final email = data['email'] ?? '';
          final facebookLink = data['facebookLink'] ?? '';
          final websiteLink = data['websiteLink'] ?? '';
          final about = data['about'] ?? 'কোনো বিবরণ নেই';

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey,
                          child: const Icon(Icons.person,
                              size: 100, color: Colors.white),
                        );
                      },
                    ),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -25, // Column ব্যবহার করার জন্য পজিশন অ্যাডজাস্ট করা হয়েছে
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        // নাম এবং পদবি একসাথে দেখানোর জন্য Column ব্যবহার করা হয়েছে
                        child: Column(
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (designation.isNotEmpty)
                              Text(
                                designation,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50), // পদবির জন্য অতিরিক্ত জায়গা
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // কন্টাক্ট ইনফরমেশন কার্ড
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('যোগাযোগের তথ্য',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const Divider(height: 24),
                              ListTile(
                                leading:
                                const Icon(Icons.phone, color: Colors.red),
                                title: const Text('মোবাইল নম্বর'),
                                subtitle: Text(mobile),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.call,
                                          color: Colors.green),
                                      onPressed: () => _launchURL(
                                          Uri(scheme: 'tel', path: mobile),
                                          context),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.message,
                                          color: Colors.teal),
                                      onPressed: () => _launchURL(
                                          Uri.parse('https://wa.me/$mobile'),
                                          context),
                                    ),
                                  ],
                                ),
                              ),
                              ListTile(
                                leading:
                                const Icon(Icons.email, color: Colors.blue),
                                title: const Text('ইমেল ঠিকানা'),
                                subtitle: Text(email),
                              ),
                              if (facebookLink.isNotEmpty)
                                ListTile(
                                  leading: const Icon(Icons.facebook,
                                      color: Colors.indigo),
                                  title: const Text('ফেসবুক লিংক'),
                                  subtitle: Text(facebookLink,
                                      style: const TextStyle(
                                          color: Colors.lightBlue)),
                                  onTap: () =>
                                      _launchURL(Uri.parse(facebookLink), context),
                                ),
                              if (websiteLink.isNotEmpty)
                                ListTile(
                                  leading: const Icon(Icons.web,
                                      color: Colors.purple),
                                  title: const Text('ওয়েবসাইট'),
                                  subtitle: Text(websiteLink,
                                      style: const TextStyle(
                                          color: Colors.lightBlue)),
                                  onTap: () =>
                                      _launchURL(Uri.parse(websiteLink), context),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // আপনার সম্বন্ধে কার্ড
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('আমার সম্বন্ধে',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const Divider(height: 24),
                              Text(about,
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

