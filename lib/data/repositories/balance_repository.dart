import 'package:baon/core/clock.dart';
import 'package:baon/core/enums.dart';
import 'package:baon/core/money.dart';
import 'package:baon/data/db/database.dart';
import 'package:baon/data/db/seed.dart';
import 'package:baon/data/repositories/account_repository.dart';
import 'package:baon/data/repositories/txn_repository.dart';
import 'package:baon/engine/reconciler.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// What happened when the user saved one balance.
class SavedBalance {
  const SavedBalance({
    required this.accountId,
    required this.snapshotId,
    required this.result,
    required this.unaccountedTxnId,
    required this.envelopeId,
  });

  final String accountId;
  final String snapshotId;
  final ReconcileResult result;

  /// The "Unaccounted" row that was created, or null when the balance matched.
  final String? unaccountedTxnId;

  /// The envelope the unaccounted change landed in, or null when none did.
  final String? envelopeId;

  bool get createdUnaccounted => unaccountedTxnId != null;
}

/// Saves the balances the user types, and reconciles each one.
///
/// BUILD_PLAN.md Section 13, screen 3: this is the main daily action and must
/// stay under fifteen seconds, so saving several balances is one call.
class BalanceRepository {
  BalanceRepository(
    this._db,
    this._clock,
    this._accounts,
    this._txns, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final BaonDatabase _db;
  final Clock _clock;
  final AccountRepository _accounts;
  final TxnRepository _txns;
  final Uuid _uuid;

  /// Records one balance and books any change it cannot explain.
  ///
  /// BUILD_PLAN.md Section 8.1. The derived row is marked `reconciled` and
  /// carries the "Unaccounted" category until the user labels it.
  Future<SavedBalance> saveBalance({
    required String accountId,
    required Money balance,
    DateTime? capturedAt,
    String? note,
    SnapshotSource source = SnapshotSource.manual,
  }) async {
    final DateTime when = capturedAt ?? _clock.nowUtc();
    final BalanceSnapshotRow? previousRow = await _accounts.latestSnapshot(
      accountId,
    );

    final SnapshotPoint? previous = previousRow == null
        ? null
        : SnapshotPoint(
            balance: previousRow.balanceCents,
            capturedAt: previousRow.capturedAt,
          );

    final List<LoggedTxn> logged = previous == null
        ? const <LoggedTxn>[]
        : await _txns.loggedBetween(
            accountId: accountId,
            from: previous.capturedAt,
            to: when,
          );

    final ReconcileResult result = reconcile(
      accountId: accountId,
      previous: previous,
      current: SnapshotPoint(balance: balance, capturedAt: when),
      logged: logged,
    );

    final String snapshotId = 'snap_${_uuid.v4()}';
    String? txnId;
    String? envelopeId;

    await _db.transaction(() async {
      await _db
          .into(_db.balanceSnapshots)
          .insert(
            BalanceSnapshotsCompanion.insert(
              id: snapshotId,
              accountId: accountId,
              balanceCents: balance,
              source: source,
              capturedAt: when,
              note: Value<String?>(note),
            ),
          );

      final ReconciledDelta? derived = result.derived;
      if (derived != null) {
        envelopeId = await _txns.defaultSpendingEnvelopeId();
        txnId = await _txns.record(
          accountId: accountId,
          amount: derived.amount,
          direction: derived.direction,
          categoryKey: unaccountedCategoryKey,
          occurredAt: derived.occurredAt,
          source: TxnSource.reconciled,
          envelopeId: envelopeId,
        );
      }
    });

    return SavedBalance(
      accountId: accountId,
      snapshotId: snapshotId,
      result: result,
      unaccountedTxnId: txnId,
      envelopeId: envelopeId,
    );
  }

  /// Saves several balances in one pass, which is how the daily update screen
  /// submits.
  Future<List<SavedBalance>> saveMany(
    Map<String, Money> balancesByAccountId, {
    DateTime? capturedAt,
  }) async {
    final DateTime when = capturedAt ?? _clock.nowUtc();
    final List<SavedBalance> out = <SavedBalance>[];
    for (final MapEntry<String, Money> entry in balancesByAccountId.entries) {
      out.add(
        await saveBalance(
          accountId: entry.key,
          balance: entry.value,
          capturedAt: when,
        ),
      );
    }
    return out;
  }

  /// Every snapshot for an account, oldest first. Used by the forecast to
  /// measure how much history exists.
  Future<List<BalanceSnapshotRow>> history(String accountId) {
    return (_db.select(_db.balanceSnapshots)
          ..where(($BalanceSnapshotsTable t) => t.accountId.equals(accountId))
          ..orderBy(<OrderClauseGenerator<$BalanceSnapshotsTable>>[
            ($BalanceSnapshotsTable t) => OrderingTerm.asc(t.capturedAt),
          ]))
        .get();
  }

  /// The oldest snapshot across all accounts, or null when there are none.
  ///
  /// BUILD_PLAN.md Section 8.8 sets `data_quality` to low under seven days of
  /// history, and this is how that age is measured.
  Future<DateTime?> earliestSnapshotAt() async {
    final BalanceSnapshotRow? row =
        await (_db.select(_db.balanceSnapshots)
              ..orderBy(<OrderClauseGenerator<$BalanceSnapshotsTable>>[
                ($BalanceSnapshotsTable t) => OrderingTerm.asc(t.capturedAt),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row?.capturedAt;
  }

  /// Accounts whose latest balance is older than 72 hours.
  Future<List<AccountWithBalance>> staleAccounts() async {
    final List<AccountWithBalance> all = await _accounts.accountsWithBalances();
    final DateTime now = _clock.nowUtc();
    return all.where((AccountWithBalance a) => a.isStaleAt(now)).toList();
  }
}
