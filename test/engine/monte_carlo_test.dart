import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/affordability.dart';
import 'package:baon/engine/engine.dart';
import 'package:baon/engine/envelope.dart';
import 'package:baon/engine/monte_carlo.dart';
import 'package:flutter_test/flutter_test.dart';

/// 2026-09-04 is a Friday.
final DateTime asOf = DateTime(2026, 9, 4);

EngineTxn out(int daysAgo, int cents, String category) => EngineTxn(
  amount: Money(cents),
  direction: TxnDirection.moneyOut,
  categoryKey: category,
  occurredAt: DateTime(2026, 9, 4 - daysAgo, 12),
);

/// A steady food envelope with 28 days of PHP 200 a day behind it.
EngineEnvelope food({
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

EngineEnvelope dates({
  Money balance = const Money(120000),
  List<String> borrowFrom = const <String>['env_food'],
}) => EngineEnvelope(
  id: 'env_dates',
  label: 'Dates',
  shape: EnvelopeShape.episodic,
  balance: balance,
  refill: const Money(300000),
  refillCadence: Cadence.monthly,
  categoryKeys: const <String>['dates_leisure'],
  allowBorrowFrom: borrowFrom,
);

const EngineEnvelope savings = EngineEnvelope(
  id: 'env_savings',
  label: 'Savings',
  shape: EnvelopeShape.reserve,
  balance: Money(472000),
  refill: Money.zero,
  refillCadence: Cadence.none,
  categoryKeys: <String>[],
);

List<EngineTxn> steadyHistory({int perDay = 20000, int days = 28}) =>
    <EngineTxn>[for (int i = 0; i < days; i++) out(i, perDay, 'food_daily')];

List<EngineTxn> dateHistory({
  List<int> amounts = const <int>[90000, 100000, 80000, 110000],
}) => <EngineTxn>[
  for (int i = 0; i < amounts.length; i++)
    out(i * 7, amounts[i], 'dates_leisure'),
];

EngineInput inputWith({
  required List<EngineEnvelope> envelopes,
  List<EngineTxn> txns = const <EngineTxn>[],
  List<EngineIncome> incomes = const <EngineIncome>[],
  List<EngineObligation> obligations = const <EngineObligation>[],
  DateTime? horizonEnd,
  DateTime? historyStartedOn,
  Money accountTotal = const Money(792000),
}) => EngineInput(
  asOf: asOf,
  envelopes: envelopes,
  txns: txns,
  incomes: incomes,
  obligations: obligations,
  horizonEnd: horizonEnd ?? DateTime(2026, 9, 11),
  historyStartedOn: historyStartedOn ?? DateTime(2026, 8, 8),
  accountTotal: accountTotal,
);

void main() {
  group('determinism', () {
    test('the same input gives the same answer, run after run', () {
      final EngineInput input = inputWith(
        envelopes: <EngineEnvelope>[food(), dates()],
        txns: <EngineTxn>[...steadyHistory(), ...dateHistory()],
      );
      final ForecastResult a = runForecast(input, runs: 500);
      final ForecastResult b = runForecast(input, runs: 500);
      expect(a.toJson(), b.toJson());
    });

    test('the seed is stable for a user, envelope and day', () {
      final int a = simulationSeed(
        userId: 'u1',
        envelopeId: 'env_food',
        today: asOf,
      );
      final int b = simulationSeed(
        userId: 'u1',
        envelopeId: 'env_food',
        today: asOf,
      );
      expect(a, b);
      expect(a, isNonNegative);
    });

    test('a different day, user or envelope gives a different seed', () {
      final int base = simulationSeed(
        userId: 'u1',
        envelopeId: 'env_food',
        today: asOf,
      );
      expect(
        simulationSeed(userId: 'u2', envelopeId: 'env_food', today: asOf),
        isNot(base),
      );
      expect(
        simulationSeed(userId: 'u1', envelopeId: 'env_dates', today: asOf),
        isNot(base),
      );
      expect(
        simulationSeed(
          userId: 'u1',
          envelopeId: 'env_food',
          today: DateTime(2026, 9, 5),
        ),
        isNot(base),
      );
    });
  });

  group('shortfall probability', () {
    test('plenty of money gives near zero risk', () {
      final ForecastResult r = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[food(balance: const Money(2000000))],
          txns: steadyHistory(),
        ),
        runs: 500,
      );
      expect(r.byId('env_food')!.pShortfallOwn, lessThan(0.01));
    });

    test('too little money gives near certain risk', () {
      final ForecastResult r = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[food(balance: const Money(5000))],
          txns: steadyHistory(),
        ),
        runs: 500,
      );
      expect(r.byId('env_food')!.pShortfallOwn, greaterThan(0.95));
    });

    test('risk rises as the balance falls', () {
      double previous = -1;
      for (final int balance in <int>[300000, 200000, 150000, 100000, 50000]) {
        final ForecastResult r = runForecast(
          inputWith(
            envelopes: <EngineEnvelope>[food(balance: Money(balance))],
            txns: steadyHistory(),
          ),
          runs: 500,
        );
        final double risk = r.byId('env_food')!.pShortfallOwn;
        expect(
          risk,
          greaterThanOrEqualTo(previous),
          reason: 'less money must never mean less risk',
        );
        previous = risk;
      }
    });

    test('the percentile fan is ordered', () {
      final ForecastResult r = runForecast(
        inputWith(envelopes: <EngineEnvelope>[food()], txns: steadyHistory()),
        runs: 800,
      );
      final EnvelopeForecast f = r.byId('env_food')!;
      expect(f.endBalanceP10 <= f.endBalanceP50, isTrue);
      expect(f.endBalanceP50 <= f.endBalanceP90, isTrue);
    });

    test('a committed commute lowers the balance but not through variance', () {
      final ForecastResult withCommute = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[
            food(commute: const CommuteCost(perWeekday: Money(15000))),
          ],
          txns: steadyHistory(),
        ),
        runs: 500,
      );
      final ForecastResult without = runForecast(
        inputWith(envelopes: <EngineEnvelope>[food()], txns: steadyHistory()),
        runs: 500,
      );
      final EnvelopeForecast a = withCommute.byId('env_food')!;
      final EnvelopeForecast b = without.byId('env_food')!;

      expect(a.committed, const Money(75000), reason: 'five weekdays at 150');
      expect(a.endBalanceP50 < b.endBalanceP50, isTrue);
      expect(
        a.endBalanceP90 - a.endBalanceP10,
        b.endBalanceP90 - b.endBalanceP10,
        reason: 'a fixed cost shifts the fan, it must not widen it',
      );
    });
  });

  group('income', () {
    EngineIncome income(IncomeConfidence confidence) => EngineIncome(
      label: 'Allowance',
      amount: const Money(200000),
      cadence: Cadence.weekly,
      nextExpectedOn: DateTime(2026, 9, 8),
      confidence: confidence,
    );

    test('certain income lowers the risk', () {
      final ForecastResult withIncome = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[food(balance: const Money(80000))],
          txns: steadyHistory(),
          incomes: <EngineIncome>[income(IncomeConfidence.certain)],
          horizonEnd: DateTime(2026, 9, 11),
        ),
        runs: 500,
      );
      final ForecastResult without = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[food(balance: const Money(80000))],
          txns: steadyHistory(),
          horizonEnd: DateTime(2026, 9, 11),
        ),
        runs: 500,
      );
      expect(
        withIncome.byId('env_food')!.pShortfallOwn,
        lessThan(without.byId('env_food')!.pShortfallOwn),
      );
    });

    test('hoped-for income never lowers the risk', () {
      final ForecastResult likely = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[food(balance: const Money(80000))],
          txns: steadyHistory(),
          incomes: <EngineIncome>[income(IncomeConfidence.likely)],
          horizonEnd: DateTime(2026, 9, 11),
        ),
        runs: 500,
      );
      final ForecastResult unsure = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[food(balance: const Money(80000))],
          txns: steadyHistory(),
          incomes: <EngineIncome>[income(IncomeConfidence.unsure)],
          horizonEnd: DateTime(2026, 9, 11),
        ),
        runs: 500,
      );
      expect(
        likely.byId('env_food')!.pShortfallOwn,
        unsure.byId('env_food')!.pShortfallOwn,
        reason: 'BUILD_PLAN.md Section 8.6: only certain income counts',
      );
    });
  });

  group('the spill rule', () {
    test('a dates overrun raises the food risk above its own', () {
      // Food is comfortable on its own: PHP 1,900 against PHP 200 a day for
      // seven days leaves PHP 500, well clear of the PHP 200 floor. Dates has
      // far too little for its usual PHP 900 to PHP 1,100 nights, and may
      // borrow. Only the spill can put food at risk here, which is the whole
      // point of the second number.
      final ForecastResult r = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[
            food(balance: const Money(190000)),
            dates(balance: const Money(20000)),
          ],
          txns: <EngineTxn>[
            ...steadyHistory(),
            ...dateHistory(amounts: <int>[90000, 100000, 95000, 110000]),
          ],
        ),
        runs: 800,
      );

      final EnvelopeForecast foodF = r.byId('env_food')!;
      final EnvelopeForecast datesF = r.byId('env_dates')!;

      expect(datesF.pShortfallOwn, greaterThan(0.3));
      expect(
        foodF.pShortfallWithSpill,
        greaterThan(foodF.pShortfallOwn),
        reason: 'the dates envelope must be shown to threaten food',
      );
      expect(datesF.borrowTarget, 'env_food');
      expect(foodF.expectedSpill.isPositive, isTrue);
    });

    test('no borrow permission means no spill', () {
      final ForecastResult r = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[
            food(balance: const Money(150000)),
            dates(balance: const Money(20000), borrowFrom: const <String>[]),
          ],
          txns: <EngineTxn>[...steadyHistory(), ...dateHistory()],
        ),
        runs: 500,
      );
      final EnvelopeForecast foodF = r.byId('env_food')!;
      expect(foodF.pShortfallWithSpill, foodF.pShortfallOwn);
      expect(foodF.expectedSpill, Money.zero);
    });

    test('a solvent borrower spills nothing', () {
      final ForecastResult r = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[
            food(balance: const Money(150000)),
            dates(balance: const Money(2000000)),
          ],
          txns: <EngineTxn>[...steadyHistory(), ...dateHistory()],
        ),
        runs: 500,
      );
      final EnvelopeForecast foodF = r.byId('env_food')!;
      expect(foodF.expectedSpill, Money.zero);
      expect(foodF.pShortfallWithSpill, foodF.pShortfallOwn);
    });

    test('spill can only add risk, never remove it', () {
      final ForecastResult r = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[
            food(balance: const Money(2000000)),
            dates(balance: const Money(1000)),
          ],
          txns: <EngineTxn>[...steadyHistory(), ...dateHistory()],
        ),
        runs: 500,
      );
      final EnvelopeForecast foodF = r.byId('env_food')!;
      expect(
        foodF.pShortfallWithSpill,
        greaterThanOrEqualTo(foodF.pShortfallOwn),
      );
    });
  });

  group('the reserve', () {
    test('savings is reported as a balance and never simulated', () {
      final ForecastResult r = runForecast(
        inputWith(
          envelopes: <EngineEnvelope>[food(), savings],
          txns: steadyHistory(),
        ),
        runs: 200,
      );
      final EnvelopeForecast s = r.byId('env_savings')!;
      expect(s.balance, const Money(472000));
      expect(s.pShortfallOwn, 0);
      expect(s.runwayDays, 0);
      expect(s.toJson().keys, <String>['id', 'label', 'shape', 'balance']);
    });
  });

  group('the 80 ms budget', () {
    test('all envelopes simulate inside the cap at 2000 runs', () {
      final EngineInput input = inputWith(
        envelopes: <EngineEnvelope>[
          food(commute: const CommuteCost(perWeekday: Money(15000))),
          dates(),
          savings,
        ],
        txns: <EngineTxn>[...steadyHistory(), ...dateHistory()],
        horizonEnd: DateTime(2026, 9, 18),
      );

      // Warm up, so the measurement is not dominated by first-call JIT.
      runForecast(input, runs: defaultRuns);

      final Stopwatch stopwatch = Stopwatch()..start();
      runForecast(input, runs: defaultRuns);
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(80),
        reason:
            'BUILD_PLAN.md Section 8.6 caps the whole run at 80 ms on a '
            'mid-range phone. Measured ${stopwatch.elapsedMilliseconds} ms.',
      );
    });
  });

  group('affordability', () {
    ForecastResult buildForecast() => runForecast(
      inputWith(
        envelopes: <EngineEnvelope>[
          food(balance: const Money(150000)),
          dates(balance: const Money(120000)),
        ],
        txns: <EngineTxn>[...steadyHistory(), ...dateHistory()],
        horizonEnd: DateTime(2026, 9, 18),
      ),
      runs: 400,
    );

    test('answers the three questions the plan asks for', () {
      final ForecastResult forecast = buildForecast();
      final AffordabilityAnswer answer = checkAffordability(
        plans: forecast.plans,
        asOf: asOf,
        userId: 'local',
        envelopeId: 'env_dates',
        amount: const Money(100000),
        on: DateTime(2026, 9, 12),
        essentialEnvelopeId: 'env_food',
        runs: 400,
      );

      expect(answer.leftInEnvelope, const Money(20000));
      expect(answer.eventsStillAffordable, 0);
      expect(answer.essentialEnvelopeId, 'env_food');
      expect(answer.envelopeLabel, 'Dates');
    });

    test('a small spend is safe and a huge one is risky', () {
      final ForecastResult forecast = buildForecast();

      final AffordabilityAnswer small = checkAffordability(
        plans: forecast.plans,
        asOf: asOf,
        userId: 'local',
        envelopeId: 'env_dates',
        amount: const Money(5000),
        on: DateTime(2026, 9, 12),
        essentialEnvelopeId: 'env_food',
        runs: 400,
      );
      final AffordabilityAnswer huge = checkAffordability(
        plans: forecast.plans,
        asOf: asOf,
        userId: 'local',
        envelopeId: 'env_dates',
        amount: const Money(500000),
        on: DateTime(2026, 9, 12),
        essentialEnvelopeId: 'env_food',
        runs: 400,
      );

      expect(huge.riskOwnAfter, greaterThan(small.riskOwnAfter));
      expect(huge.verdict, AffordVerdict.risky);
      expect(huge.leftInEnvelope.isNegative, isTrue);
    });

    test('spending more never lowers the risk', () {
      final ForecastResult forecast = buildForecast();
      double previous = -1;
      for (final int amount in <int>[0, 50000, 100000, 200000, 400000]) {
        final AffordabilityAnswer answer = checkAffordability(
          plans: forecast.plans,
          asOf: asOf,
          userId: 'local',
          envelopeId: 'env_dates',
          amount: Money(amount),
          on: DateTime(2026, 9, 12),
          essentialEnvelopeId: 'env_food',
          runs: 400,
        );
        expect(answer.riskOwnAfter, greaterThanOrEqualTo(previous));
        previous = answer.riskOwnAfter;
      }
    });

    test('the cost to food is reported in pesos, not only in percent', () {
      final ForecastResult forecast = buildForecast();
      final AffordabilityAnswer answer = checkAffordability(
        plans: forecast.plans,
        asOf: asOf,
        userId: 'local',
        envelopeId: 'env_dates',
        amount: const Money(300000),
        on: DateTime(2026, 9, 12),
        essentialEnvelopeId: 'env_food',
        runs: 400,
      );
      expect(answer.essentialCostInPesos.isPositive, isTrue);
      expect(answer.leavesEssentialsAlone, isFalse);
    });

    test('an unknown envelope is refused', () {
      final ForecastResult forecast = buildForecast();
      expect(
        () => checkAffordability(
          plans: forecast.plans,
          asOf: asOf,
          userId: 'local',
          envelopeId: 'env_nope',
          amount: const Money(1000),
          on: DateTime(2026, 9, 12),
        ),
        throwsArgumentError,
      );
    });

    test('the verdict takes the worse of the two risks', () {
      expect(verdictFor(0.05, 0.02), AffordVerdict.safe);
      expect(verdictFor(0.05, 0.20), AffordVerdict.tight);
      expect(verdictFor(0.20, 0.05), AffordVerdict.tight);
      expect(verdictFor(0.05, 0.90), AffordVerdict.risky);
      expect(verdictFor(0.10, 0.0), AffordVerdict.tight);
      expect(verdictFor(0.35, 0.0), AffordVerdict.risky);
    });
  });
}
