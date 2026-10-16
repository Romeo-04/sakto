/// Burn-rate estimators. One method for each envelope shape.
///
/// BUILD_PLAN.md Section 8.4. A daily average is right for food and wrong for
/// dates. A user does not spend PHP 143 a day on dates; they spend PHP 1,000
/// twice a month and nothing on the other days. Using one estimator for both
/// produces a number that is never true on any actual day.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

import 'dart:math' as math;

import 'package:baon/core/clock.dart';
import 'package:baon/core/money.dart';
import 'package:baon/engine/envelope.dart';

/// The default lookback for a burn-rate estimate.
const int defaultLookbackDays = 28;

/// Below this much history the estimate is marked low quality.
///
/// BUILD_PLAN.md Section 8.4 calls seven days the minimum, and Section 8.8
/// sets `data_quality` to low under seven days. They are the same threshold.
const int minimumLookbackDays = 7;

/// The EWMA smoothing factor from BUILD_PLAN.md Section 8.4.
const double ewmaAlpha = 0.35;

/// The total that left an envelope on one calendar day.
class DailyOutflow {
  const DailyOutflow({required this.date, required this.amount});

  final DateTime date;
  final Money amount;

  int get weekday => date.weekday;
}

/// A steady envelope's spending shape. Food and transport.
class SteadyBurn {
  const SteadyBurn({
    required this.mean,
    required this.ewma,
    required this.median,
    required this.dayOfWeekPool,
    required this.globalPool,
    required this.observedDays,
    required this.dailyTotals,
  });

  /// `sum(outflow) / window_days`, counting days with no spending.
  final Money mean;

  /// The exponentially weighted average. Reacts faster to a recent change.
  final Money ewma;

  /// The middle day. Unmoved by one unusual day.
  final Money median;

  /// Daily totals grouped by weekday, 1 for Monday to 7 for Sunday.
  ///
  /// This matters. A weekday costs more than a weekend when the user commutes
  /// five days a week, and a flat average hides that gap.
  final Map<int, List<Money>> dayOfWeekPool;

  /// Every daily total, used when a weekday has too few observations.
  final List<Money> globalPool;

  /// How many days the window actually covered.
  final int observedDays;

  /// The per-day totals, oldest first.
  final List<DailyOutflow> dailyTotals;

  bool get hasHistory => observedDays > 0 && globalPool.isNotEmpty;

  /// The pool to draw a day's spending from.
  ///
  /// BUILD_PLAN.md Section 8.6: a weekday pool with fewer than three
  /// observations is too thin to trust, so the global pool is used instead.
  List<Money> poolFor(int weekday) {
    final List<Money> pool = dayOfWeekPool[weekday] ?? const <Money>[];
    return pool.length < 3 ? globalPool : pool;
  }

  static const SteadyBurn empty = SteadyBurn(
    mean: Money.zero,
    ewma: Money.zero,
    median: Money.zero,
    dayOfWeekPool: <int, List<Money>>{},
    globalPool: <Money>[],
    observedDays: 0,
    dailyTotals: <DailyOutflow>[],
  );
}

/// An episodic envelope's spending shape. Dates, gifts, anything lumpy.
///
/// Held as two separate variables, a rate and a size, because reporting
/// "about 2 dates a week, about PHP 900 each" is more useful to the user than
/// "PHP 257 a day", and is the only form that is ever actually true.
class EpisodicBurn {
  const EpisodicBurn({
    required this.eventsPerWeek,
    required this.eventSizes,
    required this.observedDays,
  });

  /// The Poisson mean: events in the window divided by weeks in the window.
  final double eventsPerWeek;

  /// The amount of each event, for resampling.
  final List<Money> eventSizes;

  final int observedDays;

  int get eventCount => eventSizes.length;

  bool get hasHistory => eventSizes.isNotEmpty;

  /// The typical event size. Zero when nothing has happened yet.
  Money get medianSize => _median(eventSizes);

  Money get meanSize => eventSizes.isEmpty
      ? Money.zero
      : Money(Money.sum(eventSizes).centavos ~/ eventSizes.length);

  Money get largestSize =>
      eventSizes.isEmpty ? Money.zero : eventSizes.reduce(Money.max);

  static const EpisodicBurn empty = EpisodicBurn(
    eventsPerWeek: 0,
    eventSizes: <Money>[],
    observedDays: 0,
  );
}

/// Sums outflow by calendar day, over the lookback window.
///
/// Days with no spending are included as zero. Leaving them out would divide
/// by the number of spending days and inflate every rate.
///
/// The divisor is the history actually available, capped at [lookbackDays].
/// Dividing a short history by a fixed seven days would understate the burn
/// rate, and understating it tells the user they are safer than they are.
/// Thin history is instead reported through `data_quality`.
List<DailyOutflow> dailyOutflows({
  required List<EngineTxn> txns,
  required DateTime asOf,
  required Set<String> categoryKeys,
  required Set<String> excludedCategories,
  DateTime? historyStartedOn,
  int lookbackDays = defaultLookbackDays,
}) {
  final DateTime today = dateOnly(asOf);
  final DateTime earliestPossible = addDays(today, -(lookbackDays - 1));
  final DateTime windowStart =
      historyStartedOn != null &&
          dateOnly(historyStartedOn).isAfter(earliestPossible)
      ? dateOnly(historyStartedOn)
      : earliestPossible;

  final Map<DateTime, Money> byDay = <DateTime, Money>{};
  for (final DateTime day in daysInclusive(windowStart, today)) {
    byDay[day] = Money.zero;
  }

  for (final EngineTxn txn in txns) {
    if (!txn.isOutflow) {
      continue;
    }
    if (excludedCategories.contains(txn.categoryKey)) {
      continue;
    }
    if (categoryKeys.isNotEmpty && !categoryKeys.contains(txn.categoryKey)) {
      continue;
    }
    final DateTime day = dateOnly(txn.occurredAt);
    if (!byDay.containsKey(day)) {
      continue;
    }
    byDay[day] = byDay[day]! + txn.amount;
  }

  final List<DateTime> days = byDay.keys.toList()..sort();
  return days
      .map((DateTime d) => DailyOutflow(date: d, amount: byDay[d]!))
      .toList(growable: false);
}

