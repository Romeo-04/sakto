import 'dart:convert';
import 'dart:io';

import 'package:baon/ai/categorizer/rule_categorizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final RuleCategorizer categorizer = RuleCategorizer(<CategoryRule>[
    const CategoryRule(
      categoryKey: 'transport',
      keywords: <String>['GRAB', 'JEEP'],
    ),
    const CategoryRule(
      categoryKey: 'food_delivery',
      keywords: <String>['GRABFOOD'],
    ),
    const CategoryRule(
      categoryKey: 'groceries',
      keywords: <String>['7-ELEVEN'],
    ),
  ]);

  group('suggest', () {
    test('matches an exact keyword', () {
      final CategorySuggestion? s = categorizer.suggest('GRAB *TRANSPORT');
      expect(s!.categoryKey, 'transport');
      expect(s.confidence, 1.0);
      expect(s.canAutoApply, isTrue);
    });

    test('is case and punctuation insensitive', () {
      expect(categorizer.suggest('grab*transport')!.categoryKey, 'transport');
      expect(
        categorizer.suggest('7-Eleven Store #123')!.categoryKey,
        'groceries',
      );
      expect(categorizer.suggest('7 ELEVEN')!.categoryKey, 'groceries');
    });

    test('prefers the longer, more specific keyword', () {
      final CategorySuggestion? s = categorizer.suggest('GRABFOOD DELIVERY');
      expect(
        s!.categoryKey,
        'food_delivery',
        reason: 'GRABFOOD must not be swallowed by the shorter GRAB rule',
      );
    });

    test('returns null rather than guess when nothing matches', () {
      expect(categorizer.suggest('SOME RANDOM MERCHANT'), isNull);
      expect(categorizer.suggest(null), isNull);
      expect(categorizer.suggest(''), isNull);
      expect(categorizer.suggest('   '), isNull);
    });

    test('a null suggestion means the app must ask, not guess', () {
      final CategorySuggestion? s = categorizer.suggest('UNKNOWN SHOP');
      expect(s, isNull);
    });
  });

  group('the real asset file', () {
    late RuleCategorizer real;

    setUpAll(() {
      final String raw = File(
        'assets/categorizer_rules.json',
      ).readAsStringSync();
      real = RuleCategorizer.fromJson(raw);
    });

    test('loads and parses without error', () {
      expect(real.keywordCount, greaterThan(50));
    });

    test('catches the examples named in BUILD_PLAN.md Section 9.2', () {
      expect(real.suggest('GRABPAY *RIDE')!.categoryKey, 'transport');
      expect(real.suggest('JEEPNEY FARE')!.categoryKey, 'transport');
      expect(real.suggest('7-ELEVEN STORE 4521')!.categoryKey, 'groceries');
    });

    test('every rule in the asset round-trips through JSON', () {
      final String raw = File(
        'assets/categorizer_rules.json',
      ).readAsStringSync();
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      expect(decoded['rules'], isNotEmpty);
    });

    test('routes common everyday merchants correctly', () {
      expect(real.suggest('JOLLIBEE SM NORTH')!.categoryKey, 'food_daily');
      expect(real.suggest('GLOBE TELECOM LOAD')!.categoryKey, 'load_data');
      expect(real.suggest('NETFLIX.COM')!.categoryKey, 'dates_leisure');
      expect(real.suggest('SHOPEE PH')!.categoryKey, 'shopping');
      expect(real.suggest('MERCURY DRUG STORE')!.categoryKey, 'health');
      expect(real.suggest('INSTAPAY TRANSFER FEE')!.categoryKey, 'fees');
    });
  });
}
