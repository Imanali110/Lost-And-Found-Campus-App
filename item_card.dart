// lib/widgets/item_card.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../utils/constants.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLost = item.type == 'lost';
    final color  = isLost ? kLost : kFound;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Image or icon placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageBase64 != null
                ? Image.memory(
                    base64Decode(item.imageBase64!),
                    width: 72, height: 72, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _iconBox(),
                  )
                : _iconBox(),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(item.title,
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: item.isResolved ? kResolved : Colors.black87,
                    decoration: item.isResolved ? TextDecoration.lineThrough : null),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(isLost ? 'LOST' : 'FOUND',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                ),
              ]),
              const SizedBox(height: 4),
              Text(item.description,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on, size: 13, color: Colors.blueGrey),
                const SizedBox(width: 3),
                Expanded(child: Text(item.location,
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  overflow: TextOverflow.ellipsis)),
                Text(_ago(item.date),
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
              ]),
              if (item.isResolved)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: kResolved.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text('✓ Resolved',
                    style: TextStyle(fontSize: 11, color: kResolved)),
                ),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _iconBox() => Container(
    width: 72, height: 72, color: Colors.grey.shade100,
    child: Icon(_catIcon(), size: 30, color: Colors.grey.shade400));

  IconData _catIcon() {
    switch (item.category) {
      case 'Electronics':            return Icons.devices;
      case 'Books & Stationery':     return Icons.menu_book;
      case 'Clothing & Accessories': return Icons.checkroom;
      case 'ID & Documents':         return Icons.badge;
      case 'Keys':                   return Icons.key;
      case 'Bags & Wallets':         return Icons.backpack;
      case 'Water Bottle':           return Icons.water_drop;
      case 'Sports Equipment':       return Icons.sports_soccer;
      default:                       return Icons.help_outline;
    }
  }

  String _ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }
}
