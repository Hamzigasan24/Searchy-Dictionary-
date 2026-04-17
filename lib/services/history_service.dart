import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/search_history.dart';
import '../models/word_definition.dart';

class HistoryService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _historyRef(String uid) =>
      _db.collection('users').doc(uid).collection('history');

  // ── Save a search ───────────────────────────────────────────────────────────
  Future<void> saveSearch(
    User user,
    List<WordDefinition> definitions,
  ) async {
    if (definitions.isEmpty) return;
    final first = definitions.first;

    // Avoid saving duplicates in a row
    final recent = await _historyRef(user.uid)
        .orderBy('searchedAt', descending: true)
        .limit(1)
        .get();

    if (recent.docs.isNotEmpty) {
      final lastWord = recent.docs.first.data()['word'] as String? ?? '';
      if (lastWord.toLowerCase() == first.word.toLowerCase()) return;
    }

    await _historyRef(user.uid).add({
      'word': first.word,
      'partOfSpeech': first.partOfSpeech,
      'firstDefinition': first.definitions.isNotEmpty
          ? first.definitions.first
          : '',
      'searchedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Fetch history (most recent first) ──────────────────────────────────────
  Stream<List<SearchHistory>> historyStream(String uid) {
    return _historyRef(uid)
        .orderBy('searchedAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => SearchHistory.fromFirestore(d)).toList());
  }

  // ── Delete a single entry ───────────────────────────────────────────────────
  Future<void> deleteEntry(String uid, String docId) =>
      _historyRef(uid).doc(docId).delete();

  // ── Clear all history ───────────────────────────────────────────────────────
  Future<void> clearAll(String uid) async {
    final batch = _db.batch();
    final snap = await _historyRef(uid).get();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
