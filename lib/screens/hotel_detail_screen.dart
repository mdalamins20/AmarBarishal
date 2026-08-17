import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/auto_translated_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EmbeddedMapView extends StatefulWidget {
  final String query;
  
  const EmbeddedMapView({super.key, required this.query});

  @override
  State<EmbeddedMapView> createState() => _EmbeddedMapViewState();
}

class _EmbeddedMapViewState extends State<EmbeddedMapView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final htmlString = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body, html { margin: 0; padding: 0; height: 100%; overflow: hidden; }
        </style>
      </head>
      <body>
        <iframe 
          width="100%" 
          height="100%" 
          frameborder="0" 
          style="border:0" 
          src="https://maps.google.com/maps?q=${Uri.encodeComponent(widget.query)}&t=&z=15&ie=UTF8&iwloc=&output=embed" 
          allowfullscreen>
        </iframe>
      </body>
      </html>
    ''';
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(htmlString);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: WebViewWidget(controller: _controller),
    );
  }
}

class HotelDetailScreen extends StatelessWidget {
  final Map<String, dynamic> hotelData;

  const HotelDetailScreen({super.key, required this.hotelData});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
  
  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _launchMaps(String name, String address) async {
    final query = Uri.encodeComponent('$name, $address');
    final Uri mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final name = hotelData['name'] ?? 'নাম নেই';
    final address = hotelData['address'] ?? 'ঠিকানা নেই';
    final price = hotelData['price_per_night'] ?? 'মূল্য নেই';
    final rating = hotelData['rating']?.toString() ?? 'N/A';
    final reviews = hotelData['reviews']?.toString() ?? '0';
    final imageUrl = hotelData['image_url'] ?? '';
    final mobile = hotelData['mobile'] ?? '';
    final description = hotelData['description'] ?? 'কোনো বিবরণ নেই।';
    final List<dynamic> amenities = hotelData['amenities'] ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDarkMode ? const Color(0xFF151928) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image
                SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: Colors.grey.shade800),
                        )
                      : Container(
                          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
                          child: const Icon(Icons.hotel, size: 80, color: Colors.white54),
                        ),
                ),
                
                // Content Body
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF151928) : const Color(0xFFF5F7FA),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AutoTranslatedText(
                                name,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Location with Google Maps link
                        InkWell(
                          onTap: () => _launchMaps(name, address),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, size: 18, color: Colors.blueAccent.shade200),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    address,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.blueAccent.shade100 : Colors.blueAccent.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        if (mobile.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _makePhoneCall(mobile),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.phone, size: 16, color: Colors.green.shade400),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      mobile,
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.blueAccent.shade100 : Colors.blueAccent.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        
                        if (hotelData['email'] != null && hotelData['email'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _sendEmail(hotelData['email'].toString()),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.email, size: 16, color: Colors.orange.shade400),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      hotelData['email'],
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.blueAccent.shade100 : Colors.blueAccent.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 30),
                        
                        // Description
                        AutoTranslatedText(
                          "বিবরণ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AutoTranslatedText(
                          description,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                            height: 1.6,
                          ),
                        ),
                        
                        const SizedBox(height: 30),

                        // Location Map Title
                        Row(
                          children: [
                            Icon(Icons.map, color: Colors.indigo.shade400, size: 24),
                            const SizedBox(width: 8),
                            AutoTranslatedText(
                              "লোকেশন ম্যাপ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Embedded Map View
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDarkMode ? Colors.white12 : Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ]
                          ),
                          child: EmbeddedMapView(query: '$name, $address'),
                        ),
                        
                        const SizedBox(height: 30),

                        // Room Rents Table
                        if (hotelData['room_rents'] != null && (hotelData['room_rents'] as List).isNotEmpty) ...[
                          AutoTranslatedText(
                            "রুমের বিবরণ ও ভাড়া",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white10 : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDarkMode ? Colors.white12 : Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1.5),
                                },
                                border: TableBorder.symmetric(
                                  inside: BorderSide(color: isDarkMode ? Colors.white12 : Colors.grey.shade200),
                                ),
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.black26 : Colors.grey.shade100,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: AutoTranslatedText(
                                          "রুমের ধরন",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: AutoTranslatedText(
                                          "ভাড়া",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...((hotelData['room_rents'] as List).map((rent) {
                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: AutoTranslatedText(
                                            rent['type']?.toString() ?? '',
                                            style: TextStyle(
                                              color: isDarkMode ? Colors.white70 : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            rent['price']?.toString() ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode ? Colors.blueAccent.shade100 : Colors.blueAccent.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  })),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                        
                        // Amenities
                        AutoTranslatedText(
                          "সুযোগ-সুবিধা",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: amenities.map((amenity) {
                            IconData iconData = Icons.check_circle_outline;
                            if (amenity.toString().toLowerCase().contains('wi-fi')) iconData = Icons.wifi;
                            if (amenity.toString().toLowerCase().contains('ac')) iconData = Icons.ac_unit;
                            if (amenity.toString().toLowerCase().contains('restaurant')) iconData = Icons.restaurant;
                            if (amenity.toString().toLowerCase().contains('pool')) iconData = Icons.pool;
                            if (amenity.toString().toLowerCase().contains('parking')) iconData = Icons.local_parking;
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white10 : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isDarkMode ? Colors.white12 : Colors.grey.shade300),
                                boxShadow: isDarkMode ? [] : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(iconData, size: 18, color: Colors.blueAccent),
                                  const SizedBox(width: 8),
                                  AutoTranslatedText(
                                    amenity.toString(),
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Bar removed as per user request
        ],
      ),
    );
  }
}
