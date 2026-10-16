/// The number guard. BUILD_PLAN.md Section 9.4, mandatory.
///
/// A small language model makes arithmetic errors. This guard is what makes
/// that survivable: after the model writes a sentence, every number in that
/// sentence is checked against the numbers the engine actually produced. Any
/// number that cannot be traced back to the input is grounds to discard the
/// whole output and fall back to a template.
///
/// This file has no dependency on any particular model runtime. It works on
/// plain strings, so it can be exercised with a fixture and needs no model
/// file to be downloaded to be tested.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

/// Why a piece of generated text was rejected, or that it passed.
enum GuardVerdict {
  /// Every number in the text was traceable to the input.
  accepted,

  /// At least one number could not be traced. The whole output must be
  /// discarded, not just the offending number.
  rejected,

  /// The text had no numbers to check. Treated as accepted: a sentence with
  /// no figures cannot misstate one.
  noNumbersFound,
}

/// The result of running the guard, kept together with which numbers failed
/// so a rejection can be logged, as BUILD_PLAN.md Section 9.4 asks for.
class GuardResult {
  const GuardResult({required this.verdict, required this.rejectedNumbers});

  final GuardVerdict verdict;

  /// The raw substrings that failed to match anything in the allowed set.
  /// Empty when the verdict is not [GuardVerdict.rejected].
  final List<String> rejectedNumbers;

  bool get isAccepted => verdict != GuardVerdict.rejected;
}

/// Matches a decimal number, optionally with thousands commas and a percent
/// or currency sign glued on either side. `1,234.56`, `PHP 20`, `38%`.
///
/// The comma-grouped branch requires at least one `,ddd` group. Without that
/// `+`, a plain four-digit number such as "2026" would match only its first
/// three digits ("202"), silently truncating the number and making a real
/// figure look invented.
final RegExp _numberPattern = RegExp(
  r'(?<![\w.])(\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+(?:\.\d+)?)%?',
);

/// Extracts every number written in [text], normalised to a plain string with
/// no commas, for comparison against the allowed set.
List<String> extractNumbers(String text) {
  return _numberPattern
      .allMatches(text)
      .map((RegExpMatch m) => m.group(1)!.replaceAll(',', ''))
      .toList(growable: false);
}

/// Builds the set of numbers the model is allowed to use.
///
/// Walks the engine's JSON output (BUILD_PLAN.md Section 8.8) and collects
/// every numeric leaf, in three forms: the raw centavo integer, the peso
/// value (divided by 100), and — for anything that looks like a probability
/// between 0 and 1 — the whole-percent form, since a model is expected to
/// say "38%" rather than "0.38".
Set<String> allowedNumbersFrom(Map<String, Object?> engineJson) {
  final Set<String> allowed = <String>{};

  void visit(Object? value) {
    switch (value) {
      case final int i:
        allowed.add(i.toString());
        allowed.add((i / 100).toStringAsFixed(2));
        // A whole-peso amount, e.g. 92000 centavos also reads as "920".
        if (i % 100 == 0) {
          allowed.add((i ~/ 100).toString());
        }
        // Money.format() writes the minus sign before the "PHP" prefix, not
        // glued to the digits: "-PHP 80.00", never "PHP -80.00". The digit
        // run the guard extracts from that text is therefore unsigned, so a
        // negative figure must also be allowed in its unsigned form.
        if (i < 0) {
          final int magnitude = i.abs();
          allowed.add(magnitude.toString());
          allowed.add((magnitude / 100).toStringAsFixed(2));
          if (magnitude % 100 == 0) {
            allowed.add((magnitude ~/ 100).toString());
          }
        }
      case final double d:
        allowed.add(d.toString());
        if (d >= 0 && d <= 1) {
          allowed.add((d * 100).round().toString());
          allowed.add((d * 100).toStringAsFixed(1));
        }
      case final String s:
        // A date such as "2026-09-04" contributes its day and month numbers;
        // harmless to allow, and prevents a false rejection of the date the
        // model is asked to restate.
        for (final String part in s.split(RegExp(r'[^0-9]+'))) {
          if (part.isNotEmpty) {
            allowed.add(part);
          }
        }
      case final Map<String, Object?> m:
        for (final Object? v in m.values) {
          visit(v);
        }
      case final List<Object?> l:
        for (final Object? v in l) {
          visit(v);
        }
      default:
        break;
    }
  }

  visit(engineJson);
  return allowed;
}

/// Checks generated text against the engine output it was given.
///
/// BUILD_PLAN.md Section 9.4, steps 1 to 4: extract every number, normalise
/// it, compare against the allowed set (including simple derived forms), and
/// reject the whole output if anything fails. Step 5, the template fallback,
/// is the caller's job — see `lib/ai/templates.dart`.
GuardResult checkNumberGuard({
  required String generatedText,
  required Map<String, Object?> engineJson,
}) {
  final List<String> found = extractNumbers(generatedText);
  if (found.isEmpty) {
    return const GuardResult(
      verdict: GuardVerdict.noNumbersFound,
      rejectedNumbers: <String>[],
    );
  }

  final Set<String> allowed = allowedNumbersFrom(engineJson);
  final List<String> rejected = found
      .where(
        (String n) =>
            !allowed.contains(n) && !allowed.contains(_trimTrailingZero(n)),
      )
      .toList(growable: false);

  if (rejected.isEmpty) {
    return const GuardResult(
      verdict: GuardVerdict.accepted,
      rejectedNumbers: <String>[],
    );
  }
  return GuardResult(verdict: GuardVerdict.rejected, rejectedNumbers: rejected);
}

/// "1234.50" and "1234.5" must be treated as the same number.
String _trimTrailingZero(String n) {
  if (!n.contains('.')) {
    return n;
  }
  String trimmed = n;
  while (trimmed.endsWith('0')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }
  if (trimmed.endsWith('.')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }
  return trimmed;
}
