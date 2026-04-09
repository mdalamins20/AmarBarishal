import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_barishal_new/screens/category_detail_screen.dart';
import 'package:my_barishal_new/screens/news_links_screen.dart';
import 'package:my_barishal_new/screens/notification_screen.dart';
import 'package:my_barishal_new/screens/upazila_list_screen.dart';
import 'package:my_barishal_new/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/auto_translated_text.dart';

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

  IconData _getIconFromString(String iconName, String categoryName) {
    // Priority 1: Direct Mapping from iconName field
    switch (iconName) {
      case 'hospital': return Icons.local_hospital_rounded;
      case 'police': return Icons.security_rounded;
      case 'ambulance': return Icons.emergency_rounded;
      case 'fire_service': return Icons.fire_truck_rounded;
      case 'landscape': return Icons.landscape_rounded;
      case 'info': return Icons.info_outline_rounded;
      case 'news': return Icons.newspaper_rounded;
      case 'library': return Icons.local_library_rounded;
      case 'hotel': return Icons.hotel_rounded;
      case 'doctor': return Icons.medical_services_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'education': return Icons.school_rounded;
    }

    // Priority 2: Smart Detection based on Name (fixes icons when iconName is generic or missing)
    final name = categoryName.toLowerCase();
    if (name.contains('হাসপাতাল') || name.contains('ক্লিনিক')) return Icons.local_hospital_rounded;
    if (name.contains('ডাক্তার')) return Icons.health_and_safety_rounded;
    if (name.contains('অ্যাম্বুলেন্স')) return Icons.emergency_share_rounded;
    if (name.contains('পুলিশ') || name.contains('থানা')) return Icons.local_police_rounded;
    if (name.contains('ফায়ার')) return Icons.fire_truck_rounded;
    if (name.contains('উপজেলা')) return Icons.location_city_rounded;
    if (name.contains('রেস্টুরেন্ট') || name.contains('খাবার')) return Icons.restaurant_rounded;
    if (name.contains('স্কুল') || name.contains('কলেজ') || name.contains('শিক্ষা')) return Icons.school_rounded;
    if (name.contains('প্যাকার্স') || name.contains('কুরিয়ার')) return Icons.local_shipping_rounded;
    if (name.contains('দর্শনীয়') || name.contains('পর্যটন')) return Icons.landscape_rounded;
    if (name.contains('হোটেল')) return Icons.hotel_rounded;
    if (name.contains('সিনেমা') || name.contains('হল')) return Icons.movie_creation_rounded;
    if (name.contains('ব্যাংক')) return Icons.account_balance_rounded;
    
    return Icons.category_rounded;
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) hexColor = "FF$hexColor";
    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode 
                ? [const Color(0xFF0F1219), const Color(0xFF1A1F2B)]
                : [const Color(0xFFF0F4F8), const Color(0xFFE2E8F0)],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              elevation: 0,
              centerTitle: true,
              backgroundColor: isDarkMode ? const Color(0xFF0F1219) : const Color(0xFFF0F4F8),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Decorative Gradient
                    Positioned(
                      top: -100,
                      right: -50,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Provider.of<LanguageProvider>(context).t('welcome'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Provider.of<LanguageProvider>(context).t('app_name'),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                  ),
                  onPressed: widget.onThemeChanged,
                ),
                const SizedBox(width: 8),
              ],
            ),
            
            // Grid Categories
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categories').orderBy('order').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text(Provider.of<LanguageProvider>(context).t('category_empty'))),
                  );
                }

                final itemsToShow = snapshot.data!.docs.map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }).toList();

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final categoryData = itemsToShow[index];
                        final categoryId = categoryData['id'] as String;
                        final categoryName = categoryData['name'] as String? ?? 'নাম নেই';
                        final iconName = categoryData['icon'] as String? ?? 'category';
                        final hexColor = categoryData['color'] as String? ?? '#00A8E8';

                        final categoryIcon = _getIconFromString(iconName, categoryName);
                        final baseColor = _getColorFromHex(hexColor);

                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          columnCount: 4,
                          child: ScaleAnimation(
                            scale: 0.9,
                            child: FadeInAnimation(
                              child: _buildPremiumCard(
                                context,
                                categoryName,
                                categoryIcon,
                                baseColor,
                                () => _onCategoryTap(categoryId, categoryName, categoryData),
                                isDarkMode,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: itemsToShow.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222834) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon, 
                    size: 28, 
                    color: color,
                  ),
                ),
                const SizedBox(height: 10),
                AutoTranslatedText(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}