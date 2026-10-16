import 'dart:math' as math;

import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/burn_rate.dart';
import 'package:baon/engine/envelope.dart';
import 'package:flutter_test/flutter_test.dart';

/// 2026-09-04 is a Friday. Every date in this file is anchored to it.
final DateTime asOf = DateTime(2026, 9, 4);

EngineTxn out(int daysAgo, int cents, {String category = 'food_daily'}) =>
    EngineTxn(
      amount: Money(cents),
      direction: TxnDirection.moneyOut,
      categoryKey: category,
      occurredAt: DateTime(2026, 9, 4 - daysAgo, 12),
    );

EngineTxn income(int daysAgo, int cents) => EngineTxn(
  amount: Money(cents),
  direction: TxnDirection.moneyIn,
  categoryKey: 'income',
  occurredAt: DateTime(2026, 9, 4 - daysAgo, 12),
);

void main() {
  group('dailyOutflows', () {
    test('counts days with no spending as zero', () {
      final List<DailyOutflow> days = dailyOutflows(
        txns: <EngineTxn>[out(0, 10000)],
        asOf: asOf,
        categoryKeys: const <String>{'food_daily'},
        excludedCategories: const <String>{},
        lookbackDays: 7,
      );
      expect(days.length, 7);
      expect(days.last.amount, const Money(10000));
      expect(
        days.take(6).every((DailyOutflow d) => d.amount.isZero),
        isTrue,
        reason: 'dropping empty days would divide by the spending days only',
      );
    });

    test('ignores income', () {
      final List<DailyOutflow> days = dailyOutflows(
        txns: <EngineTxn>[income(1, 500000), out(1, 10000)],
        asOf: asOf,
        categoryKeys: const <String>{},
        excludedCategories: const <String>{},
        lookbackDays: 7,
      );
      expect(
        Money.sum(days.map((DailyOutflow d) => d.amount)),
        const Money(10000),
      );
    });

    test('excludes transfers and savings, which are not spending', () {
      final List<DailyOutflow> days = dailyOutflows(
        txns: <EngineTxn>[
          out(1, 100000, category: 'transfer_internal'),
          out(1, 100000, category: 'savings_in'),
          out(1, 15000),
        ],
        asOf: asOf,
        categoryKeys: const <String>{},
        excludedCategories: const <String>{'transfer_internal', 'savings_in'},
        lookbackDays: 7,
      );
      expect(
        Money.sum(days.map((DailyOutflow d) => d.amount)),
        const Money(15000),
        reason: 'BUILD_PLAN.md Section 8.4: a transfer is not a spend',
      );
    });

    test('keeps only the categories the envelope pays for', () {
      final List<DailyOutflow> days = dailyOutflows(
        txns: <EngineTxn>[
          out(1, 15000),
          out(1, 90000, category: 'dates_leisure'),
        ],
        asOf: asOf,
        categoryKeys: const <String>{'food_daily', 'transport'},
        excludedCategories: const <String>{},
        lookbackDays: 7,
      );
      expect(
        Money.sum(days.map((DailyOutflow d) => d.amount)),
        const Money(15000),
      );
    });

    test('drops a transaction older than the window', () {
      final List<DailyOutflow> days = dailyOutflows(
        txns: <EngineTxn>[out(40, 500000), out(1, 15000)],
        asOf: asOf,
        categoryKeys: const <String>{},
        excludedCategories: const <String>{},
      );
      expect(days.length, defaultLookbackDays);
      expect(
        Money.sum(days.map((DailyOutflow d) => d.amount)),
        const Money(15000),
      );
    });

    test('shortens the window to the history that exists', () {
      final List<DailyOutflow> days = dailyOutflows(
        txns: <EngineTxn>[out(2, 30000)],
        asOf: asOf,
        categoryKeys: const <String>{},
        excludedCategories: const <String>{},
        historyStartedOn: DateTime(2026, 9, 1),
      );
      expect(days.length, 4, reason: '1 to 4 September inclusive');
      expect(days.first.date, DateTime(2026, 9));
    });
  });

  group('estimateSteadyBurn', () {
    test('mean divides by the whole window, not the spending days', () {
      // PHP 700 across 7 days, spent on one day only.
      final SteadyBurn burn = estimateSteadyBurn(
        txns: <EngineTxn>[out(3, 70000)],
        asOf: asOf,
        categoryKeys: const <String>{},
        lookbackDays: 7,
      );
      expect(burn.mean, const Money(10000));
      expect(burn.observedDays, 7);
    });

    test('a flat spender has mean, median and EWMA in agreement', () {
      final SteadyBurn burn = estimateSteadyBurn(
        txns: List<EngineTxn>.generate(14, (int i) => out(i, 20000)),
        asOf: asOf,
        categoryKeys: const <String>{},
        lookbackDays: 14,
      );
      expect(burn.mean, const Money(20000));
      expect(burn.median, const Money(20000));
      expect(burn.ewma, const Money(20000));
    });

    test('EWMA leans toward recent days', () {
      // Old days at PHP 100, the last three at PHP 400.
      final List<EngineTxn> txns = <EngineTxn>[
        for (int i = 3; i < 14; i++) out(i, 10000),
        for (int i = 0; i < 3; i++) out(i, 40000),
      ];
      final SteadyBurn burn = estimateSteadyBurn(
        txns: txns,
        asOf: asOf,
        categoryKeys: const <String>{},
        lookbackDays: 14,
      );
      expect(
        burn.ewma > burn.mean,
        isTrue,
        reason: 'recent spending rose, so the smoothed rate must lead the mean',
      );
      expect(burn.ewma.centavos, greaterThan(25000));
    });

    test('median ignores one unusual day', () {
      final List<EngineTxn> txns = <EngineTxn>[
        for (int i = 1; i < 14; i++) out(i, 10000),
        out(0, 500000),
      ];
      final SteadyBurn burn = estimateSteadyBurn(
        txns: txns,
        asOf: asOf,
        categoryKeys: const <String>{},
        lookbackDays: 14,
      );
      expect(burn.median, const Money(10000));
      expect(burn.mean.centavos, greaterThan(burn.median.centavos));
    });

    test('groups daily totals by weekday', () {
      // Weekdays cost PHP 250, weekends PHP 50, across four weeks.
      final List<EngineTxn> txns = <EngineTxn>[];
      for (int i = 0; i < 28; i++) {
        final DateTime day = DateTime(2026, 9, 4 - i);
        final bool weekday = day.weekday <= DateTime.friday;
        txns.add(out(i, weekday ? 25000 : 5000));
      }
      final SteadyBurn burn = estimateSteadyBurn(
        txns: txns,
        asOf: asOf,
        categoryKeys: const <String>{},
      );

      expect(
        burn.dayOfWeekPool[DateTime.monday]!.every(
          (Money m) => m == const Money(25000),
        ),
        isTrue,
      );
      expect(
        burn.dayOfWeekPool[DateTime.sunday]!.every(
          (Money m) => m == const Money(5000),
        ),
        isTrue,
      );
      expect(
        burn.poolFor(DateTime.monday).first,
        const Money(25000),
        reason: 'a flat average would hide the weekday gap',
      );
    });

    test('falls back to the global pool when a weekday is too thin', () {
      final SteadyBurn burn = estimateSteadyBurn(
        txns: <EngineTxn>[out(0, 20000), out(1, 20000)],
        asOf: asOf,
        categoryKeys: const <String>{},
        lookbackDays: 7,
      );
      // Seven days gives exactly one observation per weekday.
      expect(burn.dayOfWeekPool[DateTime.friday]!.length, 1);
      expect(
        burn.poolFor(DateTime.friday).length,
        7,
        reason: 'fewer than three observations is too thin to trust',
      );
    });

    test('no history gives an empty estimate rather than a crash', () {
      final SteadyBurn burn = estimateSteadyBurn(
        txns: const <EngineTxn>[],
        asOf: asOf,
        categoryKeys: const <String>{},
        historyStartedOn: DateTime(2026, 9, 5),
      );
      expect(burn.hasHistory, isFalse);
      expect(burn.mean, Money.zero);
      expect(burn.ewma, Money.zero);
    });

    test('one day of history still produces a usable estimate', () {
      final SteadyBurn burn = estimateSteadyBurn(
        txns: <EngineTxn>[out(0, 35000)],
        asOf: asOf,
        categoryKeys: const <String>{},
        historyStartedOn: asOf,
      );
      expect(burn.observedDays, 1);
      expect(burn.mean, const Money(35000));
      expect(
        burn.ewma,
        const Money(35000),
        reason: 'the single day seeds the smoothed series',
      );
    });
  });

  group('estimateEpisodicBurn', () {
    test('counts events and their sizes, not a daily average', () {
      // Four dates in 28 days: 1200, 800, 950, 1100 pesos.
      final EpisodicBurn burn = estimateEpisodicBurn(
        txns: <EngineTxn>[
          out(2, 120000, category: 'dates_leisure'),
          out(9, 80000, category: 'dates_leisure'),
          out(16, 95000, category: 'dates_leisure'),
          out(23, 110000, category: 'dates_leisure'),
        ],
        asOf: asOf,
        categoryKeys: const <String>{'dates_leisure'},
      );
      expect(burn.eventCount, 4);
      expect(burn.eventsPerWeek, closeTo(1.0, 0.001));
      expect(burn.medianSize, const Money(102500));
      expect(burn.largestSize, const Money(120000));
    });

    test('M3b fixture: eight lumpy events give the right rate and sizes', () {
      final List<int> amounts = <int>[
        90000,
        120000,
        75000,
        150000,
        95000,
        60000,
        110000,
        85000,
      ];
      final List<EngineTxn> txns = <EngineTxn>[
        for (int i = 0; i < amounts.length; i++)
          out(i * 3, amounts[i], category: 'dates_leisure'),
      ];

      final EpisodicBurn burn = estimateEpisodicBurn(
        txns: txns,
        asOf: asOf,
        categoryKeys: const <String>{'dates_leisure'},
      );

      expect(burn.eventCount, 8);
      expect(burn.observedDays, 28);
      expect(burn.eventsPerWeek, closeTo(2.0, 0.001));
      expect(burn.medianSize, const Money(92500));
      expect(burn.meanSize, const Money(98125));
      expect(
        Money.sum(burn.eventSizes),
        const Money(785000),
        reason: 'no event may be lost or double counted',
      );
    });

    test('two taps on one night are one date', () {
      final EpisodicBurn burn = estimateEpisodicBurn(
        txns: <EngineTxn>[
          out(2, 60000, category: 'dates_leisure'),
          out(2, 40000, category: 'dates_leisure'),
        ],
        asOf: asOf,
        categoryKeys: const <String>{'dates_leisure'},
      );
      expect(burn.eventCount, 1);
      expect(burn.eventSizes.single, const Money(100000));
    });

    test('no events gives a zero rate, not a divide by zero', () {
      final EpisodicBurn burn = estimateEpisodicBurn(
        txns: const <EngineTxn>[],
        asOf: asOf,
        categoryKeys: const <String>{'dates_leisure'},
      );
      expect(burn.hasHistory, isFalse);
      expect(burn.eventsPerWeek, 0);
      expect(burn.medianSize, Money.zero);
      expect(burn.meanSize, Money.zero);
    });

    test('a daily average would be misleading here', () {
      // PHP 2,000 spread over two dates in 28 days.
      final EpisodicBurn burn = estimateEpisodicBurn(
        txns: <EngineTxn>[
          out(5, 100000, category: 'dates_leisure'),
          out(20, 100000, category: 'dates_leisure'),
        ],
        asOf: asOf,
        categoryKeys: const <String>{'dates_leisure'},
      );
      expect(burn.medianSize, const Money(100000));
      expect(burn.eventsPerWeek, closeTo(0.5, 0.001));
      // The naive daily figure would be 200000/28 = 7142 centavos a day, a
      // number that is true on no day at all.
      expect(burn.medianSize.centavos, greaterThan(7142));
    });
  });

  group('percentile', () {
    test('reads the ends and the middle', () {
      final List<Money> values = <Money>[
        const Money(100),
        const Money(200),
        const Money(300),
        const Money(400),
        const Money(500),
      ];
      expect(percentile(values, 0), const Money(100));
      expect(percentile(values, 50), const Money(300));
      expect(percentile(values, 100), const Money(500));
    });

    test('interpolates between two values', () {
      expect(
        percentile(<Money>[const Money(0), const Money(1000)], 10),
        const Money(100),
      );
    });

    test('handles an empty and a single-value list', () {
      expect(percentile(const <Money>[], 50), Money.zero);
      expect(percentile(<Money>[const Money(42)], 90), const Money(42));
    });

    test('does not care about input order', () {
      expect(
        percentile(<Money>[const Money(500), const Money(100)], 0),
        const Money(100),
      );
    });
  });

  group('poissonSample', () {
    test('a zero or negative rate never fires', () {
      final math.Random random = math.Random(1);
      expect(poissonSample(random, 0), 0);
      expect(poissonSample(random, -1), 0);
    });

    test('the long-run mean matches the rate', () {
      final math.Random random = math.Random(42);
      const double lambda = 0.4;
      int total = 0;
      for (int i = 0; i < 20000; i++) {
        total += poissonSample(random, lambda);
      }
      expect(total / 20000, closeTo(lambda, 0.03));
    });

    test('a corrupt rate returns quickly instead of hanging', () {
      expect(poissonSample(math.Random(1), 1000), 1000);
    });

    test('the same seed gives the same draw', () {
      expect(
        List<int>.generate(20, (int i) => poissonSample(math.Random(7), 1.5)),
        List<int>.generate(20, (int i) => poissonSample(math.Random(7), 1.5)),
      );
    });
  });
}
