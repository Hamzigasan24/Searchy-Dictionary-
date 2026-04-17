import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_definition.dart';

class DictionaryService {
  // Free Dictionary API — no key, no server needed.
  static const _base = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  Future<List<WordDefinition>> search(String word) async {
    final encoded = Uri.encodeComponent(word.trim().toLowerCase());
    final uri     = Uri.parse('$_base/$encoded');

    http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw Exception('No internet connection. Please check your network.');
    }

    // 404 = word not found
    if (response.statusCode == 404) {
      // The API returns {"title":"No Definitions Found",...}
      throw Exception('No definitions found for "$word". Check the spelling.');
    }

    if (response.statusCode != 200) {
      throw Exception(
          'Dictionary service error (${response.statusCode}). Try again.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List || decoded.isEmpty) {
      throw Exception('No results found for "$word".');
    }

    final results = WordDefinition.fromApiResponse(decoded);
    if (results.isEmpty) {
      throw Exception('No definitions found for "$word".');
    }
    return results;
  }
}
