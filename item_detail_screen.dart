// lib/screens/item_detail_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/items_provider.dart';
import '../utils/constants.dart';

class ItemDetailScreen extends StatelessWidget {
  final ItemModel item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final me      = context.read<AuthProvider>().user;
    final isOwner = me?.uid == item.postedByUid;
    final isLost  = item.type == 'lost';
    final color   = isLost ? kLost : kFound;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kPrimary, foregroundColor: Colors.white,
        title: Text(isLost ? 'Lost Item' : 'Found Item'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Image (decoded from Base64) ──
          if (item.imageBase64 != null)
            Builder(builder: (_) {
              try {
                final bytes = base64Decode(item.imageBase64!);
                return Image.memory(bytes,
                  width: double.infinity, height: 230, fit: BoxFit.cover);
              } catch (_) {
                return _noImage();
              }
            })
          else _noImage(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Title + badge
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(item.title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                    color: item.isResolved ? kResolved : Colors.black87,
                    decoration: item.isResolved ? TextDecoration.lineThrough : null))),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(isLost ? 'LOST' : 'FOUND',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                ),
              ]),
              const SizedBox(height: 10),

              // Resolved banner
              if (item.isResolved)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: kResolved.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kResolved)),
                  child: const Row(children: [
                    Icon(Icons.check_circle, size: 18, color: kResolved),
                    SizedBox(width: 8),
                    Text('This item has been resolved',
                      style: TextStyle(color: kResolved, fontWeight: FontWeight.w500)),
                  ]),
                ),

              const Divider(height: 24),

              _row(Icons.category_outlined,      'Category', item.category),
              _row(Icons.location_on_outlined,    'Location', item.location),
              _row(Icons.calendar_today_outlined, 'Date',     _fmt(item.date)),
              _row(Icons.person_outline,          'Posted by',item.postedByName),
              _row(Icons.contact_phone_outlined,  'Contact',  item.contact, highlight: true),

              const Divider(height: 24),

              const Text('Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(item.description,
                style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.6)),

              const SizedBox(height: 28),

              if (isOwner && !item.isResolved)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _resolve(context),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark as Resolved',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kFound,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _noImage() => Container(
    width: double.infinity, height: 160,
    color: Colors.grey.shade100,
    child: Icon(Icons.image_outlined, size: 64, color: Colors.grey.shade300));

  Widget _row(IconData icon, String label, String value, {bool highlight = false}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: kAccent),
        const SizedBox(width: 10),
        SizedBox(width: 80,
          child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.black45))),
        Expanded(child: Text(value, style: TextStyle(
          fontSize: 14,
          fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          color: highlight ? kPrimary : Colors.black87))),
      ]),
    );

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }

  Future<void> _resolve(BuildContext context) async {
    final ok = await showDialog<bool>(context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark as Resolved'),
        content: const Text('Has this item been returned? Mark it as resolved?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kFound),
            child: const Text('Yes, Resolved', style: TextStyle(color: Colors.white))),
        ],
      ));
    if (ok != true || !context.mounted) return;
    try {
      await context.read<ItemsProvider>().resolve(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Marked as resolved!'), backgroundColor: kFound));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('This will permanently delete your post. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ));
    if (ok != true || !context.mounted) return;
    try {
      await context.read<ItemsProvider>().delete(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
