/// Tier 1, the rule layer. BUILD_PLAN.md Section 9.2.
///
/// A keyword table catches the obvious cases before any model runs. The plan
/// is explicit that a rule-only version must ship if the model is not ready:
/// the app must never block on a model.
///
/// Pure Dart. No Flutter, no plugins, no I/O. The asset is loaded by the
/// caller and handed in as a string.
library;

import 'dart:convert';

/// What the categorizer thinks a transaction is.
class CategorySuggestion {
  const CategorySuggestion({
    required this.categoryKey,
    required this.confidence,
    this.matchedKeyword,
  });

  final String categoryKey;

  /// Zero to one. A rule match is 1.0, because the rule layer is exact.
  final double confidence;

  /// The keyword that fired, kept so the UI can explain the guess.
  final String? matchedKeyword;

  /// BUILD_PLAN.md Section 9.2: apply automatically only above 0.85.
  /// Anything less must be shown to the user as a question.
  bool get canAutoApply => confidence > 0.85;

  @override
  String toString() =>
      'CategorySuggestion($categoryKey, $confidence, $matchedKeyword)';
}

/// One category and the merchant words that imply it.
class CategoryRule {
  const CategoryRule({required this.categoryKey, required this.keywords});

  final String categoryKey;
  final List<String> keywords;
}

/// Matches merchant text against a keyword table.
class RuleCategorizer {
  RuleCategorizer(List<CategoryRule> rules) : _entries = _flatten(rules);

  /// Builds a categorizer from `assets/categorizer_rules.json`.
  factory RuleCategorizer.fromJson(String raw) {
    final Map<String, dynamic> decoded =
        jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> rules = decoded['rules'] as List<dynamic>;
    return RuleCategorizer(
      rules
          .map((dynamic entry) {
            final Map<String, dynamic> row = entry as Map<String, dynamic>;
            return CategoryRule(
              categoryKey: row['category_key'] as String,
              keywords: (row['keywords'] as List<dynamic>)
                  .map((dynamic k) => k as String)
                  .toList(growable: false),
            );
          })
          .toList(growable: false),
    );
  }

  /// Keyword and category pairs, longest keyword first.
  ///
  /// Order matters. "GRABFOOD" must beat "GRAB", or every food delivery would
  /// be filed as transport.
  final List<({String keyword, String categoryKey})> _entries;

  static List<({String keyword, String categoryKey})> _flatten(
    List<CategoryRule> rules,
  ) {
    final List<({String keyword, String categoryKey})> out =
        <({String keyword, String categoryKey})>[];
    for (final CategoryRule rule in rules) {
      for (final String keyword in rule.keywords) {
        out.add((keyword: _normalise(keyword), categoryKey: rule.categoryKey));
      }
    }
    out.sort(
      (
        ({String keyword, String categoryKey}) a,
        ({String keyword, String categoryKey}) b,
      ) => b.keyword.length.compareTo(a.keyword.length),
    );
    return List<({String keyword, String categoryKey})>.unmodifiable(out);
  }

  /// Guesses the category for a piece of merchant text.
  ///
  /// Returns null when nothing matches, which means the app must ask the user
  /// rather than guess. A wrong silent guess is worse than a question.
  CategorySuggestion? suggest(String? merchantRaw) {
    if (merchantRaw == null) {
      return null;
    }
    final String text = _normalise(merchantRaw);
    if (text.isEmpty) {
      return null;
    }
    for (final ({String keyword, String categoryKey}) entry in _entries) {
      if (entry.keyword.isEmpty) {
        continue;
      }
      if (text.contains(entry.keyword)) {
        return CategorySuggestion(
          categoryKey: entry.categoryKey,
          confidence: 1,
          matchedKeyword: entry.keyword,
        );
      }
    }
    return null;
  }

  /// How many keywords are loaded. Used by tests and the settings screen.
  int get keywordCount => _entries.length;

  /// Strips case and punctuation so "7-Eleven" and "7 ELEVEN" both match.
  static String _normalise(String value) {
    final StringBuffer out = StringBuffer();
    bool lastWasSpace = false;
    for (final int unit in value.toUpperCase().codeUnits) {
      final bool isDigit = unit >= 0x30 && unit <= 0x39;
      final bool isLetter = unit >= 0x41 && unit <= 0x5A;
      if (isDigit || isLetter) {
        out.writeCharCode(unit);
        lastWasSpace = false;
      } else if (!lastWasSpace) {
        out.write(' ');
        lastWasSpace = true;
      }
    }
    return out.toString().trim();
  }
}
