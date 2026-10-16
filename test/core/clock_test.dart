import 'package:baon/core/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FixedClock', () {
    test('stays frozen until moved', () {
      final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 4, 10));
      expect(clock.nowUtc(), DateTime.utc(2026, 9, 4, 10));
      expect(clock.nowUtc(), DateTime.utc(2026, 9, 4, 10));
    });

    test('advances and resets', () {
      final FixedClock clock = FixedClock(DateTime.utc(2026, 9, 4, 10));
      clock.advance(const Duration(days: 2, hours: 3));
      expect(clock.nowUtc(), DateTime.utc(2026, 9, 6, 13));
      clock.set(DateTime.utc(2026, 1, 1));
      expect(clock.nowUtc(), DateTime.utc(2026, 1, 1));
    });

    test('reports the local calendar day with no time part', () {
      final DateTime local = DateTime(2026, 9, 4, 23, 45);
      final FixedClock clock = FixedClock(local);
      expect(clock.today(), DateTime(2026, 9, 4));
      expect(clock.today().hour, 0);
    });

    test('nowUtc is always a UTC instant even from a local input', () {
      final FixedClock clock = FixedClock(DateTime(2026, 9, 4, 12));
      expect(clock.nowUtc().isUtc, isTrue);
    });
  });

  group('SystemClock', () {
    test('today has no time part and matches the local date', () {
      const SystemClock clock = SystemClock();
      final DateTime now = DateTime.now();
      expect(clock.today(), DateTime(now.year, now.month, now.day));
      expect(clock.nowUtc().isUtc, isTrue);
    });
  });

  group('dateOnly', () {
    test('strips the time part', () {
      expect(dateOnly(DateTime(2026, 9, 4, 18, 30, 5)), DateTime(2026, 9, 4));
    });

    test('converts a UTC instant to the local calendar day', () {
      final DateTime utc = DateTime.utc(2026, 9, 4, 18);
      expect(dateOnly(utc), dateOnly(utc.toLocal()));
      expect(dateOnly(utc).isUtc, isFalse);
    });
  });

  group('daysBetween', () {
    test('counts calendar boundaries, not 24-hour blocks', () {
      expect(
        daysBetween(DateTime(2026, 9, 4, 23, 59), DateTime(2026, 9, 5, 0, 1)),
        1,
        reason: 'two minutes apart, but a different day',
      );
      expect(
        daysBetween(DateTime(2026, 9, 4, 0, 1), DateTime(2026, 9, 4, 23, 59)),
        0,
      );
    });

    test('spans months and is negative when reversed', () {
      expect(daysBetween(DateTime(2026, 8, 30), DateTime(2026, 9, 5)), 6);
      expect(daysBetween(DateTime(2026, 9, 5), DateTime(2026, 8, 30)), -6);
      expect(daysBetween(DateTime(2026, 9, 5), DateTime(2026, 9, 5)), 0);
    });

    test('handles a leap day', () {
      expect(daysBetween(DateTime(2028, 2, 28), DateTime(2028, 3, 1)), 2);
    });
  });

  group('addDays', () {
    test('rolls over a month and a year', () {
      expect(addDays(DateTime(2026, 9, 28), 5), DateTime(2026, 10, 3));
      expect(addDays(DateTime(2026, 12, 30), 3), DateTime(2027, 1, 2));
    });

    test('goes backward and drops the time part', () {
      expect(addDays(DateTime(2026, 9, 3, 14, 20), -5), DateTime(2026, 8, 29));
    });
  });

  group('daysInclusive', () {
    test('includes both ends', () {
      final List<DateTime> days = daysInclusive(
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 4),
      );
      expect(days.length, 4);
      expect(days.first, DateTime(2026, 9, 1));
      expect(days.last, DateTime(2026, 9, 4));
    });

    test('gives one day when the ends match', () {
      expect(
        daysInclusive(DateTime(2026, 9, 1), DateTime(2026, 9, 1)).length,
        1,
      );
    });

    test('gives nothing when the end is before the start', () {
      expect(
        daysInclusive(DateTime(2026, 9, 4), DateTime(2026, 9, 1)),
        isEmpty,
      );
    });
  });

  group('weekdays', () {
    test('identifies Monday to Friday', () {
      // 2026-09-04 is a Friday, 2026-09-05 a Saturday, 2026-09-07 a Monday.
      expect(isWeekday(DateTime(2026, 9, 4)), isTrue);
      expect(isWeekday(DateTime(2026, 9, 5)), isFalse);
      expect(isWeekday(DateTime(2026, 9, 6)), isFalse);
      expect(isWeekday(DateTime(2026, 9, 7)), isTrue);
    });

    test('counts weekdays across a full week', () {
      expect(
        weekdaysBetween(DateTime(2026, 9, 7), DateTime(2026, 9, 13)),
        5,
        reason: 'Monday to Sunday holds five working days',
      );
      expect(weekdaysBetween(DateTime(2026, 9, 5), DateTime(2026, 9, 6)), 0);
      expect(weekdaysBetween(DateTime(2026, 9, 8), DateTime(2026, 9, 4)), 0);
    });
  });

  group('midpoint', () {
    test('lands halfway between two instants', () {
      expect(
        midpoint(DateTime.utc(2026, 9, 1), DateTime.utc(2026, 9, 5)),
        DateTime.utc(2026, 9, 3),
      );
    });

    test('is order independent and always UTC', () {
      final DateTime a = DateTime.utc(2026, 9, 1, 6);
      final DateTime b = DateTime.utc(2026, 9, 2, 18);
      expect(midpoint(a, b), midpoint(b, a));
      expect(midpoint(a, b).isUtc, isTrue);
    });

    test('gives the same instant when both ends match', () {
      final DateTime a = DateTime.utc(2026, 9, 1, 6);
      expect(midpoint(a, a), a);
    });
  });
}
