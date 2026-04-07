import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'add_edit_item_screen.dart';
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
    // ... আপনার ডিলিট করার কোড এখানে থাকবে ...
  }

  @override
  Widget build(BuildContext context) {
    Query itemsQuery;
    var collectionRef = FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.categoryDocId);

    if (widget.upazilaDocId != null) {
      collectionRef = collectionRef.collection('upazilas').doc(widget.upazilaDocId);
    }
    itemsQuery = collectionRef.collection('items');

    if (widget.schoolType != null) {
      itemsQuery = itemsQuery.where('type', isEqualTo: widget.schoolType);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'এখানে সার্চ করুন...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (widget.categoryDocId == 'schoolCollege') ...[
                  // ... আপনার ফিল্টার চিপস অপরিবর্তিত ...
                ],
              ],
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
                  return const Center(child: Text('একটি সমস্যা হয়েছে'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('কোনো তথ্য পাওয়া যায়নি'));
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
                  return const Center(child: Text('আপনার সার্চের সাথে মিলে এমন কোনো তথ্য নেই'));
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final itemDoc = filteredItems[index];
                      final item = itemDoc.data() as Map<String, dynamic>;
                      final itemDocId = itemDoc.id;
                      final user = FirebaseAuth.instance.currentUser;
                      final headmaster = item['headmaster'] ?? 'তথ্য নেই';

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                title: Text(item['name'] ?? 'নাম নেই',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 18)),
                                subtitle: widget.categoryDocId == 'schoolCollege'
                                    ? Text("প্রধান শিক্ষক: $headmaster",
                                    maxLines: 1, overflow: TextOverflow.ellipsis)
                                    : null,
                                trailing: user != null
                                    ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddEditItemScreen(
                                                  categoryDocId:
                                                  widget.categoryDocId,
                                                  upazilaDocId: widget.upazilaDocId,
                                                  itemDocId: itemDocId,
                                                  initialData: item,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _showDeleteConfirmationDialog(itemDocId),
                                    ),
                                  ],
                                )
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
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // *** এখানে FloatingActionButton পুনরায় যোগ করা হয়েছে ***
      floatingActionButton: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          // যদি ব্যবহারকারী লগইন করা থাকে, তাহলে বাটনটি দেখানো হবে
          if (userSnapshot.hasData) {
            return FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEditItemScreen(
                      categoryDocId: widget.categoryDocId,
                      upazilaDocId: widget.upazilaDocId,
                    ),
                  ),
                );
              },
            );
          }
          // লগইন করা না থাকলে কিছুই দেখানো হবে না
          return const SizedBox.shrink();
        },
      ),
    );
  }
}