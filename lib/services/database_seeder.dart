import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseSeeder {
  static const List<Map<String, dynamic>> defaultCategories = [
    {'id': 'hospital', 'name': 'হসপিটাল', 'icon': 'hospital', 'color': '#D32F2F', 'order': 1},
    {'id': 'doctor', 'name': 'ডাক্তার', 'icon': 'doctor', 'color': '#1976D2', 'order': 2},
    {'id': 'ambulance', 'name': 'অ্যাম্বুলেন্স', 'icon': 'ambulance', 'color': '#F57C00', 'order': 3},
    {'id': 'police', 'name': 'পুলিশ', 'icon': 'police', 'color': '#00796B', 'order': 4},
    {'id': 'fire_service', 'name': 'ফায়ার সার্ভিস', 'icon': 'fire_service', 'color': '#D84315', 'order': 5},
    {'id': 'upazila', 'name': 'উপজেলাসমূহ', 'icon': 'info', 'color': '#388E3C', 'order': 6},
    {'id': 'hotel', 'name': 'হোটেল', 'icon': 'hotel', 'color': '#7B1FA2', 'order': 7},
    {'id': 'landscape', 'name': 'দর্শনীয় স্থান', 'icon': 'landscape', 'color': '#558B2F', 'order': 8},
    {'id': 'education', 'name': 'স্কুল ও কলেজ', 'icon': 'education', 'color': '#FBC02D', 'order': 9},
    {'id': 'news', 'name': 'পত্রিকা', 'icon': 'news', 'color': '#0097A7', 'order': 10},
    {'id': 'restaurant', 'name': 'রেস্টুরেন্ট', 'icon': 'restaurant', 'color': '#C2185B', 'order': 11},
    {'id': 'library', 'name': 'লাইব্রেরি', 'icon': 'library', 'color': '#5D4037', 'order': 12},
  ];

  static Future<void> ensureDefaultData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection('categories');

      // 1. Fetch all existing documents to fix duplicates and check what is missing
      final snapshot = await collection.get();
      final existingDocs = snapshot.docs;
      
      final Set<String> seenNames = {};
      final List<String> docsToDelete = [];
      final Map<String, bool> existingNamesMap = {};

      for (var doc in existingDocs) {
        final data = doc.data();
        final name = data['name'] as String? ?? '';
        
        if (seenNames.contains(name)) {
          // Duplicate found! Delete it!
          docsToDelete.add(doc.id);
        } else {
          seenNames.add(name);
          existingNamesMap[name] = true;
        }
      }

      // Delete the duplicates we found
      for (var docId in docsToDelete) {
        await collection.doc(docId).delete();
        debugPrint('Deleted duplicate category: $docId');
      }

      // 2. Add missing categories (by name) and Fix the colors of existing ones!
      for (final category in defaultCategories) {
        final name = category['name'];
        if (!existingNamesMap.containsKey(name)) {
          // Doesn't exist, create it with the specified ID
          final docRef = collection.doc(category['id']);
          final data = Map<String, dynamic>.from(category);
          data.remove('id');
          await docRef.set(data);
          debugPrint('Seeded missing category: $name');
        } else {
          // Update the existing color so the pale colors become vibrant again!
          for (var doc in existingDocs) {
            String existingName = doc.data()['name'] as String? ?? '';
            if (existingName == name && !docsToDelete.contains(doc.id)) {
              await collection.doc(doc.id).update({
                'color': category['color'], 
                'icon': category['icon'] // Ensuring proper icon as well
              });
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error seeding database: $e");
    }
  }
}
