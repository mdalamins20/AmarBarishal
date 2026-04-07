import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAboutMeScreen extends StatefulWidget {
  const EditAboutMeScreen({super.key});

  @override
  State<EditAboutMeScreen> createState() => _EditAboutMeScreenState();
}

class _EditAboutMeScreenState extends State<EditAboutMeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController(); // নতুন কন্ট্রোলার
  final _imageUrlController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _facebookLinkController = TextEditingController();
  final _websiteLinkController = TextEditingController();
  final _aboutController = TextEditingController();
  bool _isLoading = false;

  final DocumentReference _docRef =
  FirebaseFirestore.instance.collection('about_me').doc('developer_info');

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _isLoading = true;
      });

      final data = {
        'name': _nameController.text,
        'designation': _designationController.text, // নতুন ডেটা
        'imageUrl': _imageUrlController.text,
        'mobile': _mobileController.text,
        'email': _emailController.text,
        'facebookLink': _facebookLinkController.text,
        'websiteLink': _websiteLinkController.text,
        'about': _aboutController.text,
      };

      try {
        await _docRef.set(data, SetOptions(merge: true));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('তথ্য সফলভাবে আপডেট করা হয়েছে')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('একটি সমস্যা হয়েছে: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রোফাইল ইডিট করুন'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'নাম'),
                validator: (value) =>
                value!.isEmpty ? 'অনুগ্রহ করে নাম লিখুন' : null,
              ),
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(labelText: 'পদবি'),
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'ছবির লিংক'),
                validator: (value) =>
                value!.isEmpty ? 'অনুগ্রহ করে ছবির লিংক দিন' : null,
              ),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'মোবাইল নম্বর'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'ইমেল'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _facebookLinkController,
                decoration: const InputDecoration(labelText: 'ফেসবুক লিংক'),
                keyboardType: TextInputType.url,
              ),
              TextFormField(
                controller: _websiteLinkController,
                decoration: const InputDecoration(labelText: 'ওয়েবসাইট লিংক'),
                keyboardType: TextInputType.url,
              ),
              TextFormField(
                controller: _aboutController,
                decoration: const InputDecoration(labelText: 'আপনার সম্বন্ধে'),
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveData,
                child: const Text('সেভ করুন'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

