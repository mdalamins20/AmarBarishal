import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_barishal_new/screens/add_edit_item_screen.dart';
import 'package:my_barishal_new/services/fcm_sender_service.dart';

class AdminCategoryDetailScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryDocId;
  final String? upazilaDocId;

  const AdminCategoryDetailScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryDocId,
    this.upazilaDocId,
  });

  @override
  State<AdminCategoryDetailScreen> createState() => _AdminCategoryDetailScreenState();
}

class _AdminCategoryDetailScreenState extends State<AdminCategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
            onPressed: () async {
              var ref = FirebaseFirestore.instance.collection('categories').doc(widget.categoryDocId);
              if (widget.upazilaDocId != null) {
                ref = ref.collection('upazilas').doc(widget.upazilaDocId);
              }
              
              // Get item name before deleting for notification
              final docSnap = await ref.collection('items').doc(docId).get();
              final itemName = docSnap.data()?['name'] ?? 'একটি তথ্য';
              
              await ref.collection('items').doc(docId).delete();
              
              FcmSenderService.sendNotificationToAllUsers(
                title: 'তথ্য মুছে ফেলা হয়েছে',
                body: '$itemName ডিরেক্টরি থেকে মুছে ফেলা হয়েছে।',
              );
              
              if (context.mounted) Navigator.of(ctx).pop();
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
    
    var collectionRef = FirebaseFirestore.instance.collection('categories').doc(widget.categoryDocId);
    if (widget.upazilaDocId != null) {
      collectionRef = collectionRef.collection('upazilas').doc(widget.upazilaDocId);
    }
    Query itemsQuery = collectionRef.collection('items');

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
        title: Text('${widget.categoryTitle} - পরিচালনা', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDarkMode ? Colors.white24 : Colors.white),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'সার্চ করুন...',
                      labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
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
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('কোনো তথ্য পাওয়া যায়নি'));
                    }

                    var items = snapshot.data!.docs;
                    final filteredItems = items.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '').toLowerCase();
                      return name.contains(_searchQuery.toLowerCase());
                    }).toList();

                    return AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final itemDoc = filteredItems[index];
                          final item = itemDoc.data() as Map<String, dynamic>;
                          final itemDocId = itemDoc.id;

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
                                        ? [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)]
                                        : [Colors.white.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.4)],
                                    ),
                                    border: Border.all(color: isDarkMode ? Colors.white12 : Colors.white, width: 1.5),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                    title: Text(item['name'] ?? 'নাম নেই',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black87)),
                                    subtitle: Text(item['phone'] ?? item['address'] ?? 'বিস্তারিত নেই', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                          onPressed: () {
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (_) => AddEditItemScreen(
                                                categoryDocId: widget.categoryDocId,
                                                upazilaDocId: widget.upazilaDocId,
                                                itemDocId: itemDocId,
                                                initialData: item,
                                              ),
                                            ));
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          onPressed: () => _showDeleteConfirmationDialog(itemDocId),
                                        ),
                                      ],
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('নতুন যোগ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AddEditItemScreen(
              categoryDocId: widget.categoryDocId,
              upazilaDocId: widget.upazilaDocId,
            ),
          ));
        },
      ),
    );
  }
}
