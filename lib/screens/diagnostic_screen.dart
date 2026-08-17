import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DiagnosticScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const DiagnosticScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  late Stream<QuerySnapshot> _diagnosticStream;

  @override
  void initState() {
    super.initState();
    _diagnosticStream = FirebaseFirestore.instance
        .collection('categories')
        .doc('diagnostic')
        .collection('items')
        .snapshots();
  }

  Future<void> _makeCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _diagnosticStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('কোন তথ্য পাওয়া যায়নি।'));
          }

          final items = snapshot.data!.docs;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index].data() as Map<String, dynamic>;
              final name = item['name'] ?? '';
              final address = item['address'] ?? '';
              final phone1 = item['phone1'] ?? '';
              final phone2 = item['phone2'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F4C81).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_hospital, color: Color(0xFF0F4C81), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        address,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDarkMode ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (phone1.isNotEmpty)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _makeCall(phone1),
                                icon: const Icon(Icons.call, size: 18),
                                label: Text(phone1, style: const TextStyle(fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22A699),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          if (phone1.isNotEmpty && phone2.isNotEmpty)
                            const SizedBox(width: 12),
                          if (phone2.isNotEmpty)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _makeCall(phone2),
                                icon: const Icon(Icons.call, size: 18),
                                label: Text(phone2, style: const TextStyle(fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F4C81),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
