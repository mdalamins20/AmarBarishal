import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/auto_translated_text.dart';

class SosListScreen extends StatelessWidget {
  const SosListScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Remove non-numeric characters for dialing, but keep + if needed
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) return;
    
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
        elevation: 0,
        title: AutoTranslatedText('জরুরি হটলাইন (SOS)', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF1A1A24), const Color(0xFF2B2D42)]
                : [const Color(0xFFFFF0F0), const Color(0xFFFFE0E0)], // Soft red gradient for emergency
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').doc('sos').collection('items').orderBy('order').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: AutoTranslatedText('কোনো হটলাইন পাওয়া যায়নি', 
                    style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white70 : Colors.black54)),
                );
              }

              final items = snapshot.data!.docs;

              return AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final data = items[index].data() as Map<String, dynamic>;
                    final logoUrl = data['logo'] ?? '';
                    final link = data['link'] ?? '';
                    final shortcode = data['shortcode'] ?? '';
                    final description = data['description'] ?? '';

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                              border: Border.all(color: isDarkMode ? Colors.redAccent.withOpacity(0.3) : Colors.red.withOpacity(0.2), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(isDarkMode ? 0.05 : 0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (logoUrl.isNotEmpty) ...[
                                        Container(
                                          width: double.infinity,
                                          height: 100,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 4,
                                              )
                                            ]
                                          ),
                                          child: Image.network(
                                            logoUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, color: Colors.red, size: 40),
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      Row(
                                        children: [
                                          const Icon(Icons.phone_in_talk, color: Colors.redAccent, size: 24),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: AutoTranslatedText(
                                              shortcode,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ),
                                          if (shortcode.isNotEmpty)
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.call, color: Colors.white, size: 18),
                                              label: const Text('কল করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.redAccent,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                elevation: 2,
                                              ),
                                              onPressed: () => _makePhoneCall(shortcode),
                                            ),
                                        ],
                                      ),
                                      if (link.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        InkWell(
                                          onTap: () => _launchUrl(link),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.language, size: 18, color: Colors.blueAccent),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  link,
                                                  style: const TextStyle(
                                                    color: Colors.blueAccent,
                                                    decoration: TextDecoration.underline,
                                                    fontSize: 14,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      if (description.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        const Divider(height: 1),
                                        const SizedBox(height: 12),
                                        AutoTranslatedText(
                                          description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.5,
                                            color: isDarkMode ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
