import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/auto_translated_text.dart';

class AmbulanceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const AmbulanceDetailScreen({super.key, required this.itemData});

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
    final String name = itemData['name'] ?? 'এম্বুলেন্স সার্ভিস';
    final String address = itemData['address']?.toString().isNotEmpty == true ? itemData['address'] : 'ঠিকানা পাওয়া যায়নি';
    final String driverName = itemData['driver_name'] ?? '';
    
    final String mobile1 = itemData['mobile']?.toString() ?? itemData['phone']?.toString() ?? '';
    final String mobile2 = itemData['mobile2']?.toString() ?? '';
    final String mobile3 = itemData['mobile3']?.toString() ?? '';
    
    String mapLink = itemData['mapLink'] ?? '';
    if (mapLink.isEmpty && name != 'এম্বুলেন্স সার্ভিস') {
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
          style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.deepOrange.shade900)
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.deepOrange.shade900),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF331400), const Color(0xFF4A1E00)] // Dark amber/orange vibe
                : [const Color(0xFFFFF3E0), const Color(0xFFFFCC80)], // Light emergency amber vibe
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
                    color: isDarkMode ? Colors.deepOrange.shade900.withOpacity(0.3) : Colors.deepOrange.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? Colors.deepOrangeAccent.withOpacity(0.5) : Colors.deepOrange,
                      width: 2
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ]
                  ),
                  child: Icon(
                    Icons.airport_shuttle_rounded,
                    size: 80,
                    color: isDarkMode ? Colors.deepOrangeAccent : Colors.deepOrange.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Ambulance Name
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
                    Icon(Icons.location_on_rounded, size: 20, color: isDarkMode ? Colors.white70 : Colors.deepOrange.shade700),
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
                
                // Driver Section
                if (driverName.isNotEmpty)
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
                            Icon(Icons.person, color: isDarkMode ? Colors.deepOrangeAccent : Colors.deepOrange.shade700),
                            const SizedBox(width: 8),
                            AutoTranslatedText(
                              'ড্রাইভারের নাম',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.deepOrangeAccent : Colors.deepOrange.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AutoTranslatedText(
                          driverName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : Colors.black87),
                        ),
                      ],
                    ),
                  ),

                // Call Section
                if (mobile1.isNotEmpty || mobile2.isNotEmpty || mobile3.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isDarkMode 
                          ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)]
                          : [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.6)],
                      ),
                      border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
                            color: isDarkMode ? Colors.deepOrangeAccent : Colors.deepOrange.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        if (mobile1.isNotEmpty)
                          _buildCallButton(context, mobile1, 'হেল্পলাইন নাম্বার ১', isDarkMode),
                          
                        if (mobile2.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildCallButton(context, mobile2, 'হেল্পলাইন নাম্বার ২', isDarkMode),
                        ],
                        
                        if (mobile3.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildCallButton(context, mobile3, 'হেল্পলাইন নাম্বার ৩', isDarkMode),
                        ],
                      ],
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
                            Icon(Icons.map_rounded, color: isDarkMode ? Colors.deepOrangeAccent : Colors.deepOrange.shade700),
                            const SizedBox(width: 8),
                            AutoTranslatedText(
                              'লোকেশন ম্যাপ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.deepOrangeAccent : Colors.deepOrange.shade800,
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

  Widget _buildCallButton(BuildContext context, String number, String label, bool isDarkMode) {
    return ElevatedButton(
      onPressed: () => _makePhoneCall(number, context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrangeAccent.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: Colors.deepOrangeAccent.withOpacity(0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
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
