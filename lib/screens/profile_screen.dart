import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'package:my_barishal_new/screens/about_me_screen.dart';
import 'package:my_barishal_new/screens/admin/admin_dashboard_screen.dart';
import 'package:my_barishal_new/screens/login_screen.dart';
import 'package:my_barishal_new/screens/settings_screen.dart';
import 'package:my_barishal_new/screens/privacy_policy_screen.dart';
import 'package:my_barishal_new/screens/share_app_screen.dart';
import 'package:my_barishal_new/screens/rating_screen.dart';
import 'package:my_barishal_new/screens/contact_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final bool isAdmin = user != null && 
            (user.uid == 'kMebekIJbSbc2xceG2SsgJSN8XR2' || 
             user.email == 'mdalaminkhalifa2002@gmail.com');

          // To help debugging, we can show their email in the UI
          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // --- সুন্দর কাস্টম প্রোফাইল হেডার ---
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 30,
                    bottom: 40,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode 
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFF0F4C81), const Color(0xFF22A699)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDarkMode ? Colors.black : const Color(0xFF0F4C81)).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            )
                          ]
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: const AssetImage('assets/icon/icon.png'), 
                          onBackgroundImageError: (_, __) => const Icon(Icons.location_city, size: 50, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        lang.t('app_name'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user != null ? (user.email ?? lang.t('welcome')) : lang.t('drawer_subtitle'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- মেন্যু আইটেম তালিকা ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (isAdmin) ...[
                      _buildSectionHeader(lang.t('admin_title'), isDarkMode),
                      _buildProfileItem(
                        context, icon: Icons.admin_panel_settings_rounded, title: lang.t('admin_dashboard'), isDarkMode: isDarkMode, iconColor: Colors.deepOrangeAccent,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    _buildSectionHeader(lang.t('others'), isDarkMode),
                    _buildProfileItem(
                      context, icon: Icons.settings_rounded, title: lang.t('settings'), isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
                      },
                    ),
                    _buildProfileItem(
                      context, icon: Icons.info_outline_rounded, title: lang.t('about_us'), isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutMeScreen()));
                      },
                    ),
                    _buildProfileItem(
                      context, icon: Icons.privacy_tip_outlined, title: lang.t('privacy_policy'), isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader(lang.t('community'), isDarkMode),
                    _buildProfileItem(
                      context, icon: Icons.share_rounded, title: lang.t('share_app'), isDarkMode: isDarkMode, iconColor: Colors.green,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ShareAppScreen()));
                      },
                    ),
                    _buildProfileItem(
                      context, icon: Icons.star_rate_rounded, title: lang.t('rate_us'), isDarkMode: isDarkMode, iconColor: Colors.amber.shade600,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RatingScreen()));
                      },
                    ),
                    _buildProfileItem(
                      context, icon: Icons.headset_mic_rounded, title: lang.t('support'), isDarkMode: isDarkMode, iconColor: Colors.blue,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ContactSupportScreen()));
                      },
                    ),

                    const SizedBox(height: 32),
                    
                    if (user != null)
                      _buildProfileItem(
                        context, icon: Icons.logout_rounded, title: lang.t('logout'), isDarkMode: isDarkMode, iconColor: Colors.redAccent,
                        isLogout: true,
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                        },
                      )
                    else
                      _buildProfileItem(
                        context, icon: Icons.login_rounded, title: lang.t('login'), isDarkMode: isDarkMode, iconColor: Colors.teal,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                        },
                      ),
                      
                    // --- ফুটার ভার্সন ইনফো ---
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '${lang.t("version")} 4.4.1',
                            style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white54 : Colors.black54, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '© ${lang.t("app_name")}, 2026',
                            style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white38 : Colors.black38),
                          ),
                          const SizedBox(height: 80), // Padding for bottom nav bar
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title, 
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: isDarkMode ? Colors.white60 : Colors.grey.shade600, 
          fontSize: 14,
          letterSpacing: 1.1
        )
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, {
    required IconData icon, required String title, required VoidCallback onTap, required bool isDarkMode, Color? iconColor, bool isLogout = false
  }) {
    final bgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final shadowColor = isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04);
    final iColor = iconColor ?? (isDarkMode ? Colors.white70 : Colors.black87);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: isLogout ? Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: iColor.withOpacity(0.1),
          highlightColor: iColor.withOpacity(0.05),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: iColor),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title, 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600, 
                      color: isLogout ? Colors.redAccent : (isDarkMode ? Colors.white : Colors.black87)
                    )
                  )
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded, 
                  size: 16, 
                  color: isDarkMode ? Colors.white30 : Colors.black26
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
