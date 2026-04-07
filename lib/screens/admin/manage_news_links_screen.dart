import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_barishal_new/screens/admin/add_edit_news_link_screen.dart';

class ManageNewsLinksScreen extends StatelessWidget {
  const ManageNewsLinksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('নিউজ লিংক পরিচালনা')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('news_links').orderBy('order').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title']),
                subtitle: Text(data['url']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditNewsLinkScreen(documentId: doc.id, initialData: data)))),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditNewsLinkScreen())),
      ),
    );
  }
}