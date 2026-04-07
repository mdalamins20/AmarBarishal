import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;
  const AddEditCategoryScreen({super.key, this.documentId, this.initialData});
  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _icon, _color;
  late int _order;

  @override
  void initState() {
    super.initState();
    _name = widget.initialData?['name'] ?? '';
    _icon = widget.initialData?['icon'] ?? 'apps';
    _color = widget.initialData?['color'] ?? '#000000';
    _order = widget.initialData?['order'] ?? 0;
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final data = {'name': _name, 'icon': _icon, 'color': _color, 'order': _order};
    if (widget.documentId == null) {
      FirebaseFirestore.instance.collection('categories').add(data);
    } else {
      FirebaseFirestore.instance.collection('categories').doc(widget.documentId).update(data);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentId == null ? 'নতুন ক্যাটাগরি' : 'ক্যাটাগরি এডিট'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(initialValue: _name, decoration: const InputDecoration(labelText: 'ক্যাটাগরির নাম'), validator: (v) => v!.isEmpty ? 'নাম দিন' : null, onSaved: (v) => _name = v!),
              TextFormField(initialValue: _icon, decoration: const InputDecoration(labelText: 'আইকনের নাম (e.g., school)'), validator: (v) => v!.isEmpty ? 'আইকনের নাম দিন' : null, onSaved: (v) => _icon = v!),
              TextFormField(initialValue: _color, decoration: const InputDecoration(labelText: 'রঙের হেক্স কোড (e.g., #4CAF50)'), validator: (v) => v!.isEmpty ? 'রঙের কোড দিন' : null, onSaved: (v) => _color = v!),
              TextFormField(initialValue: _order.toString(), decoration: const InputDecoration(labelText: 'সাজানোর নম্বর (e.g., 1, 2)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'নম্বর দিন' : null, onSaved: (v) => _order = int.parse(v!)),
            ],
          ),
        ),
      ),
    );
  }
}