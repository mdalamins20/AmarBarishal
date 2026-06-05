import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'sos_list_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import '../widgets/auto_translated_text.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  const MainScreen({super.key, required this.onThemeChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onThemeChanged: widget.onThemeChanged),
      const NotificationScreen(),
      const SosListScreen(),
      const MapScreen(),
      const ProfileScreen(),
    ];
  }

  Future<void> _callEmergency() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '999');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _callEmergency,
        backgroundColor: const Color(0xFFFF6B35), // Accent Orange
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.call, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        clipBehavior: Clip.antiAlias,
        elevation: 10,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 55, // Thinner height
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'হোম', isDarkMode),
            _buildNavItem(1, Icons.notifications_none_rounded, 'নোটিফিকেশন', isDarkMode),
            const SizedBox(width: 40), // Empty space for FAB
            _buildNavItem(3, Icons.location_on_rounded, 'মানচিত্র', isDarkMode),
            _buildNavItem(4, Icons.person_rounded, 'প্রোফাইল', isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDarkMode) {
    final isSelected = _currentIndex == index;
    final color = isSelected 
        ? const Color(0xFF0F4C81) // Primary Blue
        : (isDarkMode ? Colors.white54 : Colors.grey.shade500);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22), // Slightly smaller icon
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10, // Slightly smaller text
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
