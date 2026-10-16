/// The horizon and the deterministic runway.
///
/// BUILD_PLAN.md Sections 8.3 and 8.5. Every number here is plain arithmetic
/// on integers. Section 2: the language model never computes any of it.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/burn_rate.dart';
import 'package:baon/engine/envelope.dart';

/// The default safety floor on a steady envelope, PHP 200.
const Money defaultSteadyFloor = Money(20000);

/// The fallback horizon when nothing else sets one.
const int defaultHorizonDays = 14;

/// Works out how far ahead to forecast.
///
/// BUILD_PLAN.md Section 8.3: the earliest expected income, else the date the
/// user set, else fourteen days out.
DateTime resolveHorizonEnd({
  required DateTime asOf,
  required List<EngineIncome> incomes,
  DateTime? userChosen,
  DateTime? envelopeRefillOn,
}) {
  final DateTime today = dateOnly(asOf);

  if (envelopeRefillOn != null) {
    final DateTime refill = dateOnly(envelopeRefillOn);
    if (refill.isAfter(today)) {
      return refill;
    }
  }

  final List<DateTime> upcoming =
      incomes
          .map((EngineIncome i) => dateOnly(i.nextExpectedOn))
          .where((DateTime d) => d.isAfter(today))
          .toList()
        ..sort();
  if (upcoming.isNotEmpty) {
    return upcoming.first;
  }

  if (userChosen != null && dateOnly(userChosen).isAfter(today)) {
    return dateOnly(userChosen);
  }

  return addDays(today, defaultHorizonDays);
}

/// The money an envelope has already promised away before the horizon.
class CommittedCosts {
  const CommittedCosts({
    required this.obligations,
    required this.commute,
    required this.commuteWeekdays,
    required this.note,
  });

  static const CommittedCosts none = CommittedCosts(
    obligations: Money.zero,
    commute: Money.zero,
    commuteWeekdays: 0,
    note: '',
  );

  /// Obligations that fall due on or before the horizon.
  final Money obligations;

  /// The fixed weekday fare still to be paid.
  final Money commute;
  final int commuteWeekdays;

  /// A short plain-language explanation, for the UI and the explainer prompt.
  final String note;

  Money get total => obligations + commute;
}

/// Adds up what an envelope owes before its horizon.
///
/// Committed money is removed from the random pool entirely. A known fare has
/// no variance, and modelling it as a random spend would invent a risk that
/// does not exist.
CommittedCosts committedFor({
  required EngineEnvelope envelope,
  required List<EngineObligation> obligations,
  required DateTime asOf,
  required DateTime horizonEnd,
}) {
  final DateTime today = dateOnly(asOf);
  final DateTime end = dateOnly(horizonEnd);
  final Set<String> keys = envelope.categoryKeys.toSet();

  Money obligationTotal = Money.zero;
  final List<String> parts = <String>[];
  for (final EngineObligation obligation in obligations) {
    if (keys.isNotEmpty && !keys.contains(obligation.categoryKey)) {
      continue;
    }
    final int occurrences = obligation
        .dueDatesBetween(addDays(today, 1), end)
        .length;
    if (occurrences == 0) {
      continue;
    }
    obligationTotal += obligation.amount * occurrences;
    parts.add(
      occurrences == 1 ? obligation.label : '${obligation.label} x$occurrences',
    );
  }

  int weekdays = 0;
  Money commute = Money.zero;
  if (envelope.commute.isSet) {
    weekdays = weekdaysBetween(addDays(today, 1), end);
    commute = envelope.commute.perWeekday * weekdays;
    if (weekdays > 0) {
      parts.insert(
        0,
        'commute, $weekdays '
        '${weekdays == 1 ? 'weekday' : 'weekdays'} at '
        '${envelope.commute.perWeekday.format(symbol: false)}',
      );
    }
  }

  return CommittedCosts(
    obligations: obligationTotal,
    commute: commute,
    commuteWeekdays: weekdays,
    note: parts.join(', '),
  );
}

/// The straight-line answer for one envelope, before any simulation.
class DeterministicRunway {
  const DeterministicRunway({
    required this.envelopeId,
    required this.shape,
    required this.balance,
    required this.committed,
    required this.safetyFloor,
    required this.usable,
    required this.daysLeft,
    required this.dailyBurnEwma,
    required this.dailyBurnMedian,
    required this.safeDaily,
    required this.runwayDays,
    required this.eventsAffordable,
    required this.eventSizeMedian,
    required this.eventRatePerWeek,
  });

