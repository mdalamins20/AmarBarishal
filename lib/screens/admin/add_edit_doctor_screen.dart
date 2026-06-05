import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_barishal_new/services/fcm_sender_service.dart';

class AddEditDoctorScreen extends StatefulWidget {
  final String categoryDocId;
  final String specialtyName;
  final String? itemDocId;
  final Map<String, dynamic>? initialData;

  const AddEditDoctorScreen({
    super.key, 
    required this.categoryDocId, 
    required this.specialtyName,
    this.itemDocId, 
    this.initialData,
  });

  @override
  State<AddEditDoctorScreen> createState() => _AddEditDoctorScreenState();
}

class _AddEditDoctorScreenState extends State<AddEditDoctorScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _degreeController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _designationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _mapLinkController = TextEditingController();

  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool get _isEditing => widget.itemDocId != null;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    if (_isEditing) {
      _nameController.text = widget.initialData?['name'] ?? '';
      _degreeController.text = widget.initialData?['degree'] ?? '';
      _specialtyController.text = widget.initialData?['specialty'] ?? widget.specialtyName;
      _designationController.text = widget.initialData?['designation'] ?? '';
      _phoneController.text = widget.initialData?['phone'] ?? '';
      _addressController.text = widget.initialData?['address'] ?? '';
      _mapLinkController.text = widget.initialData?['mapLink'] ?? '';
    } else {
      _specialtyController.text = widget.specialtyName;
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final data = {
        'name': _nameController.text.trim(),
        'degree': _degreeController.text.trim(),
        'specialty': _specialtyController.text.trim(),
        'designation': _designationController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'mapLink': _mapLinkController.text.trim(),
      };

      try {
        final collection = FirebaseFirestore.instance.collection('categories').doc(widget.categoryDocId).collection('items');

        if (_isEditing) {
          await collection.doc(widget.itemDocId).update(data);
          FcmSenderService.sendNotificationToAllUsers(
            title: 'ডাক্তারের তথ্য আপডেট হয়েছে!',
            body: '${data['name']} এর তথ্য আপডেট করা হয়েছে।',
          );
        } else {
          await collection.add(data);
          FcmSenderService.sendNotificationToAllUsers(
            title: 'নতুন ডাক্তার যোগ হয়েছে!',
            body: '${data['name']} আমাদের ডিরেক্টরিতে যোগ হয়েছে।',
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('তথ্য সফলভাবে ${_isEditing ? 'আপডেট' : 'যোগ'} করা হয়েছে!'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('কোনো সমস্যা হয়েছে, আবার চেষ্টা করুন।'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _degreeController.dispose();
    _specialtyController.dispose();
    _designationController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _mapLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Colors.blueAccent;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1219) : const Color(0xFFF4F6FA),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF0F1219) : const Color(0xFFF4F6FA),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.black87),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: -80,
                    right: -60,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withOpacity(0.12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 90, left: 24, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            _isEditing ? 'সম্পাদনা' : 'নতুন তথ্য',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isEditing ? 'ডাক্তারের তথ্য আপডেট' : 'নতুন ডাক্তার যোগ',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: isDark ? Colors.white : Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('সাধারণ তথ্য'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2533) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 20, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildField(
                              controller: _nameController,
                              label: 'ডাক্তারের নাম',
                              hint: 'যেমন: ডা. মো: আব্দুর রহিম',
                              icon: Icons.person,
                              accentColor: accentColor,
                              isDark: isDark,
                              validator: (v) => (v == null || v.isEmpty) ? 'নাম লিখুন' : null,
                            ),
                            _buildDivider(isDark),
                            _buildField(
                              controller: _degreeController,
                              label: 'ডিগ্রি',
                              hint: 'যেমন: এমবিবিএস, এফসিপিএস',
                              icon: Icons.school,
                              accentColor: Colors.orange,
                              isDark: isDark,
                            ),
                            _buildDivider(isDark),
                            _buildField(
                              controller: _designationController,
                              label: 'পদবী ও কর্মস্থল',
                              hint: 'যেমন: সহকারী অধ্যাপক, শেরে বাংলা মেডিকেল কলেজ',
                              icon: Icons.work,
                              accentColor: Colors.purple,
                              isDark: isDark,
                            ),
                            _buildDivider(isDark),
                            _buildField(
                              controller: _specialtyController,
                              label: 'স্পেশালিটি (বিভাগ)',
                              hint: 'যেমন: মেডিসিন',
                              icon: Icons.medical_services,
                              accentColor: Colors.teal,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionLabel('যোগাযোগের তথ্য'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2533) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 20, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildField(
                              controller: _phoneController,
                              label: 'সিরিয়ালের ফোন নম্বর',
                              hint: '০১৭...',
                              icon: Icons.phone,
                              accentColor: Colors.green,
                              isDark: isDark,
                              keyboardType: TextInputType.phone,
                            ),
                            _buildDivider(isDark),
                            _buildField(
                              controller: _addressController,
                              label: 'চেম্বার ও ঠিকানা',
                              hint: 'যেমন: ইবনে সিনা, বরিশাল',
                              icon: Icons.location_on,
                              accentColor: Colors.redAccent,
                              isDark: isDark,
                              maxLines: 2,
                            ),
                            _buildDivider(isDark),
                            _buildField(
                              controller: _mapLinkController,
                              label: 'গুগল ম্যাপ লিংক (ঐচ্ছিক)',
                              hint: 'https://maps.app.goo.gl/...',
                              icon: Icons.map,
                              accentColor: Colors.amber,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: _isLoading
                            ? Center(child: CircularProgressIndicator(color: accentColor))
                            : ElevatedButton(
                                onPressed: _saveItem,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_isEditing ? Icons.update_rounded : Icons.save_rounded, size: 20),
                                    const SizedBox(width: 10),
                                    Text(_isEditing ? 'আপডেট করুন' : 'সেভ করুন', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 1.0));
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, indent: 56, endIndent: 0, color: isDark ? Colors.white10 : Colors.grey.shade100);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      autocorrect: false,
      enableSuggestions: false,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey.shade400, fontSize: 13),
        labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
        prefixIcon: Padding(padding: const EdgeInsets.all(14), child: Icon(icon, color: accentColor, size: 22)),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: accentColor, width: 2)),
        enabledBorder: InputBorder.none,
      ),
    );
  }
}
