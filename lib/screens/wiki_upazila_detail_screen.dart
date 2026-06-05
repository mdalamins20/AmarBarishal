import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/auto_translated_text.dart';
import 'category_detail_screen.dart';

class WikiUpazilaDetailScreen extends StatelessWidget {
  final Map<String, dynamic> upazilaData;
  final String upazilaDocId;

  const WikiUpazilaDetailScreen({
    super.key,
    required this.upazilaData,
    required this.upazilaDocId,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final name = upazilaData['name'] ?? 'উপজেলার নাম নেই';
    final wikiData = upazilaData['wiki_data'] as Map<String, dynamic>?;

    String? imageUrl = wikiData?['image_url'];
    if (imageUrl != null && imageUrl.isEmpty) imageUrl = null;

    final List<String> skipSections = ['image_url', 'তথ্যসূত্র', 'বহিঃসংযোগ'];
    
    List<Widget> sectionWidgets = [];
    
    if (wikiData != null) {
      // Add introduction first if exists
      if (wikiData.containsKey('ভূমিকা') && wikiData['ভূমিকা'].toString().trim().isNotEmpty) {
        sectionWidgets.add(_buildSectionCard('ভূমিকা', wikiData['ভূমিকা'], isDarkMode, initiallyExpanded: true));
      }
      
      // Add other sections
      wikiData.forEach((key, value) {
        if (!skipSections.contains(key) && key != 'ভূমিকা' && value.toString().trim().isNotEmpty) {
          sectionWidgets.add(_buildSectionCard(key, value.toString(), isDarkMode));
        }
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF151928), const Color(0xFF283149)]
                : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              backgroundColor: isDarkMode ? const Color(0xFF151928) : Colors.blue.shade600,
              flexibleSpace: FlexibleSpaceBar(
                title: AutoTranslatedText(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 10)]
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.blueGrey),
                      )
                    else
                      Container(color: Colors.blueGrey),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black54, Colors.transparent, Colors.black87],
                          stops: [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    if (wikiData == null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.menu_book_rounded, size: 64, color: isDarkMode ? Colors.white30 : Colors.black26),
                              const SizedBox(height: 16),
                              AutoTranslatedText(
                                'এই উপজেলার বিস্তারিত তথ্য এখনো যুক্ত করা হয়নি।',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...sectionWidgets,
                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String content, bool isDarkMode, {bool initiallyExpanded = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDarkMode 
            ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
            : [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
        ),
        border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoTranslatedText(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.blueAccent.shade100 : Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                AutoTranslatedText(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: isDarkMode ? Colors.white.withOpacity(0.85) : Colors.black87,
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
