/// The simulation that produces every probability in the app.
///
/// BUILD_PLAN.md Section 8.6. This produces the probability, not the language
/// model. Section 2 is the rule that makes this file the only source of a risk
/// number.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

import 'dart:math' as math;

import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/burn_rate.dart';
import 'package:baon/engine/envelope.dart';
import 'package:baon/engine/forecast.dart';

/// The number of simulated futures per envelope.
const int defaultRuns = 2000;

/// An extra outflow the caller wants to test, used by the affordability check.
class PlannedSpend {
  const PlannedSpend({
    required this.envelopeId,
    required this.amount,
    required this.on,
  });

  final String envelopeId;
  final Money amount;
  final DateTime on;
}

/// Everything one envelope needs to be simulated.
class EnvelopePlan {
  const EnvelopePlan({
    required this.envelope,
    required this.horizonEnd,
    required this.committed,
    required this.runway,
    this.steady = SteadyBurn.empty,
    this.episodic = EpisodicBurn.empty,
    this.obligationsByDay = const <DateTime, Money>{},
    this.incomeByDay = const <DateTime, Money>{},
  });

  final EngineEnvelope envelope;
  final DateTime horizonEnd;
  final CommittedCosts committed;
  final DeterministicRunway runway;
  final SteadyBurn steady;
  final EpisodicBurn episodic;

  /// Obligations that land on a given day inside the horizon.
  final Map<DateTime, Money> obligationsByDay;

  /// Certain income that lands on a given day inside the horizon.
  ///
  /// BUILD_PLAN.md Section 8.6 adds a refill only when confidence is certain.
  /// Money the user merely hopes for must never lower a risk figure.
  final Map<DateTime, Money> incomeByDay;

  String get id => envelope.id;
}

/// The raw per-run output of one envelope simulation.
///
/// Kept so the spill pass can work run by run. Averaging first and spilling
/// afterwards would compare a typical lender against an unlucky borrower and
/// understate the joint risk.
class EnvelopeRuns {
  const EnvelopeRuns({
    required this.endBalances,
    required this.minBalances,
    required this.deficits,
  });

  static const EnvelopeRuns empty = EnvelopeRuns(
    endBalances: <Money>[],
    minBalances: <Money>[],
    deficits: <Money>[],
  );

  final List<Money> endBalances;

  /// The lowest the envelope fell during each run.
  final List<Money> minBalances;

  /// How far below zero each run went. Zero when the run stayed solvent.
  final List<Money> deficits;

  int get length => endBalances.length;
}

/// The simulated outcome for one envelope.
class EnvelopeSimulation {
  const EnvelopeSimulation({
    required this.envelopeId,
    required this.shape,
    required this.runs,
    required this.pShortfallOwn,
    required this.pShortfallWithSpill,
    required this.endBalanceP10,
    required this.endBalanceP50,
    required this.endBalanceP90,
    required this.expectedSpill,
    required this.expectedEndBalance,
  });

  final String envelopeId;
  final EnvelopeShape shape;
  final int runs;

  /// The risk inside the envelope itself.
  final double pShortfallOwn;

  /// The risk once another envelope is allowed to borrow from this one.
  ///
  /// This is the number that matters. A date overrun is only a real problem
  /// when it eats the food budget.
  final double pShortfallWithSpill;

  final Money endBalanceP10;
  final Money endBalanceP50;
  final Money endBalanceP90;

  /// The average amount pushed onto another envelope, or taken from this one.
  final Money expectedSpill;

  final Money expectedEndBalance;

  EnvelopeSimulation copyWith({
    double? pShortfallWithSpill,
    Money? expectedSpill,
  }) => EnvelopeSimulation(
    envelopeId: envelopeId,
    shape: shape,
    runs: runs,
    pShortfallOwn: pShortfallOwn,
    pShortfallWithSpill: pShortfallWithSpill ?? this.pShortfallWithSpill,
    endBalanceP10: endBalanceP10,
    endBalanceP50: endBalanceP50,
    endBalanceP90: endBalanceP90,
    expectedSpill: expectedSpill ?? this.expectedSpill,
    expectedEndBalance: expectedEndBalance,
  );
}

/// The result of one full simulation pass across every envelope.
class SimulationResult {
  const SimulationResult({required this.byEnvelope, required this.runsById});

  final Map<String, EnvelopeSimulation> byEnvelope;

  /// The raw runs, exposed for the fan chart and for tests.
  final Map<String, EnvelopeRuns> runsById;

  EnvelopeSimulation? operator [](String envelopeId) => byEnvelope[envelopeId];
}

