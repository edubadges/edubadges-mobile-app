import 'package:equatable/equatable.dart';

class CatalogInstitution extends Equatable {
  final String entityId;
  final String? nameDutch;
  final String? nameEnglish;

  const CatalogInstitution({
    required this.entityId,
    this.nameDutch,
    this.nameEnglish,
  });

  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return false;

    final queryTerms = _normalizeString(query)
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList();

    if (queryTerms.isEmpty) return false;

    final normalizedDutch = nameDutch != null ? _normalizeString(nameDutch!) : '';
    final normalizedEnglish = nameEnglish != null ? _normalizeString(nameEnglish!) : '';
    final combinedNames = '$normalizedDutch $normalizedEnglish';

    return queryTerms.every((term) => combinedNames.contains(term));
  }

  String _normalizeString(String input) {
    var normalized = input.toLowerCase();

    const diacritics = {
      'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a', 'ā': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ė': 'e', 'ę': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'į': 'i',
      'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', 'ō': 'o', 'ø': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u',
      'ý': 'y', 'ÿ': 'y',
      'ñ': 'n', 'ç': 'c', 'ß': 'ss',
      'æ': 'ae', 'œ': 'oe',
    };

    diacritics.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });

    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    return normalized;
  }

  @override
  List<Object?> get props => [entityId, nameDutch, nameEnglish];
}
