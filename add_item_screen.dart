// lib/screens/add_item_screen.dart
// Images stored as Base64 in Firestore — no Firebase Storage needed.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/item_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _form     = GlobalKey<FormState>();
  final _titleC   = TextEditingController();
  final _descC    = TextEditingController();
  final _contactC = TextEditingController();

  String     _type     = 'lost';
  String     _category = kCategories[0];
  String     _location = kLocations[0];
  Uint8List? _imageBytes;
  bool       _saving   = false;

  @override
  void dispose() {
    _titleC.dispose(); _descC.dispose(); _contactC.dispose(); super.dispose();
  }

  Future<void> _pickImage(ImageSource src) async {
    final picked = await ImagePicker().pickImage(
      source: src,
      maxWidth: 600,      // keep file size small — must fit in Firestore doc (<1MB)
      maxHeight: 600,
      imageQuality: 60,   // compress aggressively for Base64 storage
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      // Safety check: warn if image is too large for Firestore (1MB doc limit)
      if (bytes.length > 700000) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Image too large. Please pick a smaller photo.'),
            backgroundColor: Colors.orange,
          ));
        }
        return;
      }
      setState(() => _imageBytes = bytes);
    }
  }

  void _showImageSheet() {
    showModalBottomSheet(context: context, builder: (_) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.camera_alt),
          title: const Text('Take Photo'),
          onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
        ListTile(leading: const Icon(Icons.photo_library),
          title: const Text('Choose from Gallery'),
          onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
      ]),
    ));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final user = context.read<AuthProvider>().user!;
      final id   = const Uuid().v4();

      // Convert image bytes to Base64 string — stored directly in Firestore
      String? imageBase64;
      if (_imageBytes != null) {
        imageBase64 = base64Encode(_imageBytes!);
      }

      final item = ItemModel(
        id:           id,
        title:        _titleC.text.trim(),
        description:  _descC.text.trim(),
        category:     _category,
        location:     _location,
        type:         _type,
        postedByUid:  user.uid,
        postedByName: user.name,
        contact:      _contactC.text.trim(),
        imageBase64:  imageBase64,
        date:         DateTime.now(),
      );

      await FirestoreService().addItem(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Posted successfully!'), backgroundColor: kFound));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Post an Item'),
        backgroundColor: kPrimary, foregroundColor: Colors.white),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ── Lost / Found toggle ──
            Row(children: [
              _typeBtn('Lost',  'lost',  kLost),
              const SizedBox(width: 12),
              _typeBtn('Found', 'found', kFound),
            ]),
            const SizedBox(height: 20),

            // ── Image picker ──
            GestureDetector(
              onTap: _showImageSheet,
              child: Container(
                height: 160, width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300)),
                child: _imageBytes != null
                  ? Stack(fit: StackFit.expand, children: [
                      ClipRRect(borderRadius: BorderRadius.circular(10),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover)),
                      Positioned(top: 6, right: 6,
                        child: GestureDetector(
                          onTap: () => setState(() => _imageBytes = null),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                              color: Colors.white, size: 20)))),
                    ])
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_a_photo_outlined,
                        size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('Tap to add photo (optional)',
                        style: TextStyle(color: Colors.grey.shade500)),
                      const SizedBox(height: 4),
                      Text('Keep photos small for best results',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                    ]),
              ),
            ),
            const SizedBox(height: 16),

            // ── Title ──
            _textField(_titleC, 'Item Title', Icons.label_outline,
              (v) => V.required(v, 'Title')),
            const SizedBox(height: 14),

            // ── Category ──
            _dropdown('Category', Icons.category_outlined, kCategories,
              _category, (v) => setState(() => _category = v!)),
            const SizedBox(height: 14),

            // ── Location ──
            _dropdown('Location', Icons.location_on_outlined, kLocations,
              _location, (v) => setState(() => _location = v!)),
            const SizedBox(height: 14),

            // ── Description ──
            TextFormField(
              controller: _descC, maxLines: 4,
              validator: (v) => V.required(v, 'Description'),
              textCapitalization: TextCapitalization.sentences,
              decoration: _dec('Description', Icons.description_outlined)
                .copyWith(alignLabelWithHint: true),
            ),
            const SizedBox(height: 14),

            // ── Contact ──
            _textField(_contactC, 'Your Contact (phone / email)',
              Icons.contact_phone_outlined,
              (v) => V.required(v, 'Contact info')),
            const SizedBox(height: 30),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
                child: _saving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                  : const Text('Post Item',
                      style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _typeBtn(String label, String val, Color color) {
    final sel = _type == val;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _type = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: sel ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? color : Colors.grey.shade300,
            width: sel ? 2 : 1)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(val == 'lost' ? Icons.search_off : Icons.check_circle_outline,
            color: sel ? Colors.white : Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(
            color: sel ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600, fontSize: 15)),
        ]),
      )));
  }

  Widget _textField(TextEditingController c, String label, IconData icon,
      String? Function(String?) val) =>
    TextFormField(controller: c, validator: val,
      textCapitalization: TextCapitalization.sentences,
      decoration: _dec(label, icon));

  Widget _dropdown(String label, IconData icon, List<String> items,
      String value, void Function(String?) onChanged) =>
    DropdownButtonFormField<String>(
      value: value, onChanged: onChanged, decoration: _dec(label, icon),
      items: items.map((e) =>
        DropdownMenuItem(value: e, child: Text(e))).toList());

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon),
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kAccent, width: 2)));
}
