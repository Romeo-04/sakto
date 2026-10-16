/// The answer to "can I afford this?".
///
/// BUILD_PLAN.md Section 8.7. This turns a vague worry into a number, and it
/// answers in pesos as well as in percent, because a change from 22% to 38%
/// means nothing on its own.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/monte_carlo.dart';

/// Risk at or below this counts as safe.
const double safeRiskThreshold = 0.10;

/// Risk at or below this counts as tight. Anything higher is risky.
const double tightRiskThreshold = 0.35;

/// What the app tells the user about a planned spend.
class AffordabilityAnswer {
  const AffordabilityAnswer({
    required this.envelopeId,
    required this.envelopeLabel,
    required this.amount,
    required this.on,
    required this.verdict,
    required this.leftInEnvelope,
    required this.eventsStillAffordable,
    required this.daysCovered,
    required this.riskOwnBefore,
    required this.riskOwnAfter,
    required this.essentialEnvelopeId,
    required this.essentialRiskBefore,
    required this.essentialRiskAfter,
    required this.essentialCostInPesos,
  });

  final String envelopeId;
  final String envelopeLabel;
  final Money amount;
  final DateTime on;

  final AffordVerdict verdict;

  /// Answer 1: the money left in that envelope after the event.
  final Money leftInEnvelope;

  /// Answer 3: how many further events the envelope still supports.
  final int eventsStillAffordable;

  /// For a steady envelope, the days the remaining money covers.
  final int daysCovered;

  final double riskOwnBefore;
  final double riskOwnAfter;

  /// The envelope that pays for essentials, usually food and transport.
  final String? essentialEnvelopeId;
  final double essentialRiskBefore;
  final double essentialRiskAfter;

  /// Answer 2: the change in the essential risk, in peso terms.
  ///
  /// A percentage on its own is not actionable. "It takes PHP 400 from food"
  /// is.
  final Money essentialCostInPesos;

  /// True when the spend does not touch the essential envelope at all.
  bool get leavesEssentialsAlone => essentialCostInPesos.isZero;

  double get riskDeltaOwn => riskOwnAfter - riskOwnBefore;
  double get riskDeltaEssential => essentialRiskAfter - essentialRiskBefore;
}

/// Grades a pair of risks into a verdict.
///
/// BUILD_PLAN.md Section 8.7: the verdict is the worst of the two risks, so a
/// spend that is comfortable for the dates envelope but dangerous for food is
/// never called safe.
AffordVerdict verdictFor(double ownRisk, double essentialRisk) {
  final double worst = ownRisk > essentialRisk ? ownRisk : essentialRisk;
  if (worst < safeRiskThreshold) {
    return AffordVerdict.safe;
  }
  if (worst < tightRiskThreshold) {
    return AffordVerdict.tight;
  }
  return AffordVerdict.risky;
}

/// Tests one planned spend against the current forecast.
///
/// [essentialEnvelopeId] is the envelope a shortfall would really hurt, which
/// is the steady one. It is passed in rather than guessed so the caller keeps
/// control of what counts as essential.
AffordabilityAnswer checkAffordability({
  required List<EnvelopePlan> plans,
  required DateTime asOf,
  required String userId,
  required String envelopeId,
  required Money amount,
  required DateTime on,
  String? essentialEnvelopeId,
  int runs = defaultRuns,
}) {
  final EnvelopePlan plan = plans.firstWhere(
    (EnvelopePlan p) => p.id == envelopeId,
    orElse: () => throw ArgumentError.value(
      envelopeId,
      'envelopeId',
      'no such envelope in this forecast',
    ),
  );

  final SimulationResult base = simulateAll(
    plans: plans,
    asOf: asOf,
    userId: userId,
    runs: runs,
  );
  final SimulationResult test = simulateAll(
    plans: plans,
    asOf: asOf,
    userId: userId,
    runs: runs,
    extraSpends: <PlannedSpend>[
      PlannedSpend(envelopeId: envelopeId, amount: amount, on: on),
    ],
  );

  final EnvelopeSimulation baseOwn = base[envelopeId]!;
  final EnvelopeSimulation testOwn = test[envelopeId]!;

  final Money left = plan.envelope.balance - plan.committed.total - amount;

  final Money eventSize = plan.runway.eventSizeMedian;
  final int eventsLeft = eventSize.isPositive && left.isPositive
      ? left.centavos ~/ eventSize.centavos
      : 0;

  final int burn = plan.runway.dailyBurnEwma.centavos;
  final int daysCovered = burn > 0 && left.isPositive
      ? left.centavos ~/ burn
      : 0;

  double essentialBefore = 0;
  double essentialAfter = 0;
  Money essentialCost = Money.zero;

  if (essentialEnvelopeId != null && essentialEnvelopeId != envelopeId) {
    final EnvelopeSimulation? before = base[essentialEnvelopeId];
    final EnvelopeSimulation? after = test[essentialEnvelopeId];
    if (before != null && after != null) {
      essentialBefore = before.pShortfallWithSpill;
      essentialAfter = after.pShortfallWithSpill;
      // The peso cost is the extra money the essential envelope is now
      // expected to lend out. This is the figure the user can act on.
      final Money extra = after.expectedSpill - before.expectedSpill;
      essentialCost = extra.clampToZero();
    }
  }

  return AffordabilityAnswer(
    envelopeId: envelopeId,
    envelopeLabel: plan.envelope.label,
    amount: amount,
    on: on,
    verdict: verdictFor(testOwn.pShortfallOwn, essentialAfter),
    leftInEnvelope: left,
    eventsStillAffordable: eventsLeft,
    daysCovered: daysCovered,
    riskOwnBefore: baseOwn.pShortfallOwn,
    riskOwnAfter: testOwn.pShortfallOwn,
    essentialEnvelopeId: essentialEnvelopeId,
    essentialRiskBefore: essentialBefore,
    essentialRiskAfter: essentialAfter,
    essentialCostInPesos: essentialCost,
  );
}
