import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/auto_translated_text.dart';

class LibraryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const LibraryDetailScreen({super.key, required this.itemData});

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
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
    
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('কল করা যাচ্ছে না: ').addTextSpan(phoneNumber)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final String name = itemData['name'] ?? 'লাইব্রেরি';
    final String address = itemData['address']?.toString().isNotEmpty == true ? itemData['address'] : 'ঠিকানা পাওয়া যায়নি';
    final String officer = itemData['officer']?.toString().isNotEmpty == true ? itemData['officer'] : '';
    final String established = itemData['established']?.toString().isNotEmpty == true ? itemData['established'] : '';
    final String books = itemData['books']?.toString().isNotEmpty == true ? itemData['books'] : '';
    
    String phone = itemData['mobile']?.toString() ?? itemData['phone']?.toString() ?? '';
    if (!phone.contains(RegExp(r'[0-9০-৯]'))) {
      phone = ''; 
    }
    
    String mapLink = itemData['mapLink'] ?? '';
    if (mapLink.isEmpty && name != 'লাইব্রেরি') {
      final encodedQuery = Uri.encodeComponent('$name, $address, Barishal');
      mapLink = 'https://maps.google.com/maps?q=$encodedQuery&t=&z=15&ie=UTF8&iwloc=&output=embed';
    }

    const Color themeColor = Color(0xFF6366F1); // Indigo color for Library
    final Color bgColor1 = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFEEF2FF);
    final Color bgColor2 = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE0E7FF);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.4),
        elevation: 0,
        title: AutoTranslatedText(
          name, 
          style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black87),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgColor1, bgColor2],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDarkMode ? themeColor.withValues(alpha: 0.2) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      )
                    ]
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Library Name
                AutoTranslatedText(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Address Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 20, color: themeColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AutoTranslatedText(
                        address,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Quick Stats Row
                if (established.isNotEmpty || books.isNotEmpty)
                  Row(
                    children: [
                      if (established.isNotEmpty)
                        Expanded(child: _buildStatCard(context, 'প্রতিষ্ঠা সাল', established, Icons.history_rounded, themeColor, isDarkMode)),
                      if (established.isNotEmpty && books.isNotEmpty)
                        const SizedBox(width: 16),
                      if (books.isNotEmpty)
                        Expanded(child: _buildStatCard(context, 'মোট বই', books, Icons.library_books_rounded, const Color(0xFF10B981), isDarkMode)),
                    ],
                  ),
                const SizedBox(height: 16),

                // Officer Section
                if (officer.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                      border: Border.all(color: isDarkMode ? Colors.white10 : Colors.transparent),
                      boxShadow: [if(!isDarkMode) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0,5))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_outline_rounded, color: themeColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoTranslatedText(
                                'লাইব্রেরিয়ান / কর্মকর্তা',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white54 : Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AutoTranslatedText(
                                officer,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Call Section
                if (phone.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: () => _makePhoneCall(phone, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        shadowColor: themeColor.withValues(alpha: 0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.call_rounded, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AutoTranslatedText(
                                  'কল করুন',
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                                Text(
                                  phone,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Map Section
                if (mapLink.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                      border: Border.all(color: isDarkMode ? Colors.white10 : Colors.transparent),
                      boxShadow: [if(!isDarkMode) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0,5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.map_rounded, color: themeColor),
                            const SizedBox(width: 8),
                            AutoTranslatedText(
                              'লোকেশন ম্যাপ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: InlineMapWidget(mapUrl: mapLink),
                          ),
                        ),
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

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.transparent),
        boxShadow: [if(!isDarkMode) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0,5))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          AutoTranslatedText(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDarkMode ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 4),
          AutoTranslatedText(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white54 : Colors.black45),
          ),
        ],
      ),
    );
  }
}

class InlineMapWidget extends StatefulWidget {
  final String mapUrl;
  const InlineMapWidget({super.key, required this.mapUrl});

  @override
  State<InlineMapWidget> createState() => _InlineMapWidgetState();
}

class _InlineMapWidgetState extends State<InlineMapWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );
      
    final htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body, html { margin: 0; padding: 0; height: 100%; width: 100%; overflow: hidden; background: transparent; }
          iframe { width: 100%; height: 100%; border: 0; }
        </style>
      </head>
      <body>
        <iframe src="${widget.mapUrl}" allowfullscreen></iframe>
      </body>
      </html>
    ''';
    
    _controller.loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

extension on Text {
  Text addTextSpan(String suffix) {
    return Text((data ?? '') + suffix, style: style);
  }
}
