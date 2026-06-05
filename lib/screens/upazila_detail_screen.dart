import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/auto_translated_text.dart';

class UpazilaDetailScreen extends StatelessWidget {
  final Map<String, dynamic> upazilaData;

  const UpazilaDetailScreen({super.key, required this.upazilaData});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final name = upazilaData['name'] ?? 'উপজেলার নাম নেই';
    
    final thanas = (upazilaData['thanas'] as List<dynamic>?) ?? [];
    final paurashavas = (upazilaData['paurashavas'] as List<dynamic>?) ?? [];
    final unions = (upazilaData['unions'] as List<dynamic>?) ?? [];

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
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSummaryCard(isDarkMode, thanas.length, paurashavas.length, unions.length),
              const SizedBox(height: 16),
              if (thanas.isNotEmpty)
                _buildExpandableSection(
                  title: 'থানাসমূহ',
                  icon: Icons.local_police_rounded,
                  color: isDarkMode ? Colors.orangeAccent : Colors.orange.shade700,
                  items: thanas,
                  isDarkMode: isDarkMode,
                ),
              if (paurashavas.isNotEmpty)
                _buildExpandableSection(
                  title: 'পৌরসভাসমূহ',
                  icon: Icons.location_city_rounded,
                  color: isDarkMode ? Colors.deepPurpleAccent : Colors.deepPurple.shade700,
                  items: paurashavas,
                  isDarkMode: isDarkMode,
                ),
              if (unions.isNotEmpty)
                _buildExpandableSection(
                  title: 'ইউনিয়নসমূহ',
                  icon: Icons.holiday_village_rounded,
                  color: isDarkMode ? Colors.greenAccent : Colors.green.shade700,
                  items: unions,
                  isDarkMode: isDarkMode,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(bool isDarkMode, int thanaCount, int paurashavaCount, int unionCount) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          AutoTranslatedText(
            'এক নজরে',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('থানা', thanaCount.toString(), Icons.local_police_rounded, isDarkMode ? Colors.orangeAccent : Colors.orange.shade700, isDarkMode),
              _buildStatItem('পৌরসভা', paurashavaCount.toString(), Icons.location_city_rounded, isDarkMode ? Colors.deepPurpleAccent : Colors.deepPurple.shade700, isDarkMode),
              _buildStatItem('ইউনিয়ন', unionCount.toString(), Icons.holiday_village_rounded, isDarkMode ? Colors.greenAccent : Colors.green.shade700, isDarkMode),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isDarkMode ? color : Color.lerp(color, Colors.black, 0.45)!, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        AutoTranslatedText(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<dynamic> items,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isDarkMode ? color : Color.lerp(color, Colors.black, 0.45)!, size: 20),
          ),
          title: AutoTranslatedText(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          children: items.map((item) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              leading: Icon(Icons.check_circle_outline, color: isDarkMode ? Colors.white54 : Colors.black54, size: 20),
              title: AutoTranslatedText(
                item.toString(),
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
