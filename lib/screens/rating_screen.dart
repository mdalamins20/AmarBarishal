import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedRating = 0;

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
        title: Text('রেটিং দিন (Rate Us)', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: isDarkMode 
                      ? [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)]
                      : [Colors.white.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.5)],
                  ),
                  border: Border.all(color: isDarkMode ? Colors.white24 : Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      children: [
                        Icon(
                          Icons.stars_rounded, 
                          size: 80, 
                          color: Colors.amber.shade500
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'আপনার অভিজ্ঞতা কেমন?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'আমরা সর্বদা সেবার মান উন্নত করার চেষ্টা করছি। প্লে স্টোরে আপনার সুন্দর রিভিউ আমাদের অনুপ্রেরণা যোগাবে।',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              iconSize: 40,
                              icon: Icon(
                                index < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                                color: Colors.amber.shade500,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedRating = index + 1;
                                });
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                            ),
                            icon: const Icon(Icons.thumb_up_alt_rounded),
                            label: const Text('প্লে স্টোরে রেটিং দিন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final Uri uri = Uri.parse('https://play.google.com/store/apps/details?id=com.app.mybarishal');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
