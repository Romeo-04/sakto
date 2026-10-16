/// The engine entry point. Turns an [EngineInput] into the exact object that
/// BUILD_PLAN.md Section 8.8 defines.
///
/// The AI layer receives only this object. Section 2: the language model never
/// computes a number, it only turns this into a sentence.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/burn_rate.dart';
import 'package:baon/engine/envelope.dart';
import 'package:baon/engine/forecast.dart';
import 'package:baon/engine/monte_carlo.dart';

/// Categories that are never counted as spending.
const Set<String> engineExcludedCategories = <String>{
  'transfer_internal',
  'savings_in',
};

/// The forecast for one envelope, as the UI and the explainer read it.
class EnvelopeForecast {
  const EnvelopeForecast({
    required this.id,
    required this.label,
    required this.shape,
    required this.balance,
    required this.refill,
    required this.daysLeft,
    required this.committed,
    required this.committedNote,
    required this.dailyBurnEwma,
    required this.dailyBurnMedian,
    required this.safeDaily,
    required this.runwayDays,
    required this.pShortfallOwn,
    required this.pShortfallWithSpill,
    required this.endBalanceP10,
    required this.endBalanceP50,
    required this.endBalanceP90,
    required this.eventRatePerWeek,
    required this.eventSizeMedian,
    required this.eventsAffordable,
    required this.borrowTarget,
    required this.expectedSpill,
    required this.horizonEnd,
  });

  final String id;
  final String label;
  final EnvelopeShape shape;
  final Money balance;
  final Money refill;
  final int daysLeft;
  final Money committed;
  final String committedNote;

  final Money dailyBurnEwma;
  final Money dailyBurnMedian;
  final Money safeDaily;
  final double runwayDays;

  final double pShortfallOwn;
  final double pShortfallWithSpill;

  final Money endBalanceP10;
  final Money endBalanceP50;
  final Money endBalanceP90;

  final double eventRatePerWeek;
  final Money eventSizeMedian;
  final int eventsAffordable;

  final String? borrowTarget;
  final Money expectedSpill;

  final DateTime horizonEnd;

  bool get isSteady => shape == EnvelopeShape.steady;
  bool get isEpisodic => shape == EnvelopeShape.episodic;
  bool get isReserve => shape == EnvelopeShape.reserve;

  /// The risk the user should be shown: the one including spill.
  double get headlineRisk => pShortfallWithSpill;

  /// Builds the JSON shape from BUILD_PLAN.md Section 8.8.
  ///
  /// A reserve carries only a balance, because a savings envelope has no
  /// runway and no risk.
  Map<String, Object?> toJson() {
    if (isReserve) {
      return <String, Object?>{
        'id': id,
        'label': label,
        'shape': shape.wireName,
        'balance': balance.centavos,
      };
    }
    // Key order follows the sample in Section 8.8, so a reader can compare the
    // two side by side.
    if (isSteady) {
      return <String, Object?>{
        'id': id,
        'label': label,
        'shape': shape.wireName,
        'balance': balance.centavos,
        'refill_cents': refill.centavos,
        'days_left': daysLeft,
        'committed': committed.centavos,
        'committed_note': committedNote,
        'daily_burn_ewma': dailyBurnEwma.centavos,
        'daily_burn_median': dailyBurnMedian.centavos,
        'safe_daily': safeDaily.centavos,
        'runway_days': _round1(runwayDays),
        'p_shortfall_own': _round2(pShortfallOwn),
        'p_shortfall_with_spill': _round2(pShortfallWithSpill),
        'end_balance_p10': endBalanceP10.centavos,
        'end_balance_p50': endBalanceP50.centavos,
        'end_balance_p90': endBalanceP90.centavos,
      };
    }
    return <String, Object?>{
      'id': id,
      'label': label,
      'shape': shape.wireName,
      'balance': balance.centavos,
      'refill_cents': refill.centavos,
      'days_left': daysLeft,
      'event_rate_per_week': _round1(eventRatePerWeek),
      'event_size_median': eventSizeMedian.centavos,
      'events_affordable': eventsAffordable,
      'p_shortfall_own': _round2(pShortfallOwn),
      if (borrowTarget != null) 'borrow_target': borrowTarget,
      if (borrowTarget != null) 'expected_spill': expectedSpill.centavos,
    };
  }
}

/// The single action that would help the user most.
class LargestLever {
  const LargestLever({
    required this.envelopeId,
    required this.action,
    required this.saving,
    required this.essentialRiskAfter,
  });

  final String envelopeId;
  final String action;
  final Money saving;
  final double essentialRiskAfter;

