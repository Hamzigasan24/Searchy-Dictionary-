import 'package:cloud_firestore/cloud_firestore.dart';

class SearchHistory {
  final String id;
  final String word;
  final String partOfSpeech;
  final String firstDefinition;
  final DateTime searchedAt;

  SearchHistory({
    required this.id,
    required this.word,
    required this.partOfSpeech,
    required this.firstDefinition,
    required this.searchedAt,
  });

  factory SearchHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SearchHistory(
      id: doc.id,
      word: data['word'] as String? ?? '',
      partOfSpeech: data['partOfSpeech'] as String? ?? '',
      firstDefinition: data['firstDefinition'] as String? ?? '',
      searchedAt: (data['searchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'word': word,
    'partOfSpeech': partOfSpeech,
    'firstDefinition': firstDefinition,
    'searchedAt': Timestamp.fromDate(searchedAt),
  };
}
