// lib/providers/items_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';

class ItemsProvider with ChangeNotifier {
  final _svc = FirestoreService();

  List<ItemModel> _all      = [];
  List<ItemModel> _filtered = [];
  String _search     = '';
  String _typeFilter = 'all';
  bool   _loading    = true;
  StreamSubscription? _sub;

  List<ItemModel> get items      => _filtered;
  String          get typeFilter => _typeFilter;
  bool            get isLoading  => _loading;

  void startListening() {
    _sub?.cancel();
    _loading = true;
    notifyListeners();

    _sub = _svc.itemsStream().listen((list) {
      _all     = list;
      _loading = false;
      _apply();
      notifyListeners();
    });
  }

  void stopListening() {
    _sub?.cancel();
    _all = _filtered = [];
    _loading = true;
    notifyListeners();
  }

  void search(String q)       { _search = q;       _apply(); notifyListeners(); }
  void setFilter(String type) { _typeFilter = type; _apply(); notifyListeners(); }

  void _apply() {
    _filtered = _all.where((item) {
      final typeOk   = _typeFilter == 'all' || item.type == _typeFilter;
      final searchOk = _search.isEmpty ||
          item.title.toLowerCase().contains(_search.toLowerCase()) ||
          item.location.toLowerCase().contains(_search.toLowerCase()) ||
          item.description.toLowerCase().contains(_search.toLowerCase());
      return typeOk && searchOk;
    }).toList();
  }

  Future<void> resolve(String id) => _svc.resolve(id);

  // No Storage cleanup needed — image lives inside the Firestore doc itself
  Future<void> delete(String id) => _svc.delete(id);

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}
