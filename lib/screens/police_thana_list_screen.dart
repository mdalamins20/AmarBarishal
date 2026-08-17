import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/auto_translated_text.dart';

class PoliceThanaListScreen extends StatelessWidget {
  final Map<String, dynamic> upazilaData;

  const PoliceThanaListScreen({super.key, required this.upazilaData});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final name = upazilaData['name'] ?? 'উপজেলার নাম নেই';
    final thanas = (upazilaData['thanas'] as List<dynamic>?) ?? [];

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
        elevation: 0,
        title: AutoTranslatedText('$name - পুলিশ ও থানা', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
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
          child: thanas.isEmpty
              ? Center(
                  child: AutoTranslatedText('কোনো তথ্য পাওয়া যায়নি',
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54, fontSize: 18)))
              : AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: thanas.length,
                    itemBuilder: (context, index) {
                      final thana = thanas[index] as Map<String, dynamic>? ?? {};
                      final tName = thana['name'] ?? 'থানার নাম নেই';
                      final ocName = thana['oc_name'] ?? 'অফিসার ইনচার্জ';
                      final phone = thana['phone'] ?? '';
                      final address = thana['address'] ?? '';

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: isDarkMode 
                                    ? [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)]
                                    : [Colors.white.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.4)],
                                ),
                                border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withValues(alpha: 0.15),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.local_police_rounded, color: Colors.blue, size: 28),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: AutoTranslatedText(
                                                tName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: isDarkMode ? Colors.white : Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.person_outline, size: 20, color: isDarkMode ? Colors.white54 : Colors.black54),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: AutoTranslatedText(
                                                ocName,
                                                style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black87),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (address.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.location_on_outlined, size: 20, color: isDarkMode ? Colors.white54 : Colors.black54),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: AutoTranslatedText(
                                                  address,
                                                  style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white60 : Colors.black54),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (phone.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () => _makePhoneCall(phone),
                                              icon: const Icon(Icons.call, color: Colors.white),
                                              label: const Text('কল করুন', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blueAccent,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                elevation: 2,
                                              ),
                                            ),
                                          ),
                                        ]
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
                ),
        ),
      ),
    );
  }
}
