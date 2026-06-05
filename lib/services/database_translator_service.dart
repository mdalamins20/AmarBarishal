import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:translator/translator.dart';

class DatabaseTranslatorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleTranslator _translator = GoogleTranslator();

  // Function to check if a string contains English letters
  static bool _containsEnglish(String text) {
    return RegExp(r'[a-zA-Z]').hasMatch(text);
  }

  static Future<String> _translateText(String text) async {
    if (text.isEmpty || !_containsEnglish(text)) return text;
    
    try {
      // First do some common exact replacements to keep formatting nice
      String tempText = text
        .replaceAll(' Specialist in Barisal', ' বিশেষজ্ঞ, বরিশাল')
        .replaceAll(' in Barisal', ', বরিশাল')
        .replaceAll('MBBS', 'এমবিবিএস')
        .replaceAll('FCPS', 'এফসিপিএস')
        .replaceAll('MD', 'এমডি')
        .replaceAll('MS', 'এমএস')
        .replaceAll('FRCS', 'এফআরসিএস')
        .replaceAll('Closed', 'বন্ধ')
        .replaceAll('Friday', 'শুক্রবার')
        .replaceAll('Thursday', 'বৃহস্পতিবার')
        .replaceAll('Everyday', 'প্রতিদিন');
        
      if (!_containsEnglish(tempText)) return tempText;

      final translation = await _translator.translate(tempText, from: 'en', to: 'bn');
      return translation.text;
    } catch (e) {
      debugPrint('Translation error for "$text": $e');
      return text; // Return original on error
    }
  }

  static Future<List<dynamic>> _translateList(List<dynamic> list) async {
    List<dynamic> translatedList = [];
    for (var item in list) {
      if (item is String) {
        translatedList.add(await _translateText(item));
      } else {
        translatedList.add(item);
      }
    }
    return translatedList;
  }

  static Future<void> runTranslation() async {
    try {
      debugPrint('Starting Database Translation via Google API...');
      
      // 1. Translate Category Documents
      final categoriesSnapshot = await _firestore.collection('categories').get();
      for (var doc in categoriesSnapshot.docs) {
        bool needsUpdate = false;
        Map<String, dynamic> data = doc.data();
        
        // Translate specialties array if exists
        if (data.containsKey('specialties') && data['specialties'] is List) {
          List<dynamic> oldList = data['specialties'];
          List<dynamic> newList = await _translateList(oldList);
          
          if (!listEquals(oldList, newList)) {
            data['specialties'] = newList;
            needsUpdate = true;
          }
        }
        
        // Update category name if needed
        if (data.containsKey('name') && data['name'] is String) {
          String oldName = data['name'];
          String newName = await _translateText(oldName);
          if (oldName != newName) {
            data['name'] = newName;
            needsUpdate = true;
          }
        }
        
        if (needsUpdate) {
          await _firestore.collection('categories').doc(doc.id).update(data);
          debugPrint('Updated category: ${doc.id}');
        }
        
        // 2. Translate items inside this category
        final itemsSnapshot = await _firestore.collection('categories').doc(doc.id).collection('items').get();
        for (var itemDoc in itemsSnapshot.docs) {
          bool itemNeedsUpdate = false;
          Map<String, dynamic> itemData = itemDoc.data();
          
          final fieldsToTranslate = ['name', 'specialty', 'qualifications', 'degree', 'designation', 'hospital', 'chamber', 'address', 'about', 'visiting_hours', 'visitingHours', 'category', 'description', 'type'];
          
          for (String field in fieldsToTranslate) {
            if (itemData.containsKey(field) && itemData[field] is String) {
              String oldText = itemData[field];
              String newText = await _translateText(oldText);
              if (oldText != newText) {
                itemData[field] = newText;
                itemNeedsUpdate = true;
              }
            } else if (itemData.containsKey(field) && itemData[field] is List) {
              List<dynamic> oldList = itemData[field];
              List<dynamic> newList = await _translateList(oldList);
              if (!listEquals(oldList, newList)) {
                itemData[field] = newList;
                itemNeedsUpdate = true;
              }
            }
          }

          // Translate chambers array (List of Maps)
          if (itemData.containsKey('chambers') && itemData['chambers'] is List) {
            List<dynamic> chambers = itemData['chambers'];
            bool chamberUpdated = false;
            for (int i = 0; i < chambers.length; i++) {
              if (chambers[i] is Map) {
                Map<String, dynamic> chamberMap = Map<String, dynamic>.from(chambers[i]);
                
                final chamberFields = ['name', 'address', 'visiting_hours'];
                for (String field in chamberFields) {
                  if (chamberMap.containsKey(field) && chamberMap[field] is String) {
                    String oldText = chamberMap[field];
                    String newText = await _translateText(oldText);
                    if (oldText != newText) {
                      chamberMap[field] = newText;
                      chamberUpdated = true;
                    }
                  }
                }
                chambers[i] = chamberMap;
              }
            }
            if (chamberUpdated) {
              itemData['chambers'] = chambers;
              itemNeedsUpdate = true;
            }
          }
          
          if (itemNeedsUpdate) {
            await _firestore.collection('categories').doc(doc.id).collection('items').doc(itemDoc.id).update(itemData);
            debugPrint('Updated item: ${itemDoc.id} in category ${doc.id}');
          }
          
          // Small delay to prevent rate-limiting from Google Translate API
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
      
      debugPrint('Database Translation Completed!');
    } catch (e) {
      debugPrint('Error translating database: $e');
      rethrow;
    }
  }
}
