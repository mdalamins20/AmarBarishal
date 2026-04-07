// home_screen.dart (চূড়ান্ত নির্ভুল সংস্করণ - আইকনসহ)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  // ক্যাটাগরিতে ট্যাপ করলে কী হবে, তার লজিক এখানে রাখা হয়েছে
  void _onCategoryTap(String categoryId, String categoryName, Map<String, dynamic> categoryData) {
    // বিশেষ ক্যাটাগরির জন্য ভিন্ন ভিন্ন স্ক্রিন দেখানোর লজিক
    if (categoryName == "উপজেলা পরিচিতি") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UpazilaListScreen(categoryId: categoryId, categoryTitle: categoryName)));
    } else if (categoryName == "পত্রিকা") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsLinksScreen()));
    } else {
      // অন্যান্য সব সাধারণ ক্যাটাগরির জন্য CategoryDetailScreen দেখানো হবে
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

  // --- নতুন ফাংশন: ডাটাবেজের টেক্সট থেকে Flutter আইকন তৈরি করার জন্য ---
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'hospital':
        return Icons.local_hospital;
      case 'police':
        return Icons.local_police;
      case 'ambulance':
        return Icons.emergency; // emergency আইকনটি অ্যাম্বুলেন্সের জন্য উপযুক্ত
      case 'fire_service':
        return Icons.fire_truck;
      case 'landscape':
        return Icons.landscape;
      case 'info':
        return Icons.info_outline;
      case 'news':
        return Icons.newspaper;
      case 'library':
        return Icons.local_library;
      case 'hotel':
        return Icons.hotel;
      default:
        return Icons.category; // যদি কোনো আইকন না মেলে, তাহলে এটি দেখানো হবে
    }
  }

  // --- নতুন ফাংশন: ডাটাবেজের হেক্স কোড থেকে রঙ তৈরি করার জন্য ---
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey; // যদি রঙ বুঝতে না পারে
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('আমার বরিশাল'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').orderBy('order').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('একটি সমস্যা হয়েছে: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('কোনো ক্যাটাগরি যোগ করা হয়নি।'));
          }

          final categories = snapshot.data!.docs;

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = (constraints.maxWidth > 600) ? 4 : 3;
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final categoryDoc = categories[index];
                  final categoryData = categoryDoc.data() as Map<String, dynamic>;
                  final categoryId = categoryDoc.id;
                  final categoryName = categoryData['name'] ?? 'নাম নেই';

                  // --- মূল পরিবর্তন এখানে ---
                  // 'image' এর বদলে 'icon' এবং 'color' ফিল্ড পড়া হচ্ছে
                  final iconName = categoryData['icon'] as String? ?? 'category';
                  final hexColor = categoryData['color'] as String? ?? '#808080';

                  final categoryIcon = _getIconFromString(iconName);
                  final cardColor = _getColorFromHex(hexColor);

                  return InkWell(
                    onTap: () => _onCategoryTap(categoryId, categoryName, categoryData),
                    borderRadius: BorderRadius.circular(10.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // --- Image.network এর বদলে Icon দেখানো হচ্ছে ---
                          Icon(
                            categoryIcon,
                            size: 50,
                            color: cardColor, // ডাটাবেজ থেকে রঙ ব্যবহার করা হচ্ছে
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              categoryName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}