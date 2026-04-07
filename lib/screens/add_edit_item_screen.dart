import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  // 'বিবরণ' এর পরিবর্তে 'ম্যাপ লিংক' এবং 'প্রধান শিক্ষক' এর জন্য নতুন কন্ট্রোলার
  final _mapLinkController = TextEditingController();
  final _headmasterController = TextEditingController();

  bool _isLoading = false;

  bool get _isEditing => widget.itemDocId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.initialData?['name'] ?? '';
      _addressController.text = widget.initialData?['address'] ?? '';
      _phoneController.text = widget.initialData?['phone'] ?? '';
      // নতুন ফিল্ডগুলোর জন্য ডেটা লোড করা হচ্ছে
      _mapLinkController.text = widget.initialData?['mapLink'] ?? '';
      _headmasterController.text = widget.initialData?['headmaster'] ?? '';
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // ডেটা ম্যাপ আপডেট করা হয়েছে
      final data = {
        'name': _nameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'mapLink': _mapLinkController.text, // 'description' এর পরিবর্তে 'mapLink'
      };

      // শুধুমাত্র schoolCollege ক্যাটাগরির জন্য headmaster ফিল্ড যোগ হবে
      if (widget.categoryDocId == 'schoolCollege') {
        data['headmaster'] = _headmasterController.text;
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
        } else {
          await itemsCollection.add(data);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text('তথ্য সফলভাবে ${_isEditing ? 'আপডেট' : 'যোগ'} করা হয়েছে')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        // ... error handling
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
    _addressController.dispose();
    _phoneController.dispose();
    // নতুন কন্ট্রোলারগুলো dispose করা হচ্ছে
    _mapLinkController.dispose();
    _headmasterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'তথ্য ইডিট করুন' : 'নতুন তথ্য যোগ করুন'),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'অনুগ্রহ করে নাম লিখুন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'ঠিকানা'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'অনুগ্রহ করে ঠিকানা লিখুন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'ফোন নম্বর'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // শুধুমাত্র schoolCollege ক্যাটাগরিতে 'প্রধান শিক্ষক' 필্ড দেখানো হবে
              if (widget.categoryDocId == 'schoolCollege') ...[
                TextFormField(
                  controller: _headmasterController,
                  decoration: const InputDecoration(labelText: 'প্রধান শিক্ষকের নাম'),
                ),
                const SizedBox(height: 16),
              ],

              // 'বিবরণ' ফিল্ডের পরিবর্তে 'গুগল ম্যাপ লিংক' 필্ড
              TextFormField(
                controller: _mapLinkController,
                decoration: const InputDecoration(labelText: 'গুগল ম্যাপ লিংক'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveItem,
                child: Text(_isEditing ? 'আপডেট করুন' : 'সেভ করুন'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}