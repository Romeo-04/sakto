import 'package:baon/core/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('construction', () {
    test('holds centavos exactly', () {
      expect(const Money(123456).centavos, 123456);
      expect(const Money.pesos(20).centavos, 2000);
      expect(Money.zero.centavos, 0);
    });

    test('splits into peso and centavo parts, sign removed', () {
      expect(const Money(123456).wholePesos, 1234);
      expect(const Money(123456).centavoPart, 56);
      expect(const Money(-1234).wholePesos, 12);
      expect(const Money(-1234).centavoPart, 34);
      expect(const Money(5).centavoPart, 5);
    });

    test('reports sign', () {
      expect(Money.zero.isZero, isTrue);
      expect(Money.zero.isNegative, isFalse);
      expect(Money.zero.isPositive, isFalse);
      expect(const Money(1).isPositive, isTrue);
      expect(const Money(1).isZero, isFalse);
      expect(const Money(-1).isNegative, isTrue);
      expect(const Money(-1).isPositive, isFalse);
    });
  });

  group('arithmetic', () {
    test('adds, subtracts and negates', () {
      expect(const Money(500) + const Money(250), const Money(750));
      expect(const Money(500) - const Money(750), const Money(-250));
      expect(-const Money(500), const Money(-500));
      expect(-const Money(-500), const Money(500));
    });

    test('multiplies by a whole factor without rounding', () {
      expect(const Money(15000) * 3, const Money(45000));
      expect(const Money(15000) * 0, Money.zero);
      expect(const Money(15000) * -2, const Money(-30000));
    });

    test('sums an iterable and treats empty as zero', () {
      expect(Money.sum(const <Money>[]), Money.zero);
      expect(
        Money.sum(const <Money>[Money(100), Money(250), Money(-50)]),
        const Money(300),
      );
    });

    test('abs and clampToZero', () {
      expect(const Money(-750).abs(), const Money(750));
      expect(const Money(750).abs(), const Money(750));
      expect(const Money(-750).clampToZero(), Money.zero);
      expect(const Money(750).clampToZero(), const Money(750));
      expect(Money.zero.clampToZero(), Money.zero);
    });
  });

  group('scaled', () {
    test('rounds half away from zero', () {
      expect(const Money(100).scaled(0.5), const Money(50));
      expect(const Money(101).scaled(0.5), const Money(51));
      expect(const Money(-101).scaled(0.5), const Money(-51));
      expect(const Money(100).scaled(0), Money.zero);
      expect(const Money(100).scaled(2), const Money(200));
    });

    test('rejects a non-finite result', () {
      expect(
        () => const Money(100).scaled(double.infinity),
        throwsArgumentError,
      );
      expect(() => const Money(100).scaled(double.nan), throwsArgumentError);
    });
  });

  group('dividedBy', () {
    test('truncates toward zero', () {
      expect(const Money(1000).dividedBy(3), const Money(333));
      expect(const Money(-1000).dividedBy(3), const Money(-333));
      expect(const Money(1000).dividedBy(-3), const Money(-333));
    });

    test('rejects a zero divisor', () {
      expect(() => const Money(1000).dividedBy(0), throwsArgumentError);
    });
  });

  group('allocate', () {
    test('keeps every centavo when the split is uneven', () {
      final List<Money> parts = const Money(1000).allocate(<int>[1, 1, 1]);
      expect(parts, <Money>[
        const Money(334),
        const Money(333),
        const Money(333),
      ]);
      expect(Money.sum(parts), const Money(1000));
    });

    test('honours weights', () {
      final List<Money> parts = const Money(10000).allocate(<int>[3, 1]);
      expect(parts, <Money>[const Money(7500), const Money(2500)]);
    });

    test('ignores a zero-weight part but keeps the total', () {
      final List<Money> parts = const Money(1000).allocate(<int>[1, 0]);
      expect(parts, <Money>[const Money(1000), Money.zero]);
    });

    test('splits a negative amount and still balances', () {
      final List<Money> parts = const Money(-1000).allocate(<int>[1, 1, 1]);
      expect(Money.sum(parts), const Money(-1000));
      expect(parts.every((Money m) => m.isNegative), isTrue);
    });

    test('splits zero', () {
      expect(Money.zero.allocate(<int>[1, 2]), <Money>[Money.zero, Money.zero]);
    });

    test('rejects bad ratios', () {
      expect(() => const Money(100).allocate(<int>[]), throwsArgumentError);
      expect(
        () => const Money(100).allocate(<int>[1, -1]),
        throwsArgumentError,
      );
      expect(() => const Money(100).allocate(<int>[0, 0]), throwsArgumentError);
    });
  });

  group('comparison', () {
    test('orders amounts', () {
      expect(const Money(100) < const Money(200), isTrue);
      expect(const Money(200) < const Money(100), isFalse);
      expect(const Money(100) <= const Money(100), isTrue);
      expect(const Money(101) <= const Money(100), isFalse);
      expect(const Money(200) > const Money(100), isTrue);
      expect(const Money(100) > const Money(200), isFalse);
      expect(const Money(100) >= const Money(100), isTrue);
      expect(const Money(99) >= const Money(100), isFalse);
      expect(const Money(100).compareTo(const Money(200)), lessThan(0));
    });

    test('min and max', () {
      expect(Money.min(const Money(100), const Money(200)), const Money(100));
      expect(Money.min(const Money(200), const Money(100)), const Money(100));
      expect(Money.max(const Money(100), const Money(200)), const Money(200));
      expect(Money.max(const Money(200), const Money(100)), const Money(200));
    });

    test('equality and hashCode follow the centavo value', () {
      expect(const Money(100), const Money(100));
      expect(const Money(100) == const Money(101), isFalse);
      expect(const Money(100).hashCode, const Money(100).hashCode);
    });

    test('sorts a list', () {
      final List<Money> list = <Money>[
        const Money(300),
        const Money(-100),
        const Money(100),
      ]..sort();
      expect(list, <Money>[
        const Money(-100),
        const Money(100),
        const Money(300),
      ]);
    });
  });

  group('tryParse', () {
    test('reads plain and grouped amounts', () {
      expect(Money.tryParse('1234.56'), const Money(123456));
      expect(Money.tryParse('1,234.56'), const Money(123456));
      expect(Money.tryParse('  20  '), const Money(2000));
      expect(Money.tryParse('20.5'), const Money(2050));
      expect(Money.tryParse('.5'), const Money(50));
      expect(Money.tryParse('20.'), const Money(2000));
    });

    test('reads a currency prefix in either form', () {
      expect(Money.tryParse('PHP 1,000'), const Money(100000));
      expect(Money.tryParse('php1000'), const Money(100000));
      expect(Money.tryParse('₱1,000'), const Money(100000));
    });

    test('reads an explicit sign', () {
      expect(Money.tryParse('-50'), const Money(-5000));
      expect(Money.tryParse('+50'), const Money(5000));
      expect(Money.tryParse('PHP -50.25'), const Money(-5025));
    });

    test('rejects text that is not an amount', () {
      expect(Money.tryParse(''), isNull);
      expect(Money.tryParse('   '), isNull);
      expect(Money.tryParse('abc'), isNull);
      expect(Money.tryParse('PHP'), isNull);
      expect(Money.tryParse('-'), isNull);
      expect(Money.tryParse('.'), isNull);
      expect(Money.tryParse('1.2.3'), isNull);
      expect(Money.tryParse('10.999'), isNull, reason: 'never round a typo');
      expect(Money.tryParse('10.-1'), isNull);
      expect(Money.tryParse('1e3'), isNull);
    });
  });

  group('format', () {
    test('groups thousands', () {
      expect(const Money(123456).format(), 'PHP 1,234.56');
      expect(const Money(100000000).format(), 'PHP 1,000,000.00');
      expect(const Money(12345).format(), 'PHP 123.45');
      expect(const Money(5).format(), 'PHP 0.05');
      expect(Money.zero.format(), 'PHP 0.00');
    });

    test('places the sign before the symbol', () {
      expect(const Money(-123456).format(), '-PHP 1,234.56');
    });

    test('drops the symbol on request', () {
      expect(const Money(123456).format(symbol: false), '1,234.56');
    });

    test('rounds when decimals are off', () {
      expect(const Money(123456).format(decimals: false), 'PHP 1,235');
      expect(const Money(123400).format(decimals: false), 'PHP 1,234');
      expect(const Money(-123456).format(decimals: false), '-PHP 1,235');
      expect(const Money(50).format(decimals: false), 'PHP 1');
    });

    test('toString is the default format', () {
      expect(const Money(123456).toString(), 'PHP 1,234.56');
    });
  });
}
