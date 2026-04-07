import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditNewsLinkScreen extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;
  const AddEditNewsLinkScreen({super.key, this.documentId, this.initialData});
  @override
  State<AddEditNewsLinkScreen> createState() => _AddEditNewsLinkScreenState();
}
class _AddEditNewsLinkScreenState extends State<AddEditNewsLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title, _url;
  late int _order;

  @override
  void initState() {
    super.initState();
    _title = widget.initialData?['title'] ?? '';
    _url = widget.initialData?['url'] ?? '';
    _order = widget.initialData?['order'] ?? 0;
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final data = {'title': _title, 'url': _url, 'order': _order};
    if (widget.documentId == null) {
      FirebaseFirestore.instance.collection('news_links').add(data);
    } else {
      FirebaseFirestore.instance.collection('news_links').doc(widget.documentId).update(data);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentId == null ? 'নতুন লিংক যোগ' : 'লিংক এডিট'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(initialValue: _title, decoration: const InputDecoration(labelText: 'শিরোনাম'), validator: (v) => v!.isEmpty ? 'শিরোনাম দিন' : null, onSaved: (v) => _title = v!),
              TextFormField(initialValue: _url, decoration: const InputDecoration(labelText: 'URL/লিংক'), keyboardType: TextInputType.url, validator: (v) => v!.isEmpty ? 'লিংক দিন' : null, onSaved: (v) => _url = v!),
              TextFormField(initialValue: _order.toString(), decoration: const InputDecoration(labelText: 'সাজানোর নম্বর'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'নম্বর দিন' : null, onSaved: (v) => _order = int.parse(v!)),
            ],
          ),
        ),
      ),
    );
  }
}