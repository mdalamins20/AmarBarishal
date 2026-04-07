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

  // *** এই ফাংশনটি আপডেট করা হয়েছে ***
  Future<void> _launchGoogleMaps(String mapUrl, BuildContext context) async {
    // এখন এটি সরাসরি আপনার দেওয়া লিংক ব্যবহার করবে
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
    final name = itemData['name'] ?? 'নাম পাওয়া যায়নি';
    final address = itemData['address'] ?? 'ঠিকানা পাওয়া যায়নি';
    final phone = itemData['phone'] ?? '';
    final headmaster = itemData['headmaster'] ?? 'পাওয়া যায়নি';
    final mapLink = itemData['mapLink'] ?? ''; // <-- নতুন: ম্যাপ লিংক আনা হচ্ছে

    final bool isSchoolCollege = categoryId == 'schoolCollege';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(
                  icon: Icons.location_on,
                  color: Colors.blue,
                  title: 'ঠিকানা',
                  content: address,
                ),
                const Divider(height: 32),
                if (isSchoolCollege) ...[
                  _buildInfoSection(
                    icon: Icons.person,
                    color: Colors.teal,
                    title: 'প্রধান শিক্ষক',
                    content: headmaster,
                  ),
                  const Divider(height: 32),
                ],
                if (phone.isNotEmpty) ...[
                  _buildPhoneSection(phone, context),
                  const Divider(height: 32),
                ],
                // ম্যাপ সেকশন (সবার জন্য, যদি লিংক থাকে)
                if (mapLink.isNotEmpty) ...[
                  _buildMapSection(mapLink, context), // <-- address এর পরিবর্তে mapLink পাস করা হচ্ছে
                ]
              ],
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
  }) {
    // ... এই উইজেটটি অপরিবর্তিত ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 8),
            Text(title,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildPhoneSection(String phone, BuildContext context) {
    // ... এই উইজেটটি অপরিবর্তিত ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.phone, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('ফোন',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.call),
              label: const Text('কল করুন'),
              onPressed: () => _makePhoneCall(phone, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(phone,
            style:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMapSection(String mapUrl, BuildContext context) {
    // ... এই উইজেটটি অপরিবর্তিত, শুধু address এর পরিবর্তে mapUrl গ্রহণ করছে ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoSection(
          icon: Icons.map_outlined,
          color: Colors.purple,
          title: 'লোকেশন',
          content: 'ঠিকানাটি গুগল ম্যাপে দেখুন',
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('ম্যাপ খুলুন'),
            onPressed: () => _launchGoogleMaps(mapUrl, context),
          ),
        ),
      ],
    );
  }
}