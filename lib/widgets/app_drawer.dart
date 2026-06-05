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

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);

    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF4F7FC),
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, spreadRadius: 1)]),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: const AssetImage('assets/icon/icon.png'), 
                        onBackgroundImageError: (_, __) => const Icon(Icons.location_city, size: 32, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lang.t('app_name'),
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user != null ? (user.email ?? lang.t('welcome')) : lang.t('drawer_subtitle'),
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // --- মেন্যু আইটেম তালিকা ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  physics: const ClampingScrollPhysics(),
                  children: <Widget>[
                    _buildDrawerItem(
                      context, icon: Icons.home_rounded, title: lang.t('home'), isDarkMode: isDarkMode,
                      onTap: () => Navigator.pop(context),
                    ),
                    
                    if (isAdmin) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                        child: Text(lang.t('admin_title'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                      ),
                      _buildDrawerItem(
                        context, icon: Icons.admin_panel_settings_rounded, title: lang.t('admin_dashboard'), isDarkMode: isDarkMode, iconColor: Colors.deepOrangeAccent,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
                        },
                      ),
                      const SizedBox(height: 8),
                    ],

                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                      child: Text(lang.t('others'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                    ),

                    _buildDrawerItem(
                      context, icon: Icons.settings_rounded, title: lang.t('settings'), isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
                      },
                    ),
                    _buildDrawerItem(
                      context, icon: Icons.info_outline_rounded, title: lang.t('about_us'), isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutMeScreen()));
                      },
                    ),
                    _buildDrawerItem(
                      context, icon: Icons.privacy_tip_outlined, title: lang.t('privacy_policy'), isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                      child: Text(lang.t('community'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                    ),

                    _buildDrawerItem(
                      context, icon: Icons.share_rounded, title: lang.t('share_app'), isDarkMode: isDarkMode, iconColor: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ShareAppScreen()));
                      },
                    ),
                    _buildDrawerItem(
                      context, icon: Icons.star_rate_rounded, title: lang.t('rate_us'), isDarkMode: isDarkMode, iconColor: Colors.amber.shade600,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RatingScreen()));
                      },
                    ),
                    _buildDrawerItem(
                      context, icon: Icons.headset_mic_rounded, title: lang.t('support'), isDarkMode: isDarkMode, iconColor: Colors.blue,
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
                        context, icon: Icons.logout_rounded, title: lang.t('logout'), isDarkMode: isDarkMode, iconColor: Colors.redAccent,
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                        },
                      )
                    else
                      _buildDrawerItem(
                        context, icon: Icons.login_rounded, title: lang.t('login'), isDarkMode: isDarkMode, iconColor: Colors.teal,
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
                      '${lang.t("version")} 4.4.1',
                      style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white54 : Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© ${lang.t("app_name")}, 2026',
                      style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white38 : Colors.black38),
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

  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon, required String title, required VoidCallback onTap, required bool isDarkMode, Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
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
                Icon(icon, size: 24, color: iconColor ?? (isDarkMode ? Colors.white70 : Colors.black54)),
                const SizedBox(width: 20),
                Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : Colors.black87))),
                Icon(Icons.chevron_right_rounded, size: 20, color: isDarkMode ? Colors.white30 : Colors.black26)
              ],
            ),
          ),
        ),
      ),
    );
  }
}