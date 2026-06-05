import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/auto_translated_text.dart';
import 'item_detail_screen.dart';
import 'hospital_detail_screen.dart';
import 'school_detail_screen.dart';
import 'library_detail_screen.dart';
import 'ambulance_detail_screen.dart';
import 'fire_service_detail_screen.dart';
import 'hotel_detail_screen.dart';
import 'news_detail_screen.dart';

class GlobalSearchDelegate extends SearchDelegate {
  final bool isDarkMode;
  final Color primaryColor;
  
  // Cache for all items to avoid multiple Firestore reads
  static Future<List<DocumentSnapshot>>? _fetchFuture;

  GlobalSearchDelegate({required this.isDarkMode, required this.primaryColor});

  @override
  String get searchFieldLabel => 'খুঁজুন (যেমন: হাসপাতাল, স্কুল, ডাক্তার)...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black87),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey.shade400, fontSize: 16),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(color: isDarkMode ? Colors.white : Colors.black87, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  Future<List<DocumentSnapshot>> _fetchData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collectionGroup('items').get();
      return snapshot.docs;
    } catch (e) {
      debugPrint("Error fetching global items: $e");
      return [];
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildFutureBody(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildFutureBody(context);
  }

  Widget _buildFutureBody(BuildContext context) {
    _fetchFuture ??= _fetchData();

    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                AutoTranslatedText('ডাটা লোড হচ্ছে...', style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey)),
              ],
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: AutoTranslatedText('ডাটা লোড করতে সমস্যা হয়েছে!', style: TextStyle(color: Colors.red)),
          );
        }

        final items = snapshot.data!;
        return _buildBody(context, items);
      },
    );
  }

  Widget _buildBody(BuildContext context, List<DocumentSnapshot> cachedItems) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 80, color: isDarkMode ? Colors.white12 : Colors.black12),
            const SizedBox(height: 16),
            AutoTranslatedText('যেকোনো তথ্য খুঁজতে উপরে টাইপ করুন', style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey)),
          ],
        ),
      );
    }

    final queryLower = query.toLowerCase();
    
    // Search algorithm
    final results = cachedItems.where((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final name = (data['name'] ?? '').toString().toLowerCase();
      final address = (data['address'] ?? '').toString().toLowerCase();
      final mobile = (data['mobile'] ?? '').toString().toLowerCase();
      final type = (data['type'] ?? '').toString().toLowerCase();
      
      return name.contains(queryLower) || 
             address.contains(queryLower) || 
             mobile.contains(queryLower) ||
             type.contains(queryLower);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: isDarkMode ? Colors.white12 : Colors.black12),
            const SizedBox(height: 16),
            AutoTranslatedText('কোনো ফলাফল পাওয়া যায়নি!', style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey)),
          ],
        ),
      );
    }

    return Container(
      color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const ClampingScrollPhysics(),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final doc = results[index];
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final name = data['name'] ?? 'অজানা';
          final address = data['address'] ?? '';
          
          // category is the parent collection's parent document ID
          final categoryId = doc.reference.parent.parent?.id ?? '';
          
          IconData icon;
          Color iconColor;
          String catName = '';
          
          if (categoryId == 'hospital') { icon = Icons.local_hospital_rounded; iconColor = Colors.redAccent; catName = 'হাসপাতাল'; }
          else if (['primarySchool', 'highSchool', 'college', 'university', 'madrasa', 'schoolCollege'].contains(categoryId)) { icon = Icons.school_rounded; iconColor = Colors.green; catName = 'শিক্ষা প্রতিষ্ঠান'; }
          else if (categoryId == 'library') { icon = Icons.menu_book_rounded; iconColor = Colors.indigo; catName = 'লাইব্রেরি'; }
          else if (categoryId == 'hotel') { icon = Icons.hotel_rounded; iconColor = Colors.blueAccent; catName = 'হোটেল'; }
          else if (categoryId == 'police') { icon = Icons.local_police_rounded; iconColor = Colors.blue; catName = 'পুলিশ'; }
          else if (categoryId == 'ambulance') { icon = Icons.emergency_share_rounded; iconColor = Colors.orange; catName = 'অ্যাম্বুলেন্স'; }
          else if (categoryId == 'fireService') { icon = Icons.fire_truck_rounded; iconColor = Colors.deepOrange; catName = 'ফায়ার সার্ভিস'; }
          else if (categoryId == 'news') { icon = Icons.newspaper_rounded; iconColor = Colors.teal; catName = 'সংবাদ'; }
          else { icon = Icons.info_outline_rounded; iconColor = Colors.grey; catName = 'তথ্য'; }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  _navigateToDetail(context, categoryId, data);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (address.toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                catName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: isDarkMode ? Colors.white24 : Colors.black26),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String categoryDocId, Map<String, dynamic> item) {
    if (categoryDocId == 'hospital') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HospitalDetailScreen(itemData: item)));
    } else if (categoryDocId == 'fireService') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FireServiceDetailScreen(itemData: item)));
    } else if (categoryDocId == 'ambulance') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AmbulanceDetailScreen(itemData: item)));
    } else if (categoryDocId == 'library') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => LibraryDetailScreen(itemData: item)));
    } else if (categoryDocId == 'hotel') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HotelDetailScreen(hotelData: item)));
    } else if (categoryDocId == 'news') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewsDetailScreen(itemData: item)));
    } else if (['primarySchool', 'highSchool', 'college', 'university', 'madrasa', 'schoolCollege'].contains(categoryDocId)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SchoolDetailScreen(itemData: item)));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ItemDetailScreen(itemData: item, categoryId: categoryDocId)));
    }
  }
}
