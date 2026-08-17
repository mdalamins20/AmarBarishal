import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_barishal_new/services/fcm_sender_service.dart';
import 'add_edit_sos_screen.dart';

class AdminSosListScreen extends StatelessWidget {
  const AdminSosListScreen({super.key});

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
        backgroundColor: isDarkMode ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.4),
        title: Text('জরুরি হটলাইন (SOS) পরিচালনা', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditSosScreen()));
        },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('নতুন হটলাইন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF151928), const Color(0xFF2B1F31)]
                : [const Color(0xFFFFF0F0), const Color(0xFFFFE0E0)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').doc('sos').collection('items').orderBy('order').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('কোনো তথ্য নেই।'));
              }

              return AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16).copyWith(bottom: 80),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final item = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                            elevation: isDarkMode ? 0 : 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: const CircleAvatar(
                                backgroundColor: Colors.redAccent,
                                child: Icon(Icons.phone_in_talk, color: Colors.white),
                              ),
                              title: Text(
                                item['shortcode'] ?? 'নাম নেই',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black87),
                              ),
                              subtitle: Text(item['description'] ?? 'বিবরণ নেই', style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => AddEditSosScreen(
                                          itemDocId: docId,
                                          initialData: item,
                                        )
                                      ));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _showDeleteDialog(context, docId, item['shortcode'] ?? 'এই হটলাইনটি'),
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
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String docId, String itemName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নিশ্চিত করুন'),
        content: const Text('আপনি কি সত্যিই এই তথ্য মুছে ফেলতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('না')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('categories').doc('sos').collection('items').doc(docId).delete();
              FcmSenderService.sendNotificationToAllUsers(
                title: 'তথ্য মুছে ফেলা হয়েছে',
                body: '$itemName জরুরি সেবা থেকে মুছে ফেলা হয়েছে।',
              );
              if (context.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('হ্যাঁ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
