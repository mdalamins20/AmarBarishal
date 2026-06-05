import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/auto_translated_text.dart';

class HospitalDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const HospitalDetailScreen({super.key, required this.itemData});

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
    final String name = itemData['name'] ?? 'হাসপাতাল';
    final String address = itemData['address']?.toString().isNotEmpty == true ? itemData['address'] : 'ঠিকানা পাওয়া যায়নি';
    final String providerName = itemData['provider_name'] ?? '';
    final String providerDesignation = itemData['provider_designation'] ?? '';
    final String phone = itemData['mobile']?.toString() ?? itemData['phone']?.toString() ?? '';
    
    String mapLink = itemData['mapLink'] ?? '';
    if (mapLink.isEmpty && name != 'হাসপাতাল') {
      final encodedQuery = Uri.encodeComponent('$name, Barishal');
      mapLink = 'https://maps.google.com/maps?q=$encodedQuery&t=&z=15&ie=UTF8&iwloc=&output=embed';
    }

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
        title: AutoTranslatedText(
          name, 
          style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.teal.shade900)
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.teal.shade900),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF001A1A), const Color(0xFF003333)] // Dark teal vibe
                : [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)], // Light medical teal vibe
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
                    color: isDarkMode ? Colors.teal.shade900.withOpacity(0.3) : Colors.teal.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? Colors.tealAccent.withOpacity(0.5) : Colors.teal,
                      width: 2
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ]
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    size: 80,
                    color: isDarkMode ? Colors.tealAccent : Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Hospital Name
                AutoTranslatedText(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Address Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_rounded, size: 20, color: isDarkMode ? Colors.white70 : Colors.teal.shade700),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AutoTranslatedText(
                        address,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Information Provider Section
                if (providerName.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isDarkMode ? Colors.black26 : Colors.white60,
                      border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: isDarkMode ? Colors.tealAccent : Colors.teal.shade700),
                            const SizedBox(width: 8),
                            AutoTranslatedText(
                              'তথ্য প্রদানকারী',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.tealAccent : Colors.teal.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AutoTranslatedText(
                          providerName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : Colors.black87),
                        ),
                        if (providerDesignation.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: AutoTranslatedText(
                              providerDesignation,
                              style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white70 : Colors.black54),
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
                        backgroundColor: isDarkMode ? Colors.teal.shade700 : Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        shadowColor: Colors.teal.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
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
                                  'হাসপাতালে কল করুন',
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                                Text(
                                  phone,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
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
                      color: isDarkMode ? Colors.black26 : Colors.white60,
                      border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.map_rounded, color: isDarkMode ? Colors.tealAccent : Colors.teal.shade700),
                            const SizedBox(width: 8),
                            AutoTranslatedText(
                              'লোকেশন ম্যাপ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.tealAccent : Colors.teal.shade800,
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
