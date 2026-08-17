import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/auto_translated_text.dart';

class FireServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const FireServiceDetailScreen({super.key, required this.itemData});

  Future<void> _makePhoneCall(String phoneNumber) async {
    const bengaliToEnglish = {
      '০': '0', '১': '1', '২': '2', '৩': '3', '৪': '4',
      '৫': '5', '৬': '6', '৭': '7', '৮': '8', '৯': '9',
    };
    
    String englishNumber = phoneNumber;
    bengaliToEnglish.forEach((bn, en) {
      englishNumber = englishNumber.replaceAll(bn, en);
    });

    final cleanNumber = englishNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanNumber.isEmpty) return;
    
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String name = itemData['name'] ?? 'ফায়ার সার্ভিস স্টেশন';
    final String district = itemData['district'] ?? itemData['address'] ?? 'অজানা জেলা';
    final String mobile1 = itemData['mobile']?.toString() ?? '';
    final String mobile2 = itemData['mobile2']?.toString() ?? '';

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
        title: AutoTranslatedText(
          name, 
          style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF2A0800), const Color(0xFF4A1000)] // Dark emergency red vibe
                : [const Color(0xFFFFE0D6), const Color(0xFFFFC0B2)], // Light emergency red vibe
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? Colors.redAccent.withValues(alpha: 0.5) : Colors.redAccent,
                      width: 2
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ]
                  ),
                  child: Icon(
                    Icons.fire_truck_rounded,
                    size: 80,
                    color: isDarkMode ? Colors.redAccent : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Station Name
                AutoTranslatedText(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // District Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_rounded, size: 20, color: isDarkMode ? Colors.white70 : Colors.black54),
                    const SizedBox(width: 4),
                    AutoTranslatedText(
                      district,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Emergency Calling Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: isDarkMode 
                        ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.03)]
                        : [Colors.white.withValues(alpha: 0.9), Colors.white.withValues(alpha: 0.6)],
                    ),
                    border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      AutoTranslatedText(
                        'জরুরী প্রয়োজনে কল করুন',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.redAccent : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      if (mobile1.isNotEmpty)
                        _buildCallButton(context, mobile1, 'হেল্পলাইন নাম্বার ১', isDarkMode),
                        
                      if (mobile1.isNotEmpty && mobile2.isNotEmpty)
                        const SizedBox(height: 16),
                        
                      if (mobile2.isNotEmpty)
                        _buildCallButton(context, mobile2, 'হেল্পলাইন নাম্বার ২', isDarkMode),
                        
                      if (mobile1.isEmpty && mobile2.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AutoTranslatedText(
                            'কোনো নাম্বার পাওয়া যায়নি',
                            style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton(BuildContext context, String number, String label, bool isDarkMode) {
    return ElevatedButton(
      onPressed: () => _makePhoneCall(number),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: Colors.redAccent.withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.call_rounded, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoTranslatedText(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
