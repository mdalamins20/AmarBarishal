import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:my_barishal_new/screens/admin/add_edit_category_screen.dart';
import 'package:my_barishal_new/services/database_translator_service.dart';

// Routing Imports for Data Management
import 'package:my_barishal_new/screens/admin/admin_category_detail_screen.dart';
import 'package:my_barishal_new/screens/admin/admin_upazila_list_screen.dart';
import 'package:my_barishal_new/screens/admin/manage_news_links_screen.dart';
import 'package:my_barishal_new/screens/admin/admin_doctor_list_screen.dart';
import 'package:my_barishal_new/screens/admin/admin_diagnostic_list_screen.dart';
import 'package:my_barishal_new/screens/admin/admin_sos_list_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _onCategoryTap(BuildContext context, String categoryId, String categoryName) {
    if (categoryId == 'upazila' || categoryId == 'upazilas' || categoryName == "উপজেলা পরিচিতি") {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AdminUpazilaListScreen(categoryId: categoryId, categoryTitle: categoryName)
      ));
    } else if (categoryId == 'news' || categoryName == 'পত্রিকা') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const ManageNewsLinksScreen()
      ));
    } else if (categoryId == 'sos' || categoryName == 'জরুরি কল') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const AdminSosListScreen()
      ));
    } else if (categoryId == 'doctor' || categoryName == 'ডাক্তার') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AdminSpecialistListScreen(categoryTitle: categoryName, categoryDocId: categoryId)
      ));
    } else if (categoryId == 'diagnostic' || categoryName == 'ডায়াগনস্টিক') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AdminDiagnosticListScreen(categoryId: categoryId, categoryTitle: categoryName)
      ));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AdminCategoryDetailScreen(categoryTitle: categoryName, categoryDocId: categoryId)
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0F4C81);
    final secondaryColor = const Color(0xFF22A699);
    final emergencyColor = const Color(0xFFFF4B4B);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('অ্যাডমিন ড্যাশবোর্ড', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ডাটা এডিট, এড বা ডিলিট করতে যেকোনো ক্যাটাগরিতে ক্লিক করুন।',
                      style: TextStyle(
                        color: isDarkMode ? Colors.blueAccent.shade100 : Colors.blueAccent.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Temporary Translate Database Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                  try {
                    await DatabaseTranslatorService.runTranslation();
                    if (context.mounted) {
                      Navigator.pop(context); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ডাটাবেজ সফলভাবে বাংলায় অনুবাদ করা হয়েছে!'),
                          backgroundColor: Colors.green,
                        )
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('অনুবাদ করতে সমস্যা হয়েছে: $e'),
                          backgroundColor: Colors.red,
                        )
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.translate),
                label: const Text('ডাটাবেজ বাংলায় রূপান্তর করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),

            _buildCategoryGroup(context, 'জরুরি সেবা', [
              {'id': 'ambulance', 'name': 'অ্যাম্বুলেন্স', 'icon': Icons.emergency_share},
              {'id': 'police', 'name': 'পুলিশ', 'icon': Icons.local_police},
              {'id': 'fire_service', 'name': 'ফায়ার সার্ভিস', 'icon': Icons.fire_truck},
              {'id': 'sos', 'name': 'জরুরি কল', 'icon': Icons.sos_rounded},
            ], emergencyColor, isDarkMode),

            _buildCategoryGroup(context, 'স্বাস্থ্যসেবা', [
              {'id': 'hospital', 'name': 'হাসপাতাল', 'icon': Icons.local_hospital},
              {'id': 'doctor', 'name': 'ডাক্তার', 'icon': Icons.health_and_safety},
              {'id': 'diagnostic', 'name': 'ডায়াগনস্টিক', 'icon': Icons.biotech},
            ], secondaryColor, isDarkMode),
            
            _buildCategoryGroup(context, 'শিক্ষা', [
              {'id': 'primarySchool', 'name': 'প্রাথমিক স্কুল', 'icon': Icons.child_care},
              {'id': 'highSchool', 'name': 'হাই স্কুল', 'icon': Icons.school},
              {'id': 'college', 'name': 'কলেজ', 'icon': Icons.account_balance},
              {'id': 'university', 'name': 'বিশ্ববিদ্যালয়', 'icon': Icons.history_edu},
              {'id': 'medical_college', 'name': 'মেডিকেল কলেজ', 'icon': Icons.local_hospital},
              {'id': 'engineering_college', 'name': 'ইঞ্জিনিয়ারিং কলেজ', 'icon': Icons.engineering},
              {'id': 'polytechnic', 'name': 'পলিটেকনিক', 'icon': Icons.architecture},
              {'id': 'higher_secondary', 'name': 'উচ্চ মাধ্যমিক', 'icon': Icons.school},
              {'id': 'english_medium', 'name': 'ইংলিশ মিডিয়াম', 'icon': Icons.school},
              {'id': 'madrasa', 'name': 'মাদ্রাসা', 'icon': Icons.menu_book},
              {'id': 'technical_school', 'name': 'টেকনিক্যাল স্কুল', 'icon': Icons.build},
              {'id': 'drama_school', 'name': 'ড্রামা স্কুল', 'icon': Icons.theater_comedy},
              {'id': 'art_school', 'name': 'আর্ট স্কুল', 'icon': Icons.palette},
              {'id': 'training_institute', 'name': 'ট্রেনিং ইন্সটিটিউট', 'icon': Icons.model_training},
              {'id': 'research_institution', 'name': 'রিসার্চ প্রতিষ্ঠান', 'icon': Icons.biotech},
              {'id': 'special_school', 'name': 'স্পেশাল স্কুল', 'icon': Icons.accessibility_new},
              {'id': 'library', 'name': 'লাইব্রেরি', 'icon': Icons.local_library},
            ], primaryColor, isDarkMode),
            
            _buildCategoryGroup(context, 'ভ্রমণ ও অন্যান্য', [
              {'id': 'hotel', 'name': 'হোটেল', 'icon': Icons.hotel},
              {'id': 'upazila', 'name': 'উপজেলা পরিচিতি', 'icon': Icons.location_city},
              {'id': 'news', 'name': 'পত্রিকা', 'icon': Icons.newspaper},
              {'id': 'electricity', 'name': 'বিদ্যুৎ', 'icon': Icons.electric_bolt},
            ], const Color(0xFF8E24AA), isDarkMode),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add_rounded),
        label: const Text('নতুন ক্যাটাগরি', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditCategoryScreen())),
      ),
    );
  }

  Widget _buildCategoryGroup(BuildContext context, String groupName, List<Map<String, dynamic>> items, Color groupColor, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          groupName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildServiceButton(
              context,
              item['name'], 
              item['icon'], 
              groupColor, 
              () => _onCategoryTap(context, item['id'], item['name']), 
              isDarkMode,
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildServiceButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
