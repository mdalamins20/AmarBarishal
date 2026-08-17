import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/auto_translated_text.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  final String sourceId;
  final String sourceName;
  final Color color;

  const NewsListScreen({
    super.key,
    required this.sourceId,
    required this.sourceName,
    required this.color,
  });

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  DateTime? _selectedDate;

  Future<List<Map<String, dynamic>>> _fetchNewsApi() async {
    try {
      String url = 'http://192.168.0.246:8000/api/news?source_id=${widget.sourceId}';
      if (_selectedDate != null) {
        final dateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
        url += '&date=$dateStr';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint("Error fetching news api: $e");
    }
    return [];
  }

  Widget _buildNewsCard(Map<String, dynamic> item, bool isDarkMode, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(
              itemData: item,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(color: isDarkMode ? Colors.white12 : Colors.black12, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['image_url'] != null && item['image_url'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  item['image_url'],
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 180,
                    width: double.infinity,
                    color: isDarkMode ? Colors.white10 : Colors.black12,
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoTranslatedText(
                    item['name'] ?? 'শিরোনাম নেই',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AutoTranslatedText(
                          item['source'] ?? widget.sourceName,
                          style: TextStyle(color: widget.color, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: isDarkMode ? Colors.white54 : Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            item['date'] ?? '',
                            style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.4),
        elevation: 0,
        title: AutoTranslatedText(widget.sourceName, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDarkMode ? Colors.white24 : Colors.white),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoTranslatedText(
                              _selectedDate == null 
                                  ? 'যেকোনো তারিখের খবর খুঁজুন...' 
                                  : 'নির্বাচিত তারিখ: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                              style: TextStyle(
                                color: _selectedDate == null ? (isDarkMode ? Colors.white70 : Colors.black54) : (isDarkMode ? Colors.white : Colors.black87),
                                fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Icon(Icons.calendar_month_rounded, color: isDarkMode ? Colors.white70 : Colors.black54),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchNewsApi(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: AutoTranslatedText('একটি সমস্যা হয়েছে: ${snapshot.error}', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.newspaper_rounded, size: 80, color: isDarkMode ? Colors.white30 : Colors.black26),
                            const SizedBox(height: 16),
                            AutoTranslatedText('কোনো খবর পাওয়া যায়নি', style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 18)),
                          ],
                        ),
                      );
                    }
                    
                    final itemsList = snapshot.data!;
                    return AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: itemsList.length,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildNewsCard(itemsList[index], isDarkMode, context),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
