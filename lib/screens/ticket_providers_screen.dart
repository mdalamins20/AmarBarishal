import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../widgets/auto_translated_text.dart';
import 'bus_ticket_screen.dart';

class TicketProvidersScreen extends StatefulWidget {
  const TicketProvidersScreen({super.key});

  @override
  State<TicketProvidersScreen> createState() => _TicketProvidersScreenState();
}

class _TicketProvidersScreenState extends State<TicketProvidersScreen> {
  String _englishCity = 'Dhaka';
  bool _isLoadingLoc = true;

  @override
  void initState() {
    super.initState();
    _fetchEnglishLocation();
  }

  Future<void> _fetchEnglishLocation() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 3),
        );
      final lat = position.latitude;
      final lon = position.longitude;

      final geoResponse = await http.get(
        Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en'),
      );
      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body);
        String? name = geoData['city'] ?? geoData['locality'] ?? geoData['principalSubdivision'];
        if (name != null && name.isNotEmpty) {
          setState(() {
            _englishCity = name.replaceAll(' Division', '').replaceAll(' District', '').replaceAll(' City', '');
            _isLoadingLoc = false;
          });
          return;
        }
      }
    } catch (e) {
      // Ignore
    }
    setState(() {
      _isLoadingLoc = false;
    });
  }

  void _openProvider(String name, String url) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => BusTicketScreen(
        providerName: name,
        url: url,
        fromCity: _englishCity,
      )
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final providers = [
      {'name': 'Shohoz', 'url': 'https://www.shohoz.com/bus-tickets', 'color': const Color(0xFF009C48), 'icon': Icons.directions_bus},
      {'name': 'bdtickets', 'url': 'https://bdtickets.com/', 'color': const Color(0xFFE3106D), 'icon': Icons.confirmation_num},
      {'name': 'Jatri', 'url': 'https://jatri.co/bus', 'color': const Color(0xFFFF6B35), 'icon': Icons.route},
      {'name': 'Shyamoli', 'url': 'https://shyamolitickets.com/', 'color': const Color(0xFF0F4C81), 'icon': Icons.airport_shuttle},
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const AutoTranslatedText('বাসের টিকেট বুকিং', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoadingLoc
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AutoTranslatedText('আপনার বর্তমান লোকেশন:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(_englishCity, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const AutoTranslatedText('পছন্দের ওয়েবসাইট নির্বাচন করুন:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: providers.length,
                      itemBuilder: (context, index) {
                        final p = providers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () {
                              if (p['name'] == 'Jatri') {
                                // For Jatri we use the user's suggested URL pattern directly as a fallback because their JS is hard to inject
                                final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
                                // Using Dhaka UUIDs as fallback if city is Dhaka, else just open Jatri homepage
                                String url = 'https://jatri.co/bus';
                                if (_englishCity.toLowerCase() == 'dhaka') {
                                  url = 'https://jatri.co/bus?from=673dac796f9d59f53663839a&to=673dac796f9d59f5366383bc&date=$date&returnDate=&fromName=Dhaka&toName=Barishal&fromLat=23.810332&fromLong=90.4125181&toLat=22.7029212&toLong=90.3465971&fGeo=false&tGeo=false&adult=1&children=0&infant=0';
                                }
                                _openProvider(p['name'] as String, url);
                              } else {
                                _openProvider(p['name'] as String, p['url'] as String);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: p['color'] as Color,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: (p['color'] as Color).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(p['icon'] as IconData, color: Colors.white, size: 32),
                                  const SizedBox(width: 16),
                                  Text(
                                    p['name'] as String,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
