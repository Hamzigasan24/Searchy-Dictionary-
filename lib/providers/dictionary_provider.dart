import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/word_definition.dart';
import '../services/dictionary_service.dart';
import '../services/history_service.dart';

enum SearchStatus { idle, loading, success, error }

class DictionaryProvider extends ChangeNotifier {
  final DictionaryService _dictService = DictionaryService();
  final HistoryService _historyService = HistoryService();

  SearchStatus _status = SearchStatus.idle;
  List<WordDefinition> _results = [];
  String? _errorMessage;
  String _lastQuery = '';

  SearchStatus get status => _status;
  List<WordDefinition> get results => _results;
  String? get errorMessage => _errorMessage;
  String get lastQuery => _lastQuery;

  Future<void> search(String word, User? user) async {
    final trimmed = word.trim();
    if (trimmed.isEmpty) return;

    _status = SearchStatus.loading;
    _errorMessage = null;
    _lastQuery = trimmed;
    notifyListeners();

    try {
      _results = await _dictService.search(trimmed);
      _status = SearchStatus.success;
      notifyListeners();

      // Save to history if user is logged in
      if (user != null) {
        await _historyService.saveSearch(user, _results);
      }
    } catch (e) {
      _results = [];
      _status = SearchStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void reset() {
    _status = SearchStatus.idle;
    _results = [];
    _errorMessage = null;
    _lastQuery = '';
    notifyListeners();
  }
}
