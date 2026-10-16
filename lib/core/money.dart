/// Money value type. BUILD_PLAN.md Section 3: money is a 64-bit integer of
/// centavos. Floating point causes rounding errors, so no `double` ever holds a
/// peso amount.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

/// An amount of Philippine pesos, held as whole centavos.
///
/// `Money(123456)` is PHP 1,234.56.
final class Money implements Comparable<Money> {
  /// Builds an amount from whole centavos.
  const Money(this.centavos);

  /// Builds an amount from whole pesos. `Money.pesos(20)` is PHP 20.00.
  const Money.pesos(int pesos) : centavos = pesos * 100;

  /// The additive identity, PHP 0.00.
  static const Money zero = Money(0);

  /// The amount, in whole centavos. Negative values are permitted.
  final int centavos;

  /// The whole-peso part, sign removed. PHP -12.34 gives 12.
  int get wholePesos => centavos.abs() ~/ 100;

  /// The centavo part, sign removed, always 0 to 99.
  int get centavoPart => centavos.abs() % 100;

  bool get isZero => centavos == 0;
  bool get isNegative => centavos < 0;
  bool get isPositive => centavos > 0;

  Money operator +(Money other) => Money(centavos + other.centavos);

  Money operator -(Money other) => Money(centavos - other.centavos);

  Money operator -() => Money(-centavos);

  /// Repeats the amount a whole number of times. Exact, no rounding.
  Money operator *(int factor) => Money(centavos * factor);

  /// Scales the amount by a rate, for example a burn rate over days.
  ///
  /// This is the one place a `double` may touch money. It rounds half away
  /// from zero so that a scaled amount never silently loses a centavo.
  Money scaled(num factor) {
    final double raw = centavos * factor.toDouble();
    if (!raw.isFinite) {
      throw ArgumentError.value(
        factor,
        'factor',
        'scaling gave a non-finite value',
      );
    }
    return Money(raw.abs().round() * (raw.isNegative ? -1 : 1));
  }

  /// Splits the amount into [divisor] parts. The remainder is dropped, so
  /// prefer [allocate] when every centavo must be kept.
  Money dividedBy(int divisor) {
    if (divisor == 0) {
      throw ArgumentError.value(
        divisor,
        'divisor',
        'cannot divide money by zero',
      );
    }
    return Money(centavos ~/ divisor);
  }

  /// Splits the amount across [ratios] without losing or inventing a centavo.
  ///
  /// Uses the largest-remainder method: every part gets its truncated share,
  /// then the leftover centavos go one at a time to the earliest parts. The
  /// returned amounts always sum back to this amount exactly.
  List<Money> allocate(List<int> ratios) {
    if (ratios.isEmpty) {
      throw ArgumentError.value(ratios, 'ratios', 'needs at least one ratio');
    }
    if (ratios.any((int r) => r < 0)) {
      throw ArgumentError.value(ratios, 'ratios', 'ratios cannot be negative');
    }
    final int total = ratios.fold(0, (int a, int b) => a + b);
    if (total == 0) {
      throw ArgumentError.value(ratios, 'ratios', 'ratios cannot all be zero');
    }

    final List<int> shares = <int>[];
    int remainder = centavos;
    for (final int ratio in ratios) {
      final int share = centavos * ratio ~/ total;
      shares.add(share);
      remainder -= share;
    }

    final int step = remainder.isNegative ? -1 : 1;
    int index = 0;
    while (remainder != 0) {
      shares[index] += step;
      remainder -= step;
      index = (index + 1) % shares.length;
    }
    return shares.map(Money.new).toList(growable: false);
  }

  Money abs() => Money(centavos.abs());

  /// The amount, or zero when the amount is negative. Used where a negative
  /// balance must not create negative spending room.
  Money clampToZero() => isNegative ? zero : this;

  bool operator <(Money other) => centavos < other.centavos;
  bool operator <=(Money other) => centavos <= other.centavos;
  bool operator >(Money other) => centavos > other.centavos;
  bool operator >=(Money other) => centavos >= other.centavos;

  @override
  int compareTo(Money other) => centavos.compareTo(other.centavos);

  static Money min(Money a, Money b) => a <= b ? a : b;

  static Money max(Money a, Money b) => a >= b ? a : b;

  /// Adds every amount in [amounts]. An empty list gives [zero].
  static Money sum(Iterable<Money> amounts) =>
      amounts.fold(zero, (Money a, Money b) => a + b);

  /// Reads a user-typed peso amount, for example `1,234.56` or `PHP 20`.
  ///
  /// Returns null when the text is not a valid amount. Three or more decimal
  /// places are rejected rather than rounded, so a typo never becomes money.
  static Money? tryParse(String input) {
    String text = input.trim();
    if (text.isEmpty) {
      return null;
    }
    text = text.replaceAll('\u20B1', '').replaceAll(',', '').trim();
    if (text.toUpperCase().startsWith('PHP')) {
      text = text.substring(3).trim();
    }

    bool negative = false;
    if (text.startsWith('-')) {
      negative = true;
      text = text.substring(1).trim();
    } else if (text.startsWith('+')) {
      text = text.substring(1).trim();
    }
    if (text.isEmpty) {
      return null;
    }

    final List<String> parts = text.split('.');
    if (parts.length > 2) {
      return null;
    }
    final String whole = parts[0].isEmpty ? '0' : parts[0];
    final String fraction = parts.length == 2 ? parts[1] : '';
    if (fraction.length > 2) {
      return null;
    }
    if (parts.length == 2 && parts[0].isEmpty && fraction.isEmpty) {
      return null;
    }

    final int? wholeValue = int.tryParse(whole);
    if (wholeValue == null || wholeValue < 0) {
      return null;
    }
    int fractionValue = 0;
    if (fraction.isNotEmpty) {
      final int? parsed = int.tryParse(fraction);
      if (parsed == null || parsed < 0) {
        return null;
      }
      fractionValue = fraction.length == 1 ? parsed * 10 : parsed;
    }

    final int magnitude = wholeValue * 100 + fractionValue;
    return Money(negative ? -magnitude : magnitude);
  }

  /// Formats the amount for display, for example `PHP 1,234.56`.
  ///
  /// Set [symbol] to false to drop the `PHP` prefix. Set [decimals] to false
  /// for a rounded, compact form used on dense cards.
  String format({bool symbol = true, bool decimals = true}) {
    final String sign = isNegative ? '-' : '';
    final String prefix = symbol ? 'PHP ' : '';
    if (decimals) {
      final String cents = centavoPart.toString().padLeft(2, '0');
      return '$sign$prefix${_group(wholePesos)}.$cents';
    }
    final int rounded = (centavos.abs() + 50) ~/ 100;
    return '$sign$prefix${_group(rounded)}';
  }

  static String _group(int value) {
    final String digits = value.toString();
    if (digits.length <= 3) {
      return digits;
    }
    final StringBuffer out = StringBuffer();
    final int lead = digits.length % 3;
    if (lead > 0) {
      out.write(digits.substring(0, lead));
    }
    for (int i = lead; i < digits.length; i += 3) {
      if (out.isNotEmpty) {
        out.write(',');
      }
      out.write(digits.substring(i, i + 3));
    }
    return out.toString();
  }

  @override
  String toString() => format();

  @override
  bool operator ==(Object other) =>
      other is Money && other.centavos == centavos;

  @override
  int get hashCode => centavos.hashCode;
}
