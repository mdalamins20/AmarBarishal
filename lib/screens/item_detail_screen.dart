import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/auto_translated_text.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final String categoryId;

  const ItemDetailScreen({
    super.key,
    required this.itemData,
    required this.categoryId,
  });

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

  Future<void> _launchGoogleMaps(String mapUrl, BuildContext context) async {
    final Uri mapUri = Uri.parse(mapUrl);
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('ম্যাপ খোলা যাচ্ছে না: ').addTextSpan(mapUrl)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final name = itemData['name'] ?? 'নাম পাওয়া যায়নি';
    final address = itemData['address'] ?? 'ঠিকানা পাওয়া যায়নি';
    final headmaster = itemData['headmaster'] ?? 'পাওয়া যায়নি';
    final phone = itemData['mobile']?.toString() ?? itemData['phone']?.toString() ?? '';
    
    String mapLink = itemData['mapLink'] ?? '';
    if (mapLink.isEmpty && name != 'নাম পাওয়া যায়নি') {
      final encodedQuery = Uri.encodeComponent('$name, Barishal');
      mapLink = 'https://maps.google.com/maps?q=$encodedQuery&t=&z=15&ie=UTF8&iwloc=&output=embed';
    }

    final bool isSchoolCollege = categoryId == 'schoolCollege';
    final bool isHospital = categoryId == 'hospital';
    final bool isAmbulance = categoryId == 'ambulance';

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
        title: AutoTranslatedText(name, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: isDarkMode 
                    ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
                    : [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.4)],
                ),
                border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          icon: Icons.location_on_rounded,
                          color: isDarkMode ? Colors.blueAccent : Colors.blue.shade700,
                          title: 'ঠিকানা',
                          content: address,
                          isDarkMode: isDarkMode,
                        ),
                        if (isSchoolCollege) ...[
                          Divider(height: 32, color: isDarkMode ? Colors.white24 : Colors.black12),
                          _buildInfoSection(
                            icon: Icons.person_rounded,
                            color: isDarkMode ? Colors.tealAccent : Colors.teal.shade700,
                            title: 'প্রধান শিক্ষক',
                            content: headmaster,
                            isDarkMode: isDarkMode,
                          ),
                        ],
                        if (isHospital) ...[
                          Divider(height: 32, color: isDarkMode ? Colors.white24 : Colors.black12),
                          _buildInfoSection(
                            icon: Icons.person_rounded,
                            color: isDarkMode ? Colors.tealAccent : Colors.teal.shade700,
                            title: 'তথ্য প্রদানকারী',
                            content: "${itemData['provider_name'] ?? 'নাই'} (${itemData['provider_designation'] ?? 'পদবী নেই'})",
                            isDarkMode: isDarkMode,
                          ),
                        ],
                        if (isAmbulance && itemData['driver_name'] != null && itemData['driver_name'].toString().isNotEmpty) ...[
                          Divider(height: 32, color: isDarkMode ? Colors.white24 : Colors.black12),
                          _buildInfoSection(
                            icon: Icons.airline_seat_recline_normal_rounded,
                            color: isDarkMode ? Colors.redAccent : Colors.red.shade700,
                            title: 'ড্রাইভারের নাম',
                            content: itemData['driver_name'].toString(),
                            isDarkMode: isDarkMode,
                          ),
                        ],
                        if (itemData['thanas'] != null && (itemData['thanas'] as List).isNotEmpty) ...[
                          Divider(height: 32, color: isDarkMode ? Colors.white24 : Colors.black12),
                          _buildListSection(
                            icon: Icons.local_police_rounded,
                            color: isDarkMode ? Colors.orangeAccent : Colors.orange.shade700,
                            title: 'থানাসমূহ',
                            items: itemData['thanas'],
                            isDarkMode: isDarkMode,
                          ),
                        ],
                        if (itemData['paurashavas'] != null && (itemData['paurashavas'] as List).isNotEmpty) ...[
                          Divider(height: 32, color: isDarkMode ? Colors.white24 : Colors.black12),
                          _buildListSection(
                            icon: Icons.location_city_rounded,
                            color: isDarkMode ? Colors.deepPurpleAccent : Colors.deepPurple.shade700,
                            title: 'পৌরসভাসমূহ',
                            items: itemData['paurashavas'],
                            isDarkMode: isDarkMode,
                          ),
                        ],

                        if (itemData['unions'] != null && (itemData['unions'] as List).isNotEmpty) ...[
                          Divider(height: 32, color: isDarkMode ? Colors.white24 : Colors.black12),
                          _buildListSection(
                            icon: Icons.holiday_village_rounded,
                            color: isDarkMode ? Colors.greenAccent : Colors.green.shade700,
                            title: 'ইউনিয়নসমূহ',
                            items: itemData['unions'],
                            isDarkMode: isDarkMode,
                          ),
                        ],
                        if (phone.isNotEmpty) ...[
                          Divider(height: 32, color: isDarkMode ? Colors.white24 : Colors.black12),
                          _buildPhoneSection(phone, 'ফোন', context, isDarkMode),
                        ],
                        if (itemData['mobile2'] != null && itemData['mobile2'].toString().isNotEmpty) ...[
                          Divider(height: 32, color: isDarkMode ? Colors.white24 : Colors.black12),
                          _buildPhoneSection(itemData['mobile2'].toString(), 'বিকল্প নাম্বার', context, isDarkMode),
                        ],
                        if (itemData['mobile3'] != null && itemData['mobile3'].toString().isNotEmpty) ...[
                          Divider(height: 32, color: isDarkMode ? Colors.white24 : Colors.black12),
                          _buildPhoneSection(itemData['mobile3'].toString(), 'বিকল্প নাম্বার ২', context, isDarkMode),
                        ],
                        if (mapLink.isNotEmpty) ...[
                          Divider(height: 32, color: isDarkMode ? Colors.white24 : Colors.black12),
                          _buildMapSection(mapLink, context, isDarkMode),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isDarkMode ? color : Color.lerp(color, Colors.black, 0.45)!, size: 24),
            ),
            const SizedBox(width: 12),
            AutoTranslatedText(title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: AutoTranslatedText(content, style: TextStyle(fontSize: 16, height: 1.5, color: isDarkMode ? Colors.white70 : Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildListSection({
    required IconData icon,
    required Color color,
    required String title,
    required List<dynamic> items,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isDarkMode ? color : Color.lerp(color, Colors.black, 0.45)!, size: 24),
            ),
            const SizedBox(width: 12),
            AutoTranslatedText(title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 8.0, top: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_right, size: 20, color: isDarkMode ? Colors.white54 : Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: AutoTranslatedText(item.toString(),
                    style: TextStyle(fontSize: 16, height: 1.3, color: isDarkMode ? Colors.white70 : Colors.black87)),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildPhoneSection(String phone, String title, BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.phone_rounded, color: isDarkMode ? Colors.greenAccent : Colors.green.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            AutoTranslatedText(title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(phone,
                     // Phone number usually doesn't need translation
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : Colors.black87)),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.call_rounded),
              label: const AutoTranslatedText('কল করুন'),
              onPressed: () => _makePhoneCall(phone, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.greenAccent.shade700 : Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildMapSection(String mapUrl, BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.map_rounded, color: isDarkMode ? Colors.purpleAccent : Colors.purple.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            AutoTranslatedText('লোকেশন',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InlineMapWidget(mapUrl: mapUrl),
          ),
        ),
      ],
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