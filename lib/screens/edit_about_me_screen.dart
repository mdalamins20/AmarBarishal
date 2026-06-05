import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAboutMeScreen extends StatefulWidget {
  const EditAboutMeScreen({super.key});

  @override
  State<EditAboutMeScreen> createState() => _EditAboutMeScreenState();
}

class _EditAboutMeScreenState extends State<EditAboutMeScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _facebookLinkController = TextEditingController();
  final _websiteLinkController = TextEditingController();
  final _aboutController = TextEditingController();
  
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final DocumentReference _docRef = FirebaseFirestore.instance.collection('about_me').doc('developer_info');

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    final snapshot = await _docRef.get();
    if (snapshot.exists && mounted) {
      final data = snapshot.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _designationController.text = data['designation'] ?? '';
      _imageUrlController.text = data['imageUrl'] ?? '';
      _mobileController.text = data['mobile'] ?? '';
      _emailController.text = data['email'] ?? '';
      _facebookLinkController.text = data['facebookLink'] ?? '';
      _websiteLinkController.text = data['websiteLink'] ?? '';
      _aboutController.text = data['about'] ?? '';
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final data = {
        'name': _nameController.text.trim(),
        'designation': _designationController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
        'facebookLink': _facebookLinkController.text.trim(),
        'websiteLink': _websiteLinkController.text.trim(),
        'about': _aboutController.text.trim(),
      };

      try {
        await _docRef.set(data, SetOptions(merge: true));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text('তথ্য সফলভাবে আপডেট করা হয়েছে!'),
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
              content: const Text('সংরক্ষণ করতে সমস্যা হয়েছে!'),
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
    _designationController.dispose();
    _imageUrlController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _facebookLinkController.dispose();
    _websiteLinkController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = const Color(0xFF6C63FF);

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
                    top: -80, right: -60,
                    child: Container(
                      width: 250, height: 250,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor.withOpacity(0.12)),
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
                            'প্রোফাইল আপডেট',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'প্রোফাইল ইডিট করুন',
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
                        _buildCard(isDark, children: [
                          _buildField(controller: _nameController, label: 'নাম', hint: 'আপনার পুরো নাম', icon: Icons.person_rounded, accentColor: accentColor, isDark: isDark, validator: (v) => v!.isEmpty ? 'নাম লিখুন' : null),
                          _buildDivider(isDark),
                          _buildField(controller: _designationController, label: 'পদবি', hint: 'আপনার পদবি লিখুন', icon: Icons.work_rounded, accentColor: Colors.orange, isDark: isDark),
                          _buildDivider(isDark),
                          _buildField(controller: _imageUrlController, label: 'ছবির লিংক', hint: 'https://...', icon: Icons.image_rounded, accentColor: Colors.pink, isDark: isDark, validator: (v) => v!.isEmpty ? 'লিংক দিন' : null),
                          _buildDivider(isDark),
                          _buildField(controller: _aboutController, label: 'আপনার সম্বন্ধে', hint: 'কিছু লিখুন...', icon: Icons.info_outline_rounded, accentColor: Colors.brown, isDark: isDark, maxLines: 4),
                        ]),
                        
                        const SizedBox(height: 24),
                        _buildSectionLabel('যোগাযোগ ও লিঙ্ক'),
                        const SizedBox(height: 12),
                        _buildCard(isDark, children: [
                          _buildField(controller: _mobileController, label: 'মোবাইল নম্বর', hint: '০১৭...', icon: Icons.phone_rounded, accentColor: Colors.green, isDark: isDark, keyboardType: TextInputType.phone),
                          _buildDivider(isDark),
                          _buildField(controller: _emailController, label: 'ইমেইল', hint: 'example@email.com', icon: Icons.email_rounded, accentColor: Colors.redAccent, isDark: isDark, keyboardType: TextInputType.emailAddress),
                          _buildDivider(isDark),
                          _buildField(controller: _facebookLinkController, label: 'ফেসবুক লিংক', hint: 'https://facebook.com/...', icon: Icons.facebook_rounded, accentColor: Colors.blue, isDark: isDark, keyboardType: TextInputType.url),
                          _buildDivider(isDark),
                          _buildField(controller: _websiteLinkController, label: 'ওয়েবসাইট লিংক', hint: 'https://...', icon: Icons.language_rounded, accentColor: Colors.teal, isDark: isDark, keyboardType: TextInputType.url),
                        ]),

                        const SizedBox(height: 36),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: _isLoading 
                             ? Center(child: CircularProgressIndicator(color: accentColor))
                             : ElevatedButton(
                                 onPressed: _saveData,
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: accentColor,
                                   foregroundColor: Colors.white,
                                   elevation: 8,
                                   shadowColor: accentColor.withOpacity(0.4),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                 ),
                                 child: const Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                      Icon(Icons.save_rounded, size: 20),
                                      SizedBox(width: 10),
                                      Text('সেভ করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
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

  Widget _buildSectionLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 1.0));
  }

  Widget _buildCard(bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2533) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, indent: 56, endIndent: 0, color: isDark ? Colors.white10 : Colors.grey.shade100);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label, required String hint,
    required IconData icon, required Color accentColor,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
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