  Map<String, Object?> toJson() => <String, Object?>{
    'envelope_id': envelopeId,
    'action': action,
    'saving': saving.centavos,
    'food_risk_after': _round2(essentialRiskAfter),
  };
}

/// The whole engine output. This is the only thing the AI layer ever sees.
class ForecastResult {
  const ForecastResult({
    required this.asOf,
    required this.accountTotal,
    required this.unallocated,
    required this.envelopes,
    required this.largestLever,
    required this.staleAccounts,
    required this.dataQuality,
    required this.plans,
  });

  final DateTime asOf;
  final Money accountTotal;
  final Money unallocated;
  final List<EnvelopeForecast> envelopes;
  final LargestLever? largestLever;
  final List<String> staleAccounts;
  final DataQuality dataQuality;

  /// The plans behind this result, so an affordability check can reuse them
  /// instead of rebuilding every estimate.
  final List<EnvelopePlan> plans;

  /// True when the invariant in Section 8.2 is broken.
  bool get envelopesNeedFixing => unallocated.isNegative;

  EnvelopeForecast? byId(String id) {
    for (final EnvelopeForecast e in envelopes) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }

  /// The envelope that pays for essentials: the first steady one.
  EnvelopeForecast? get essentialEnvelope {
    for (final EnvelopeForecast e in envelopes) {
      if (e.isSteady) {
        return e;
      }
    }
    return null;
  }

  /// BUILD_PLAN.md Section 8.8 exactly.
  Map<String, Object?> toJson() => <String, Object?>{
    'as_of': _isoDate(asOf),
    'currency': 'PHP',
    'account_total': accountTotal.centavos,
    'unallocated': unallocated.centavos,
    'envelopes': envelopes
        .map((EnvelopeForecast e) => e.toJson())
        .toList(growable: false),
    if (largestLever != null) 'largest_lever': largestLever!.toJson(),
    'stale_accounts': staleAccounts,
    'data_quality': dataQuality.wireName,
  };
}

/// Runs the whole forecast.
///
/// The order matters: estimate the burn rates, work out the horizon and the
/// committed costs, compute the straight-line runway, then simulate. The
/// simulation depends on all of it.
ForecastResult runForecast(EngineInput input, {int runs = defaultRuns}) {
  final DateTime asOf = dateOnly(input.asOf);
  final List<EnvelopePlan> plans = <EnvelopePlan>[];

  for (final EngineEnvelope envelope in input.envelopes) {
    final DateTime horizonEnd = resolveHorizonEnd(
      asOf: asOf,
      incomes: input.incomes,
      userChosen: input.horizonEnd,
      envelopeRefillOn: envelope.nextRefillOn,
    );

    final Set<String> keys = envelope.categoryKeys.toSet();
    final SteadyBurn steady = envelope.shape == EnvelopeShape.steady
        ? estimateSteadyBurn(
            txns: input.txns,
            asOf: asOf,
            categoryKeys: keys,
            excludedCategories: engineExcludedCategories,
            historyStartedOn: input.historyStartedOn,
          )
        : SteadyBurn.empty;

    final EpisodicBurn episodic = envelope.shape == EnvelopeShape.episodic
        ? estimateEpisodicBurn(
            txns: input.txns,
            asOf: asOf,
            categoryKeys: keys,
            excludedCategories: engineExcludedCategories,
            historyStartedOn: input.historyStartedOn,
          )
        : EpisodicBurn.empty;

    final CommittedCosts committed = committedFor(
      envelope: envelope,
      obligations: input.obligations,
      asOf: asOf,
      horizonEnd: horizonEnd,
    );

    final DeterministicRunway runway = computeRunway(
      envelope: envelope,
      asOf: asOf,
      horizonEnd: horizonEnd,
      committed: committed,
      steady: steady,
      episodic: episodic,
    );

    plans.add(
      EnvelopePlan(
        envelope: envelope,
        horizonEnd: horizonEnd,
        committed: committed,
        runway: runway,
        steady: steady,
        episodic: episodic,
        obligationsByDay: _obligationsByDay(
          envelope: envelope,
          obligations: input.obligations,
          asOf: asOf,
          horizonEnd: horizonEnd,
        ),
        incomeByDay: _incomeByDay(
          envelope: envelope,
          incomes: input.incomes,
          asOf: asOf,
          horizonEnd: horizonEnd,
        ),
      ),
    );
  }

  final SimulationResult simulation = simulateAll(
    plans: plans,
    asOf: asOf,
    userId: input.userId,
    runs: runs,
  );

  final List<EnvelopeForecast> forecasts = <EnvelopeForecast>[];
  for (final EnvelopePlan plan in plans) {
    final EnvelopeSimulation sim = simulation[plan.id]!;
    final EngineEnvelope envelope = plan.envelope;
    forecasts.add(
      EnvelopeForecast(
        id: envelope.id,
        label: envelope.label,
        shape: envelope.shape,
        balance: envelope.balance,
        refill: envelope.refill,
        daysLeft: plan.runway.daysLeft,
        committed: plan.committed.total,
        committedNote: plan.committed.note,
        dailyBurnEwma: plan.runway.dailyBurnEwma,
        dailyBurnMedian: plan.runway.dailyBurnMedian,
        safeDaily: plan.runway.safeDaily,
        runwayDays: plan.runway.runwayDays,
        pShortfallOwn: sim.pShortfallOwn,
        pShortfallWithSpill: sim.pShortfallWithSpill,
        endBalanceP10: sim.endBalanceP10,
        endBalanceP50: sim.endBalanceP50,
        endBalanceP90: sim.endBalanceP90,
        eventRatePerWeek: plan.runway.eventRatePerWeek,
        eventSizeMedian: plan.runway.eventSizeMedian,
        eventsAffordable: plan.runway.eventsAffordable,
        borrowTarget: envelope.allowBorrowFrom.isEmpty
            ? null
            : envelope.allowBorrowFrom.first,
        expectedSpill: sim.expectedSpill,
        horizonEnd: plan.horizonEnd,
      ),
    );
  }

  return ForecastResult(
    asOf: asOf,
    accountTotal: input.accountTotal,
    unallocated: input.unallocated,
    envelopes: forecasts,
    largestLever: _largestLever(forecasts),
    staleAccounts: input.staleAccountLabels,
    dataQuality: input.dataQuality,
    plans: plans,
  );
}

