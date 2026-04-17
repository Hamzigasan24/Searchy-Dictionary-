/// Data model parsed from the Free Dictionary API
/// https://api.dictionaryapi.dev/api/v2/entries/en/{word}
/// No API key or server required.
class WordDefinition {
  final String word;
  final String partOfSpeech;
  final String pronunciation;
  final List<String> definitions;
  final List<String> examples;
  final List<String> synonyms;
  final String? etymology; // not provided by free API; kept for MW compat

  WordDefinition({
    required this.word,
    required this.partOfSpeech,
    required this.pronunciation,
    required this.definitions,
    this.examples = const [],
    this.synonyms = const [],
    this.etymology,
  });

  /// Parse ONE "meaning" block from the Free Dictionary API response entry.
  /// Each meaning = one part of speech (noun, verb, etc.).
  factory WordDefinition.fromMeaning({
    required String word,
    required String pronunciation,
    required Map<String, dynamic> meaning,
  }) {
    final partOfSpeech = meaning['partOfSpeech'] as String? ?? '';

    final rawDefs = meaning['definitions'] as List? ?? [];
    final definitions = <String>[];
    final examples    = <String>[];

    for (final d in rawDefs) {
      final def = d['definition'] as String?;
      if (def != null && def.isNotEmpty) definitions.add(def);

      final ex = d['example'] as String?;
      if (ex != null && ex.isNotEmpty) examples.add(ex);
    }

    // Synonyms from the meaning level
    final synRaw = meaning['synonyms'] as List? ?? [];
    final synonyms = List<String>.from(synRaw);

    return WordDefinition(
      word: word,
      partOfSpeech: partOfSpeech,
      pronunciation: pronunciation,
      definitions: definitions,
      examples: examples,
      synonyms: synonyms,
    );
  }

  /// Parses the full Free Dictionary API response (a JSON array of entries).
  /// Returns one [WordDefinition] per meaning block across all entries.
  static List<WordDefinition> fromApiResponse(List<dynamic> response) {
    final results = <WordDefinition>[];

    for (final entry in response) {
      if (entry is! Map<String, dynamic>) continue;

      final word = entry['word'] as String? ?? '';

      // Best phonetic: prefer one with a non-empty text field
      String pronunciation = entry['phonetic'] as String? ?? '';
      if (pronunciation.isEmpty) {
        final phonetics = entry['phonetics'] as List? ?? [];
        for (final p in phonetics) {
          final t = p['text'] as String? ?? '';
          if (t.isNotEmpty) { pronunciation = t; break; }
        }
      }

      final meanings = entry['meanings'] as List? ?? [];
      for (final meaning in meanings) {
        if (meaning is Map<String, dynamic>) {
          try {
            results.add(WordDefinition.fromMeaning(
              word: word,
              pronunciation: pronunciation,
              meaning: meaning,
            ));
          } catch (_) {
            // skip malformed meanings
          }
        }
      }
    }

    return results;
  }

  Map<String, dynamic> toMap() => {
    'word': word,
    'partOfSpeech': partOfSpeech,
    'pronunciation': pronunciation,
    'definitions': definitions,
    if (examples.isNotEmpty) 'examples': examples,
    if (synonyms.isNotEmpty) 'synonyms': synonyms,
  };
}
