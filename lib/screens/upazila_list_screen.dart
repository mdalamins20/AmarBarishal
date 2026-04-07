import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_barishal_new/screens/category_detail_screen.dart';

class UpazilaListScreen extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;

  const UpazilaListScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('upazilas')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('একটি সমস্যা হয়েছে'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('কোনো উপজেলা পাওয়া যায়নি'));
          }

          final upazilas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: upazilas.length,
            itemBuilder: (context, index) {
              final upazila = upazilas[index].data() as Map<String, dynamic>;
              final upazilaName = upazila['name'] ?? 'নাম নেই';
              final upazilaId = upazilas[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(upazilaName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDetailScreen(
                          categoryTitle: upazilaName,
                          categoryDocId: categoryId,
                          upazilaDocId: upazilaId, // উপজেলার আইডি পাঠানো হচ্ছে
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
    );
  }
}