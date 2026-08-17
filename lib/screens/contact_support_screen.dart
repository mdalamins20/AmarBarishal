import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.4),
        title: Text('যোগাযোগ ও সাপোর্ট', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF151928), const Color(0xFF283149)]
                : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(Icons.headset_mic_rounded, size: 80, color: Colors.blue.shade400),
                const SizedBox(height: 16),
                Text(
                  'আমরা আছি আপনার পাশেই',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'যেকোনো প্রয়োজনে বা অ্যাপের সমস্যা জানাতে আমাদের সাথে যোগাযোগ করুন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildContactCard(
                  context: context,
                  icon: Icons.email_rounded,
                  title: 'ইমেইল করুন',
                  subtitle: 'support@mybarishal.com',
                  url: 'mailto:support@mybarishal.com',
                  color: Colors.redAccent,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildContactCard(
                  context: context,
                  icon: Icons.facebook_rounded,
                  title: 'ফেসবুক পেজ',
                  subtitle: 'fb.com/MyBarishalApp',
                  url: 'https://fb.com/MyBarishalApp',
                  color: Colors.blueAccent,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildContactCard(
                  context: context,
                  icon: Icons.phone_in_talk_rounded,
                  title: 'হটলাইন নম্বর',
                  subtitle: '+880 1234 567890',
                  url: 'tel:+8801234567890',
                  color: Colors.green,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchIntent(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String url,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDarkMode 
            ? [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)]
            : [Colors.white.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.4)],
        ),
        border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black87)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(subtitle, style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black54)),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: isDarkMode ? Colors.white30 : Colors.black26),
            onTap: () {
              _launchIntent(url);
            },
          ),
        ),
      ),
    );
  }
}
