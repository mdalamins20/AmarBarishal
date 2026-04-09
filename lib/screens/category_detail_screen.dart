import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/auto_translated_text.dart';
import 'item_detail_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryDocId;
  final String? upazilaDocId;
  final String? schoolType;

  const CategoryDetailScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryDocId,
    this.upazilaDocId,
    this.schoolType,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmationDialog(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নিশ্চিত করুন'),
        content: const Text('আপনি কি সত্যিই এই তথ্য মুছে ফেলতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('না')),
          TextButton(
            onPressed: () {
              var ref = FirebaseFirestore.instance.collection('categories').doc(widget.categoryDocId);
              if (widget.upazilaDocId != null) {
                ref = ref.collection('upazilas').doc(widget.upazilaDocId);
              }
              ref.collection('items').doc(docId).delete();
              Navigator.of(ctx).pop();
            },
            child: const Text('হ্যাঁ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Query itemsQuery;
    var collectionRef = FirebaseFirestore.instance.collection('categories').doc(widget.categoryDocId);

    if (widget.upazilaDocId != null) {
      collectionRef = collectionRef.collection('upazilas').doc(widget.upazilaDocId);
    }
    itemsQuery = collectionRef.collection('items');

    if (widget.schoolType != null) {
      itemsQuery = itemsQuery.where('type', isEqualTo: widget.schoolType);
    }

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDarkMode ? Colors.white24 : Colors.white),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      label: AutoTranslatedText('এখানে সার্চ করুন...', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                      prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black54),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: itemsQuery.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: AutoTranslatedText('একটি সমস্যা হয়েছে', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 80, color: isDarkMode ? Colors.white30 : Colors.black26),
                            const SizedBox(height: 16),
                            AutoTranslatedText('কোনো তথ্য পাওয়া যায়নি', style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 18)),
                          ],
                        ),
                      );
                    }

                    var items = snapshot.data!.docs;

                    final filteredItems = items.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '').toLowerCase();
                      final searchLower = _searchQuery.toLowerCase();
                      final type = data['type'] as String?;
                      final typeMatch = _selectedFilter == 'all' || type == _selectedFilter;
                      final nameMatch = name.contains(searchLower);
                      return typeMatch && nameMatch;
                    }).toList();

                    if (filteredItems.isEmpty) {
                      return Center(child: AutoTranslatedText('আপনার সার্চের সাথে মিলে এমন কোনো তথ্য নেই', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
                    }

                    return AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final itemDoc = filteredItems[index];
                          final item = itemDoc.data() as Map<String, dynamic>;
                          final itemDocId = itemDoc.id;
                          final user = FirebaseAuth.instance.currentUser;
                          final headmaster = item['headmaster'] ?? 'তথ্য নেই';

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16.0),
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
                                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        title: AutoTranslatedText(item['name'] ?? 'নাম নেই',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold, 
                                                fontSize: 18,
                                                color: isDarkMode ? Colors.white : Colors.black87)),
                                        subtitle: widget.categoryDocId == 'schoolCollege'
                                            ? AutoTranslatedText("প্রধান শিক্ষক: $headmaster",
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54))
                                            : null,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ItemDetailScreen(
                                                    itemData: item,
                                                    categoryId: widget.categoryDocId,
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
            ],
          ),
        ),
      ),
    );
  }
}