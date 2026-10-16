@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/engine.dart';
import 'package:baon/engine/envelope.dart';
import 'package:flutter_test/flutter_test.dart';

/// 2026-09-04 is a Friday.
final DateTime asOf = DateTime(2026, 9, 4);

EngineTxn out(int daysAgo, int cents, String category, {int hour = 12}) =>
    EngineTxn(
      amount: Money(cents),
      direction: TxnDirection.moneyOut,
      categoryKey: category,
      occurredAt: DateTime(2026, 9, 4 - daysAgo, hour),
    );

/// The reference scenario. This is the one pinned to a golden file, so any
/// change to the Section 8.8 schema fails the test loudly.
EngineInput referenceInput() {
  final List<EngineTxn> txns = <EngineTxn>[
    for (int i = 0; i < 28; i++)
      out(
        i,
        DateTime(2026, 9, 4 - i).weekday <= 5 ? 25000 : 12000,
        'food_daily',
      ),
    for (final int d in <int>[3, 10, 17, 24])
      out(
        d,
        d == 3 ? 120000 : (d == 10 ? 80000 : 95000),
        'dates_leisure',
        hour: 19,
      ),
  ];

  return EngineInput(
    asOf: asOf,
    accountTotal: const Money(684000),
    historyStartedOn: DateTime(2026, 8, 8),
    horizonEnd: DateTime(2026, 9, 11),
    envelopes: <EngineEnvelope>[
      EngineEnvelope(
        id: 'env_food',
        label: 'Food and transport',
        shape: EnvelopeShape.steady,
        balance: const Money(92000),
        refill: const Money(200000),
        refillCadence: Cadence.weekly,
        categoryKeys: const <String>['food_daily', 'transport'],
        safetyFloor: const Money(20000),
        commute: const CommuteCost(perWeekday: Money(15000)),
        nextRefillOn: DateTime(2026, 9, 7),
      ),
      EngineEnvelope(
        id: 'env_dates',
        label: 'Dates',
        shape: EnvelopeShape.episodic,
        balance: const Money(120000),
        refill: const Money(300000),
        refillCadence: Cadence.monthly,
        categoryKeys: const <String>['dates_leisure'],
        allowBorrowFrom: const <String>['env_food'],
        nextRefillOn: DateTime(2026, 9, 16),
      ),
      const EngineEnvelope(
        id: 'env_savings',
        label: 'Savings',
        shape: EnvelopeShape.reserve,
        balance: Money(472000),
        refill: Money.zero,
        refillCadence: Cadence.none,
        categoryKeys: <String>[],
      ),
    ],
    txns: txns,
  );
}

EngineEnvelope steady({
  Money balance = const Money(200000),
  Money floor = const Money(20000),
  CommuteCost commute = CommuteCost.none,
}) => EngineEnvelope(
  id: 'env_food',
  label: 'Food and transport',
  shape: EnvelopeShape.steady,
  balance: balance,
  refill: const Money(200000),
  refillCadence: Cadence.weekly,
  categoryKeys: const <String>['food_daily', 'transport'],
  safetyFloor: floor,
  commute: commute,
);

EngineInput scenario({
  required List<EngineEnvelope> envelopes,
  List<EngineTxn> txns = const <EngineTxn>[],
  DateTime? historyStartedOn,
  DateTime? horizonEnd,
  List<EngineIncome> incomes = const <EngineIncome>[],
  List<EngineObligation> obligations = const <EngineObligation>[],
  List<String> staleAccounts = const <String>[],
  Money accountTotal = const Money(200000),
  Money unallocated = Money.zero,
}) => EngineInput(
  asOf: asOf,
  envelopes: envelopes,
  txns: txns,
  incomes: incomes,
  obligations: obligations,
  staleAccountLabels: staleAccounts,
  accountTotal: accountTotal,
  unallocated: unallocated,
  historyStartedOn: historyStartedOn,
  horizonEnd: horizonEnd ?? DateTime(2026, 9, 11),
);

