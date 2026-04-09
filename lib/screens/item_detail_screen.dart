import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final String categoryId;

  const ItemDetailScreen({
    super.key,
    required this.itemData,
    required this.categoryId,
  });

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('কল করা যাচ্ছে না: $phoneNumber')),
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
          SnackBar(content: Text('ম্যাপ খোলা যাচ্ছে না: $mapUrl')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final name = itemData['name'] ?? 'নাম পাওয়া যায়নি';
    final address = itemData['address'] ?? 'ঠিকানা পাওয়া যায়নি';
    final phone = itemData['phone'] ?? '';
    final headmaster = itemData['headmaster'] ?? 'পাওয়া যায়নি';
    final mapLink = itemData['mapLink'] ?? '';

    final bool isSchoolCollege = categoryId == 'schoolCollege';

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
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
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
                        if (phone.isNotEmpty) ...[
                          Divider(height: 32, color: isDarkMode ? Colors.white24 : Colors.black12),
                          _buildPhoneSection(phone, context, isDarkMode),
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
            Text(title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(content, style: TextStyle(fontSize: 16, height: 1.5, color: isDarkMode ? Colors.white70 : Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildPhoneSection(String phone, BuildContext context, bool isDarkMode) {
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
            Text('ফোন',
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : Colors.black87)),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.call_rounded),
              label: const Text('কল করুন'),
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
            Text('লোকেশন',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text('ঠিকানাটি গুগল ম্যাপে দেখুন', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black87)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('ম্যাপ খুলুন'),
          onPressed: () => _launchGoogleMaps(mapUrl, context),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? Colors.purpleAccent.shade700 : Colors.purple.shade600,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}