import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/burn_rate.dart';
import 'package:baon/engine/envelope.dart';
import 'package:baon/engine/forecast.dart';
import 'package:flutter_test/flutter_test.dart';

/// 2026-09-04 is a Friday.
final DateTime asOf = DateTime(2026, 9, 4);

EngineEnvelope steadyEnvelope({
  Money balance = const Money(92000),
  Money floor = defaultSteadyFloor,
  CommuteCost commute = CommuteCost.none,
}) => EngineEnvelope(
  id: 'env_food',
  label: 'Food and transport',
  shape: EnvelopeShape.steady,
  balance: balance,
  refill: const Money(200000),
  refillCadence: Cadence.weekly,
  categoryKeys: const <String>['transport', 'food_daily'],
  safetyFloor: floor,
  commute: commute,
);

EngineEnvelope datesEnvelope({Money balance = const Money(120000)}) =>
    EngineEnvelope(
      id: 'env_dates',
      label: 'Dates',
      shape: EnvelopeShape.episodic,
      balance: balance,
      refill: const Money(300000),
      refillCadence: Cadence.monthly,
      categoryKeys: const <String>['dates_leisure'],
      allowBorrowFrom: const <String>['env_food'],
    );

void main() {
  group('resolveHorizonEnd', () {
    test('prefers the envelope refill date', () {
      expect(
        resolveHorizonEnd(
          asOf: asOf,
          incomes: const <EngineIncome>[],
          envelopeRefillOn: DateTime(2026, 9, 7),
        ),
        DateTime(2026, 9, 7),
      );
    });

    test('falls to the earliest expected income', () {
      final DateTime end = resolveHorizonEnd(
        asOf: asOf,
        incomes: <EngineIncome>[
          EngineIncome(
            label: 'Allowance',
            amount: const Money(200000),
            cadence: Cadence.weekly,
            nextExpectedOn: DateTime(2026, 9, 15),
            confidence: IncomeConfidence.certain,
          ),
          EngineIncome(
            label: 'Stipend',
            amount: const Money(500000),
            cadence: Cadence.monthly,
            nextExpectedOn: DateTime(2026, 9, 9),
            confidence: IncomeConfidence.likely,
          ),
        ],
      );
      expect(end, DateTime(2026, 9, 9));
    });

    test('ignores an income date that has already passed', () {
      final DateTime end = resolveHorizonEnd(
        asOf: asOf,
        incomes: <EngineIncome>[
          EngineIncome(
            label: 'Old',
            amount: const Money(200000),
            cadence: Cadence.weekly,
            nextExpectedOn: DateTime(2026, 9),
            confidence: IncomeConfidence.certain,
          ),
        ],
      );
      expect(end, DateTime(2026, 9, 18), reason: 'the 14 day default');
    });

    test('uses the user date when there is no income', () {
      expect(
        resolveHorizonEnd(
          asOf: asOf,
          incomes: const <EngineIncome>[],
          userChosen: DateTime(2026, 9, 10),
        ),
        DateTime(2026, 9, 10),
      );
    });

    test('defaults to fourteen days out', () {
      expect(
        resolveHorizonEnd(asOf: asOf, incomes: const <EngineIncome>[]),
        DateTime(2026, 9, 18),
      );
    });
  });

  group('obligation due dates', () {
    test('a one-off falls only inside the window', () {
      final EngineObligation o = EngineObligation(
        label: 'Rent share',
        amount: const Money(300000),
        cadence: Cadence.once,
        nextDueOn: DateTime(2026, 9, 10),
        categoryKey: 'other',
      );
      expect(o.dueDatesBetween(asOf, DateTime(2026, 9, 18)).length, 1);
      expect(o.dueDatesBetween(asOf, DateTime(2026, 9, 8)), isEmpty);
    });

    test('a weekly obligation repeats inside a fortnight', () {
      final EngineObligation o = EngineObligation(
        label: 'Load',
        amount: const Money(5000),
        cadence: Cadence.weekly,
        nextDueOn: DateTime(2026, 9, 6),
        categoryKey: 'load_data',
      );
      expect(o.dueDatesBetween(asOf, DateTime(2026, 9, 18)), <DateTime>[
        DateTime(2026, 9, 6),
        DateTime(2026, 9, 13),
      ]);
    });

    test('a monthly obligation lands once', () {
      final EngineObligation o = EngineObligation(
        label: 'Netflix',
        amount: const Money(14900),
        cadence: Cadence.monthly,
        nextDueOn: DateTime(2026, 9, 12),
        categoryKey: 'dates_leisure',
      );
      expect(o.dueDatesBetween(asOf, DateTime(2026, 10, 20)).length, 2);
    });

    test('a past weekly obligation rolls forward instead of piling up', () {
      final EngineObligation o = EngineObligation(
        label: 'Load',
        amount: const Money(5000),
        cadence: Cadence.weekly,
        nextDueOn: DateTime(2026, 1),
        categoryKey: 'load_data',
      );
      expect(o.dueDatesBetween(asOf, DateTime(2026, 9, 11)).length, 1);
    });

    test('a cadence of none never falls due', () {
      final EngineObligation o = EngineObligation(
        label: 'Nothing',
        amount: const Money(5000),
        cadence: Cadence.none,
        nextDueOn: DateTime(2026, 9, 6),
        categoryKey: 'other',
      );
      expect(o.dueDatesBetween(asOf, DateTime(2026, 12)), isEmpty);
    });
  });

  group('committedFor', () {
    test('reserves the weekday commute and explains it', () {
      // Saturday 5 to Monday 7 September holds one weekday.
      final CommittedCosts c = committedFor(
        envelope: steadyEnvelope(
          commute: const CommuteCost(perWeekday: Money(15000)),
        ),
        obligations: const <EngineObligation>[],
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 7),
      );
      expect(c.commuteWeekdays, 1);
      expect(c.commute, const Money(15000));
      expect(c.note, 'commute, 1 weekday at 150.00');
    });

    test('reserves three weekdays across a working week', () {
      final CommittedCosts c = committedFor(
        envelope: steadyEnvelope(
          commute: const CommuteCost(perWeekday: Money(15000)),
        ),
        obligations: const <EngineObligation>[],
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 9),
      );
      expect(c.commuteWeekdays, 3, reason: 'Mon 7, Tue 8, Wed 9');
      expect(c.commute, const Money(45000));
      expect(c.note, 'commute, 3 weekdays at 150.00');
    });

    test('adds obligations that route to this envelope only', () {
      final CommittedCosts c = committedFor(
        envelope: steadyEnvelope(),
        obligations: <EngineObligation>[
          EngineObligation(
            label: 'Load',
            amount: const Money(5000),
            cadence: Cadence.weekly,
            nextDueOn: DateTime(2026, 9, 6),
            categoryKey: 'food_daily',
          ),
          EngineObligation(
            label: 'Netflix',
            amount: const Money(14900),
            cadence: Cadence.monthly,
            nextDueOn: DateTime(2026, 9, 8),
            categoryKey: 'dates_leisure',
          ),
        ],
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 11),
      );
      expect(c.obligations, const Money(5000));
      expect(c.note, 'Load');
      expect(c.total, const Money(5000));
    });

    test('counts a repeating obligation once per occurrence', () {
      final CommittedCosts c = committedFor(
        envelope: steadyEnvelope(),
        obligations: <EngineObligation>[
          EngineObligation(
            label: 'Load',
            amount: const Money(5000),
            cadence: Cadence.weekly,
            nextDueOn: DateTime(2026, 9, 6),
            categoryKey: 'food_daily',
          ),
        ],
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 18),
      );
      expect(c.obligations, const Money(10000));
      expect(c.note, 'Load x2');
    });

    test('nothing committed reads as zero with no note', () {
      final CommittedCosts c = committedFor(
        envelope: steadyEnvelope(),
        obligations: const <EngineObligation>[],
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 11),
      );
      expect(c.total, Money.zero);
      expect(c.note, isEmpty);
    });
  });

  group('computeRunway, steady', () {
    SteadyBurn burnAt(int cents) => SteadyBurn(
      mean: Money(cents),
      ewma: Money(cents),
      median: Money(cents),
      dayOfWeekPool: const <int, List<Money>>{},
      globalPool: <Money>[Money(cents)],
      observedDays: 28,
      dailyTotals: const <DailyOutflow>[],
    );

    test('usable money removes the committed costs and the floor', () {
      final DeterministicRunway r = computeRunway(
        envelope: steadyEnvelope(balance: const Money(92000)),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 7),
        committed: const CommittedCosts(
          obligations: Money.zero,
          commute: Money(45000),
          commuteWeekdays: 3,
          note: 'commute',
        ),
        steady: burnAt(21000),
      );
      expect(r.usable, const Money(27000), reason: '92000 - 45000 - 20000');
      expect(r.daysLeft, 3);
    });

    test('safe daily divides the usable money over the days left', () {
      final DeterministicRunway r = computeRunway(
        envelope: steadyEnvelope(
          balance: const Money(92000),
          floor: Money.zero,
        ),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 8),
        committed: CommittedCosts.none,
        steady: burnAt(21000),
      );
      expect(r.daysLeft, 4);
      expect(r.safeDaily, const Money(23000));
    });

    test('runway days divides the usable money by the burn rate', () {
      final DeterministicRunway r = computeRunway(
        envelope: steadyEnvelope(
          balance: const Money(112000),
          floor: Money.zero,
        ),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 8),
        committed: CommittedCosts.none,
        steady: burnAt(20000),
      );
      expect(r.runwayDays, closeTo(5.6, 0.001));
      expect(r.runsShort, isFalse, reason: '5.6 days covers 4 days left');
    });

    test('flags an envelope that runs short before the horizon', () {
      final DeterministicRunway r = computeRunway(
        envelope: steadyEnvelope(
          balance: const Money(60000),
          floor: Money.zero,
        ),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 11),
        committed: CommittedCosts.none,
        steady: burnAt(20000),
      );
      expect(r.runwayDays, closeTo(3.0, 0.001));
      expect(r.daysLeft, 7);
      expect(r.runsShort, isTrue);
    });

    test('a zero burn rate does not divide by zero', () {
      final DeterministicRunway r = computeRunway(
        envelope: steadyEnvelope(
          balance: const Money(50000),
          floor: Money.zero,
        ),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 11),
        committed: CommittedCosts.none,
        steady: SteadyBurn.empty,
      );
      expect(
        r.runwayDays,
        50000.0,
        reason: 'the burn rate floors at 1 centavo',
      );
      expect(r.runwayDays.isFinite, isTrue);
    });

    test(
      'negative usable money gives no runway and no negative safe daily',
      () {
        final DeterministicRunway r = computeRunway(
          envelope: steadyEnvelope(balance: const Money(10000)),
          asOf: asOf,
          horizonEnd: DateTime(2026, 9, 11),
          committed: const CommittedCosts(
            obligations: Money(50000),
            commute: Money.zero,
            commuteWeekdays: 0,
            note: 'Rent',
          ),
          steady: burnAt(20000),
        );
        expect(r.usable.isNegative, isTrue);
        expect(r.runwayDays, 0);
        expect(
          r.safeDaily,
          Money.zero,
          reason: 'never suggest a negative budget',
        );
        expect(r.runsShort, isTrue);
      },
    );

    test('a horizon of today does not divide by zero days', () {
      final DeterministicRunway r = computeRunway(
        envelope: steadyEnvelope(
          balance: const Money(50000),
          floor: Money.zero,
        ),
        asOf: asOf,
        horizonEnd: asOf,
        committed: CommittedCosts.none,
        steady: burnAt(20000),
      );
      expect(r.daysLeft, 0);
      expect(r.safeDaily, const Money(50000));
    });
  });

  group('computeRunway, episodic', () {
    EpisodicBurn burn({int size = 90000, double rate = 1.8}) => EpisodicBurn(
      eventsPerWeek: rate,
      eventSizes: <Money>[Money(size)],
      observedDays: 28,
    );

    test('reports events left, not days left', () {
      final DeterministicRunway r = computeRunway(
        envelope: datesEnvelope(balance: const Money(120000)),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 16),
        committed: CommittedCosts.none,
        episodic: burn(),
      );
      expect(
        r.eventsAffordable,
        1,
        reason: 'PHP 1,200 buys one more PHP 900 date',
      );
      expect(r.eventSizeMedian, const Money(90000));
      expect(r.eventRatePerWeek, 1.8);
      expect(r.runwayDays, 0, reason: 'a daily rate is meaningless here');
    });

    test('runs short when not even one event fits', () {
      final DeterministicRunway r = computeRunway(
        envelope: datesEnvelope(balance: const Money(50000)),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 16),
        committed: CommittedCosts.none,
        episodic: burn(),
      );
      expect(r.eventsAffordable, 0);
      expect(r.runsShort, isTrue);
    });

    test('no event history means no event estimate', () {
      final DeterministicRunway r = computeRunway(
        envelope: datesEnvelope(balance: const Money(120000)),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 16),
        committed: CommittedCosts.none,
        episodic: EpisodicBurn.empty,
      );
      expect(r.eventsAffordable, 0);
      expect(r.eventSizeMedian, Money.zero);
    });
  });

  group('computeRunway, reserve', () {
    test('a savings envelope reports a balance and nothing else', () {
      final DeterministicRunway r = computeRunway(
        envelope: const EngineEnvelope(
          id: 'env_savings',
          label: 'Savings',
          shape: EnvelopeShape.reserve,
          balance: Money(472000),
          refill: Money.zero,
          refillCadence: Cadence.none,
          categoryKeys: <String>[],
        ),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 18),
        committed: CommittedCosts.none,
      );
      expect(r.balance, const Money(472000));
      expect(r.usable, const Money(472000));
      expect(r.runwayDays, 0);
      expect(r.safeDaily, Money.zero);
      expect(
        r.eventsAffordable,
        0,
        reason:
            'BUILD_PLAN.md Section 8.4: never include a reserve in a runway',
      );
    });
  });

  group('M3 golden scenarios', () {
    SteadyBurn burnAt(int cents) => SteadyBurn(
      mean: Money(cents),
      ewma: Money(cents),
      median: Money(cents),
      dayOfWeekPool: const <int, List<Money>>{},
      globalPool: <Money>[Money(cents)],
      observedDays: 28,
      dailyTotals: const <DailyOutflow>[],
    );

    test('1: the plan worked example reproduces exactly', () {
      // BUILD_PLAN.md Section 8.8 sample: PHP 920 left, 3 days left, PHP 450
      // committed as "commute, 3 weekdays at PHP 150", PHP 210 a day burn.
      //
      // The sample only holds when all three remaining days are working days,
      // so this scenario is anchored to Monday 7 September with the horizon on
      // Thursday 10 September. Anchored to a Friday the same inputs would
      // commit one weekday, not three.
      final DateTime monday = DateTime(2026, 9, 7);
      final DateTime thursday = DateTime(2026, 9, 10);
      const CommuteCost commute = CommuteCost(perWeekday: Money(15000));

      final CommittedCosts committed = committedFor(
        envelope: steadyEnvelope(commute: commute),
        obligations: const <EngineObligation>[],
        asOf: monday,
        horizonEnd: thursday,
      );
      final DeterministicRunway r = computeRunway(
        envelope: steadyEnvelope(balance: const Money(92000), commute: commute),
        asOf: monday,
        horizonEnd: thursday,
        committed: committed,
        steady: burnAt(21000),
      );

      expect(r.balance, const Money(92000));
      expect(r.daysLeft, 3);
      expect(r.dailyBurnEwma, const Money(21000));
      expect(committed.commuteWeekdays, 3);
      expect(committed.total, const Money(45000));
      expect(committed.note, 'commute, 3 weekdays at 150.00');

      // Section 8.5 defines usable as balance less committed less the safety
      // floor, so PHP 920 - PHP 450 - PHP 200 = PHP 270, and PHP 90 a day.
      // The sample JSON in Section 8.8 shows 15600, which is the same figure
      // with the floor left in. The formula in 8.5 is the normative one and is
      // what this engine follows.
      expect(r.usable, const Money(27000));
      expect(r.safeDaily, const Money(9000));
    });

    test('2: zero history leaves the balance intact and the rate at zero', () {
      final DeterministicRunway r = computeRunway(
        envelope: steadyEnvelope(balance: const Money(200000)),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 11),
        committed: CommittedCosts.none,
        steady: SteadyBurn.empty,
      );
      expect(r.dailyBurnEwma, Money.zero);
      expect(r.usable, const Money(180000));
      expect(r.safeDaily, const Money(180000 ~/ 7));
    });

    test('3: a negative balance never yields a positive runway', () {
      final DeterministicRunway r = computeRunway(
        envelope: steadyEnvelope(balance: const Money(-5000)),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 11),
        committed: CommittedCosts.none,
        steady: burnAt(20000),
      );
      expect(r.usable, const Money(-25000));
      expect(r.runwayDays, 0);
      expect(r.safeDaily, Money.zero);
      expect(r.runsShort, isTrue);
    });

    test('4: a large one-off obligation eats the whole envelope', () {
      final CommittedCosts committed = committedFor(
        envelope: steadyEnvelope(),
        obligations: <EngineObligation>[
          EngineObligation(
            label: 'Rent share',
            amount: const Money(300000),
            cadence: Cadence.once,
            nextDueOn: DateTime(2026, 9, 8),
            categoryKey: 'food_daily',
          ),
        ],
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 11),
      );
      final DeterministicRunway r = computeRunway(
        envelope: steadyEnvelope(balance: const Money(320000)),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 11),
        committed: committed,
        steady: burnAt(20000),
      );
      expect(committed.total, const Money(300000));
      expect(r.usable, Money.zero);
      expect(r.safeDaily, Money.zero);
      expect(r.runsShort, isTrue);
    });

    test('5: a commute-only week leaves exactly the floor', () {
      final CommittedCosts committed = committedFor(
        envelope: steadyEnvelope(
          commute: const CommuteCost(perWeekday: Money(15000)),
        ),
        obligations: const <EngineObligation>[],
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 11),
      );
      expect(committed.commuteWeekdays, 5, reason: 'Mon 7 to Fri 11');
      final DeterministicRunway r = computeRunway(
        envelope: steadyEnvelope(
          balance: const Money(95000),
          commute: const CommuteCost(perWeekday: Money(15000)),
        ),
        asOf: asOf,
        horizonEnd: DateTime(2026, 9, 11),
        committed: committed,
        steady: burnAt(20000),
      );
      expect(committed.commute, const Money(75000));
      expect(
        r.usable,
        Money.zero,
        reason: 'PHP 950 less PHP 750 commute less the PHP 200 floor',
      );
      expect(r.safeDaily, Money.zero);
    });
  });
}
