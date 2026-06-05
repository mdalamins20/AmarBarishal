import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/auto_translated_text.dart';

class DoctorListScreen extends StatefulWidget {
  final String specialtyName;
  final String categoryDocId;

  const DoctorListScreen({
    Key? key,
    required this.specialtyName,
    required this.categoryDocId,
  }) : super(key: key);

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late Stream<QuerySnapshot> _doctorStream;

  @override
  void initState() {
    super.initState();
    _doctorStream = FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.categoryDocId)
        .collection('items')
        .where('specialty', isEqualTo: widget.specialtyName)
        .snapshots();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Keep only numbers and '+'
    final cleanNum = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNum,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1219) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: AutoTranslatedText(
          widget.specialtyName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _doctorStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: AutoTranslatedText('Error loading doctors', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 80, color: isDarkMode ? Colors.white24 : Colors.black26),
                  const SizedBox(height: 16),
                  AutoTranslatedText(
                    'No doctors found for this specialty.',
                    style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index].data() as Map<String, dynamic>;
              return _buildDoctorCard(context, doc, isDarkMode);
            },
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doctor, bool isDarkMode) {
    final name = doctor['name'] ?? 'Unknown Doctor';
    final qualifications = doctor['qualifications'] ?? '';
    final specialty = doctor['specialty'] ?? '';
    final designation = doctor['designation'] ?? '';
    final about = doctor['about'] ?? '';
    final imageUrl = doctor['image_url'] ?? '';
    
    // Support new schema (list) and fallback to old schema
    List<dynamic> chambers = doctor['chambers'] ?? [];
    if (chambers.isEmpty && doctor.containsKey('chamber_address')) {
      chambers = [{
        'name': 'Chamber',
        'address': doctor['chamber_address'] ?? '',
        'visiting_hours': doctor['visiting_hours'] ?? '',
        'appointment_number': doctor['appointment_number'] ?? ''
      }];
    }

    final cardBg = isDarkMode ? const Color(0xFF1A1F2B) : Colors.white;
    final borderColor = isDarkMode ? Colors.white12 : Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: isDarkMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section: Image and Name
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (imageUrl.isNotEmpty)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade300, child: const Icon(Icons.person, color: Colors.white, size: 50)),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
                    ),
                    child: Icon(Icons.person, size: 60, color: isDarkMode ? Colors.white30 : Colors.grey.shade400),
                  ),
                const SizedBox(height: 12),
                AutoTranslatedText(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.blueAccent.shade100 : Colors.blue.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (qualifications.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AutoTranslatedText(
                    qualifications,
                    style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white70 : Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (specialty.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AutoTranslatedText(
                    specialty,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (designation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AutoTranslatedText(
                    designation,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white70 : Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          
          Divider(color: borderColor, height: 1),
          
          // Loop through all chambers
          ...chambers.map((chamberData) {
            final cName = chamberData['name'] ?? '';
            final cAddress = chamberData['address'] ?? '';
            final cVisiting = chamberData['visiting_hours'] ?? '';
            final cPhone = chamberData['appointment_number'] ?? '';
            
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                  child: Center(
                    child: AutoTranslatedText(
                      "Chamber & Appointment",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
                Divider(color: borderColor, height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (cName.isNotEmpty)
                        AutoTranslatedText(
                          cName,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.blueAccent.shade100 : Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (cAddress.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        AutoTranslatedText(
                          cAddress,
                          style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white70 : Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 8),
                      if (cVisiting.isNotEmpty)
                        AutoTranslatedText(
                          "Visiting Hour: $cVisiting",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      if (cPhone.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        AutoTranslatedText(
                          "Appointment: $cPhone",
                          style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white70 : Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _makePhoneCall(cPhone),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const AutoTranslatedText("Call Now", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
                Divider(color: borderColor, height: 1),
              ],
            );
          }).toList(),
          
          // About Section at the bottom
          if (about.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
              child: Center(
                child: AutoTranslatedText(
                  "About $name",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            Divider(color: borderColor, height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AutoTranslatedText(
                about,
                style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white70 : Colors.black87, height: 1.5),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
