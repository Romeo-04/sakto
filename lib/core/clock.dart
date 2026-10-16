/// The one place the app is allowed to read the wall clock.
///
/// BUILD_PLAN.md Section 16: never call `DateTime.now()` anywhere else. Inject
/// a [Clock]. A forecast that reads the real clock cannot be tested.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

/// A source of the current time.
///
/// Instants are UTC, because every stored timestamp is UTC ISO-8601. Calendar
/// days are local, because a day-of-week spending pool must follow the day the
/// user actually lived. In Manila those two differ by eight hours, so a
/// midnight jeepney fare would land on the wrong weekday if UTC decided the
/// calendar.
abstract interface class Clock {
  /// The current instant, in UTC.
  DateTime nowUtc();

  /// The current local calendar date, at midnight, with no time part.
  DateTime today();
}

/// The real clock. Used everywhere except tests.
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  DateTime today() => dateOnly(DateTime.now());
}

/// A clock frozen at one instant, for tests and for golden fixtures.
final class FixedClock implements Clock {
  /// Freezes the clock. [instant] may be UTC or local; both views stay
  /// consistent with each other.
  FixedClock(DateTime instant) : _instant = instant;

  DateTime _instant;

  /// Moves the frozen clock forward, so a test can step through days.
  void advance(Duration by) => _instant = _instant.add(by);

  /// Jumps the frozen clock to a new instant.
  void set(DateTime instant) => _instant = instant;

  @override
  DateTime nowUtc() => _instant.toUtc();

  @override
  DateTime today() => dateOnly(_instant.toLocal());
}

/// Strips the time part, leaving local midnight on the same calendar day.
DateTime dateOnly(DateTime value) {
  final DateTime local = value.isUtc ? value.toLocal() : value;
  return DateTime(local.year, local.month, local.day);
}

/// The number of whole calendar days from [from] to [to].
///
/// Counts calendar boundaries crossed, not 24-hour blocks, so a daylight or
/// timezone shift never adds or drops a day. A later [from] gives a negative
/// result.
int daysBetween(DateTime from, DateTime to) =>
    dateOnly(to).difference(dateOnly(from)).inDays;

/// The calendar date [days] after [from], at local midnight.
DateTime addDays(DateTime from, int days) {
  final DateTime base = dateOnly(from);
  return DateTime(base.year, base.month, base.day + days);
}

/// Every calendar date from [start] to [end], both ends included.
///
/// Returns an empty list when [end] is before [start].
List<DateTime> daysInclusive(DateTime start, DateTime end) {
  final int span = daysBetween(start, end);
  if (span < 0) {
    return const <DateTime>[];
  }
  return List<DateTime>.generate(span + 1, (int i) => addDays(start, i));
}

/// True when the date falls Monday to Friday. Used for the commute cost, which
/// only applies on a working day.
bool isWeekday(DateTime date) => date.weekday <= DateTime.friday;

/// The number of weekdays from [start] to [end], both ends included.
int weekdaysBetween(DateTime start, DateTime end) =>
    daysInclusive(start, end).where(isWeekday).length;

/// The calendar date midway between two instants, used to place a reconciled
/// transaction when the exact moment of the spend is unknown.
DateTime midpoint(DateTime a, DateTime b) {
  final int micros = (a.microsecondsSinceEpoch + b.microsecondsSinceEpoch) ~/ 2;
  return DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);
}