/// Builds the seed for a run.
///
/// BUILD_PLAN.md Section 8.6: the same input gives the same answer on the same
/// day. A probability that flickers between screens destroys trust as surely
/// as a wrong one. `String.hashCode` is not stable across processes, so this
/// uses FNV-1a instead.
int simulationSeed({
  required String userId,
  required String envelopeId,
  required DateTime today,
}) {
  final String key =
      '$userId|$envelopeId|${today.year}-${today.month}-${today.day}';
  int hash = 0x811c9dc5;
  for (final int unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

/// The outcome of simulating one envelope on its own.
typedef SingleEnvelopeOutcome = ({
  EnvelopeSimulation summary,
  EnvelopeRuns runs,
});

/// Runs the simulation for one envelope, ignoring any spill.
///
/// A reserve is not simulated. A savings balance has no burn model, so a
/// probability of shortfall would be meaningless.
SingleEnvelopeOutcome simulateEnvelope({
  required EnvelopePlan plan,
  required DateTime asOf,
  required String userId,
  int runs = defaultRuns,
  List<PlannedSpend> extraSpends = const <PlannedSpend>[],
}) {
  final EngineEnvelope envelope = plan.envelope;
  final DateTime today = dateOnly(asOf);

  if (envelope.isReserve) {
    return (
      summary: EnvelopeSimulation(
        envelopeId: envelope.id,
        shape: envelope.shape,
        runs: 0,
        pShortfallOwn: 0,
        pShortfallWithSpill: 0,
        endBalanceP10: envelope.balance,
        endBalanceP50: envelope.balance,
        endBalanceP90: envelope.balance,
        expectedSpill: Money.zero,
        expectedEndBalance: envelope.balance,
      ),
      runs: EnvelopeRuns.empty,
    );
  }

  final List<DateTime> days = daysInclusive(
    addDays(today, 1),
    dateOnly(plan.horizonEnd),
  );

  final math.Random random = math.Random(
    simulationSeed(userId: userId, envelopeId: envelope.id, today: today),
  );

  final List<Money> endBalances = <Money>[];
  final List<Money> minBalances = <Money>[];
  final List<Money> deficits = <Money>[];
  int shortfalls = 0;

  // The commute is a committed cost, not a random spend, so it comes off the
  // opening balance once rather than being drawn each day. Section 8.4: this
  // removes variance and makes the forecast much sharper.
  final Money opening = envelope.balance - plan.committed.commute;
  final int floor = envelope.safetyFloor.centavos;

  // Pre-resolve the extra spends for this envelope so the inner loop stays
  // cheap. Section 8.6 caps the whole run at 80 ms on a mid-range phone.
  final Map<DateTime, int> extraByDay = <DateTime, int>{};
  for (final PlannedSpend extra in extraSpends) {
    if (extra.envelopeId != envelope.id) {
      continue;
    }
    final DateTime day = dateOnly(extra.on);
    extraByDay[day] = (extraByDay[day] ?? 0) + extra.amount.centavos;
  }

  final Map<DateTime, int> obligations = <DateTime, int>{
    for (final MapEntry<DateTime, Money> e in plan.obligationsByDay.entries)
      dateOnly(e.key): e.value.centavos,
  };
  final Map<DateTime, int> income = <DateTime, int>{
    for (final MapEntry<DateTime, Money> e in plan.incomeByDay.entries)
      dateOnly(e.key): e.value.centavos,
  };

  final bool isSteady = envelope.shape == EnvelopeShape.steady;
  final double dailyEventRate = plan.episodic.eventsPerWeek / 7;
  final List<Money> eventSizes = plan.episodic.eventSizes;

  for (int run = 0; run < runs; run++) {
    int balance = opening.centavos;
    int minBalance = balance;

    for (final DateTime day in days) {
      int spend = extraByDay[day] ?? 0;

      if (isSteady) {
        final List<Money> pool = plan.steady.poolFor(day.weekday);
        if (pool.isNotEmpty) {
          spend += pool[random.nextInt(pool.length)].centavos;
        }
      } else if (eventSizes.isNotEmpty) {
        final int events = poissonSample(random, dailyEventRate);
        for (int e = 0; e < events; e++) {
          spend += eventSizes[random.nextInt(eventSizes.length)].centavos;
        }
      }

      balance -= spend;
      balance -= obligations[day] ?? 0;
      balance += income[day] ?? 0;

      if (balance < minBalance) {
        minBalance = balance;
      }
    }

    if (minBalance < floor) {
      shortfalls++;
    }
    endBalances.add(Money(balance));
    minBalances.add(Money(minBalance));
    deficits.add(Money(minBalance < 0 ? -minBalance : 0));
  }

  final double p = runs == 0 ? 0 : shortfalls / runs;
  return (
    summary: EnvelopeSimulation(
      envelopeId: envelope.id,
      shape: envelope.shape,
      runs: runs,
      pShortfallOwn: p,
      pShortfallWithSpill: p,
      endBalanceP10: percentile(endBalances, 10),
      endBalanceP50: percentile(endBalances, 50),
      endBalanceP90: percentile(endBalances, 90),
      expectedSpill: _mean(deficits),
      expectedEndBalance: _mean(endBalances),
    ),
    runs: EnvelopeRuns(
      endBalances: endBalances,
      minBalances: minBalances,
      deficits: deficits,
    ),
  );
}

/// Runs every envelope, then applies the spill rule.
///
/// BUILD_PLAN.md Section 8.6. After the per-envelope runs, a second pass moves
/// the deficit of a borrowing envelope onto the envelope named in
/// `allow_borrow_from`, then re-measures that envelope.
///
/// Two numbers come out of this. `p_shortfall_own` is the risk inside the
/// envelope. `p_shortfall_with_spill` is the risk to food and transport caused
/// by the dates envelope, and it is the one that matters.
SimulationResult simulateAll({
  required List<EnvelopePlan> plans,
  required DateTime asOf,
  required String userId,
  int runs = defaultRuns,
  List<PlannedSpend> extraSpends = const <PlannedSpend>[],
}) {
  final Map<String, EnvelopeSimulation> results =
      <String, EnvelopeSimulation>{};
  final Map<String, EnvelopeRuns> traces = <String, EnvelopeRuns>{};
  final Map<String, EnvelopePlan> planById = <String, EnvelopePlan>{
    for (final EnvelopePlan p in plans) p.id: p,
  };

  for (final EnvelopePlan plan in plans) {
    final SingleEnvelopeOutcome outcome = simulateEnvelope(
      plan: plan,
      asOf: asOf,
      userId: userId,
      runs: runs,
      extraSpends: extraSpends,
    );
    results[plan.id] = outcome.summary;
    traces[plan.id] = outcome.runs;
  }

  // For each lender, add up what every borrower pushes at it, run by run.
  final Map<String, List<int>> incomingByLender = <String, List<int>>{};
  for (final EnvelopePlan plan in plans) {
    final EnvelopeRuns borrower = traces[plan.id] ?? EnvelopeRuns.empty;
    if (plan.envelope.allowBorrowFrom.isEmpty || borrower.length == 0) {
      continue;
    }
    for (final String lenderId in plan.envelope.allowBorrowFrom) {
      if (!planById.containsKey(lenderId) || lenderId == plan.id) {
        continue;
      }
      final List<int> running = incomingByLender.putIfAbsent(
        lenderId,
        () => List<int>.filled(borrower.length, 0),
      );
      final int count = math.min(running.length, borrower.length);
      for (int i = 0; i < count; i++) {
        running[i] += borrower.deficits[i].centavos;
      }
    }
  }

  // Re-measure each lender with the borrowed money taken out of it.
  for (final MapEntry<String, List<int>> entry in incomingByLender.entries) {
    final EnvelopePlan? lenderPlan = planById[entry.key];
    final EnvelopeSimulation? base = results[entry.key];
    final EnvelopeRuns? lenderRuns = traces[entry.key];
    if (lenderPlan == null || base == null || lenderRuns == null) {
      continue;
    }

    final List<int> incoming = entry.value;
    final int floor = lenderPlan.envelope.safetyFloor.centavos;
    final int total = math.min(incoming.length, lenderRuns.length);
    if (total == 0) {
      continue;
    }

    int shortfalls = 0;
    for (int i = 0; i < total; i++) {
      if (lenderRuns.minBalances[i].centavos - incoming[i] < floor) {
        shortfalls++;
      }
    }

    results[entry.key] = base.copyWith(
      // The spill can only add risk, never remove it.
      pShortfallWithSpill: math.max(base.pShortfallOwn, shortfalls / total),
      expectedSpill: Money(
        incoming.take(total).fold(0, (int a, int b) => a + b) ~/ total,
      ),
    );
  }

  return SimulationResult(byEnvelope: results, runsById: traces);
}

Money _mean(List<Money> values) => values.isEmpty
    ? Money.zero
    : Money(Money.sum(values).centavos ~/ values.length);
