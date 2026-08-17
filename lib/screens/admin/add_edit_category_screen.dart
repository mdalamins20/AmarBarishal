import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_barishal_new/services/fcm_sender_service.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;
  const AddEditCategoryScreen({super.key, this.documentId, this.initialData});
  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late String _name, _icon, _color;
  late int _order;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    _name = widget.initialData?['name'] ?? '';
    _icon = widget.initialData?['icon'] ?? 'apps';
    _color = widget.initialData?['color'] ?? '#000000';
    _order = widget.initialData?['order'] ?? 0;
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    final data = {'name': _name, 'icon': _icon, 'color': _color, 'order': _order};
    
    try {
      if (widget.documentId == null) {
        await FirebaseFirestore.instance.collection('categories').add(data);
        FcmSenderService.sendNotificationToAllUsers(
          title: 'নতুন ফিচার যুক্ত হয়েছে!',
          body: 'অ্যাপে "$_name" নামে একটি নতুন ক্যাটাগরি যুক্ত করা হয়েছে।',
        );
      } else {
        await FirebaseFirestore.instance.collection('categories').doc(widget.documentId).update(data);
        FcmSenderService.sendNotificationToAllUsers(
          title: 'ক্যাটাগরি আপডেট হয়েছে',
          body: '"$_name" ক্যাটাগরিটি আপডেট করা হয়েছে।',
        );
      }
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text('সফলভাবে সংরক্ষিত হয়েছে!'),
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
    } catch(e) {
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('সংরক্ষণ করতে সমস্যা হয়েছে!'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
         );
      }
    } finally {
       if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
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
                             widget.documentId == null ? 'নতুন ক্যাটাগরি' : 'সম্পাদনা',
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
                          widget.documentId == null ? 'ক্যাটাগরি যোগ করুন' : 'ক্যাটাগরি আপডেট',
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
                        Text('বিস্তারিত তথ্য', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 1.0)),
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
                                initialValue: _name,
                                label: 'ক্যাটাগরির নাম',
                                hint: 'যেমন: স্কুল ও কলেজ',
                                icon: Icons.category_rounded,
                                accentColor: accentColor,
                                isDark: isDark,
                                onSaved: (v) => _name = v!.trim(),
                                validator: (v) => v!.trim().isEmpty ? 'নাম দিন' : null,
                              ),
                              _buildDivider(isDark),
                              _buildField(
                                initialValue: _icon,
                                label: 'আইকনের নাম',
                                hint: 'e.g., school, hospital, police',
                                icon: Icons.insert_emoticon_rounded,
                                accentColor: Colors.orange,
                                isDark: isDark,
                                onSaved: (v) => _icon = v!.trim(),
                                validator: (v) => v!.trim().isEmpty ? 'আইকনের নাম দিন' : null,
                              ),
                              _buildDivider(isDark),
                              _buildField(
                                initialValue: _color,
                                label: 'রঙের হেক্স কোড',
                                hint: 'e.g., #4CAF50',
                                icon: Icons.color_lens_rounded,
                                accentColor: Colors.green,
                                isDark: isDark,
                                onSaved: (v) => _color = v!.trim(),
                                validator: (v) => v!.trim().isEmpty ? 'রঙের কোড দিন' : null,
                              ),
                              _buildDivider(isDark),
                              _buildField(
                                initialValue: _order.toString(),
                                label: 'সাজানোর নম্বর (ক্রম)',
                                hint: 'e.g., 1, 2, 3',
                                icon: Icons.format_list_numbered_rounded,
                                accentColor: Colors.blue,
                                isDark: isDark,
                                keyboardType: TextInputType.number,
                                onSaved: (v) => _order = int.tryParse(v!.trim()) ?? 0,
                                validator: (v) => v!.trim().isEmpty ? 'নম্বর দিন' : null,
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
                                 onPressed: _saveForm,
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: accentColor,
                                   foregroundColor: Colors.white,
                                   elevation: 8,
                                   shadowColor: accentColor.withValues(alpha: 0.4),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                 ),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                      Icon(widget.documentId == null ? Icons.save_rounded : Icons.update_rounded, size: 20),
                                      const SizedBox(width: 10),
                                      Text(widget.documentId == null ? 'সংরক্ষণ করুন' : 'আপডেট করুন', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
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

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, indent: 56, endIndent: 0, color: isDark ? Colors.white10 : Colors.grey.shade100);
  }

  Widget _buildField({
    required String initialValue,
    required String label,
    required String hint,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
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
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
      ),
    );
  }
}