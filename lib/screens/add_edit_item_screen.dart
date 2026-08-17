import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/fcm_sender_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final String categoryDocId;
  final String? upazilaDocId;
  final String? itemDocId;
  final Map<String, dynamic>? initialData;

  const AddEditItemScreen({
    super.key,
    required this.categoryDocId,
    this.upazilaDocId,
    this.itemDocId,
    this.initialData,
  });

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mapLinkController = TextEditingController();
  final _headmasterController = TextEditingController();

  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool get _isEditing => widget.itemDocId != null;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    if (_isEditing) {
      _nameController.text = widget.initialData?['name'] ?? '';
      _addressController.text = widget.initialData?['address'] ?? '';
      _phoneController.text = widget.initialData?['phone'] ?? '';
      _mapLinkController.text = widget.initialData?['mapLink'] ?? '';
      _headmasterController.text = widget.initialData?['headmaster'] ?? '';
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final data = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'mapLink': _mapLinkController.text.trim(),
      };

      if (widget.categoryDocId == 'schoolCollege') {
        data['headmaster'] = _headmasterController.text.trim();
      }

      try {
        CollectionReference itemsCollection;
        if (widget.upazilaDocId != null) {
          itemsCollection = FirebaseFirestore.instance
              .collection('categories')
              .doc(widget.categoryDocId)
              .collection('upazilas')
              .doc(widget.upazilaDocId)
              .collection('items');
        } else {
          itemsCollection = FirebaseFirestore.instance
              .collection('categories')
              .doc(widget.categoryDocId)
              .collection('items');
        }

        if (_isEditing) {
          await itemsCollection.doc(widget.itemDocId).update(data);
          FcmSenderService.sendNotificationToAllUsers(
            title: 'তথ্য আপডেট হয়েছে!',
            body: '${data['name']} এর তথ্য সম্প্রতি আপডেট করা হয়েছে।',
          );
        } else {
          await itemsCollection.add(data);
          FcmSenderService.sendNotificationToAllUsers(
            title: 'নতুন তথ্য যোগ হয়েছে!',
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
              content: const Row(
                children: [
                  Icon(Icons.error_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text('কোনো সমস্যা হয়েছে, আবার চেষ্টা করুন।'),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
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
    _addressController.dispose();
    _phoneController.dispose();
    _mapLinkController.dispose();
    _headmasterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1219) : const Color(0xFFF4F6FA),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          // ─── Premium SliverAppBar ───────────────────────────────────────
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
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Decorative circle
                  Positioned(
                    top: -80,
                    right: -60,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -40,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal.withValues(alpha: 0.08),
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
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            _isEditing ? 'সম্পাদনা' : 'নতুন তথ্য',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isEditing ? 'তথ্য আপডেট করুন' : 'নতুন তথ্য যোগ করুন',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Form Body ──────────────────────────────────────────────────
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
                      _buildSectionLabel('প্রাথমিক তথ্য'),
                      const SizedBox(height: 12),
                      _buildCard(
                        isDark,
                        children: [
                          _buildField(
                            controller: _nameController,
                            label: 'নাম',
                            hint: 'প্রতিষ্ঠানের/ব্যক্তির নাম',
                            icon: Icons.badge_rounded,
                            accentColor: accentColor,
                            isDark: isDark,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'নাম লিখুন' : null,
                          ),
                          _buildDivider(isDark),
                          _buildField(
                            controller: _addressController,
                            label: 'ঠিকানা',
                            hint: 'সম্পূর্ণ ঠিকানা লিখুন',
                            icon: Icons.location_on_rounded,
                            accentColor: Colors.orange,
                            isDark: isDark,
                            maxLines: 2,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'ঠিকানা লিখুন' : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildSectionLabel('যোগাযোগ'),
                      const SizedBox(height: 12),
                      _buildCard(
                        isDark,
                        children: [
                          _buildField(
                            controller: _phoneController,
                            label: 'ফোন নম্বর',
                            hint: '০১XXXXXXXXX',
                            icon: Icons.phone_rounded,
                            accentColor: Colors.green,
                            isDark: isDark,
                            keyboardType: TextInputType.phone,
                          ),
                          if (widget.categoryDocId == 'schoolCollege') ...[
                            _buildDivider(isDark),
                            _buildField(
                              controller: _headmasterController,
                              label: 'প্রধান শিক্ষকের নাম',
                              hint: 'প্রধান শিক্ষক / অধ্যক্ষের নাম',
                              icon: Icons.person_rounded,
                              accentColor: Colors.teal,
                              isDark: isDark,
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildSectionLabel('অবস্থান'),
                      const SizedBox(height: 12),
                      _buildCard(
                        isDark,
                        children: [
                          _buildField(
                            controller: _mapLinkController,
                            label: 'গুগল ম্যাপ লিংক',
                            hint: 'https://maps.google.com/...',
                            icon: Icons.map_rounded,
                            accentColor: Colors.blue,
                            isDark: isDark,
                            keyboardType: TextInputType.url,
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    color: accentColor,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _saveItem,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: accentColor.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isEditing
                                          ? Icons.update_rounded
                                          : Icons.save_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isEditing ? 'আপডেট করুন' : 'সেভ করুন',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
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
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildCard(bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2533) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 0,
      color: isDark ? Colors.white10 : Colors.grey.shade100,
    );
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
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white24 : Colors.grey.shade400,
          fontSize: 13,
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.grey.shade600,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        enabledBorder: InputBorder.none,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        filled: false,
      ),
    );
  }
}