import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_barishal_new/screens/admin/admin_category_detail_screen.dart';
import 'package:my_barishal_new/screens/admin/admin_upazila_list_screen.dart';
import 'package:my_barishal_new/screens/admin/manage_news_links_screen.dart';
import 'package:my_barishal_new/screens/admin/admin_doctor_list_screen.dart';
import 'package:my_barishal_new/screens/admin/admin_diagnostic_list_screen.dart';
import 'package:my_barishal_new/screens/admin/admin_sos_list_screen.dart';
import 'package:my_barishal_new/utils/helpers.dart';

class AdminManageDataCategoriesScreen extends StatelessWidget {
  const AdminManageDataCategoriesScreen({super.key});

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
        backgroundColor: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
        title: Text('ক্যাটাগরি ডেটা নির্বাচন করুন', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        elevation: 0,
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
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('কোনো ক্যাটাগরি নেই।'));
              }

              return AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final category = doc.data() as Map<String, dynamic>;
                    final categoryDocId = doc.id;
                    final iconColor = getColorFromString(category['color'] ?? '#000000');

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
                            elevation: 0,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: iconColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(getIconFromString(category['icon']), color: iconColor),
                              ),
                              title: Text(
                                category['name'] ?? 'নাম নেই',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black87),
                              ),
                              subtitle: Text('ডাটা ম্যানেজ করতে ক্লিক করুন', style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54)),
                              trailing: Icon(Icons.arrow_forward_ios, color: isDarkMode ? Colors.white30 : Colors.black26, size: 18),
                              onTap: () {
                                if (categoryDocId == 'upazilas' || categoryDocId == 'upazila') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdminUpazilaListScreen(
                                      categoryId: categoryDocId,
                                      categoryTitle: category['name'],
                                    )
                                  ));
                                } else if (categoryDocId == 'news' || category['name'] == 'পত্রিকা' || category['name'].toString().contains('খবর')) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const ManageNewsLinksScreen()
                                  ));
                                } else if (categoryDocId == 'sos') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const AdminSosListScreen()
                                  ));
                                } else if (categoryDocId == 'doctor') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdminSpecialistListScreen(
                                      categoryTitle: category['name'] ?? 'ডাক্তার', 
                                      categoryDocId: categoryDocId
                                    )
                                  ));
                                } else if (categoryDocId == 'diagnostic') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdminDiagnosticListScreen(
                                      categoryId: categoryDocId, 
                                      categoryTitle: category['name'] ?? 'ডায়াগনস্টিক'
                                    )
                                  ));
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdminCategoryDetailScreen(
                                      categoryTitle: category['name'] ?? 'নাম নেই',
                                      categoryDocId: categoryDocId,
                                    )
                                  ));
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
