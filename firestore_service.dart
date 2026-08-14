// lib/services/firestore_service.dart
// No Firebase Storage needed — images stored as Base64 inside Firestore documents.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('items');

  Future<void> addItem(ItemModel item) async {
    await _col.doc(item.id).set(item.toMap());
  }

  Stream<List<ItemModel>> itemsStream() {
    return _col
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ItemModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> resolve(String id) async {
    await _col.doc(id).update({'isResolved': true});
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