/// Estimates the spending shape of a steady envelope.
SteadyBurn estimateSteadyBurn({
  required List<EngineTxn> txns,
  required DateTime asOf,
  required Set<String> categoryKeys,
  Set<String> excludedCategories = const <String>{},
  DateTime? historyStartedOn,
  int lookbackDays = defaultLookbackDays,
}) {
  final List<DailyOutflow> totals = dailyOutflows(
    txns: txns,
    asOf: asOf,
    categoryKeys: categoryKeys,
    excludedCategories: excludedCategories,
    historyStartedOn: historyStartedOn,
    lookbackDays: lookbackDays,
  );
  if (totals.isEmpty) {
    return SteadyBurn.empty;
  }

  final List<Money> amounts = totals
      .map((DailyOutflow d) => d.amount)
      .toList(growable: false);
  final int days = totals.length;

  final Money mean = Money(Money.sum(amounts).centavos ~/ days);

  double smoothed = amounts.first.centavos.toDouble();
  for (int i = 1; i < amounts.length; i++) {
    smoothed = ewmaAlpha * amounts[i].centavos + (1 - ewmaAlpha) * smoothed;
  }

  final Map<int, List<Money>> pool = <int, List<Money>>{};
  for (final DailyOutflow day in totals) {
    pool.putIfAbsent(day.weekday, () => <Money>[]).add(day.amount);
  }

  return SteadyBurn(
    mean: mean,
    ewma: Money(smoothed.round()),
    median: _median(amounts),
    dayOfWeekPool: Map<int, List<Money>>.unmodifiable(pool),
    globalPool: List<Money>.unmodifiable(amounts),
    observedDays: days,
    dailyTotals: totals,
  );
}

/// Estimates the spending shape of an episodic envelope.
///
/// One event is one calendar day on which the envelope was used. Two taps at
/// the same dinner are one date, not two, so same-day spending is grouped.
EpisodicBurn estimateEpisodicBurn({
  required List<EngineTxn> txns,
  required DateTime asOf,
  required Set<String> categoryKeys,
  Set<String> excludedCategories = const <String>{},
  DateTime? historyStartedOn,
  int lookbackDays = defaultLookbackDays,
}) {
  final List<DailyOutflow> totals = dailyOutflows(
    txns: txns,
    asOf: asOf,
    categoryKeys: categoryKeys,
    excludedCategories: excludedCategories,
    historyStartedOn: historyStartedOn,
    lookbackDays: lookbackDays,
  );
  if (totals.isEmpty) {
    return EpisodicBurn.empty;
  }

  final List<Money> events = totals
      .where((DailyOutflow d) => d.amount.isPositive)
      .map((DailyOutflow d) => d.amount)
      .toList(growable: false);

  final double weeks = totals.length / 7.0;
  final double rate = weeks <= 0 ? 0 : events.length / weeks;

  return EpisodicBurn(
    eventsPerWeek: rate,
    eventSizes: List<Money>.unmodifiable(events),
    observedDays: totals.length,
  );
}

Money _median(List<Money> values) {
  if (values.isEmpty) {
    return Money.zero;
  }
  final List<Money> sorted = List<Money>.of(values)..sort();
  final int mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) {
    return sorted[mid];
  }
  return Money((sorted[mid - 1].centavos + sorted[mid].centavos) ~/ 2);
}

/// The value at a percentile, from 0 to 100, using linear interpolation.
Money percentile(List<Money> values, double p) {
  if (values.isEmpty) {
    return Money.zero;
  }
  final List<Money> sorted = List<Money>.of(values)..sort();
  if (sorted.length == 1) {
    return sorted.first;
  }
  final double rank = (p / 100) * (sorted.length - 1);
  final int low = rank.floor();
  final int high = rank.ceil();
  if (low == high) {
    return sorted[low];
  }
  final double weight = rank - low;
  final double value =
      sorted[low].centavos * (1 - weight) + sorted[high].centavos * weight;
  return Money(value.round());
}

/// Draws a count from a Poisson distribution with mean [lambda].
///
/// Knuth's method. Fine for the small means this app uses, where lambda is a
/// fraction of an event per day.
int poissonSample(math.Random random, double lambda) {
  if (lambda <= 0) {
    return 0;
  }
  if (lambda > 30) {
    // Guards against the loop below running for a very long time. A rate this
    // high is not a real spending pattern, but a corrupt input must not hang
    // the app.
    return lambda.round();
  }
  final double limit = math.exp(-lambda);
  int count = 0;
  double product = random.nextDouble();
  while (product > limit) {
    count++;
    product *= random.nextDouble();
  }
  return count;
}
