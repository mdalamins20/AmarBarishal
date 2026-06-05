import 'package:flutter/material.dart';
import '../widgets/auto_translated_text.dart';
import 'category_detail_screen.dart';
import 'upazila_list_screen.dart';
import 'news_source_screen.dart';
import 'diagnostic_screen.dart';
import 'specialist_list_screen.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  void _onCategoryTap(BuildContext context, String categoryId, String categoryName) {
    if (categoryName == "উপজেলা পরিচিতি" || categoryId == 'upazila') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UpazilaListScreen(categoryId: categoryId, categoryTitle: categoryName)));
    } else if (categoryId == 'news' || categoryName == 'পত্রিকা') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsSourceScreen()));
    } else if (categoryId == 'doctor') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialistListScreen(categoryTitle: categoryName, categoryDocId: categoryId)));
    } else if (categoryId == 'diagnostic') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DiagnosticScreen(categoryId: categoryId, categoryTitle: categoryName)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailScreen(categoryTitle: categoryName, categoryDocId: categoryId)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0F4C81);
    final secondaryColor = const Color(0xFF22A699);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const AutoTranslatedText('সকল সেবা', style: TextStyle(fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGroup(BuildContext context, String groupName, List<Map<String, dynamic>> items, Color groupColor, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoTranslatedText(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AutoTranslatedText(
                  title, 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11, 
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
