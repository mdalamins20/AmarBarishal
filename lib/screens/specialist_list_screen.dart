import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/auto_translated_text.dart';
import 'doctor_list_screen.dart';

class SpecialistListScreen extends StatefulWidget {
  final String categoryDocId;
  final String categoryTitle;

  const SpecialistListScreen({
    Key? key,
    required this.categoryDocId,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  State<SpecialistListScreen> createState() => _SpecialistListScreenState();
}

class _SpecialistListScreenState extends State<SpecialistListScreen> {
  late Stream<DocumentSnapshot> _specialistStream;

  @override
  void initState() {
    super.initState();
    _specialistStream = FirebaseFirestore.instance.collection('categories').doc(widget.categoryDocId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1219) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: AutoTranslatedText(
          widget.categoryTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black87),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode 
                  ? [Colors.blueAccent.shade700.withOpacity(0.2), Colors.transparent]
                  : [Colors.blue.withOpacity(0.1), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _specialistStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: AutoTranslatedText(
                'Something went wrong. Please try again.',
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No Data"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final specialties = List<String>.from(data['specialties'] ?? []);

          if (specialties.isEmpty) {
            return Center(
              child: AutoTranslatedText(
                'No specialties found.',
                style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: AutoTranslatedText(
                      "Specialist Doctors List in Barisal",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.blueAccent.shade100 : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: specialties.length,
                  itemBuilder: (context, index) {
                    final specialty = specialties[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1A1F2B) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: isDarkMode ? [] : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorListScreen(
                                specialtyName: specialty,
                                categoryDocId: widget.categoryDocId,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          child: Center(
                            child: AutoTranslatedText(
                              specialty,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDarkMode ? Colors.blueAccent.shade100 : Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
