// lib/models/item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String type;
  final String postedByUid;
  final String postedByName;
  final String contact;
  // FIX: imageBase64 instead of imageUrl — stored directly in Firestore, no Storage needed
  final String? imageBase64;
  final DateTime date;
  final bool isResolved;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.type,
    required this.postedByUid,
    required this.postedByName,
    required this.contact,
    this.imageBase64,
    required this.date,
    this.isResolved = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'type': type,
        'postedByUid': postedByUid,
        'postedByName': postedByName,
        'contact': contact,
        'imageBase64': imageBase64,
        'date': Timestamp.fromDate(date),
        'isResolved': isResolved,
      };

  factory ItemModel.fromMap(Map<String, dynamic> m, String docId) => ItemModel(
        id: docId,
        title: m['title'] ?? '',
        description: m['description'] ?? '',
        category: m['category'] ?? '',
        location: m['location'] ?? '',
        type: m['type'] ?? 'lost',
        postedByUid: m['postedByUid'] ?? '',
        postedByName: m['postedByName'] ?? '',
        contact: m['contact'] ?? '',
        imageBase64: m['imageBase64'],
        date: m['date'] is Timestamp
            ? (m['date'] as Timestamp).toDate()
            : DateTime.tryParse(m['date']?.toString() ?? '') ?? DateTime.now(),
        isResolved: m['isResolved'] ?? false,
      );

  ItemModel copyWith({bool? isResolved}) => ItemModel(
        id: id,
        title: title,
        description: description,
        category: category,
        location: location,
        type: type,
        postedByUid: postedByUid,
        postedByName: postedByName,
        contact: contact,
        imageBase64: imageBase64,
        date: date,
        isResolved: isResolved ?? this.isResolved,
      );
}
