import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/data/db/seed.dart';
import 'package:baon/data/repositories/envelope_repository.dart';
import 'package:baon/engine/reconciler.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Reads and writes transactions, and keeps envelope balances in step with
/// them.
class TxnRepository {
  TxnRepository(this._db, this._clock, this._envelopes, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final BaonDatabase _db;
  final Clock _clock;
  final EnvelopeRepository _envelopes;
  final Uuid _uuid;

  /// Records a transaction and moves the matching envelope by the same amount.
  ///
  /// Returns the new row id. [envelopeId] overrides the routing that the
  /// category would otherwise pick, which is how the user re-files an
  /// "Unaccounted" item with one tap.
  Future<String> record({
    required String accountId,
    required Money amount,
    required TxnDirection direction,
    required String categoryKey,
    required DateTime occurredAt,
    TxnSource source = TxnSource.manual,
    String? merchantRaw,
    String? note,
    double categoryConfidence = 0,
    bool userCorrected = false,
    String? envelopeId,
  }) async {
    final String id = 'txn_${_uuid.v4()}';
    final DateTime now = _clock.nowUtc();
    await _db.transaction(() async {
      await _db
          .into(_db.txns)
          .insert(
            TxnsCompanion.insert(
              id: id,
              accountId: accountId,
              amountCents: amount.abs(),
              direction: direction,
              categoryKey: categoryKey,
              merchantRaw: Value<String?>(merchantRaw),
              note: Value<String?>(note),
              occurredAt: occurredAt,
              source: source,
              categoryConfidence: Value<double>(categoryConfidence),
              userCorrected: Value<bool>(userCorrected),
              updatedAt: now,
            ),
          );
      await _applyToEnvelope(
        categoryKey: categoryKey,
        amount: amount.abs(),
        direction: direction,
        envelopeId: envelopeId,
      );
    });
    return id;
  }

  /// Moves the envelope that pays for [categoryKey].
  ///
  /// A transfer between the user's own accounts and a move into savings do not
  /// touch an envelope. BUILD_PLAN.md Section 8.4: a transfer is not a spend,
  /// and treating it as one would double the estimated burn rate.
  Future<void> _applyToEnvelope({
    required String categoryKey,
    required Money amount,
    required TxnDirection direction,
    String? envelopeId,
  }) async {
    if (envelopeId == null && nonSpendCategories.contains(categoryKey)) {
      return;
    }
    final String? target = envelopeId ?? await _resolveEnvelope(categoryKey);
    if (target == null) {
      return;
    }
    final Money delta = direction == TxnDirection.moneyOut ? -amount : amount;
    await _envelopes.adjustBalance(target, delta);
  }

  /// Finds the envelope for a category, falling back to the everyday spending
  /// envelope for anything unrouted.
  ///
  /// An unlabelled spend still came out of real money, so it must land
  /// somewhere. Dropping it would leave the envelope totals drifting away from
  /// the account totals and break the unallocated invariant.
  ///
  /// Public as [previewEnvelopeFor] so the UI can show which envelope a
  /// transaction will hit before the user commits to it, without duplicating
  /// this routing rule in two places.
  Future<String?> previewEnvelopeFor(String categoryKey) =>
      _resolveEnvelope(categoryKey);

  Future<String?> _resolveEnvelope(String categoryKey) async {
    final String? mapped = await _envelopes.envelopeForCategory(categoryKey);
    if (mapped != null) {
      return mapped;
    }
    return defaultSpendingEnvelopeId();
  }

  /// The envelope that catches anything not routed anywhere else.
  ///
  /// Prefers an explicit route for the "Unaccounted" category, then the first
  /// steady envelope, which is the everyday food and transport one.
  Future<String?> defaultSpendingEnvelopeId() async {
    final String? explicit = await _envelopes.envelopeForCategory(
      unaccountedCategoryKey,
    );
    if (explicit != null) {
      return explicit;
    }
    final List<EnvelopeRow> all = await _envelopes.activeEnvelopes();
    for (final EnvelopeRow envelope in all) {
      if (envelope.shape == EnvelopeShape.steady) {
        return envelope.id;
      }
    }
    return null;
  }

  /// Transactions for one account inside a window, as the reconciler needs
  /// them.
  Future<List<LoggedTxn>> loggedBetween({
    required String accountId,
    required DateTime from,
    required DateTime to,
  }) async {
    final List<TxnRow> rows =
        await (_db.select(_db.txns)
              ..where(($TxnsTable t) => t.accountId.equals(accountId))
              ..where(($TxnsTable t) => t.deletedAt.isNull())
              ..where(($TxnsTable t) => t.occurredAt.isBiggerOrEqualValue(from))
              ..where(($TxnsTable t) => t.occurredAt.isSmallerOrEqualValue(to)))
            .get();
    return rows
        .map(
          (TxnRow r) => LoggedTxn(
            amount: r.amountCents,
            direction: r.direction,
            occurredAt: r.occurredAt,
          ),
        )
        .toList(growable: false);
  }

  /// Every transaction in a date window, newest first.
  Future<List<TxnRow>> between(DateTime from, DateTime to) {
    return (_db.select(_db.txns)
          ..where(($TxnsTable t) => t.deletedAt.isNull())
          ..where(($TxnsTable t) => t.occurredAt.isBiggerOrEqualValue(from))
          ..where(($TxnsTable t) => t.occurredAt.isSmallerOrEqualValue(to))
          ..orderBy(<OrderClauseGenerator<$TxnsTable>>[
            ($TxnsTable t) => OrderingTerm.desc(t.occurredAt),
          ]))
        .get();
  }

  /// Items the reconciler derived that the user has not labelled yet.
  ///
  /// These sit at the top of the transaction list and are the app's main
  /// prompt for a correction.
  Future<List<TxnRow>> unaccounted() {
    return (_db.select(_db.txns)
          ..where(($TxnsTable t) => t.deletedAt.isNull())
          ..where(($TxnsTable t) => t.source.equalsValue(TxnSource.reconciled))
          ..where(($TxnsTable t) => t.userCorrected.equals(false))
          ..orderBy(<OrderClauseGenerator<$TxnsTable>>[
            ($TxnsTable t) => OrderingTerm.desc(t.occurredAt),
          ]))
        .get();
  }

  Stream<List<TxnRow>> watchUnaccounted() {
    return (_db.select(_db.txns)
          ..where(($TxnsTable t) => t.deletedAt.isNull())
          ..where(($TxnsTable t) => t.source.equalsValue(TxnSource.reconciled))
          ..where(($TxnsTable t) => t.userCorrected.equals(false))
          ..orderBy(<OrderClauseGenerator<$TxnsTable>>[
            ($TxnsTable t) => OrderingTerm.desc(t.occurredAt),
          ]))
        .watch();
  }

  Stream<List<TxnRow>> watchRecent({int limit = 100}) {
    return (_db.select(_db.txns)
          ..where(($TxnsTable t) => t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$TxnsTable>>[
            ($TxnsTable t) => OrderingTerm.desc(t.occurredAt),
          ])
          ..limit(limit))
        .watch();
  }

  /// Relabels a transaction and moves the money to the right envelope.
  ///
  /// BUILD_PLAN.md Section 9.2: every correction is stored with
  /// `user_corrected = 1`, and those rows are the categorizer training set.
  Future<void> relabel({
    required String txnId,
    required String categoryKey,
    String? envelopeId,
  }) async {
    final TxnRow row = await (_db.select(
      _db.txns,
    )..where(($TxnsTable t) => t.id.equals(txnId))).getSingle();
    if (row.categoryKey == categoryKey && envelopeId == null) {
      await _markCorrected(txnId);
      return;
    }

    await _db.transaction(() async {
      // Undo the old envelope move, then apply the new one. Doing it in one
      // transaction keeps the envelope total from ever going out of step.
      await _applyToEnvelope(
        categoryKey: row.categoryKey,
        amount: row.amountCents,
        direction: row.direction == TxnDirection.moneyOut
            ? TxnDirection.moneyIn
            : TxnDirection.moneyOut,
      );
      await _applyToEnvelope(
        categoryKey: categoryKey,
        amount: row.amountCents,
        direction: row.direction,
        envelopeId: envelopeId,
      );
      await (_db.update(
        _db.txns,
      )..where(($TxnsTable t) => t.id.equals(txnId))).write(
        TxnsCompanion(
          categoryKey: Value<String>(categoryKey),
          userCorrected: const Value<bool>(true),
          categoryConfidence: const Value<double>(1),
          updatedAt: Value<DateTime>(_clock.nowUtc()),
        ),
      );
    });
  }

  Future<void> _markCorrected(String txnId) async {
    await (_db.update(
      _db.txns,
    )..where(($TxnsTable t) => t.id.equals(txnId))).write(
      TxnsCompanion(
        userCorrected: const Value<bool>(true),
        categoryConfidence: const Value<double>(1),
        updatedAt: Value<DateTime>(_clock.nowUtc()),
      ),
    );
  }

  /// Splits one transaction into parts, used to break up a large
  /// "Unaccounted" item.
  ///
  /// The parts always sum to the original amount, so a split can never create
  /// or destroy money.
  Future<List<String>> split({
    required String txnId,
    required List<({Money amount, String categoryKey})> parts,
  }) async {
    if (parts.isEmpty) {
      throw ArgumentError.value(
        parts,
        'parts',
        'a split needs at least one part',
      );
    }
    final TxnRow row = await (_db.select(
      _db.txns,
    )..where(($TxnsTable t) => t.id.equals(txnId))).getSingle();
    final Money partsTotal = Money.sum(
      parts.map((({Money amount, String categoryKey}) p) => p.amount),
    );
    if (partsTotal != row.amountCents) {
      throw ArgumentError(
        'the parts must sum to the original amount, '
        'so that a split cannot create or destroy money',
      );
    }

    final List<String> ids = <String>[];
    await _db.transaction(() async {
      await _applyToEnvelope(
        categoryKey: row.categoryKey,
        amount: row.amountCents,
        direction: row.direction == TxnDirection.moneyOut
            ? TxnDirection.moneyIn
            : TxnDirection.moneyOut,
      );
      await (_db.update(
        _db.txns,
      )..where(($TxnsTable t) => t.id.equals(txnId))).write(
        TxnsCompanion(
          deletedAt: Value<DateTime>(_clock.nowUtc()),
          updatedAt: Value<DateTime>(_clock.nowUtc()),
        ),
      );
      for (final ({Money amount, String categoryKey}) part in parts) {
        ids.add(
          await record(
            accountId: row.accountId,
            amount: part.amount,
            direction: row.direction,
            categoryKey: part.categoryKey,
            occurredAt: row.occurredAt,
            source: row.source,
            merchantRaw: row.merchantRaw,
            userCorrected: true,
            categoryConfidence: 1,
          ),
        );
      }
    });
    return ids;
  }

  Future<void> softDelete(String txnId) async {
    final TxnRow row = await (_db.select(
      _db.txns,
    )..where(($TxnsTable t) => t.id.equals(txnId))).getSingle();
    await _db.transaction(() async {
      await _applyToEnvelope(
        categoryKey: row.categoryKey,
        amount: row.amountCents,
        direction: row.direction == TxnDirection.moneyOut
            ? TxnDirection.moneyIn
            : TxnDirection.moneyOut,
      );
      await (_db.update(
        _db.txns,
      )..where(($TxnsTable t) => t.id.equals(txnId))).write(
        TxnsCompanion(
          deletedAt: Value<DateTime>(_clock.nowUtc()),
          updatedAt: Value<DateTime>(_clock.nowUtc()),
        ),
      );
    });
  }

  Future<List<CategoryRow>> categories() {
    return (_db.select(_db.categories)
          ..orderBy(<OrderClauseGenerator<$CategoriesTable>>[
            ($CategoriesTable t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .get();
  }
}
