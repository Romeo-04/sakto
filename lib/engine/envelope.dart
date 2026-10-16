/// The plain inputs the engine works from.
///
/// BUILD_PLAN.md Section 6: `lib/engine/` takes plain Dart objects and returns
/// plain Dart objects. Repositories map database rows into these types, so the
/// engine never touches Drift, a plugin or the disk.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';

/// One movement of money, as the engine reads it.
class EngineTxn {
  const EngineTxn({
    required this.amount,
    required this.direction,
    required this.categoryKey,
    required this.occurredAt,
  });

  /// Always positive.
  final Money amount;
  final TxnDirection direction;
  final String categoryKey;
  final DateTime occurredAt;

  bool get isOutflow => direction == TxnDirection.moneyOut;
}

/// A known future outflow, such as rent share or a subscription.
class EngineObligation {
  const EngineObligation({
    required this.label,
    required this.amount,
    required this.cadence,
    required this.nextDueOn,
    required this.categoryKey,
  });

  final String label;
  final Money amount;
  final Cadence cadence;
  final DateTime nextDueOn;
  final String categoryKey;

  /// Every date this obligation falls due between [from] and [to].
  ///
  /// A weekly obligation inside a two-week horizon is due twice, and the
  /// forecast must reserve money for both.
  List<DateTime> dueDatesBetween(DateTime from, DateTime to) {
    final DateTime start = dateOnly(from);
    final DateTime end = dateOnly(to);
    final List<DateTime> out = <DateTime>[];
    DateTime cursor = dateOnly(nextDueOn);

    switch (cadence) {
      case Cadence.once:
        if (!cursor.isBefore(start) && !cursor.isAfter(end)) {
          out.add(cursor);
        }
      case Cadence.weekly:
        while (cursor.isBefore(start)) {
          cursor = addDays(cursor, 7);
        }
        while (!cursor.isAfter(end)) {
          out.add(cursor);
          cursor = addDays(cursor, 7);
        }
      case Cadence.monthly:
        while (cursor.isBefore(start)) {
          cursor = DateTime(cursor.year, cursor.month + 1, cursor.day);
        }
        while (!cursor.isAfter(end)) {
          out.add(cursor);
          cursor = DateTime(cursor.year, cursor.month + 1, cursor.day);
        }
      case Cadence.none:
        break;
    }
    return out;
  }
}

/// Money the user expects to receive.
class EngineIncome {
  const EngineIncome({
    required this.label,
    required this.amount,
    required this.cadence,
    required this.nextExpectedOn,
    required this.confidence,
  });

  final String label;
  final Money amount;
  final Cadence cadence;
  final DateTime nextExpectedOn;
  final IncomeConfidence confidence;

  /// BUILD_PLAN.md Section 8.6: only certain income is added inside the
  /// simulation. Money the user merely hopes for must never lower a risk
  /// figure.
  bool get countsInSimulation => confidence == IncomeConfidence.certain;
}

/// A fixed cost the user has already committed to.
///
/// BUILD_PLAN.md Section 8.4: a known weekday fare has no variance. Modelling
/// it as a random spend gives a false risk, so it is taken out of the random
/// pool and reserved up front.
class CommuteCost {
  const CommuteCost({required this.perWeekday});

  static const CommuteCost none = CommuteCost(perWeekday: Money.zero);

  /// The fare for one working day, both ways.
  final Money perWeekday;

  bool get isSet => perWeekday.isPositive;

  /// The total still to be spent between [from] and [to], both ends included.
  Money committedBetween(DateTime from, DateTime to) =>
      perWeekday * weekdaysBetween(from, to);
}

/// An envelope and everything the engine needs to forecast it.
class EngineEnvelope {
  const EngineEnvelope({
    required this.id,
    required this.label,
    required this.shape,
    required this.balance,
    required this.refill,
    required this.refillCadence,
    required this.categoryKeys,
    this.allowBorrowFrom = const <String>[],
    this.priority = 5,
    this.safetyFloor = Money.zero,
    this.commute = CommuteCost.none,
    this.nextRefillOn,
  });

  final String id;
  final String label;
  final EnvelopeShape shape;

  /// The money in the envelope right now.
  final Money balance;

  /// How much lands at the next refill.
  final Money refill;
  final Cadence refillCadence;

  /// The categories whose spending comes out of this envelope.
  final List<String> categoryKeys;

  /// Envelopes this one may take from when it runs out.
  final List<String> allowBorrowFrom;

  /// 1 is protected first when money is short.
  final int priority;

  /// The buffer the user never wants to go below. BUILD_PLAN.md Section 8.5
  /// defaults this to PHP 200 on the steady envelope and zero elsewhere.
  final Money safetyFloor;

  /// The fixed weekday fare, which only the steady envelope carries.
  final CommuteCost commute;

  /// When this envelope refills next. Null means it never does.
  final DateTime? nextRefillOn;

  /// A reserve is tracked, never spent down, and never in a runway.
  bool get isReserve => shape == EnvelopeShape.reserve;

  EngineEnvelope copyWith({Money? balance, Money? safetyFloor}) =>
      EngineEnvelope(
        id: id,
        label: label,
        shape: shape,
        balance: balance ?? this.balance,
        refill: refill,
        refillCadence: refillCadence,
        categoryKeys: categoryKeys,
        allowBorrowFrom: allowBorrowFrom,
        priority: priority,
        safetyFloor: safetyFloor ?? this.safetyFloor,
        commute: commute,
        nextRefillOn: nextRefillOn,
      );
}

/// Everything the engine needs for one full forecast run.
class EngineInput {
  const EngineInput({
    required this.asOf,
    required this.envelopes,
    required this.txns,
    this.obligations = const <EngineObligation>[],
    this.incomes = const <EngineIncome>[],
    this.accountTotal = Money.zero,
    this.unallocated = Money.zero,
    this.staleAccountLabels = const <String>[],
    this.historyStartedOn,
    this.userId = 'local',
    this.horizonEnd,
  });

  /// The calendar day the forecast is made for. Local, no time part.
  final DateTime asOf;
  final List<EngineEnvelope> envelopes;

  /// Spending history, already filtered to what the engine may see.
  final List<EngineTxn> txns;
  final List<EngineObligation> obligations;
  final List<EngineIncome> incomes;
  final Money accountTotal;
  final Money unallocated;

  /// Accounts whose balance is older than 72 hours.
  final List<String> staleAccountLabels;

  /// The first day any balance was recorded. Drives data quality.
  final DateTime? historyStartedOn;

  /// Seeds the simulation, so the same user gets the same answer on a day.
  final String userId;

  /// An explicit horizon the user chose, which overrides the default.
  final DateTime? horizonEnd;

  /// How many days of history exist.
  int get historyDays =>
      historyStartedOn == null ? 0 : daysBetween(historyStartedOn!, asOf) + 1;

  /// BUILD_PLAN.md Section 8.8: quality is low under seven days of history.
  DataQuality get dataQuality =>
      historyDays < 7 ? DataQuality.low : DataQuality.good;
}
