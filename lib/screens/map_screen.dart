import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/auto_translated_text.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isLoadingLocation = false;
  Position? _currentPosition;
  String _locationMessage = "আপনার বর্তমান অবস্থান জানতে লোকেশন পারমিশন দিন।";

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
  }

  Future<void> _checkPermissionAndGetLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationMessage = "লোকেশন খোঁজা হচ্ছে...";
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoadingLocation = false;
        _locationMessage = "আপনার মোবাইলের লোকেশন সার্ভিস (GPS) বন্ধ আছে। দয়া করে চালু করুন।";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoadingLocation = false;
          _locationMessage = "লোকেশন পারমিশন দেওয়া হয়নি। পারমিশন ছাড়া কাজ করবে না।";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoadingLocation = false;
        _locationMessage = "লোকেশন পারমিশন চিরতরে বন্ধ করা আছে। সেটিংসে গিয়ে চালু করুন।";
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _locationMessage = "আপনার বর্তমান অবস্থান পাওয়া গেছে!";
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationMessage = "লোকেশন পেতে সমস্যা হচ্ছে। আবার চেষ্টা করুন।";
      });
    }
  }

  Future<void> _openGoogleMaps(String query) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("আগে লোকেশন পারমিশন দিন, তারপর ম্যাপ ওপেন হবে।")),
      );
      await _checkPermissionAndGetLocation();
      if (_currentPosition == null) return;
    }

    // Use geo intent for Android, and universal URL for fallback/iOS
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Maps ওপেন করা যাচ্ছে না।")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0F4C81);
    final bgColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const AutoTranslatedText('মানচিত্র ও আশেপাশের সেবা', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _currentPosition != null ? Icons.my_location : Icons.location_off,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  AutoTranslatedText(
                    _locationMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (_isLoadingLocation)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  if (!_isLoadingLocation && _currentPosition == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton.icon(
                        onPressed: _checkPermissionAndGetLocation,
                        icon: const Icon(Icons.refresh, color: Colors.blue),
                        label: const AutoTranslatedText("পুনরায় চেষ্টা করুন", style: TextStyle(color: Colors.blue)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            AutoTranslatedText(
              "নিকটবর্তী সেবাসমূহ খুঁজুন",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Map Action Buttons
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  _buildMapActionCard(
                    "নিকটবর্তী হাসপাতাল",
                    "আপনার আশেপাশের সকল হাসপাতাল ও ক্লিনিক দেখুন",
                    Icons.local_hospital,
                    Colors.redAccent,
                    () => _openGoogleMaps("Hospitals near me"),
                    isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  _buildMapActionCard(
                    "নিকটবর্তী থানা",
                    "আপনার আশেপাশের পুলিশ স্টেশন ও ফাঁড়ি দেখুন",
                    Icons.local_police,
                    Colors.blueAccent,
                    () => _openGoogleMaps("Police stations near me"),
                    isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  _buildMapActionCard(
                    "নিকটবর্তী হোটেল",
                    "আপনার আশেপাশের থাকার মতো হোটেল খুঁজুন",
                    Icons.hotel,
                    Colors.orangeAccent,
                    () => _openGoogleMaps("Hotels near me"),
                    isDarkMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapActionCard(String title, String subtitle, IconData icon, Color iconColor, VoidCallback onTap, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: iconColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoTranslatedText(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AutoTranslatedText(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: isDarkMode ? Colors.white30 : Colors.black26, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