void main() {
  group('golden schema', () {
    final File goldenFile = File('test/engine/goldens/forecast_reference.json');

    test('the Section 8.8 output has not changed', () {
      final ForecastResult result = runForecast(referenceInput());
      final String actual =
          '${const JsonEncoder.withIndent('  ').convert(result.toJson())}\n';

      // Set BAON_UPDATE_GOLDEN=1 to re-record after a deliberate change.
      if (Platform.environment['BAON_UPDATE_GOLDEN'] == '1') {
        goldenFile.writeAsStringSync(actual);
      }

      expect(
        goldenFile.existsSync(),
        isTrue,
        reason: 'the golden file must be committed alongside the engine',
      );
      expect(
        actual.replaceAll('\r\n', '\n'),
        goldenFile.readAsStringSync().replaceAll('\r\n', '\n'),
        reason:
            'The engine output schema changed. BUILD_PLAN.md Section 16 says '
            'to stop and ask before changing the Section 8.8 schema. If the '
            'change is intended, re-record with BAON_UPDATE_GOLDEN=1.',
      );
    });

    test('carries every top-level field the plan names', () {
      final Map<String, Object?> json = runForecast(
        referenceInput(),
        runs: 200,
      ).toJson();
      expect(
        json.keys,
        containsAll(<String>[
          'as_of',
          'currency',
          'account_total',
          'unallocated',
          'envelopes',
          'largest_lever',
          'stale_accounts',
          'data_quality',
        ]),
      );
      expect(json['currency'], 'PHP');
      expect(json['as_of'], '2026-09-04');
    });

    test('a steady envelope carries the fields the plan names', () {
      final ForecastResult r = runForecast(referenceInput(), runs: 200);
      final Map<String, Object?> food = r.byId('env_food')!.toJson();
      expect(
        food.keys,
        containsAll(<String>[
          'id',
          'label',
          'shape',
          'balance',
          'refill_cents',
          'days_left',
          'committed',
          'committed_note',
          'daily_burn_ewma',
          'daily_burn_median',
          'safe_daily',
          'runway_days',
          'p_shortfall_own',
          'p_shortfall_with_spill',
          'end_balance_p10',
          'end_balance_p50',
          'end_balance_p90',
        ]),
      );
    });

    test('an episodic envelope reports events, not a daily rate', () {
      final ForecastResult r = runForecast(referenceInput(), runs: 200);
      final Map<String, Object?> d = r.byId('env_dates')!.toJson();
      expect(
        d.keys,
        containsAll(<String>[
          'event_rate_per_week',
          'event_size_median',
          'events_affordable',
          'borrow_target',
          'expected_spill',
        ]),
      );
      expect(
        d.containsKey('daily_burn_ewma'),
        isFalse,
        reason: 'a daily average is meaningless for a lumpy envelope',
      );
      expect(d.containsKey('safe_daily'), isFalse);
    });

    test('every money field is a whole number of centavos', () {
      final Map<String, Object?> json = runForecast(
        referenceInput(),
        runs: 200,
      ).toJson();
      expect(json['account_total'], isA<int>());
      for (final Object? envelope in json['envelopes']! as List<Object?>) {
        final Map<String, Object?> e = envelope! as Map<String, Object?>;
        for (final String key in <String>[
          'balance',
          'refill_cents',
          'committed',
          'safe_daily',
          'end_balance_p10',
          'event_size_median',
        ]) {
          if (e.containsKey(key)) {
            expect(e[key], isA<int>(), reason: '$key must be centavos');
          }
        }
      }
    });

    test('the output survives a JSON round trip', () {
      final Map<String, Object?> json = runForecast(
        referenceInput(),
        runs: 200,
      ).toJson();
      expect(
        jsonDecode(jsonEncode(json)),
        json,
        reason: 'the AI layer receives this object as JSON',
      );
    });
  });

  group('Section 15 edge cases', () {
    test('1: zero history gives a low quality flag and no crash', () {
      final ForecastResult r = runForecast(
        scenario(envelopes: <EngineEnvelope>[steady()]),
        runs: 200,
      );
      expect(r.dataQuality, DataQuality.low);
      final EnvelopeForecast f = r.byId('env_food')!;
      expect(f.dailyBurnEwma, Money.zero);
      expect(f.pShortfallOwn, 0);
      expect(f.endBalanceP50, const Money(200000));
    });

    test('2: one day of history is still low quality', () {
      final ForecastResult r = runForecast(
        scenario(
          envelopes: <EngineEnvelope>[steady()],
          txns: <EngineTxn>[out(0, 30000, 'food_daily')],
          historyStartedOn: asOf,
        ),
        runs: 200,
      );
      expect(r.dataQuality, DataQuality.low);
      expect(r.byId('env_food')!.dailyBurnEwma, const Money(30000));
    });

    test('3: seven days of history reaches good quality', () {
      final ForecastResult r = runForecast(
        scenario(
          envelopes: <EngineEnvelope>[steady()],
          txns: <EngineTxn>[
            for (int i = 0; i < 7; i++) out(i, 20000, 'food_daily'),
          ],
          historyStartedOn: DateTime(2026, 8, 29),
        ),
        runs: 200,
      );
      expect(r.dataQuality, DataQuality.good);
    });

    test('4: a negative balance never gives a positive runway', () {
      final ForecastResult r = runForecast(
        scenario(
          envelopes: <EngineEnvelope>[steady(balance: const Money(-15000))],
          txns: <EngineTxn>[
            for (int i = 0; i < 14; i++) out(i, 20000, 'food_daily'),
          ],
          historyStartedOn: DateTime(2026, 8, 22),
        ),
        runs: 200,
      );
      final EnvelopeForecast f = r.byId('env_food')!;
      expect(f.balance.isNegative, isTrue);
      expect(f.runwayDays, 0);
      expect(f.safeDaily, Money.zero);
      expect(f.pShortfallOwn, 1.0);
    });

    test(
      '5: a large one-off income lifts the fan but is not double counted',
      () {
        final ForecastResult r = runForecast(
          scenario(
            envelopes: <EngineEnvelope>[steady(balance: const Money(50000))],
            txns: <EngineTxn>[
              for (int i = 0; i < 14; i++) out(i, 20000, 'food_daily'),
            ],
            historyStartedOn: DateTime(2026, 8, 22),
            incomes: <EngineIncome>[
              EngineIncome(
                label: 'Bonus',
                amount: const Money(500000),
                cadence: Cadence.once,
                nextExpectedOn: DateTime(2026, 9, 6),
                confidence: IncomeConfidence.certain,
              ),
            ],
            horizonEnd: DateTime(2026, 9, 11),
          ),
          runs: 400,
        );
        final EnvelopeForecast f = r.byId('env_food')!;
        // Section 8.3 puts the horizon at the earliest expected income, so the
        // 6th wins over the 11th the caller asked for. That leaves two days,
        // the 5th and the 6th, at PHP 200 each.
        expect(f.daysLeft, 2);
        expect(f.endBalanceP50, const Money(510000));
        expect(
          f.pShortfallOwn,
          0,
          reason: 'certain income arriving inside the horizon removes the risk',
        );
      },
    );

    test('6: a weekend spike shows up in the day-of-week pool', () {
      // Weekdays PHP 100, weekends PHP 600, over 28 days. Both forecasts below
      // cover exactly two days, so only which days they are can differ. A flat
      // average would make them identical.
      EngineInput twoDaysFrom(DateTime anchor) {
        final List<EngineTxn> txns = <EngineTxn>[];
        for (int i = 0; i < 28; i++) {
          final DateTime day = DateTime(
            anchor.year,
            anchor.month,
            anchor.day - i,
          );
          txns.add(
            EngineTxn(
              amount: Money(day.weekday <= DateTime.friday ? 10000 : 60000),
              direction: TxnDirection.moneyOut,
              categoryKey: 'food_daily',
              occurredAt: DateTime(day.year, day.month, day.day, 12),
            ),
          );
        }
        return EngineInput(
          asOf: anchor,
          envelopes: <EngineEnvelope>[steady(balance: const Money(100000))],
          txns: txns,
          historyStartedOn: DateTime(
            anchor.year,
            anchor.month,
            anchor.day - 27,
          ),
          horizonEnd: DateTime(anchor.year, anchor.month, anchor.day + 2),
        );
      }

      // Friday 4 September, so the two days ahead are Saturday and Sunday.
      final EnvelopeForecast weekend = runForecast(
        twoDaysFrom(DateTime(2026, 9, 4)),
        runs: 200,
      ).byId('env_food')!;
      // Monday 7 September, so the two days ahead are Tuesday and Wednesday.
      final EnvelopeForecast weekdays = runForecast(
        twoDaysFrom(DateTime(2026, 9, 7)),
        runs: 200,
      ).byId('env_food')!;

      expect(weekend.daysLeft, 2);
      expect(weekdays.daysLeft, 2);
      expect(
        weekend.endBalanceP50,
        const Money(-20000),
        reason: 'two weekend days at PHP 600 overrun PHP 1,000',
      );
      expect(
        weekdays.endBalanceP50,
        const Money(80000),
        reason: 'two weekdays at PHP 100 barely touch it',
      );
      expect(
        weekend.endBalanceP50 < weekdays.endBalanceP50,
        isTrue,
        reason: 'a flat average would hide the weekend spike entirely',
      );
    });

    test('7: a stale snapshot is carried through to the output', () {
      final ForecastResult r = runForecast(
        scenario(
          envelopes: <EngineEnvelope>[steady()],
          staleAccounts: <String>['GCash main', 'MariBank'],
        ),
        runs: 100,
      );
      expect(r.staleAccounts, <String>['GCash main', 'MariBank']);
      expect(r.toJson()['stale_accounts'], <String>['GCash main', 'MariBank']);
    });

    test('8: over-allocated envelopes surface as a broken invariant', () {
      final ForecastResult r = runForecast(
        scenario(
          envelopes: <EngineEnvelope>[steady()],
          accountTotal: const Money(100000),
          unallocated: const Money(-50000),
        ),
        runs: 100,
      );
      expect(r.envelopesNeedFixing, isTrue);
      expect(r.toJson()['unallocated'], -50000);
    });

    test('9: an envelope with no categories still forecasts', () {
      final ForecastResult r = runForecast(
        scenario(
          envelopes: <EngineEnvelope>[
            const EngineEnvelope(
              id: 'env_misc',
              label: 'Misc',
              shape: EnvelopeShape.steady,
              balance: Money(50000),
              refill: Money(50000),
              refillCadence: Cadence.weekly,
              categoryKeys: <String>[],
            ),
          ],
          txns: <EngineTxn>[
            for (int i = 0; i < 14; i++) out(i, 5000, 'anything'),
          ],
          historyStartedOn: DateTime(2026, 8, 22),
        ),
        runs: 200,
      );
      expect(r.byId('env_misc')!.dailyBurnEwma, const Money(5000));
    });

    test('10: a transfer never counts as spending', () {
      final ForecastResult r = runForecast(
        scenario(
          envelopes: <EngineEnvelope>[steady()],
          txns: <EngineTxn>[
            for (int i = 0; i < 14; i++) out(i, 100000, 'transfer_internal'),
            for (int i = 0; i < 14; i++) out(i, 100000, 'savings_in'),
          ],
          historyStartedOn: DateTime(2026, 8, 22),
        ),
        runs: 200,
      );
      expect(
        r.byId('env_food')!.dailyBurnEwma,
        Money.zero,
        reason: 'BUILD_PLAN.md Section 8.4 excludes transfers from outflow',
      );
    });

    test('11: an obligation inside the horizon is reserved', () {
      final ForecastResult r = runForecast(
        scenario(
          envelopes: <EngineEnvelope>[steady(balance: const Money(200000))],
          obligations: <EngineObligation>[
            EngineObligation(
              label: 'Rent share',
              amount: const Money(80000),
              cadence: Cadence.once,
              nextDueOn: DateTime(2026, 9, 8),
              categoryKey: 'food_daily',
            ),
          ],
          historyStartedOn: DateTime(2026, 8, 22),
        ),
        runs: 200,
      );
      final EnvelopeForecast f = r.byId('env_food')!;
      expect(f.committed, const Money(80000));
      expect(f.committedNote, 'Rent share');
      expect(f.endBalanceP50, const Money(120000));
    });

    test('12: no envelopes at all produces a valid empty forecast', () {
      final ForecastResult r = runForecast(
        scenario(envelopes: const <EngineEnvelope>[]),
        runs: 100,
      );
      expect(r.envelopes, isEmpty);
      expect(r.largestLever, isNull);
      expect(r.toJson()['envelopes'], isEmpty);
      expect(r.toJson().containsKey('largest_lever'), isFalse);
      expect(r.essentialEnvelope, isNull);
    });
  });

  group('probabilities stay inside their range', () {
    test('every risk is between zero and one', () {
      final ForecastResult r = runForecast(referenceInput(), runs: 400);
      for (final EnvelopeForecast f in r.envelopes) {
        expect(f.pShortfallOwn, inInclusiveRange(0.0, 1.0));
        expect(f.pShortfallWithSpill, inInclusiveRange(0.0, 1.0));
        expect(
          f.pShortfallWithSpill,
          greaterThanOrEqualTo(f.pShortfallOwn),
          reason: 'spill can only add risk',
        );
      }
    });
  });
}
