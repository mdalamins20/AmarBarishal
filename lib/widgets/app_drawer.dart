import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_barishal_new/screens/about_me_screen.dart';
import 'package:my_barishal_new/screens/admin/admin_dashboard_screen.dart';
import 'package:my_barishal_new/screens/login_screen.dart';
import 'package:my_barishal_new/screens/settings_screen.dart';
import 'package:my_barishal_new/screens/privacy_policy_screen.dart';
import 'package:my_barishal_new/screens/share_app_screen.dart';
import 'package:my_barishal_new/screens/rating_screen.dart';
import 'package:my_barishal_new/screens/contact_support_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showComingSoonMessage(BuildContext context, String feature) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature শিঘ্রই আসছে!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF4F7FC),
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          // 🔴 জরুরি: এখানে আপনার নিজের আসল অ্যাডমিন User ID (UID) দিন
          final bool isAdmin = user != null && user.uid == 'u8bcTPpfyBddB52zSChZFF9Fldj2';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- সুন্দর কাস্টম ড্রয়ার হেডার ---
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 30,
                  bottom: 30,
                  left: 24,
                  right: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode 
                      ? [const Color(0xFF2B2B4A), const Color(0xFF16213E)]
                      : [const Color(0xFF448AFF), const Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: const AssetImage('assets/icon/icon.png'), // আপনার লোগো
                            // যদি লোগো লোড না হয় তবে নিচের আইকনটি দেখাবে
                            onBackgroundImageError: (_, __) => const Icon(Icons.location_city, size: 32, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'আমার বরিশাল',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user != null ? (user.email ?? 'স্বাগতম, ব্যবহারকারী') : 'বরিশালের সেরা স্মার্ট গাইড',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // --- মেন্যু আইটেম তালিকা ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  children: <Widget>[
                    _buildDrawerItem(
                      context,
                      icon: Icons.home_rounded,
                      title: 'হোম',
                      isDarkMode: isDarkMode,
                      onTap: () => Navigator.pop(context),
                    ),
                    
                    if (isAdmin) ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                        child: Text('অ্যাডমিন প্যানেল', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.admin_panel_settings_rounded,
                        title: 'অ্যাডমিন ড্যাশবোর্ড',
                        isDarkMode: isDarkMode,
                        iconColor: Colors.deepOrangeAccent,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
                        },
                      ),
                      const SizedBox(height: 8),
                    ],

                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                      child: Text('অন্যান্য', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                    ),

                    _buildDrawerItem(
                      context,
                      icon: Icons.settings_rounded,
                      title: 'সেটিংস',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: 'আমাদের সম্পর্কে',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutMeScreen()));
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'প্রাইভেসি পলিসি',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                      },
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                      child: Text('কমিউনিটি', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                    ),

                    _buildDrawerItem(
                      context,
                      icon: Icons.share_rounded,
                      title: 'বন্ধুদের সাথে শেয়ার করুন',
                      isDarkMode: isDarkMode,
                      iconColor: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ShareAppScreen()));
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.star_rate_rounded,
                      title: 'রেটিং দিন (Rate Us)',
                      isDarkMode: isDarkMode,
                      iconColor: Colors.amber.shade600,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RatingScreen()));
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.headset_mic_rounded,
                      title: 'যোগাযোগ ও সাপোর্ট',
                      isDarkMode: isDarkMode,
                      iconColor: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ContactSupportScreen()));
                      },
                    ),

                    const SizedBox(height: 16),
                    Divider(color: isDarkMode ? Colors.white12 : Colors.black12, thickness: 1),
                    const SizedBox(height: 8),
                    
                    if (user != null)
                      _buildDrawerItem(
                        context,
                        icon: Icons.logout_rounded,
                        title: 'লগআউট',
                        isDarkMode: isDarkMode,
                        iconColor: Colors.redAccent,
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                        },
                      )
                    else
                      _buildDrawerItem(
                        context,
                        icon: Icons.login_rounded,
                        title: 'লগইন করুন',
                        isDarkMode: isDarkMode,
                        iconColor: Colors.teal,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                        },
                      ),
                  ],
                ),
              ),

              // --- ফুটার ভার্সন ইনফো ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      'ভার্সন ১.০.০',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© আমার বরিশাল, ২০২৬',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // কাস্টম মেন্যু আইটেম বিল্ডার ফাংশন
  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon, 
    required String title, 
    required VoidCallback onTap, 
    required bool isDarkMode,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // hover/tap effect-এর জন্য Material ব্যবহার করা হয়েছে নিচে
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: isDarkMode ? Colors.white12 : Colors.black12,
          highlightColor: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon, 
                  size: 24, 
                  color: iconColor ?? (isDarkMode ? Colors.white70 : Colors.black54)
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDarkMode ? Colors.white30 : Colors.black26,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}