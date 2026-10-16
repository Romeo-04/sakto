import 'package:baon/ai/explainer/number_guard.dart';
import 'package:flutter_test/flutter_test.dart';

/// A representative engine output, shaped like BUILD_PLAN.md Section 8.8.
final Map<String, Object?> sampleJson = <String, Object?>{
  'as_of': '2026-09-04',
  'currency': 'PHP',
  'account_total': 684000,
  'unallocated': 0,
  'envelopes': <Object?>[
    <String, Object?>{
      'id': 'env_food',
      'label': 'Food and transport',
      'shape': 'steady',
      'balance': 92000,
      'refill_cents': 200000,
      'days_left': 3,
      'committed': 45000,
      'committed_note': 'commute, 3 weekdays at PHP 150',
      'daily_burn_ewma': 21000,
      'daily_burn_median': 19000,
      'safe_daily': 15600,
      'runway_days': 4.4,
      'p_shortfall_own': 0.22,
      'p_shortfall_with_spill': 0.38,
      'end_balance_p10': -8000,
      'end_balance_p50': 14000,
      'end_balance_p90': 33000,
    },
    <String, Object?>{
      'id': 'env_dates',
      'label': 'Dates',
      'shape': 'episodic',
      'balance': 120000,
      'refill_cents': 300000,
      'days_left': 12,
      'event_rate_per_week': 1.8,
      'event_size_median': 90000,
      'events_affordable': 1,
      'p_shortfall_own': 0.47,
      'borrow_target': 'env_food',
      'expected_spill': 26000,
    },
  ],
  'stale_accounts': <Object?>[],
  'data_quality': 'good',
};

void main() {
  group('extractNumbers', () {
    test('reads plain integers and decimals', () {
      expect(extractNumbers('You have 920 pesos, or 920.00 exactly.'), <String>[
        '920',
        '920.00',
      ]);
    });

    test('strips thousands commas', () {
      expect(extractNumbers('That is 1,234.56 pesos.'), <String>['1234.56']);
    });

    test('reads a percent as its bare number', () {
      expect(extractNumbers('Risk is 38% today.'), <String>['38']);
    });

    test('finds nothing in a sentence with no numbers', () {
      expect(extractNumbers('Everything looks fine.'), isEmpty);
    });
  });

  group('allowedNumbersFrom', () {
    test('allows the raw centavo figure', () {
      expect(allowedNumbersFrom(sampleJson), contains('92000'));
    });

    test('allows the peso form of a centavo figure', () {
      expect(allowedNumbersFrom(sampleJson), contains('920.00'));
    });

    test('allows the whole-peso short form when it divides evenly', () {
      expect(allowedNumbersFrom(sampleJson), contains('920'));
    });

    test('allows a probability as a whole percent', () {
      final Set<String> allowed = allowedNumbersFrom(sampleJson);
      expect(allowed, contains('22'));
      expect(allowed, contains('38'));
      expect(allowed, contains('47'));
    });

    test('allows the date components', () {
      final Set<String> allowed = allowedNumbersFrom(sampleJson);
      expect(allowed, contains('2026'));
      expect(allowed, contains('09'));
      expect(allowed, contains('04'));
    });
  });

  group('checkNumberGuard', () {
    test('accepts a sentence built entirely from the input numbers', () {
      final GuardResult r = checkNumberGuard(
        generatedText:
            'You have PHP 920.00 for 3 days. Chance of running short: 22%.',
        engineJson: sampleJson,
      );
      expect(r.verdict, GuardVerdict.accepted);
      expect(r.isAccepted, isTrue);
    });

    test('accepts a sentence with no numbers at all', () {
      final GuardResult r = checkNumberGuard(
        generatedText: 'Your spending looks steady this week.',
        engineJson: sampleJson,
      );
      expect(r.verdict, GuardVerdict.noNumbersFound);
      expect(r.isAccepted, isTrue);
    });

    test('rejects a sentence with an invented number', () {
      final GuardResult r = checkNumberGuard(
        generatedText:
            'You have PHP 5,000.00 left, which is completely made up.',
        engineJson: sampleJson,
      );
      expect(r.verdict, GuardVerdict.rejected);
      expect(r.isAccepted, isFalse);
      expect(r.rejectedNumbers, contains('5000.00'));
    });

    test('rejects the whole output even when only one number is wrong', () {
      final GuardResult r = checkNumberGuard(
        generatedText:
            'You have PHP 920.00 for 3 days, but somehow also 999 pesos more.',
        engineJson: sampleJson,
      );
      expect(r.verdict, GuardVerdict.rejected);
    });

    test('accepts a slightly reformatted but still traceable number', () {
      final GuardResult r = checkNumberGuard(
        generatedText: 'Around 47% risk of running out of dates money.',
        engineJson: sampleJson,
      );
      expect(r.verdict, GuardVerdict.accepted);
    });

    test('a trailing-zero difference does not cause a false rejection', () {
      final GuardResult r = checkNumberGuard(
        generatedText: 'The runway is about 4.4 days, or 4.40 by one measure.',
        engineJson: sampleJson,
      );
      expect(r.verdict, GuardVerdict.accepted);
    });
  });

  group('M9 acceptance: rejection rate under 2% on 200 fixtures', () {
    test('sentences built only from allowed numbers are accepted', () {
      final Set<String> allowed = allowedNumbersFrom(
        sampleJson,
      ).toList().toSet();
      final List<String> allowedList = allowed.toList();
      int rejections = 0;
      const int fixtureCount = 200;

      for (int i = 0; i < fixtureCount; i++) {
        // Build a deterministic pseudo-random sentence from two allowed
        // numbers, mimicking a well-behaved model that only ever restates
        // figures it was given.
        final String a = allowedList[i % allowedList.length];
        final String b = allowedList[(i * 7 + 3) % allowedList.length];
        final String sentence =
            'You have $a for the period. Related figure: $b.';

        final GuardResult r = checkNumberGuard(
          generatedText: sentence,
          engineJson: sampleJson,
        );
        if (!r.isAccepted) {
          rejections++;
        }
      }

      final double rate = rejections / fixtureCount;
      expect(
        rate,
        lessThan(0.02),
        reason:
            'BUILD_PLAN.md Section 9.4/M9: rejection rate must be under 2% '
            'when the generated text only restates numbers it was given. '
            'Measured $rejections / $fixtureCount = $rate.',
      );
    });

    test(
      'a model that fabricates one figure per sentence is caught every time',
      () {
        int rejections = 0;
        const int fixtureCount = 200;
        for (int i = 0; i < fixtureCount; i++) {
          final String sentence =
              'You have PHP ${7777 + i}.00 completely invented.';
          final GuardResult r = checkNumberGuard(
            generatedText: sentence,
            engineJson: sampleJson,
          );
          if (!r.isAccepted) {
            rejections++;
          }
        }
        expect(
          rejections,
          fixtureCount,
          reason: 'a fabricated figure must never slip through',
        );
      },
    );
  });
}