/// Picks the one action that would help most.
///
/// The lever is always "one fewer event", because that is a thing the user can
/// actually decide to do. Telling somebody to spend less on food each day is
/// not an action.
LargestLever? _largestLever(List<EnvelopeForecast> forecasts) {
  EnvelopeForecast? worst;
  for (final EnvelopeForecast e in forecasts) {
    if (!e.isEpisodic || e.eventSizeMedian.isZero) {
      continue;
    }
    if (worst == null || e.expectedSpill > worst.expectedSpill) {
      worst = e;
    }
  }
  if (worst == null) {
    return null;
  }

  EnvelopeForecast? essential;
  for (final EnvelopeForecast e in forecasts) {
    if (e.isSteady) {
      essential = e;
      break;
    }
  }

  return LargestLever(
    envelopeId: worst.id,
    action: 'one fewer event this period',
    saving: worst.eventSizeMedian,
    essentialRiskAfter: essential?.pShortfallOwn ?? 0,
  );
}

Map<DateTime, Money> _obligationsByDay({
  required EngineEnvelope envelope,
  required List<EngineObligation> obligations,
  required DateTime asOf,
  required DateTime horizonEnd,
}) {
  final Set<String> keys = envelope.categoryKeys.toSet();
  final Map<DateTime, Money> out = <DateTime, Money>{};
  for (final EngineObligation obligation in obligations) {
    if (keys.isNotEmpty && !keys.contains(obligation.categoryKey)) {
      continue;
    }
    for (final DateTime due in obligation.dueDatesBetween(
      addDays(asOf, 1),
      horizonEnd,
    )) {
      out[due] = (out[due] ?? Money.zero) + obligation.amount;
    }
  }
  return out;
}

/// Only a refill the user is certain of is added inside the simulation.
///
/// BUILD_PLAN.md Section 8.6. Counting hoped-for money would quietly lower
/// every risk figure, which is the one direction a money app must not err in.
Map<DateTime, Money> _incomeByDay({
  required EngineEnvelope envelope,
  required List<EngineIncome> incomes,
  required DateTime asOf,
  required DateTime horizonEnd,
}) {
  final Map<DateTime, Money> out = <DateTime, Money>{};
  if (envelope.isReserve) {
    return out;
  }
  for (final EngineIncome income in incomes) {
    if (!income.countsInSimulation) {
      continue;
    }
    final DateTime day = dateOnly(income.nextExpectedOn);
    if (day.isAfter(asOf) && !day.isAfter(dateOnly(horizonEnd))) {
      out[day] = (out[day] ?? Money.zero) + income.amount;
    }
  }
  return out;
}

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

double _round1(double value) => (value * 10).round() / 10;

double _round2(double value) => (value * 100).round() / 100;
