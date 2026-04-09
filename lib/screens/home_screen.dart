import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_barishal_new/screens/category_detail_screen.dart';
import 'package:my_barishal_new/screens/news_links_screen.dart';
import 'package:my_barishal_new/screens/notification_screen.dart';
import 'package:my_barishal_new/screens/upazila_list_screen.dart';
import 'package:my_barishal_new/widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  const HomeScreen({super.key, required this.onThemeChanged});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Local categories removed, loading straight from Firestore
  void _onCategoryTap(String categoryId, String categoryName, Map<String, dynamic> categoryData) {
    if (categoryName == "উপজেলা পরিচিতি" || categoryId == 'upazila') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UpazilaListScreen(categoryId: categoryId, categoryTitle: categoryName)));
    } else if (categoryName == "পত্রিকা" || categoryId == 'news') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsLinksScreen()));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryDetailScreen(
            categoryTitle: categoryName,
            categoryDocId: categoryId,
          ),
        ),
      );
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'hospital': return Icons.local_hospital_rounded;
      case 'police': return Icons.local_police_rounded;
      case 'ambulance': return Icons.emergency_rounded;
      case 'fire_service': return Icons.fire_truck_rounded;
      case 'landscape': return Icons.landscape_rounded;
      case 'info': return Icons.info_outline_rounded;
      case 'news': return Icons.newspaper_rounded;
      case 'library': return Icons.local_library_rounded;
      case 'hotel': return Icons.hotel_rounded;
      default: return Icons.category_rounded;
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) hexColor = "FF$hexColor";
    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
        elevation: 0,
        title: Text('আমার বরিশাল', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
            },
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeChanged,
          ),
        ],
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').orderBy('order').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Map<String, dynamic>> itemsToShow = [];

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                itemsToShow = snapshot.data!.docs.map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }).toList();
              } else {
                return const Center(child: Text('কোনো ক্যাটাগরি ডাটাবেসে নেই!'));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = (constraints.maxWidth > 800) ? 5 : (constraints.maxWidth > 500) ? 4 : 3;
                  return AnimationLimiter(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: itemsToShow.length,
                      itemBuilder: (context, index) {
                        final categoryData = itemsToShow[index];
                        final categoryId = categoryData['id'] as String;
                        final categoryName = categoryData['name'] as String? ?? 'নাম নেই';
                        final iconName = categoryData['icon'] as String? ?? 'category';
                        final hexColor = categoryData['color'] as String? ?? '#808080';

                        final categoryIcon = _getIconFromString(iconName);
                        final cardColor = _getColorFromHex(hexColor);

                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 600),
                          columnCount: crossAxisCount,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: _buildGlassCard(
                                context,
                                categoryName,
                                categoryIcon,
                                cardColor,
                                () => _onCategoryTap(categoryId, categoryName, categoryData),
                                isDarkMode,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(isDark ? 0.3 : 0.15),
              color.withOpacity(isDark ? 0.1 : 0.05),
            ],
          ),
          border: Border.all(
            color: color.withOpacity(isDark ? 0.6 : 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 1,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDark ? 0.2 : 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon, 
                    size: 26, 
                    color: isDark ? color : Color.lerp(color, Colors.black, 0.45)!,
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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