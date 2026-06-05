import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_barishal_new/screens/category_detail_screen.dart';
import '../widgets/auto_translated_text.dart';
import 'wiki_upazila_detail_screen.dart';
class UpazilaListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const UpazilaListScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<UpazilaListScreen> createState() => _UpazilaListScreenState();
}

class _UpazilaListScreenState extends State<UpazilaListScreen> {
  late Stream<QuerySnapshot> _upazilaStream;

  @override
  void initState() {
    super.initState();
    _upazilaStream = FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.categoryId)
        .collection('upazilas')
        .snapshots();
  }

  // Local upazilas removed, loaded fully from DB.
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
        elevation: 0,
        title: AutoTranslatedText(widget.categoryTitle, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
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
          child: StreamBuilder<QuerySnapshot>(
            stream: _upazilaStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: AutoTranslatedText('কোনো উপজেলা ডাটাবেসে নেই!'));
              }

              List<Map<String, dynamic>> upazilasToShow = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              }).toList();
              return AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: upazilasToShow.length,
                  itemBuilder: (context, index) {
                    final upazila = upazilasToShow[index];
                    final upazilaName = upazila['name'];
                    final upazilaId = upazila['id'];

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: isDarkMode 
                                  ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
                                  : [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.4)],
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
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  title: AutoTranslatedText(
                                    upazilaName, 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: isDarkMode ? Colors.white : Colors.black87
                                    )
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.arrow_forward_ios, size: 16, color: isDarkMode ? Colors.white70 : Colors.black54),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WikiUpazilaDetailScreen(
                                          upazilaData: upazila,
                                          upazilaDocId: upazilaId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
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