  final String envelopeId;
  final EnvelopeShape shape;
  final Money balance;
  final CommittedCosts committed;
  final Money safetyFloor;

  /// `balance - committed - safety_floor`. What is genuinely free to spend.
  final Money usable;

  /// Whole days from today to the horizon.
  final int daysLeft;

  final Money dailyBurnEwma;
  final Money dailyBurnMedian;

  /// What the user may spend each day to reach the horizon exactly.
  final Money safeDaily;

  /// How many days the usable money lasts at the current rate.
  final double runwayDays;

  /// For an episodic envelope: how many more events fit.
  ///
  /// "You can afford 1 more date this week" is the answer the user wants.
  final int eventsAffordable;
  final Money eventSizeMedian;
  final double eventRatePerWeek;

  /// True when the money runs out before the horizon.
  bool get runsShort => shape == EnvelopeShape.steady
      ? runwayDays < daysLeft
      : eventsAffordable <= 0;
}

/// Computes the straight-line runway for one envelope.
///
/// BUILD_PLAN.md Section 8.5. A steady envelope reports days; an episodic one
/// reports events. A reserve reports neither, because a savings balance is not
/// a runway.
DeterministicRunway computeRunway({
  required EngineEnvelope envelope,
  required DateTime asOf,
  required DateTime horizonEnd,
  required CommittedCosts committed,
  SteadyBurn steady = SteadyBurn.empty,
  EpisodicBurn episodic = EpisodicBurn.empty,
}) {
  final int daysLeft = daysBetween(asOf, horizonEnd);

  if (envelope.isReserve) {
    return DeterministicRunway(
      envelopeId: envelope.id,
      shape: envelope.shape,
      balance: envelope.balance,
      committed: CommittedCosts.none,
      safetyFloor: Money.zero,
      usable: envelope.balance,
      daysLeft: daysLeft,
      dailyBurnEwma: Money.zero,
      dailyBurnMedian: Money.zero,
      safeDaily: Money.zero,
      runwayDays: 0,
      eventsAffordable: 0,
      eventSizeMedian: Money.zero,
      eventRatePerWeek: 0,
    );
  }

  final Money usable =
      envelope.balance - committed.total - envelope.safetyFloor;

  if (envelope.shape == EnvelopeShape.episodic) {
    final Money size = episodic.medianSize;
    final int affordable = size.isPositive && usable.isPositive
        ? usable.centavos ~/ size.centavos
        : 0;
    return DeterministicRunway(
      envelopeId: envelope.id,
      shape: envelope.shape,
      balance: envelope.balance,
      committed: committed,
      safetyFloor: envelope.safetyFloor,
      usable: usable,
      daysLeft: daysLeft,
      dailyBurnEwma: Money.zero,
      dailyBurnMedian: Money.zero,
      safeDaily: Money.zero,
      runwayDays: 0,
      eventsAffordable: affordable,
      eventSizeMedian: size,
      eventRatePerWeek: episodic.eventsPerWeek,
    );
  }

  // A burn rate of zero would divide by zero, so it is floored at one centavo
  // exactly as BUILD_PLAN.md Section 8.5 specifies.
  final int burn = steady.ewma.centavos < 1 ? 1 : steady.ewma.centavos;
  final double runwayDays = usable.centavos <= 0 ? 0 : usable.centavos / burn;
  final Money safeDaily = Money(
    usable.clampToZero().centavos ~/ (daysLeft < 1 ? 1 : daysLeft),
  );

  return DeterministicRunway(
    envelopeId: envelope.id,
    shape: envelope.shape,
    balance: envelope.balance,
    committed: committed,
    safetyFloor: envelope.safetyFloor,
    usable: usable,
    daysLeft: daysLeft,
    dailyBurnEwma: steady.ewma,
    dailyBurnMedian: steady.median,
    safeDaily: safeDaily,
    runwayDays: runwayDays,
    eventsAffordable: 0,
    eventSizeMedian: Money.zero,
    eventRatePerWeek: 0,
  );
}
