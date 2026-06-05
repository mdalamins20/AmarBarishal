import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/auto_translated_text.dart';
import 'edit_about_me_screen.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  Future<void> _launchURL(Uri uri, BuildContext context) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch ${uri.path}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = const Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1219) : const Color(0xFFF4F6FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
           onTap: () => Navigator.pop(context),
           child: Container(
             margin: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: Colors.black.withOpacity(0.3),
               shape: BoxShape.circle,
             ),
             child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
           ),
        ),
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return GestureDetector(
                   onTap: () {
                     Navigator.of(context).push(MaterialPageRoute(
                       builder: (context) => const EditAboutMeScreen(),
                     ));
                   },
                   child: Container(
                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: Colors.black.withOpacity(0.3),
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                   ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('about_me').doc('developer_info').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('কোনো তথ্য পাওয়া যায়নি'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'ডেভেলপার';
          final designation = data['designation'] ?? 'ডেভেলপার';
          final imageUrl = data['imageUrl'] ?? '';
          final mobile = data['mobile'] ?? '';
          final email = data['email'] ?? '';
          final facebookLink = data['facebookLink'] ?? '';
          final websiteLink = data['websiteLink'] ?? '';
          final about = data['about'] ?? 'কোনো বিবরণ নেই';

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                // ─── Beautiful Header Stack ────
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Profile Background Image
                    Image.network(
                      imageUrl,
                      height: 320,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 320,
                          width: double.infinity,
                          decoration: BoxDecoration(
                             gradient: LinearGradient(
                               colors: [accentColor.withOpacity(0.5), accentColor],
                               begin: Alignment.topLeft, end: Alignment.bottomRight,
                             ),
                          ),
                          child: const Icon(Icons.person, size: 100, color: Colors.white54),
                        );
                      },
                    ),
                    // Gradient Overlay for readability
                    Container(
                      height: 320,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isDark ? const Color(0xFF0F1219) : const Color(0xFFF4F6FA),
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    
                    // Floating Name Badge
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2533) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            AutoTranslatedText(
                              name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (designation.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: AutoTranslatedText(
                                  designation.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Contact Action Buttons ────
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.call_rounded,
                              label: 'কল করুন',
                              color: Colors.green,
                              isDark: isDark,
                              onTap: () => _launchURL(Uri.parse('tel:$mobile'), context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.message_rounded,
                              label: 'হোয়াটসঅ্যাপ',
                              color: Colors.teal,
                              isDark: isDark,
                              onTap: () => _launchURL(Uri.parse('https://wa.me/$mobile'), context),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // ─── Links Info Card ────
                      _buildSectionTitle('যোগাযোগের মাধ্যম', isDark),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2533) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                             BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 15, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (mobile.isNotEmpty) _buildInfoTile(icon: Icons.phone_android_rounded, title: 'মোবাইল', subtitle: mobile, iconColor: Colors.green, isDark: isDark, onTap: () => _launchURL(Uri.parse('tel:$mobile'), context)),
                            if (mobile.isNotEmpty) _buildDivider(isDark),
                            if (email.isNotEmpty) _buildInfoTile(icon: Icons.alternate_email_rounded, title: 'ইমেইল', subtitle: email, iconColor: Colors.redAccent, isDark: isDark, onTap: () => _launchURL(Uri.parse('mailto:$email'), context)),
                            if (email.isNotEmpty) _buildDivider(isDark),
                            if (facebookLink.isNotEmpty) _buildInfoTile(icon: Icons.facebook_rounded, title: 'ফেসবুক', subtitle: 'প্রোফাইল ভিজিট করুন', iconColor: Colors.blue, isDark: isDark, onTap: () => _launchURL(Uri.parse(facebookLink), context)),
                            if (facebookLink.isNotEmpty && websiteLink.isNotEmpty) _buildDivider(isDark),
                            if (websiteLink.isNotEmpty) _buildInfoTile(icon: Icons.language_rounded, title: 'ওয়েবসাইট', subtitle: 'ভিজিট করুন', iconColor: Colors.purple, isDark: isDark, onTap: () => _launchURL(Uri.parse(websiteLink), context)),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // ─── About Section ────
                      _buildSectionTitle('আমার সম্বন্ধে', isDark),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2533) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                             BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 15, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: AutoTranslatedText(
                          about,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 50),
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: AutoTranslatedText(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required bool isDark, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            AutoTranslatedText(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, indent: 64, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade100);
  }

  Widget _buildInfoTile({
    required IconData icon, required String title, required String subtitle, required Color iconColor, required bool isDark, required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoTranslatedText(title, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  AutoTranslatedText(subtitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, size: 18, color: isDark ? Colors.white30 : Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
