import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// An envelope together with the money currently in it and the categories it
/// pays for.
class EnvelopeWithState {
  const EnvelopeWithState({
    required this.envelope,
    required this.balance,
    required this.periodStart,
    required this.categoryKeys,
  });

  final EnvelopeRow envelope;
  final Money balance;
  final DateTime periodStart;
  final List<String> categoryKeys;

  String get id => envelope.id;
  String get label => envelope.label;
  EnvelopeShape get shape => envelope.shape;
}

/// How the account total compares with the money the envelopes claim.
///
/// BUILD_PLAN.md Section 8.2. The invariant is that [unallocated] is never
/// negative. When it is, the user has spent money no envelope covers, and the
/// dashboard must say so rather than hide it.
class EnvelopeTotals {
  const EnvelopeTotals({
    required this.accountTotal,
    required this.envelopeTotal,
  });

  final Money accountTotal;
  final Money envelopeTotal;

  Money get unallocated => accountTotal - envelopeTotal;

  /// True while the books balance. False means "Fix your envelopes".
  bool get invariantHolds => !unallocated.isNegative;

  /// How much the envelopes over-claim. Zero while the invariant holds.
  Money get overAllocated => unallocated.isNegative ? -unallocated : Money.zero;
}

/// Reads and writes envelopes, the purposes money is put to.
class EnvelopeRepository {
  EnvelopeRepository(this._db, this._clock, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final BaonDatabase _db;
  final Clock _clock;
  final Uuid _uuid;

  Future<List<EnvelopeRow>> activeEnvelopes() {
    return (_db.select(_db.envelopes)
          ..where(($EnvelopesTable t) => t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$EnvelopesTable>>[
            ($EnvelopesTable t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .get();
  }

  /// Every envelope with its current money and its category routes.
  Future<List<EnvelopeWithState>> envelopesWithState() async {
    final List<EnvelopeRow> envelopes = await activeEnvelopes();
    final List<EnvelopeWithState> out = <EnvelopeWithState>[];
    for (final EnvelopeRow envelope in envelopes) {
      final AllocationRow? allocation = await currentAllocation(envelope.id);
      final List<String> keys = await categoryKeysFor(envelope.id);
      out.add(
        EnvelopeWithState(
          envelope: envelope,
          balance: allocation?.balanceCents ?? Money.zero,
          periodStart: allocation?.periodStart ?? _clock.today(),
          categoryKeys: keys,
        ),
      );
    }
    return out;
  }

  Stream<List<EnvelopeWithState>> watchEnvelopesWithState() {
    return _db
        .select(_db.envelopes)
        .watch()
        .asyncMap((List<EnvelopeRow> _) => envelopesWithState());
  }

  Future<AllocationRow?> currentAllocation(String envelopeId) {
    return (_db.select(_db.allocations)
          ..where(($AllocationsTable t) => t.envelopeId.equals(envelopeId))
          ..orderBy(<OrderClauseGenerator<$AllocationsTable>>[
            ($AllocationsTable t) => OrderingTerm.desc(t.periodStart),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<String>> categoryKeysFor(String envelopeId) async {
    final List<EnvelopeCategoryRow> rows =
        await (_db.select(_db.envelopeCategories)..where(
              ($EnvelopeCategoriesTable t) => t.envelopeId.equals(envelopeId),
            ))
            .get();
    return rows.map((EnvelopeCategoryRow r) => r.categoryKey).toList();
  }

  /// Creates an envelope and opens its first allocation period.
  ///
  /// [openingBalance] is the money already set aside for this purpose. It is
  /// what the user has, not what the envelope refills to.
  Future<String> create({
    required String label,
    required EnvelopeShape shape,
    required Money refill,
    required Cadence refillCadence,
    required String refillAnchor,
    Money openingBalance = Money.zero,
    List<String> categoryKeys = const <String>[],
    List<String> allowBorrowFrom = const <String>[],
    int priority = 5,
    int? sortOrder,
  }) async {
    final String id = 'env_${_uuid.v4()}';
    final DateTime now = _clock.nowUtc();
    final int order = sortOrder ?? (await activeEnvelopes()).length * 10;

    await _db.transaction(() async {
      await _db
          .into(_db.envelopes)
          .insert(
            EnvelopesCompanion.insert(
              id: id,
              label: label,
              shape: shape,
              refillCents: refill,
              refillCadence: refillCadence,
              refillAnchor: refillAnchor,
              allowBorrowFrom: Value<List<String>>(allowBorrowFrom),
              priority: priority,
              sortOrder: order,
              updatedAt: now,
            ),
          );
      await _db
          .into(_db.allocations)
          .insert(
            AllocationsCompanion.insert(
              id: 'alloc_${_uuid.v4()}',
              envelopeId: id,
              balanceCents: openingBalance,
              periodStart: _clock.today(),
              updatedAt: now,
            ),
          );
      for (final String key in categoryKeys) {
        await _db
            .into(_db.envelopeCategories)
            .insert(
              EnvelopeCategoriesCompanion.insert(
                envelopeId: id,
                categoryKey: key,
              ),
            );
      }
    });
    return id;
  }

  /// Replaces the set of categories that route to an envelope.
  Future<void> setCategories(
    String envelopeId,
    List<String> categoryKeys,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(_db.envelopeCategories)..where(
            ($EnvelopeCategoriesTable t) => t.envelopeId.equals(envelopeId),
          ))
          .go();
      for (final String key in categoryKeys) {
        await _db
            .into(_db.envelopeCategories)
            .insert(
              EnvelopeCategoriesCompanion.insert(
                envelopeId: envelopeId,
                categoryKey: key,
              ),
            );
      }
    });
  }

  /// Moves an envelope balance to an exact figure.
  Future<void> setBalance(String envelopeId, Money balance) async {
    final AllocationRow? allocation = await currentAllocation(envelopeId);
    final DateTime now = _clock.nowUtc();
    if (allocation == null) {
      await _db
          .into(_db.allocations)
          .insert(
            AllocationsCompanion.insert(
              id: 'alloc_${_uuid.v4()}',
              envelopeId: envelopeId,
              balanceCents: balance,
              periodStart: _clock.today(),
              updatedAt: now,
            ),
          );
      return;
    }
    await (_db.update(
      _db.allocations,
    )..where(($AllocationsTable t) => t.id.equals(allocation.id))).write(
      AllocationsCompanion(
        balanceCents: Value<Money>(balance),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  /// Adds to or takes from an envelope balance.
  Future<void> adjustBalance(String envelopeId, Money delta) async {
    final AllocationRow? allocation = await currentAllocation(envelopeId);
    final Money current = allocation?.balanceCents ?? Money.zero;
    await setBalance(envelopeId, current + delta);
  }

  /// Which envelope pays for a category, or null when nothing routes it.
  Future<String?> envelopeForCategory(String categoryKey) async {
    final EnvelopeCategoryRow? row =
        await (_db.select(_db.envelopeCategories)..where(
              ($EnvelopeCategoriesTable t) => t.categoryKey.equals(categoryKey),
            ))
            .getSingleOrNull();
    return row?.envelopeId;
  }

  /// The sum of every envelope balance.
  Future<Money> envelopeTotal() async {
    final List<EnvelopeWithState> envelopes = await envelopesWithState();
    return Money.sum(envelopes.map((EnvelopeWithState e) => e.balance));
  }

  /// Compares the account total against the envelope total.
  ///
  /// The caller passes [accountTotal] because accounts and envelopes are
  /// separate ideas and this repository must not reach across to accounts.
  Future<EnvelopeTotals> totals(Money accountTotal) async {
    return EnvelopeTotals(
      accountTotal: accountTotal,
      envelopeTotal: await envelopeTotal(),
    );
  }

  /// Records one envelope covering another. BUILD_PLAN.md Section 8.6.
  Future<String> recordBorrow({
    required String fromEnvelopeId,
    required String toEnvelopeId,
    required Money amount,
  }) async {
    final String id = 'brw_${_uuid.v4()}';
    await _db.transaction(() async {
      await _db
          .into(_db.borrowEvents)
          .insert(
            BorrowEventsCompanion.insert(
              id: id,
              fromEnvelopeId: fromEnvelopeId,
              toEnvelopeId: toEnvelopeId,
              amountCents: amount,
              occurredAt: _clock.nowUtc(),
            ),
          );
      await adjustBalance(fromEnvelopeId, -amount);
      await adjustBalance(toEnvelopeId, amount);
    });
    return id;
  }

  Future<void> softDelete(String envelopeId) async {
    final DateTime now = _clock.nowUtc();
    await (_db.update(
      _db.envelopes,
    )..where(($EnvelopesTable t) => t.id.equals(envelopeId))).write(
      EnvelopesCompanion(
        deletedAt: Value<DateTime>(now),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }
}
