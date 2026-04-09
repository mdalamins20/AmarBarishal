import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_barishal_new/screens/admin/manage_categories_screen.dart';
import 'package:my_barishal_new/screens/admin/manage_news_links_screen.dart';
import 'package:my_barishal_new/screens/admin/admin_manage_data_categories_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
        backgroundColor: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
        title: Text('অ্যাডমিন ড্যাশবোর্ড', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
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
                ? [const Color(0xFF151928), const Color(0xFF2B1F31), const Color(0xFF1F2B3A)]
                : [const Color(0xFFE0EAFC), const Color(0xFFF3E7E9), const Color(0xFFCFDEF3)],
          ),
        ),
        child: SafeArea(
          child: AnimationLimiter(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 600),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'সম্পূর্ণ অ্যাপ নিয়ন্ত্রণ কেন্দ্র',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'এখান থেকে অ্যাপের সবকিছু ম্যানেজ করতে পারবেন। ম্যানুয়ালি ফায়ারবেস বা ডাটাবেজে যাওয়ার কোনো প্রয়োজন নেই।',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  _buildAdminTile(
                    context,
                    title: 'ক্যাটাগরি পরিচালনা',
                    subtitle: 'হোম পেজের মূল আইকন ও নাম এডিট করুন',
                    icon: Icons.category_rounded,
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()));
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildAdminTile(
                    context,
                    title: 'সকল তথ্য/ডেটা পরিচালনা',
                    subtitle: 'বিভিন্ন ক্যাটাগরির ভেতরের ডাটা অ্যাড বা রিমুভ করুন',
                    icon: Icons.storage_rounded,
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminManageDataCategoriesScreen()));
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildAdminTile(
                    context,
                    title: 'নিউজ লিংক পরিচালনা',
                    subtitle: 'খবরের লিংক ও শিরোনাম পরিবর্তন করুন',
                    icon: Icons.newspaper_rounded,
                    color: Colors.purpleAccent,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageNewsLinksScreen()));
                    },
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminTile(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDarkMode 
            ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)]
            : [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.4)],
        ),
        border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              highlightColor: color.withOpacity(0.1),
              splashColor: color.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 36),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: isDarkMode ? Colors.white30 : Colors.black26, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
