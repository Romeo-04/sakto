import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:drift/drift.dart';

/// Stores [Money] as the INTEGER centavo column that BUILD_PLAN.md Section 7
/// requires. No peso value ever reaches SQLite as a float.
class MoneyConverter extends TypeConverter<Money, int>
    with JsonTypeConverter<Money, int> {
  const MoneyConverter();

  @override
  Money fromSql(int fromDb) => Money(fromDb);

  @override
  int toSql(Money value) => value.centavos;
}

/// Stores an enum by its `wireName`, the string BUILD_PLAN.md Section 7 and
/// the Supabase schema expect. Drift's `textEnum` would store the Dart
/// `Enum.name` instead (`moneyOut`, not `out`), which a rename in Dart would
/// break and the server would reject.
class WireEnumConverter<T extends WireNamed> extends TypeConverter<T, String> {
  const WireEnumConverter(this._fromWire);

  final T Function(String) _fromWire;

  @override
  T fromSql(String fromDb) => _fromWire(fromDb);

  @override
  String toSql(T value) => value.wireName;
}

/// Stores a list of envelope ids as a JSON array, used by `allow_borrow_from`.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    final String trimmed = fromDb.trim();
    if (trimmed.isEmpty || trimmed == '[]') {
      return const <String>[];
    }
    return trimmed
        .substring(1, trimmed.length - 1)
        .split(',')
        .map((String s) => s.trim().replaceAll('"', ''))
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  @override
  String toSql(List<String> value) =>
      '[${value.map((String s) => '"$s"').join(',')}]';
}

/// The static bank and wallet registry, seeded from `assets/providers.json`.
@DataClassName('ProviderRow')
class Providers extends Table {
  TextColumn get key => text()();
  TextColumn get displayName => text()();
  TextColumn get kind => text().map(
    const WireEnumConverter<ProviderKind>(ProviderKind.fromWire),
  )();
  TextColumn get brandColor => text()();
  TextColumn get logoAsset => text()();

  /// The Android package that sends transaction alerts. Null when the provider
  /// has no app, such as cash.
  TextColumn get notificationPackage => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

/// A place that holds money. GCash, GoTyme, a wallet in a pocket.
@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().withDefault(const Constant<String>('local'))();
  TextColumn get providerKey => text().references(Providers, #key)();
  TextColumn get label => text()();
  TextColumn get role =>
      text().map(const WireEnumConverter<AccountRole>(AccountRole.fromWire))();

  /// False for money the user does not treat as available, such as a bond.
  BoolColumn get includeInSpendable =>
      boolean().withDefault(const Constant<bool>(true))();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant<bool>(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Set when the row is soft deleted, so sync can carry the deletion.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A balance the user typed, with the moment it was true.
@DataClassName('BalanceSnapshotRow')
class BalanceSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();
  IntColumn get balanceCents => integer().map(const MoneyConverter())();
  TextColumn get source => text().map(
    const WireEnumConverter<SnapshotSource>(SnapshotSource.fromWire),
  )();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A spending category. Seeded, then extended by the user.
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get key => text()();
  TextColumn get displayName => text()();

  /// Transport and food are essential. Dates are not. Drives which envelope a
  /// shortfall is allowed to hurt.
  BoolColumn get isEssential => boolean()();
  TextColumn get icon => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

/// One movement of money. Typed, parsed, or derived by the reconciler.
@DataClassName('TxnRow')
class Txns extends Table {
  TextColumn get id => text()();
  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();

  /// Always positive. [direction] carries the sign.
  IntColumn get amountCents => integer().map(const MoneyConverter())();
  TextColumn get direction => text().map(
    const WireEnumConverter<TxnDirection>(TxnDirection.fromWire),
  )();
  TextColumn get categoryKey => text().references(Categories, #key)();

  /// The source text the categorizer reads.
  TextColumn get merchantRaw => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get source =>
      text().map(const WireEnumConverter<TxnSource>(TxnSource.fromWire))();
  RealColumn get categoryConfidence =>
      real().withDefault(const Constant<double>(0))();

  /// 1 marks a row the user relabelled. These rows are the training set.
  BoolColumn get userCorrected =>
      boolean().withDefault(const Constant<bool>(false))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A known future outflow. Rent share, a subscription, a loan payment.
@DataClassName('ObligationRow')
class Obligations extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().withDefault(const Constant<String>('local'))();
  TextColumn get label => text()();
  IntColumn get amountCents => integer().map(const MoneyConverter())();
  TextColumn get cadence =>
      text().map(const WireEnumConverter<Cadence>(Cadence.fromWire))();
  DateTimeColumn get nextDueOn => dateTime()();
  TextColumn get categoryKey => text().references(Categories, #key)();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Money the user expects to receive. An allowance, a stipend, a salary.
@DataClassName('IncomeExpectationRow')
class IncomeExpectations extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().withDefault(const Constant<String>('local'))();
  TextColumn get label => text()();
  IntColumn get amountCents => integer().map(const MoneyConverter())();
  TextColumn get cadence =>
      text().map(const WireEnumConverter<Cadence>(Cadence.fromWire))();
  DateTimeColumn get nextExpectedOn => dateTime()();
  TextColumn get confidence => text().map(
    const WireEnumConverter<IncomeConfidence>(IncomeConfidence.fromWire),
  )();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A purpose for money. An envelope is not a place; accounts are places.
@DataClassName('EnvelopeRow')
class Envelopes extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().withDefault(const Constant<String>('local'))();
  TextColumn get label => text()();
  TextColumn get shape => text().map(
    const WireEnumConverter<EnvelopeShape>(EnvelopeShape.fromWire),
  )();

  /// How much lands at each refill. 200000 is a PHP 2,000 weekly budget.
  IntColumn get refillCents => integer().map(const MoneyConverter())();
  TextColumn get refillCadence =>
      text().map(const WireEnumConverter<Cadence>(Cadence.fromWire))();

  /// A weekday name for a weekly refill, or a day of month for a monthly one.
  TextColumn get refillAnchor => text()();

  /// Envelopes this one may take from when it runs out. Drives the spill rule.
  TextColumn get allowBorrowFrom => text()
      .map(const StringListConverter())
      .withDefault(const Constant<String>('[]'))();

  /// 1 is protected first when money is short.
  IntColumn get priority => integer()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Routes a category to the envelope that pays for it.
@DataClassName('EnvelopeCategoryRow')
class EnvelopeCategories extends Table {
  TextColumn get envelopeId =>
      text().references(Envelopes, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryKey => text().references(Categories, #key)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{
    envelopeId,
    categoryKey,
  };
}

/// How much money is in an envelope right now, for the current period.
@DataClassName('AllocationRow')
class Allocations extends Table {
  TextColumn get id => text()();
  TextColumn get envelopeId =>
      text().references(Envelopes, #id, onDelete: KeyAction.cascade)();
  IntColumn get balanceCents => integer().map(const MoneyConverter())();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A record of one envelope covering another. The spill made visible.
@DataClassName('BorrowEventRow')
class BorrowEvents extends Table {
  TextColumn get id => text()();
  @ReferenceName('lentBorrowEvents')
  TextColumn get fromEnvelopeId =>
      text().references(Envelopes, #id, onDelete: KeyAction.cascade)();

  @ReferenceName('receivedBorrowEvents')
  TextColumn get toEnvelopeId =>
      text().references(Envelopes, #id, onDelete: KeyAction.cascade)();
  IntColumn get amountCents => integer().map(const MoneyConverter())();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get repaidAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A small key and value store for user preferences.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}
