import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_barishal_new/services/fcm_sender_service.dart';

class AddEditSosScreen extends StatefulWidget {
  final String? itemDocId;
  final Map<String, dynamic>? initialData;

  const AddEditSosScreen({super.key, this.itemDocId, this.initialData});

  @override
  State<AddEditSosScreen> createState() => _AddEditSosScreenState();
}

class _AddEditSosScreenState extends State<AddEditSosScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _shortcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _orderController = TextEditingController();

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
      _shortcodeController.text = widget.initialData?['shortcode'] ?? '';
      _descriptionController.text = widget.initialData?['description'] ?? '';
      _linkController.text = widget.initialData?['link'] ?? '';
      _orderController.text = (widget.initialData?['order'] ?? 0).toString();
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final data = {
        'shortcode': _shortcodeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'link': _linkController.text.trim(),
        'order': int.tryParse(_orderController.text.trim()) ?? 0,
      };

      try {
        final collection = FirebaseFirestore.instance.collection('categories').doc('sos').collection('items');

        if (_isEditing) {
          await collection.doc(widget.itemDocId).update(data);
          FcmSenderService.sendNotificationToAllUsers(
            title: 'জরুরি সেবা আপডেট হয়েছে!',
            body: '${data['shortcode']} এর তথ্য আপডেট করা হয়েছে।',
          );
        } else {
          await collection.add(data);
          FcmSenderService.sendNotificationToAllUsers(
            title: 'নতুন জরুরি সেবা যোগ হয়েছে!',
            body: '${data['shortcode']} আমাদের জরুরি সেবায় যোগ হয়েছে।',
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
    _shortcodeController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = Colors.redAccent;

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
                        color: accentColor.withValues(alpha: 0.12),
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
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isEditing ? 'হটলাইন আপডেট করুন' : 'নতুন হটলাইন যোগ করুন',
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
                      _buildSectionLabel('হটলাইন তথ্য'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2533) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05), blurRadius: 20, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildField(
                              controller: _shortcodeController,
                              label: 'ফোন নম্বর (শর্টকোড)',
                              hint: 'যেমন: ৯৯৯, ১০৯',
                              icon: Icons.phone_in_talk,
                              accentColor: accentColor,
                              isDark: isDark,
                              validator: (v) => (v == null || v.isEmpty) ? 'নম্বর লিখুন' : null,
                            ),
                            _buildDivider(isDark),
                            _buildField(
                              controller: _descriptionController,
                              label: 'বিবরণ',
                              hint: 'যেমন: জাতীয় জরুরি সেবা',
                              icon: Icons.description_rounded,
                              accentColor: Colors.orange,
                              isDark: isDark,
                              maxLines: 2,
                            ),
                            _buildDivider(isDark),
                            _buildField(
                              controller: _linkController,
                              label: 'ওয়েবসাইট লিংক (অপশনাল)',
                              hint: 'https://...',
                              icon: Icons.language,
                              accentColor: Colors.blue,
                              isDark: isDark,
                            ),
                            _buildDivider(isDark),
                            _buildField(
                              controller: _orderController,
                              label: 'ক্রম (Order)',
                              hint: '1, 2, 3...',
                              icon: Icons.format_list_numbered,
                              accentColor: Colors.green,
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: accentColor))
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
