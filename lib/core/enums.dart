/// Closed vocabularies shared by the database, the engine and the UI.
///
/// Each enum carries the exact `wireName` string that BUILD_PLAN.md Section 7
/// stores in SQLite. Never persist `Enum.name` directly; go through
/// [wireName] and [fromWire] so a rename in Dart cannot corrupt stored rows.
///
/// Pure Dart. No Flutter, no plugins, no I/O.
library;

/// An enum whose values are stored and sent by a fixed string, not by their
/// Dart name. Every enum below implements it.
abstract interface class WireNamed {
  String get wireName;
}

/// What kind of institution holds an account.
enum ProviderKind implements WireNamed {
  ewallet('ewallet'),
  digitalBank('digital_bank'),
  traditionalBank('traditional_bank'),
  cash('cash');

  const ProviderKind(this.wireName);

  @override
  final String wireName;

  static ProviderKind fromWire(String value) => _fromWire(
    ProviderKind.values,
    value,
    (ProviderKind e) => e.wireName,
    'ProviderKind',
  );
}

/// The job an account does for the user.
enum AccountRole implements WireNamed {
  spending('spending'),
  savings('savings'),
  buffer('buffer');

  const AccountRole(this.wireName);

  @override
  final String wireName;

  static AccountRole fromWire(String value) => _fromWire(
    AccountRole.values,
    value,
    (AccountRole e) => e.wireName,
    'AccountRole',
  );
}

/// The shape of spending in an envelope. This picks the burn-rate model.
///
/// BUILD_PLAN.md Section 8.4. A daily average is right for food and wrong for
/// dates, so the shape decides which estimator runs.
enum EnvelopeShape implements WireNamed {
  /// A small amount on most days. Food, transport.
  steady('steady'),

  /// Lumpy events with gaps between them. Dates, gifts.
  episodic('episodic'),

  /// Savings. Tracked, never spent down, never in a runway.
  reserve('reserve');

  const EnvelopeShape(this.wireName);

  @override
  final String wireName;

  static EnvelopeShape fromWire(String value) => _fromWire(
    EnvelopeShape.values,
    value,
    (EnvelopeShape e) => e.wireName,
    'EnvelopeShape',
  );
}

/// Which way money moved.
enum TxnDirection implements WireNamed {
  moneyIn('in'),
  moneyOut('out');

  const TxnDirection(this.wireName);

  @override
  final String wireName;

  static TxnDirection fromWire(String value) => _fromWire(
    TxnDirection.values,
    value,
    (TxnDirection e) => e.wireName,
    'TxnDirection',
  );
}

/// Where a transaction row came from.
enum TxnSource implements WireNamed {
  /// The user typed it.
  manual('manual'),

  /// An Android notification was parsed. v2.
  notification('notification'),

  /// The reconciler derived it from a balance change. Shown as "Unaccounted".
  reconciled('reconciled');

  const TxnSource(this.wireName);

  @override
  final String wireName;

  static TxnSource fromWire(String value) => _fromWire(
    TxnSource.values,
    value,
    (TxnSource e) => e.wireName,
    'TxnSource',
  );
}

/// Where a balance figure came from.
enum SnapshotSource implements WireNamed {
  manual('manual'),
  notification('notification'),
  derived('derived');

  const SnapshotSource(this.wireName);

  @override
  final String wireName;

  static SnapshotSource fromWire(String value) => _fromWire(
    SnapshotSource.values,
    value,
    (SnapshotSource e) => e.wireName,
    'SnapshotSource',
  );
}

/// How often a repeating amount lands.
enum Cadence implements WireNamed {
  once('once'),
  weekly('weekly'),
  monthly('monthly'),

  /// Used by an envelope that never refills, such as a reserve.
  none('none');

  const Cadence(this.wireName);

  @override
  final String wireName;

  static Cadence fromWire(String value) =>
      _fromWire(Cadence.values, value, (Cadence e) => e.wireName, 'Cadence');
}

/// How sure the user is that expected income will arrive.
///
/// BUILD_PLAN.md Section 8.6: only `certain` income is added inside the
/// simulation. Hoped-for money must never lower a risk figure.
enum IncomeConfidence implements WireNamed {
  certain('certain'),
  likely('likely'),
  unsure('unsure');

  const IncomeConfidence(this.wireName);

  @override
  final String wireName;

  static IncomeConfidence fromWire(String value) => _fromWire(
    IncomeConfidence.values,
    value,
    (IncomeConfidence e) => e.wireName,
    'IncomeConfidence',
  );
}

/// How much history the forecast had to work with.
///
/// BUILD_PLAN.md Section 8.8: when quality is low the UI shows a range, not a
/// single number.
enum DataQuality implements WireNamed {
  good('good'),
  low('low');

  const DataQuality(this.wireName);

  @override
  final String wireName;

  static DataQuality fromWire(String value) => _fromWire(
    DataQuality.values,
    value,
    (DataQuality e) => e.wireName,
    'DataQuality',
  );
}

/// The answer to "can I afford this?". BUILD_PLAN.md Section 8.7.
enum AffordVerdict implements WireNamed {
  safe('safe'),
  tight('tight'),
  risky('risky');

  const AffordVerdict(this.wireName);

  @override
  final String wireName;

  static AffordVerdict fromWire(String value) => _fromWire(
    AffordVerdict.values,
    value,
    (AffordVerdict e) => e.wireName,
    'AffordVerdict',
  );
}

T _fromWire<T>(
  List<T> values,
  String value,
  String Function(T) name,
  String label,
) {
  for (final T candidate in values) {
    if (name(candidate) == value) {
      return candidate;
    }
  }
  throw ArgumentError.value(value, label, 'not a known $label');
}
