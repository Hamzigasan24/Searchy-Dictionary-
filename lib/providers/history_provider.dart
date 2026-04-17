import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart' show firebaseReady;
import '../models/search_history.dart';
import '../services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _service = HistoryService();

  List<SearchHistory> _history = [];
  bool _loading = false;
  String? _errorMessage;
  StreamSubscription<List<SearchHistory>>? _sub;

  List<SearchHistory> get history => _history;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  void startListening(String uid) {
    if (!firebaseReady) {
      _loading = false;
      notifyListeners();
      return;
    }
    _sub?.cancel();
    _loading = true;
    notifyListeners();

    _sub = _service.historyStream(uid).listen(
      (items) {
        _history = items;
        _loading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        _errorMessage = 'Failed to load history.';
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _sub?.cancel();
    _history = [];
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteEntry(String uid, String docId) async {
    await _service.deleteEntry(uid, docId);
  }

  Future<void> clearAll(String uid) async {
    await _service.clearAll(uid);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
